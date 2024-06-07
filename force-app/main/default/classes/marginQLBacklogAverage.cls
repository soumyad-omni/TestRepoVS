global class marginQLBacklogAverage implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        /*List<String> segmentMap =  new List<String>();
        
        for(Portfolio_Segment_and_Simplified_Segment__mdt segment : [SELECT label, Simplified_Segment__c FROM Portfolio_Segment_and_Simplified_Segment__mdt])
        {
            if(segment.Simplified_Segment__c == 'Automated Dispensing Cabinet')
                segmentMap.add(segment.label);
        }*/
        Date dt = system.today();
        //dt = dt.addYears(50);
        String query ='Select  id, Opportunity_Forecast_Category__c, SAP_ORDER_LINE_ITEM_NUMBER__C, Product__c, SAP_Order_Number__c, SAP_Quote_Number__c, Quote_Line__c, Quote__c, Opportunity__c, Derived_Portfolio_Segment__c,';
        query = query + ' Valid_From__c, Valid_To__c, Total_Cost__c ,expected_booking__c, Cost__c, Overhead_Cost__c, Margin__c, Labor_Cost__c, Quantity__c, RLD_Date__c, Opportunity_Forecast_Category_Order__c';
        query = query + ' FROM Quote_Line_Backlog__c';
        query = query + ' WHERE Product__r.SAP_Product_Type__c IN (\'Frame\',\'Standard Frame\')';
        query = query + ' AND Higher_Level_Item__c = 0';
        query = query + ' AND Derived_Portfolio_Segment__c = \'Automated Dispensing Cabinets\'';
        query = query + ' AND is_processed__c = FALSE';
        query = query + ' AND Is_One_Time_Process__c = FALSE';
        if(!test.isRunningTest())
        {
            query = query + ' AND Valid_From__c <= :dt';
            query = query + ' AND Valid_To__c >= :dt';
            //query = query + ' AND SAP_Quote_Number__c IN (\'5550044\') AND sap_line_number__c IN (11800)';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote_Line_Backlog__c> qlbList) 
    {
        Date dt = system.today();
        //dt = dt.addYears(50);
        
        List<Integer> sapLineNumberList = new List<Integer>();
        List<String> quoteIdList = new List<String>();
        List<String> forecastList = new List<String>();
        List<Quote_line_average__c> insertQLAverageList = new List<Quote_line_average__c>();
        List<Quote_Line_Backlog__c> updateProcessedFlag = new List<Quote_Line_Backlog__c>();
        Map<String, Quote_Line_Backlog__c> sapLineQuoteMap = new Map<String, Quote_Line_Backlog__c>();
        Map<String, Decimal> expectedBookingMap = new Map<String, Decimal>();
        Map<String, Decimal> costMap = new Map<String, Decimal>();
        Map<String, Decimal> overHeadMap = new Map<String, Decimal>();
        Map<String, Decimal> marginMap = new Map<String, Decimal>();
        Map<String, Decimal> laborMap = new Map<String, Decimal>();
        Map<String, Decimal> totalCostMap = new Map<String, Decimal>();
        
        for(Quote_Line_Backlog__c qlb : qlbList)
        {
            quoteIdList.add(qlb.SAP_Quote_Number__c);
            sapLineNumberList.add(Integer.valueOf(qlb.SAP_ORDER_LINE_ITEM_NUMBER__C));
            forecastList.add(qlb.Opportunity_Forecast_Category_Order__c);
            sapLineQuoteMap.put(qlb.SAP_Quote_Number__c+'-'+Integer.valueOf(qlb.SAP_ORDER_LINE_ITEM_NUMBER__C)+'-'+qlb.Opportunity_Forecast_Category_Order__c, qlb);
        }
        
        List<Quote_Line_Backlog__c> newQlbList = [SELECT id, SAP_ORDER_LINE_ITEM_NUMBER__C, SAP_Quote_Number__c, Opportunity_Forecast_Category__c, Higher_Level_Item__c, Opportunity_Forecast_Category_Order__c,
                                                  Total_Cost__c ,expected_booking__c, Cost__c, Overhead_Cost__c, Margin__c, Labor_Cost__c
                                                  FROM Quote_Line_Backlog__c 
                                                  WHERE SAP_Quote_Number__c IN :quoteIdList
                                                  AND Higher_Level_Item__c IN :sapLineNumberList
                                                  AND is_processed__c = FALSE
                                                  AND Opportunity_Forecast_Category_Order__c IN :forecastList
                                                  AND id NOT IN :qlbList
                                                  AND Valid_From__c <= :dt
                                                  AND Valid_To__c >= :dt
                                                  AND product__r.SAP_Product_Type__c != 'Subscription'];
        
        Map<String, Quote_Line_Backlog__c> newCQLRMap = new Map<String, Quote_Line_Backlog__c>();
        for(Quote_Line_Backlog__c qlb: newQlbList)
        {
            String uniqueKey = qlb.SAP_Quote_Number__c+'-'+Integer.valueOf(qlb.Higher_Level_Item__c)+'-'+qlb.Opportunity_Forecast_Category_Order__c;
            if(sapLineQuoteMap.containsKey(uniqueKey))
            {
                qlb.is_processed__c = true;
                updateProcessedFlag.add(qlb);
                
                if(expectedBookingMap.containsKey(uniqueKey))
                    expectedBookingMap.put(uniqueKey, expectedBookingMap.get(uniqueKey) + (qlb.expected_booking__c == NULL ? 0 : qlb.expected_booking__c));
                else
                    expectedBookingMap.put(uniqueKey, qlb.expected_booking__c == NULL ? 0 : qlb.expected_booking__c);
                
                
                if(costMap.containsKey(uniqueKey))
                    costMap.put(uniqueKey, costMap.get(uniqueKey) + (qlb.Cost__c == NULL ? 0 : qlb.Cost__c));
                else
                    costMap.put(uniqueKey, qlb.Cost__c == NULL ? 0 : qlb.Cost__c);
                
                
                if(overHeadMap.containsKey(uniqueKey))
                    overHeadMap.put(uniqueKey, overHeadMap.get(uniqueKey) + (qlb.Overhead_Cost__c == NULL ? 0 : qlb.Overhead_Cost__c));
                else
                    overHeadMap.put(uniqueKey, qlb.Overhead_Cost__c == NULL ? 0 : qlb.Overhead_Cost__c);
                
                
                if(marginMap.containsKey(uniqueKey))
                    marginMap.put(uniqueKey, marginMap.get(uniqueKey) + (qlb.Margin__c == NULL ? 0 : qlb.Margin__c));
                else
                    marginMap.put(uniqueKey, qlb.Margin__c == NULL ? 0 : qlb.Margin__c);
                
                
                if(laborMap.containsKey(uniqueKey))
                    laborMap.put(uniqueKey, laborMap.get(uniqueKey) + (qlb.Labor_Cost__c == NULL ? 0 : qlb.Labor_Cost__c));
                else
                    laborMap.put(uniqueKey, qlb.Labor_Cost__c == NULL ? 0 : qlb.Labor_Cost__c);
                
                if(totalCostMap.containsKey(uniqueKey))
                    totalCostMap.put(uniqueKey, totalCostMap.get(uniqueKey) + (qlb.Total_Cost__c == NULL ? 0 : qlb.Total_Cost__c));
                else
                    totalCostMap.put(uniqueKey, qlb.Total_Cost__c == NULL ? 0 : qlb.Total_Cost__c);    
            }
        }
        
        Map<String, Process_ASP_Records__c> csMap = Process_ASP_Records__c.getAll();
        
        
        for(Quote_Line_Backlog__c qlb : qlbList)
        {
            String uniqueKey = qlb.SAP_Quote_Number__c+'-'+Integer.valueOf(qlb.SAP_ORDER_LINE_ITEM_NUMBER__C)+'-'+qlb.Opportunity_Forecast_Category_Order__c;
            qlb.is_processed__c = true;
            
            for(String str : csMap.keySet())
            {
                if(qlb.Opportunity_Forecast_Category_Order__c <> NULL && qlb.Opportunity_Forecast_Category_Order__c <> ''
                   && qlb.Opportunity_Forecast_Category_Order__c.startswith(str) 
                   && csMap.get(str).Only_One_Time_Process__c)
                {
                    qlb.Is_One_Time_Process__c = true;
                    break;
                }
            }
            
            updateProcessedFlag.add(qlb);
            
            Quote_line_average__c qla 					= new Quote_line_average__c();
            qla.quote_line__c 							= qlb.Quote_Line__c;
            qla.quote__c								= qlb.Quote__c;
            qla.Opportunity__c 							= qlb.Opportunity__c;
            qla.Product__c 								= qlb.Product__c;
            qla.SAP_Line_Number__c						= qlb.SAP_ORDER_LINE_ITEM_NUMBER__C;
            qla.SAP_Quote_Number__c						= qlb.SAP_Quote_Number__c;
            qla.Requested_land_date_RLD__c 				= qlb.RLD_Date__c;
            qla.Opportunity_Forecast_Category_Order__c	= qlb.Opportunity_Forecast_Category_Order__c;
            qla.Opportunity_Forecast_Category__c		= qlb.Opportunity_Forecast_Category__c;
            qla.expected_booking__c 					= (qlb.expected_booking__c == NULL ? 0 : qlb.expected_booking__c) + (expectedBookingMap.containsKey(uniqueKey) ? expectedBookingMap.get(uniqueKey) : 0);
            qla.Cost__c 								= (qlb.Cost__c == NULL ? 0 : qlb.Cost__c) + (costMap.containsKey(uniqueKey) ? costMap.get(uniqueKey) : 0);
            qla.Overhead_Cost__c 						= (qlb.Overhead_Cost__c == NULL ? 0 : qlb.Overhead_Cost__c) + (overHeadMap.containsKey(uniqueKey) ? overHeadMap.get(uniqueKey) : 0);
            qla.Margin__c 								= (qlb.Margin__c == NULL ? 0 : qlb.Margin__c) + (marginMap.containsKey(uniqueKey) ? marginMap.get(uniqueKey) : 0);
            qla.Labor_Cost__c 							= (qlb.Labor_Cost__c == NULL ? 0 : qlb.Labor_Cost__c) + (laborMap.containsKey(uniqueKey) ? laborMap.get(uniqueKey) : 0);
            qla.Total_Cost_Currency__c					= (qlb.Total_Cost__c == NULL ? 0 : qlb.Total_Cost__c) + (totalCostMap.containsKey(uniqueKey) ? totalCostMap.get(uniqueKey) : 0);
            qla.quantity__c 							= qlb.quantity__c;
            qla.Derived_Portfolio_Segment__c			= qlb.Derived_Portfolio_Segment__c;
            qla.Valid_From__c 							= qlb.Valid_From__c;
            qla.Valid_To__c								= qlb.Valid_To__c;
            insertQLAverageList.add(qla);
        }
        
        if(!insertQLAverageList.isEmpty())
            insert insertQLAverageList;
        
        if(!updateProcessedFlag.isEmpty())
            update updateProcessedFlag;
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        database.executebatch(new ResetBacklogQLProcessFlag(),5000);
    }
}