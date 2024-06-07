//Test Class: marginCurrentQLBatchTest
global class marginCurrentQLBatch implements Database.Batchable<sObject>
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
        
        String rec1 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'NAA_Opportunity' limit 1].id;//IBA-5024
        String rec2 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'US_Canada_Advanced_Services' limit 1].id;//IBA-5024
        String rec3 = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'US_Canada_Specialty' limit 1].id;//IBA-5024

        String query='SELECT id, quote__c,quote__r.opportunityId,quote__r.opportunity.Pipeline_Category__c, Material_Type__c, Line_Status__c, product__c, quote__r.Status, quote__r.opportunity.OppStatus__c,quote__r.opportunity.opportunity__c, ';
        query = query + 'quote__r.Order_Type__c, SAP_Line_Number__c, product__r.SAP_Product_Type__c, product__r.Portfolio_Segment__c, SAP_Line_Item_GUID__c,quote__r.opportunity.OpportunityGroup__c,';
        query = query + 'Quantity__c, Margin_Percentage__c, Labor_Cost__c, Overhead_Cost__c, Product_Cost__c, Line_Expected_Booking__c, Requested_Delivery_Date__c';
        query = query + ' FROM Quote_Line__c WHERE Material_Type__c IN (\'PRODUCT\',\'SERVICE\') AND quote__r.Primary_Quote__c = true AND product__r.ProductCode <> \'FREIGHT\' AND Line_Status__c <> \'E0006\' AND Product_Code__c != \'LEASE BUYOUT\'';
        query = query + ' AND (((quote__r.opportunity.Pipeline_Category__c in (\'Development\',\'Upside\',\'Committed\') OR (quote__r.opportunity.Pipeline_Category__c in (\'Booked\') AND quote__r.opportunity.OppStatus__c in (\'Open\',\'PO Received - Pending Paperwork\',\'PO Received\')))  and Quote__r.Opportunity.CloseDate >2018-12-31) ';
        query = query + ' OR (quote__r.opportunity.Pipeline_Category__c in (\'Booked\') and quote__r.opportunity.OppStatus__c IN (\'Fully Booked\',\'Non Comissionable Booking\',\'Commissionable - No Service PO\',\'Non Comm. Book - No Service PO\',\'Booked with No PO\',\'Booked with No Service PO\',\'Booked with No Product PO\') and Quote__r.Opportunity.CloseDate >= :startDate AND Quote__r.Opportunity.CloseDate < :endDate))'; //IBA-4182
        query = query + ' AND (quote__r.opportunity.RecordTypeId  =:rec1 OR quote__r.opportunity.RecordTypeId  =:rec2 OR quote__r.opportunity.RecordTypeId  =:rec3)';//IBA-5024
        //query = query + ' AND Quote__r.AccountId  != \'0011N00001pYpTbQAK\'';
        query = query + ' AND Quote__r.Account.Territory_Assignment_Criteria__c!=\'Omnicell Account\'';
        query = query + ' AND (quote__r.Order_Type__c = \'ZQRS\' OR Material_Type__c = \'PRODUCT\')';
        //query = query + ' AND quote__c = \'0Q03l000002ZXYqCAO\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quote_Line__c> lstFC)
    {
        
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
            cbr.Simplified_Segment__c = segmentMap.containskey(ql.product__r.Portfolio_Segment__c) ? segmentMap.get(ql.product__r.Portfolio_Segment__c) : '';
            
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
                     || ql.quote__r.opportunity.OppStatus__c=='	Booked with No PO' || ql.quote__r.opportunity.OppStatus__c== 'Booked with No Service PO'|| ql.quote__r.opportunity.OppStatus__c == 'Booked with No Product PO')) // IBA-4182 ends
                cbr.Opportunity_Forecast_Category_Order__c = '4-Booked (Last 4 QTR)';
            
            String derivedPortSegment = '';
            
            if(ql.quote__r.Status == 'E0024' || ql.quote__r.opportunity.OpportunityGroup__c == 'Advanced Services'
              || ql.quote__r.opportunity.Opportunity__c == 'Adv Svc Renewal' || ql.quote__r.Order_Type__c == 'ZQRS'
              || ql.product__r.Portfolio_Segment__c == 'Services' || ql.product__r.Portfolio_Segment__c == 'Central Pharmacy Dispensing Service'  //IBA-4331
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
        
        if(!insertCBR.isEmpty()){
            insert insertCBR;
        }
    }
    /*global void execute(Database.BatchableContext BC, List<Quote_Line__c> lstFC){
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
            if(ql.quote__r.Order_Type__c == 'ZQRS')
                oppRelatedQL.put(ql.SAP_Line_Item_GUID__c, ql);
            else
            {
                if(ql.Material_Type__c == 'PRODUCT')
                    oppRelatedQL.put(ql.SAP_Line_Item_GUID__c, ql);
            }
            
           
        }
        for(Quote_Line__c quoteLine: lstFC)
        {
            String lineNumber = quoteLine.SAP_Line_Item_GUID__c;
            if(oppRelatedQL.get(lineNumber) != null){
                Current_Quote_Line_Result__c cbr = new Current_Quote_Line_Result__c();
                cbr.Margin__c = oppRelatedQL.get(lineNumber).Margin_Percentage__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Margin_Percentage__c;
                cbr.expected_booking__c = oppRelatedQL.get(lineNumber).Line_Expected_Booking__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Line_Expected_Booking__c;
                cbr.Labor_Cost__c = oppRelatedQL.get(lineNumber).Labor_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Labor_Cost__c;
                cbr.Overhead_Cost__c = oppRelatedQL.get(lineNumber).Overhead_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Overhead_Cost__c;
                cbr.Cost__c = oppRelatedQL.get(lineNumber).Product_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Product_Cost__c;
                cbr.Quantity__c = oppRelatedQL.get(lineNumber).Quantity__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Quantity__c;
                
                cbr.Opportunity__c = oppRelatedQL.get(lineNumber).quote__r.opportunityId;
                cbr.Quote__c = oppRelatedQL.get(lineNumber).quote__c;
                cbr.Opportunity_Forecast_Category__c = oppRelatedQL.get(lineNumber).quote__r.opportunity.Pipeline_Category__c ;
                String pipeLineCategory = oppRelatedQL.get(lineNumber).quote__r.opportunity.Pipeline_Category__c;
                //cbr.Changed_Date__c = fc.Opportunity_Change_Datetime__c;
                //cbr.Change_Date_Convert__c = marginDevelopmentSchedulableBatch.changeFormat(cbr.Changed_Date__c);
                
                cbr.Quote_Line__c = oppRelatedQL.get(lineNumber).Id;
                cbr.Product__c = oppRelatedQL.get(lineNumber).product__c;
                cbr.Requested_land_date_RLD__c = oppRelatedQL.get(lineNumber).Requested_Delivery_Date__c;
                cbr.Simplified_Segment__c = segmentMap.containskey(oppRelatedQL.get(lineNumber).product__r.Portfolio_Segment__c) ? segmentMap.get(oppRelatedQL.get(lineNumber).product__r.Portfolio_Segment__c) : '';
                if(pipeLineCategory == 'Development')
                    cbr.Opportunity_Forecast_Category_Order__c = '1-Development';
                else if(pipeLineCategory == 'Upside')
                    cbr.Opportunity_Forecast_Category_Order__c = '2-Upside';
                else if(pipeLineCategory == 'Committed')
                    cbr.Opportunity_Forecast_Category_Order__c = '3-Committed';
                else if(pipeLineCategory == 'Booked')
                    cbr.Opportunity_Forecast_Category_Order__c = '4-Booked';
                insertCBR.add(cbr);
            }
        }
        if(!insertCBR.isEmpty()){
            insert insertCBR;
        }
    }
*/
    /*global void execute(Database.BatchableContext BC, List<Forecast_Dimension__c> lstFC) 
{
Map<String,String> segmentMap =  new Map<String, String>();

for(Portfolio_Segment_and_Simplified_Segment__mdt segment : [SELECT label, Simplified_Segment__c FROM Portfolio_Segment_and_Simplified_Segment__mdt])
{
segmentMap.put(segment.label,segment.Simplified_Segment__c);
}

Map<String,Forecast_Dimension__c> oppCategoryDataMap = new Map<String,Forecast_Dimension__c>();
List<Current_Quote_Line_Result__c> insertCBR = new List<Current_Quote_Line_Result__c>();
Set<id> oppIds = new Set<id>();
Map<id, String> oppIdsToProcess = new Map<id, String>();

for( Forecast_Dimension__c fc :lstFC){
oppIds.add(fc.Opportunity_ID__c);
}
Datetime dt = datetime.newInstance(2019,7,1,0,0,0);
List<Forecast_Dimension__c> forcastDataForOpps = [Select Is_Processed__c,Primary_Quote_ID__c,Opportunity_Change_Datetime__c,Opportunity_Created_Date__c, 
Opportunity_ID__c,Opportunity_Forecast_Category__c,Is_Manually_Added__c,Primary_Quote_SAP_Number__c, 
Opportunity_ID__r.closeDate, Opportunity_ID__r.Pipeline_Category__c  
from Forecast_Dimension__c 
WHERE ((Opportunity_Forecast_Category__c IN ('Development') and Is_Manually_Added__c = True)
OR Opportunity_Forecast_Category__c IN ('Upside','Committed','Booked')) 
and Is_Processed__c = false 
and Opportunity_ID__r.Pipeline_Category__c != 'Lost' 
and Opportunity_ID__c in:oppIds 
order by Opportunity_ID__c,Opportunity_Change_Datetime__c ASC];

for(Forecast_Dimension__c fc : forcastDataForOpps)
{
oppCategoryDataMap.put(fc.Opportunity_ID__c+fc.Opportunity_Forecast_Category__c,fc);
oppIdsToProcess.put(fc.Opportunity_ID__c, fc.Opportunity_Forecast_Category__c);
}

Map<String,Quote_Line__c> oppRelatedQL = new Map<String,Quote_Line__c>();
Map<String,Set<String>> oppAndQuoteLineMap = new Map<String,Set<String>>();

for(Quote_Line__c ql : [SELECT id, quote__r.opportunityId, Material_Type__c, Line_Status__c, product__c,
quote__r.Order_Type__c, SAP_Line_Number__c, product__r.Portfolio_Segment__c, SAP_Line_Item_GUID__c,
Quantity__c, Margin_Percentage__c, Labor_Cost__c, Overhead_Cost__c, Product_Cost__c, Line_Expected_Booking__c, Requested_Delivery_Date__c
FROM Quote_Line__c
WHERE Material_Type__c IN ('PRODUCT','SERVICE')
AND quote__r.Primary_Quote__c = true
AND quote__r.opportunityId IN :oppIds
AND product__r.ProductCode <> 'FREIGHT'
AND Line_Status__c <> 'E0006'])
{
if(ql.quote__r.Order_Type__c == 'ZQRS')
oppRelatedQL.put(ql.SAP_Line_Item_GUID__c, ql);
else
{
if(ql.Material_Type__c == 'PRODUCT')
oppRelatedQL.put(ql.SAP_Line_Item_GUID__c, ql);
}

if(oppAndQuoteLineMap.get(ql.quote__r.opportunityId) != null)
{
Set<String> qllineNumber = oppAndQuoteLineMap.get(ql.quote__r.opportunityId);
qllineNumber.add(ql.SAP_Line_Item_GUID__c);
oppAndQuoteLineMap.put(ql.quote__r.opportunityId, qllineNumber);
}
else
{
Set<String> qllineNumber = new Set<String>();
qllineNumber.add(ql.SAP_Line_Item_GUID__c);
oppAndQuoteLineMap.put(ql.quote__r.opportunityId, qllineNumber);   
}
}

for(id oppId: oppIdsToProcess.keyset())
{
if(oppAndQuoteLineMap.containsKey(oppId))
{
for(String lineNumber : oppAndQuoteLineMap.get(oppId))
{
if(oppCategoryDataMap.containsKey(oppId+oppIdsToProcess.get(oppId)))
{
Forecast_Dimension__c fc = oppCategoryDataMap.get(oppId+oppIdsToProcess.get(oppId));
if(!fc.Is_Processed__c && oppRelatedQL.containsKey(lineNumber))
{
Current_Quote_Line_Result__c cbr = new Current_Quote_Line_Result__c();

cbr.Margin__c = oppRelatedQL.get(lineNumber).Margin_Percentage__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Margin_Percentage__c;
cbr.expected_booking__c = oppRelatedQL.get(lineNumber).Line_Expected_Booking__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Line_Expected_Booking__c;
cbr.Labor_Cost__c = oppRelatedQL.get(lineNumber).Labor_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Labor_Cost__c;
cbr.Overhead_Cost__c = oppRelatedQL.get(lineNumber).Overhead_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Overhead_Cost__c;
cbr.Cost__c = oppRelatedQL.get(lineNumber).Product_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Product_Cost__c;
cbr.Quantity__c = oppRelatedQL.get(lineNumber).Quantity__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Quantity__c;

cbr.Opportunity__c = fc.Opportunity_ID__c;
cbr.Quote__c = fc.Primary_Quote_ID__c;
cbr.Opportunity_Forecast_Category__c = fc.Opportunity_Forecast_Category__c;
cbr.Changed_Date__c = fc.Opportunity_Change_Datetime__c;
cbr.Change_Date_Convert__c = marginDevelopmentSchedulableBatch.changeFormat(cbr.Changed_Date__c);

cbr.Quote_Line__c = oppRelatedQL.get(lineNumber).Id;
cbr.Product__c = oppRelatedQL.get(lineNumber).product__c;
cbr.Requested_land_date_RLD__c = oppRelatedQL.get(lineNumber).Requested_Delivery_Date__c;
cbr.Simplified_Segment__c = segmentMap.containskey(oppRelatedQL.get(lineNumber).product__r.Portfolio_Segment__c) ? segmentMap.get(oppRelatedQL.get(lineNumber).product__r.Portfolio_Segment__c) : '';


if(fc.Opportunity_Forecast_Category__c == 'Development')
cbr.Opportunity_Forecast_Category_Order__c = '1-Development';
else if(fc.Opportunity_Forecast_Category__c == 'Upside')
cbr.Opportunity_Forecast_Category_Order__c = '2-Upside';
else if(fc.Opportunity_Forecast_Category__c == 'Committed')
cbr.Opportunity_Forecast_Category_Order__c = '3-Committed';
else if(fc.Opportunity_Forecast_Category__c == 'Booked')
cbr.Opportunity_Forecast_Category_Order__c = '4-Booked';

insertCBR.add(cbr);
}
}
}
}
}

if(!insertCBR.isEmpty())
insert insertCBR;

List<Forecast_Dimension__c> processedForecastData = new List<Forecast_Dimension__c>();
for(Forecast_Dimension__c forecastData: forcastDataForOpps)
{
Forecast_Dimension__c fd = new Forecast_Dimension__c(id=forecastData.id);
fd.Is_Processed__c = true;
processedForecastData.add(fd);
}

if(!processedForecastData.isEmpty())
update processedForecastData;
}*/
    
    global void finish(Database.BatchableContext BC) 
    {
        database.executebatch(new marginCurrentQLNonPrimary(),100);
    }
}