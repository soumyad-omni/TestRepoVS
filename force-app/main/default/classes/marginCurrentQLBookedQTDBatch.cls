global class marginCurrentQLBookedQTDBatch implements Database.Batchable<sObject> 
{
     global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String rec1 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'NAA_Opportunity' limit 1].id;//IBA-5024
        String rec2 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'US_Canada_Advanced_Services' limit 1].id;//IBA-5024
        String rec3 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'US_Canada_Specialty' limit 1].id;//IBA-5024

        String query='SELECT id, quote__c,quote__r.opportunityId,quote__r.opportunity.Pipeline_Category__c, Material_Type__c, Line_Status__c, product__c, quote__r.Status,';
        query = query + 'quote__r.Order_Type__c, SAP_Line_Number__c, product__r.Portfolio_Segment__c, SAP_Line_Item_GUID__c, quote__r.opportunity.OpportunityGroup__c,';
        query = query + 'quote__r.opportunity.opportunity__c,Quantity__c, Margin_Percentage__c, Labor_Cost__c, Overhead_Cost__c, Product_Cost__c, Line_Expected_Booking__c, Requested_Delivery_Date__c, product__r.SAP_Product_Type__c';
        query = query + ' FROM Quote_Line__c WHERE Material_Type__c IN (\'PRODUCT\',\'SERVICE\') AND quote__r.Primary_Quote__c = true AND product__r.ProductCode <> \'FREIGHT\' AND Line_Status__c <> \'E0006\' AND Product_Code__c != \'LEASE BUYOUT\'';
        query = query + ' AND quote__r.opportunity.Pipeline_Category__c in (\'Booked\') and quote__r.opportunity.OppStatus__c IN (\'Fully Booked\',\'Non Comissionable Booking\',\'Commissionable - No Service PO\',\'Non Comm. Book - No Service PO\',\'Non Comm. Book - No Proj. Plan\') and (quote__r.opportunity.RecordTypeId  =:rec1 OR quote__r.opportunity.RecordTypeId  =:rec2 OR quote__r.opportunity.RecordTypeId  =:rec3) and Quote__r.Opportunity.CloseDate >2018-12-31 AND Quote__r.Account.Territory_Assignment_Criteria__c!=\'Omnicell Account\' '; //IBA-5024
        query = query + ' AND (quote__r.Order_Type__c = \'ZQRS\' OR Material_Type__c = \'PRODUCT\')';
        query = query + ' AND Quote__r.Opportunity.CloseDate >= THIS_FISCAL_QUARTER';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quote_Line__c> lstFC){
        Map<String,String> segmentMap =  new Map<String, String>();
        
        for(Portfolio_Segment_and_Simplified_Segment__mdt segment : [SELECT label, Simplified_Segment__c FROM Portfolio_Segment_and_Simplified_Segment__mdt])
        {
            segmentMap.put(segment.label,segment.Simplified_Segment__c);
        }
        Set<id> oppIds = new Set<id>();
        Map<String,Quote_Line__c> oppRelatedQL = new Map<String,Quote_Line__c>();
        Map<String,Set<String>> oppAndQuoteLineMap = new Map<String,Set<String>>();
        List<Current_Quote_Line_Result__c> insertCBR = new List<Current_Quote_Line_Result__c>();
        for(Quote_Line__c ql : lstFC)
        {
            Current_Quote_Line_Result__c cbr = new Current_Quote_Line_Result__c();
            
            cbr.Margin__c = ql.Margin_Percentage__c == NULL ? 0 : ql.Margin_Percentage__c;
            cbr.expected_booking__c = ql.Line_Expected_Booking__c == NULL ? 0 : ql.Line_Expected_Booking__c;
            cbr.Labor_Cost__c = ql.Labor_Cost__c == NULL ? 0 : ql.Labor_Cost__c;
            cbr.Overhead_Cost__c = ql.Overhead_Cost__c == NULL ? 0 : ql.Overhead_Cost__c;
            cbr.Cost__c = ql.Product_Cost__c == NULL ? 0 : ql.Product_Cost__c;
            cbr.Quantity__c = ql.Quantity__c == NULL ? 0 : ql.Quantity__c;
            
            if(ql.quote__r.opportunity.opportunity__c == 'Change Order - Credit' || test.isRunningTest()){
                cbr.Labor_Cost__c = cbr.Labor_Cost__c * -1;
                cbr.Overhead_Cost__c = cbr.Overhead_Cost__c * -1;
                cbr.Cost__c = cbr.Cost__c * -1;
                cbr.Quantity__c = cbr.Quantity__c * -1;
            }
            
            cbr.Opportunity__c = ql.quote__r.opportunityId;
            cbr.Quote__c = ql.quote__c;
            cbr.Opportunity_Forecast_Category__c = 'Booked QTD';
            cbr.Quote_Line__c = ql.Id;
            cbr.Product__c = ql.product__c;
            cbr.Requested_land_date_RLD__c = ql.Requested_Delivery_Date__c;
            cbr.Simplified_Segment__c = segmentMap.containskey(ql.product__r.Portfolio_Segment__c) ? segmentMap.get(ql.product__r.Portfolio_Segment__c) : '';
            cbr.Opportunity_Forecast_Category_Order__c = '6-Booked QTD';
            cbr.Valid_From__c = Date.today();
            cbr.Valid_To__c = Date.newInstance(2999, 12, 31);
            String derivedPortSegment = '';
            
            if(ql.quote__r.Status == 'E0024' || ql.quote__r.opportunity.OpportunityGroup__c == 'Advanced Services' || ql.quote__r.opportunity.Opportunity__c=='Adv Svc Renewal' 
	       || ql.quote__r.Order_Type__c == 'ZQRS' || ql.product__r.Portfolio_Segment__c == 'Services' 
	       || ql.product__r.Portfolio_Segment__c == 'Central Pharmacy Dispensing Service'   //IBA-4331
               || ql.product__r.Portfolio_Segment__c == 'IV Compounding Service' || ql.product__r.Portfolio_Segment__c == 'IV Legacy'
               || ql.product__r.Portfolio_Segment__c == 'IVX Workflow')//IBA-5787 updated if condition with ql.quote__r.opportunity.Opportunity__c=='Adv Svc Renewal' Saptarsha Panthi
            {
                derivedPortSegment = 'Advanced Services';
            }
            else if(ql.product__r.SAP_Product_Type__c == 'Subscription')
            {
                derivedPortSegment = 'Subscriptions';
            }
            else if(ql.product__r.Portfolio_Segment__c == 'MA Consumable' || ql.product__r.Portfolio_Segment__c == 'Core Machine' 
                    || ql.product__r.Portfolio_Segment__c == 'MA Raw/MA tooling' || ql.product__r.Portfolio_Segment__c == 'MultiMed Automation'
                    || ql.product__r.Portfolio_Segment__c == 'Packagers' || ql.product__r.Portfolio_Segment__c == 'SingleDose Automation')
            {
                derivedPortSegment = 'Consumables / Core Machines';
            }
            else if(ql.product__r.Portfolio_Segment__c == 'Cloud Hosted OmniCenter' || ql.product__r.Portfolio_Segment__c == 'Infrastructure' 
                    || ql.product__r.Portfolio_Segment__c == 'Inventory Optimization Service and Platform')  //IBA-4331
            {
                derivedPortSegment = 'Infrastructure / Shared';
            }
            else if(ql.product__r.Portfolio_Segment__c == 'Carousels' || ql.product__r.Portfolio_Segment__c == 'Central Pharmacy' 
                    || ql.product__r.Portfolio_Segment__c == 'Central Pharmacy Legacy')
            {
                derivedPortSegment = 'Central Pharmacy';
            }
            else if(ql.product__r.Portfolio_Segment__c == 'Anesthesia Workstation' || ql.product__r.Portfolio_Segment__c == 'Automated Dispensing Cabinets' 
                    || ql.product__r.Portfolio_Segment__c == 'Supply')
            {
                derivedPortSegment = 'Automated Dispensing Cabinets';
            }else{
                derivedPortSegment = 'Others';
            }
            
            cbr.Derived_Portfolio_Segment__c = derivedPortSegment;
            
            insertCBR.add(cbr);
        }
        
        if(!insertCBR.isEmpty()){
            insert insertCBR;
        }
    }
    /*
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT id, Quote__c, Quote_Line__c,Margin__c, expected_booking__c, Labor_Cost__c,';
        query = query + ' Overhead_Cost__c, Cost__c , Opportunity__c, SAP_Line_Number__c, Opportunity_Forecast_Category__c,';
        query = query + ' Opportunity__r.closedate, Simplified_Segment__c, Requested_land_date_RLD__c,';
        query = query + ' Product__c, Quantity__c';
        query = query + ' FROM Current_Quote_Line_Result__c';
        //query = query + ' WHERE ID = \'aEK230000005bV6GAI\'';
        query = query + ' WHERE Opportunity_Forecast_Category_Order__c = \'4-Booked\'';
        query = query + ' AND Opportunity__r.closedate >= THIS_FISCAL_QUARTER';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Current_Quote_Line_Result__c> obrList) 
    {
        List<Current_Quote_Line_Result__c> insertOBRBookingQTD = new List<Current_Quote_Line_Result__c>();
        
        for(Current_Quote_Line_Result__c obr : obrList)
        {
            Current_Quote_Line_Result__c newOBR = obr.clone(); 
            newOBR.Opportunity_Forecast_Category_Order__c = '6-Booked QTD';
            newOBR.Opportunity_Forecast_Category__c = 'Booked QTD';
            
            insertOBRBookingQTD.add(newOBR);
        }
        
        if(!insertOBRBookingQTD.isEmpty())
            insert insertOBRBookingQTD;
    }
    */
    global void finish(Database.BatchableContext BC) {
        database.executeBatch(new marginDeleteQLAverageBatch(), 5000);
    }
}