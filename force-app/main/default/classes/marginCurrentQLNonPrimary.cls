//Test Class: marginCurrentQLBatchTest
global class marginCurrentQLNonPrimary implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Integer currentMonth = system.today().month();
        Date startDate = system.today();
        Date endDate = system.today();
        
        if(currentMonth == 1 || currentMonth == 2 || currentMonth == 3)
        {
            startDate = date.newInstance(system.today().year()-1, 1, 1);
            endDate = date.newInstance(system.today().year(), 1, 1);
        }
        else if(currentMonth == 4 || currentMonth == 5 || currentMonth == 6)
        {
            startDate = date.newInstance(system.today().year()-1, 4, 1);
            endDate = date.newInstance(system.today().year(), 4, 1);
        }
        else if(currentMonth == 7 || currentMonth == 8 || currentMonth == 9)
        {
            startDate = date.newInstance(system.today().year()-1, 7, 1);
            endDate = date.newInstance(system.today().year(), 7, 1);
        }
        else if(currentMonth == 10 || currentMonth == 11 || currentMonth == 12)
        {
            startDate = date.newInstance(system.today().year()-1, 10, 1);
            endDate = date.newInstance(system.today().year(), 10, 1);
        }
        system.debug('startDate-->'+startDate);
        system.debug('endDate-->'+endDate);
        
        String query='SELECT id, quote__c,quote__r.opportunityId,quote__r.opportunity.Pipeline_Category__c, Material_Type__c, Line_Status__c, product__c, quote__r.Status, quote__r.opportunity.OppStatus__c,quote__r.opportunity.opportunity__c, ';
        query = query + 'quote__r.Order_Type__c, SAP_Line_Number__c, product__r.SAP_Product_Type__c, product__r.Portfolio_Segment__c, SAP_Line_Item_GUID__c,quote__r.opportunity.OpportunityGroup__c,';
        query = query + 'Quantity__c, Margin_Percentage__c, Labor_Cost__c, Overhead_Cost__c, Product_Cost__c, Line_Expected_Booking__c, Requested_Delivery_Date__c';
        query = query + ' FROM Quote_Line__c';

        String rec1 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'NAA_Opportunity' limit 1].id;//IBA-5024
        String rec2 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'US_Canada_Advanced_Services' limit 1].id;//IBA-5024
        String rec3 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'US_Canada_Specialty' limit 1].id;//IBA-5024
        
        if(!test.isRunningTest())
        {
            query = query + '  WHERE Material_Type__c IN (\'PRODUCT\',\'SERVICE\') AND quote__r.Primary_Quote__c = false AND product__r.ProductCode <> \'FREIGHT\' AND Line_Status__c <> \'E0006\' AND Product_Code__c != \'LEASE BUYOUT\'';
            query = query + ' AND (((quote__r.opportunity.Pipeline_Category__c in (\'Development\',\'Upside\',\'Committed\') OR (quote__r.opportunity.Pipeline_Category__c in (\'Booked\') AND quote__r.opportunity.OppStatus__c in (\'Open\',\'PO Received - Pending Paperwork\',\'PO Received\')))  and Quote__r.Opportunity.CloseDate >2018-12-31) ';
            query = query + ' OR (quote__r.opportunity.Pipeline_Category__c in (\'Booked\') and quote__r.opportunity.OppStatus__c IN (\'Fully Booked\',\'Non Comissionable Booking\',\'Commissionable - No Service PO\',\'Non Comm. Book - No Service PO\',\'Booked with No PO\',\'Booked with No Service PO\',\'Booked with No Product PO\') and Quote__r.Opportunity.CloseDate >= :startDate AND Quote__r.Opportunity.CloseDate < :endDate))'; //IBA-4182
            query = query + ' AND (quote__r.opportunity.RecordTypeId  =:rec1 OR quote__r.opportunity.RecordTypeId  =:rec2 OR quote__r.opportunity.RecordTypeId  =:rec3)';
            query = query + ' AND Quote__r.Account.Territory_Assignment_Criteria__c!=\'Omnicell Account\'';
            query = query + ' AND (quote__r.Order_Type__c = \'ZQRS\' OR Material_Type__c = \'PRODUCT\')';
        }
        //query = query + ' WHERE quote__c = \'0Q03l000001xaU9\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote_Line__c> lstFC)
    {
        Set<id> oppIdList = new Set<id>();
        Map<String,Quote_Line__c> oppRelatedQL = new Map<String,Quote_Line__c>();
        Map<String,Set<String>> oppAndQuoteLineMap = new Map<String,Set<String>>();
        List<Current_Quote_Line_Result__c> insertCBR = new List<Current_Quote_Line_Result__c>();
        
        for(Quote_Line__c ql : lstFC)
        {
            oppIdList.add(ql.quote__r.opportunityId);
        }
        
        Map<Id, Opportunity> oppList = new Map<Id, Opportunity>([SELECT id, (SELECT id, Primary_Quote__c FROM Quotes) 
                                                                 FROM opportunity 
                                                                 WHERE id IN :oppIdList]);
        
        for(Quote_Line__c ql : lstFC)
        {
            Boolean continueToInsert = false;
            
            if(oppList.containsKey(ql.Quote__r.opportunityId))
            {
                Opportunity opp = oppList.get(ql.Quote__r.opportunityId);
                
                if(opp.quotes.size() == 1 && !opp.quotes[0].Primary_Quote__c && opp.quotes[0].id == ql.Quote__c)
                    continueToInsert = true;
            }
            
            if(continueToInsert)
            {
                Current_Quote_Line_Result__c cbr = new Current_Quote_Line_Result__c();
                
                cbr.Valid_From__c = Date.today();
                cbr.Valid_To__c = Date.newInstance(2999, 12, 31);
                cbr.Margin__c = ql.Margin_Percentage__c == NULL ? 0 : ql.Margin_Percentage__c;
                cbr.expected_booking__c = ql.Line_Expected_Booking__c == NULL ? 0 : ql.Line_Expected_Booking__c;
                cbr.Labor_Cost__c = ql.Labor_Cost__c == NULL ? 0 : ql.Labor_Cost__c;
                cbr.Overhead_Cost__c = ql.Overhead_Cost__c == NULL ? 0 : ql.Overhead_Cost__c;
                cbr.Cost__c = ql.Product_Cost__c == NULL ? 0 : ql.Product_Cost__c;
                cbr.Quantity__c = ql.Quantity__c == NULL ? 0 : ql.Quantity__c;
                if(ql.quote__r.opportunity.opportunity__c == 'Change Order - Credit'){
                    cbr.Labor_Cost__c = cbr.Labor_Cost__c * -1;
                    cbr.Overhead_Cost__c = cbr.Overhead_Cost__c * -1;
                    cbr.Cost__c = cbr.Cost__c * -1;
                    cbr.Quantity__c = cbr.Quantity__c * -1;
                }
                
                cbr.Opportunity__c = ql.quote__r.opportunityId;
                cbr.Quote__c = ql.quote__c;
                cbr.Opportunity_Forecast_Category__c = ql.quote__r.opportunity.Pipeline_Category__c ;
                String pipeLineCategory = ql.quote__r.opportunity.Pipeline_Category__c;
                
                cbr.Quote_Line__c = ql.Id;
                cbr.Product__c = ql.product__c;
                cbr.Requested_land_date_RLD__c = ql.Requested_Delivery_Date__c;
                
                if(pipeLineCategory == 'Development')
                    cbr.Opportunity_Forecast_Category_Order__c = '1-Development';
                else if(pipeLineCategory == 'Upside')
                    cbr.Opportunity_Forecast_Category_Order__c = '2-Upside';
                else if(pipeLineCategory == 'Committed' || (pipeLineCategory == 'Booked' &&
                                                            (ql.quote__r.opportunity.OppStatus__c == 'Open' || ql.quote__r.opportunity.OppStatus__c == 'PO Received - Pending Paperwork' 
                                                             || ql.quote__r.opportunity.OppStatus__c == 'PO Received'))
                       )
                    cbr.Opportunity_Forecast_Category_Order__c = '3-Committed';
                else if(pipeLineCategory == 'Booked' && 
                        (ql.quote__r.opportunity.OppStatus__c == 'Fully Booked' || ql.quote__r.opportunity.OppStatus__c == 'Non Comissionable Booking' 
                         || ql.quote__r.opportunity.OppStatus__c == 'Commissionable - No Service PO' || ql.quote__r.opportunity.OppStatus__c == 'Non Comm. Book - No Service PO' 
                         // IBA-4182 starts || ql.quote__r.opportunity.OppStatus__c == 'Non Comm. Book - No Proj. Plan'
                         || ql.quote__r.opportunity.OppStatus__c=='Booked with No PO' || ql.quote__r.opportunity.OppStatus__c== 'Booked with No Service PO'|| ql.quote__r.opportunity.OppStatus__c == 'Booked with No Product PO' // IBA-4182 ends
                       ))
                            cbr.Opportunity_Forecast_Category_Order__c = '4-Booked (Last 4 QTR)';
                
                String derivedPortSegment = '';
                
                if(ql.quote__r.Status == 'E0024' || ql.quote__r.opportunity.OpportunityGroup__c == 'Advanced Services' 
                   || ql.quote__r.opportunity.Opportunity__c=='Adv Svc Renewal' || ql.quote__r.Order_Type__c == 'ZQRS'
                   || ql.product__r.Portfolio_Segment__c == 'Services' || ql.product__r.Portfolio_Segment__c == 'Central Pharmacy Dispensing Service'   //IBA-4331
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
                }
                else{
                    derivedPortSegment = 'Others';
                }
                
                cbr.Derived_Portfolio_Segment__c = derivedPortSegment;
                
                insertCBR.add(cbr);
            }
        }
        if(!insertCBR.isEmpty()){
            insert insertCBR;
        }
            
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        database.executebatch(new marginCurrentQLBookedQTDBatch(),200);
    }
}