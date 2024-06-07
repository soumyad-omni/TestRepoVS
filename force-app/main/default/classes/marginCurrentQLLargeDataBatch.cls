global class marginCurrentQLLargeDataBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Set<Id> oppIds = new Set<Id>();
        AggregateResult[] groupedResults
            = [Select count(id), quote__r.opportunityId oppId
               FROM Quote_Line__c 
               Where  Material_Type__c IN ('PRODUCT','SERVICE')
               AND quote__r.Primary_Quote__c = true AND product__r.ProductCode <> 'FREIGHT' 
               AND Line_Status__c <> 'E0006' 
               AND Product_Code__c != 'LEASE BUYOUT' 
               AND quote__r.opportunity.Pipeline_Category__c in ('Development','Upside','Committed','Booked') 
               AND quote__r.opportunity.RecordTypeId ='0121N000001M5A8QAK' AND quote__r.opportunity.closedate>2018-12-31 
               //AND quote__r.opportunityId in ('0063l00000hu9ybAAA','0061N00000gMrgaQAC') 
               group by quote__r.opportunityId having count(id)>2000 ];
        for (AggregateResult ar : groupedResults)  {
            oppIds.add((ID) ar.get('oppId'));
        }        
        String query;                        
        if(Test.isRunningTest())  {
            query='Select id from Opportunity where Pipeline_Category__c in (\'Development\',\'Upside\',\'Committed\',\'Booked\') and RecordTypeId =\'0121N000001M5A8QAK\' and closedate>2018-12-31';
        }else{
            query='Select id from Opportunity where Pipeline_Category__c in (\'Development\',\'Upside\',\'Committed\',\'Booked\') and RecordTypeId =\'0121N000001M5A8QAK\' and closedate>2018-12-31 and id in :oppIds';
		 }        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> lstFC){
        Map<String,String> segmentMap =  new Map<String, String>();
        
        for(Portfolio_Segment_and_Simplified_Segment__mdt segment : [SELECT label, Simplified_Segment__c FROM Portfolio_Segment_and_Simplified_Segment__mdt])
        {
            segmentMap.put(segment.label,segment.Simplified_Segment__c);
        }
        Set<id> oppIds = new Set<id>();
        for(Opportunity opp:lstFC){
            oppIds.add(opp.id);
        }
        Map<String,Quote_Line__c> oppRelatedQL = new Map<String,Quote_Line__c>();
        Map<String,Set<String>> oppAndQuoteLineMap = new Map<String,Set<String>>();
        List<Current_Quote_Line_Result__c> insertCBR = new List<Current_Quote_Line_Result__c>();
        for(Quote_Line__c ql : [SELECT id, quote__c,quote__r.opportunityId,quote__r.opportunity.Pipeline_Category__c, Material_Type__c, Line_Status__c, product__c,
                                quote__r.Order_Type__c, SAP_Line_Number__c, product__r.Portfolio_Segment__c, SAP_Line_Item_GUID__c,
                                Quantity__c, Margin_Percentage__c, Labor_Cost__c, Overhead_Cost__c, Product_Cost__c, Line_Expected_Booking__c, Requested_Delivery_Date__c
                                FROM Quote_Line__c
                                WHERE Material_Type__c IN ('PRODUCT','SERVICE')
                                AND quote__r.Primary_Quote__c = true
                                AND quote__r.opportunityId IN :oppIds
                                AND product__r.ProductCode <> 'FREIGHT'
                                AND Line_Status__c <> 'E0006'
                                AND Product_Code__c != 'LEASE BUYOUT'])
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
        for(id oppId: oppIds)
        {
            if(oppAndQuoteLineMap.containsKey(oppId))
            {
                for(String lineNumber : oppAndQuoteLineMap.get(oppId))
                {
                    if(oppRelatedQL.get(lineNumber) != null){
                        Current_Quote_Line_Result__c cbr = new Current_Quote_Line_Result__c();
                        cbr.Margin__c = oppRelatedQL.get(lineNumber).Margin_Percentage__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Margin_Percentage__c;
                        cbr.expected_booking__c = oppRelatedQL.get(lineNumber).Line_Expected_Booking__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Line_Expected_Booking__c;
                        cbr.Labor_Cost__c = oppRelatedQL.get(lineNumber).Labor_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Labor_Cost__c;
                        cbr.Overhead_Cost__c = oppRelatedQL.get(lineNumber).Overhead_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Overhead_Cost__c;
                        cbr.Cost__c = oppRelatedQL.get(lineNumber).Product_Cost__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Product_Cost__c;
                        cbr.Quantity__c = oppRelatedQL.get(lineNumber).Quantity__c == NULL ? 0 : oppRelatedQL.get(lineNumber).Quantity__c;
                        
                        cbr.Opportunity__c = oppId;
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
            }
        }
        if(!insertCBR.isEmpty())
            insert insertCBR;
    }
    
   /* global void execute(Database.BatchableContext BC, List<Quote_Line__c> lstFC) 
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
        
        for( Quote_Line__c fc :lstFC){
            oppIds.add(fc.quote__r.opportunityId);
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
        database.executebatch(new marginCurrentQLBatch(),50);
    }
}