global class marginQLAverage implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query ='Select  id, Opportunity_Forecast_Category__c, sap_line_number__c, Quote__c, Product__c, Opportunity__c, Quote_Line__c, Requested_land_date_RLD__c, Derived_Portfolio_Segment__c,';
        query = query + ' Total_Cost__c , expected_booking__c, Cost__c, Overhead_Cost__c, Margin__c, Labor_Cost__c, Quantity__c, Quote__r.SAP_Quote_Number_Truncated__c, Opportunity_Forecast_Category_Order__c';
        query = query + ' FROM Current_Quote_Line_Result__c';
        query = query + ' WHERE Product__r.SAP_Product_Type__c IN (\'Frame\',\'Standard Frame\')';
        query = query + ' AND Quote_line__r.Higher_Level_Item__c = 0';
        query = query + ' AND Derived_Portfolio_Segment__c = \'Automated Dispensing Cabinets\' AND Quote_line__r.Material_Type__c = \'PRODUCT\'';
        query = query + ' AND is_processed__c = FALSE';
        query = query + ' AND Valid_From__c <= TODAY';
        query = query + ' AND Valid_To__c >= TODAY';
        //query = query + ' AND Quote__c IN (\'0Q01N000001m5o6SAA\')';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Current_Quote_Line_Result__c> cqlrList) 
    {
        List<Integer> sapLineNumberList = new List<Integer>();
        List<String> quoteIdList = new List<String>();
        List<String> forecastList = new List<String>();
        List<Quote_line_average__c> insertQLAverageList = new List<Quote_line_average__c>();
        List<Current_Quote_Line_Result__c> updateProcessedFlag = new List<Current_Quote_Line_Result__c>();
        Map<String, Current_Quote_Line_Result__c> sapLineQuoteMap = new Map<String, Current_Quote_Line_Result__c>();
        Map<String, Decimal> expectedBookingMap = new Map<String, Decimal>();
        Map<String, Decimal> costMap = new Map<String, Decimal>();
        Map<String, Decimal> overHeadMap = new Map<String, Decimal>();
        Map<String, Decimal> marginMap = new Map<String, Decimal>();
        Map<String, Decimal> laborMap = new Map<String, Decimal>();
        Map<String, Decimal> totalCostMap = new Map<String, Decimal>();
        
        for(Current_Quote_Line_Result__c cqlr : cqlrList)
        {
            quoteIdList.add(cqlr.Quote__c);
            sapLineNumberList.add(Integer.valueOf(cqlr.sap_line_number__c));
            forecastList.add(cqlr.Opportunity_Forecast_Category_Order__c);
            sapLineQuoteMap.put(cqlr.Quote__c+'-'+Integer.valueOf(cqlr.sap_line_number__c)+'-'+cqlr.Opportunity_Forecast_Category_Order__c, cqlr);
        }
        
        List<Current_Quote_Line_Result__c> newCqlrList = [SELECT id, quote__c, Opportunity_Forecast_Category__c, Higher_Level_Item__c, Opportunity_Forecast_Category_Order__c,
                                                          Total_Cost__c ,expected_booking__c, Cost__c, Overhead_Cost__c, Margin__c, Labor_Cost__c,opportunity__r.opportunity__c 
                                                          FROM Current_Quote_Line_Result__c 
                                                          WHERE quote__c IN :quoteIdList
                                                          AND Higher_Level_Item__c IN :sapLineNumberList
                                                          AND Quote_line__r.Material_Type__c = 'PRODUCT'
                                                          AND is_processed__c = FALSE
                                                          AND Opportunity_Forecast_Category_Order__c IN :forecastList
                                                          AND product__r.SAP_Product_Type__c != 'Subscription'
                                                          AND id NOT IN :cqlrList
                                                          AND Valid_From__c <= TODAY
        												  AND Valid_To__c >= TODAY];
        
        Map<String, Current_Quote_Line_Result__c> newCQLRMap = new Map<String, Current_Quote_Line_Result__c>();
        for(Current_Quote_Line_Result__c cqlr: newCqlrList)//child records
        {
            String uniqueKey = cqlr.quote__c+'-'+Integer.valueOf(cqlr.Higher_Level_Item__c)+'-'+cqlr.Opportunity_Forecast_Category_Order__c;
            if(sapLineQuoteMap.containsKey(uniqueKey))
            {
                cqlr.Is_Processed__c = true;
                updateProcessedFlag.add(cqlr);
                
                if(expectedBookingMap.containsKey(uniqueKey))
                    expectedBookingMap.put(uniqueKey, expectedBookingMap.get(uniqueKey)+ (cqlr.expected_booking__c == NULL ? 0 : cqlr.expected_booking__c));
                else
                    expectedBookingMap.put(uniqueKey, cqlr.expected_booking__c == NULL ? 0 : cqlr.expected_booking__c);
                
                
                if(costMap.containsKey(uniqueKey))
                    costMap.put(uniqueKey, costMap.get(uniqueKey) + (cqlr.Cost__c == NULL ? 0 : cqlr.Cost__c));
                else
                    costMap.put(uniqueKey, cqlr.Cost__c == NULL ? 0 : cqlr.Cost__c);
                
                
                if(overHeadMap.containsKey(uniqueKey))
                    overHeadMap.put(uniqueKey, overHeadMap.get(uniqueKey) + (cqlr.Overhead_Cost__c == NULL ? 0 : cqlr.Overhead_Cost__c));
                else
                    overHeadMap.put(uniqueKey, cqlr.Overhead_Cost__c == NULL ? 0 : cqlr.Overhead_Cost__c);
                
                
                if(marginMap.containsKey(uniqueKey))
                    marginMap.put(uniqueKey, marginMap.get(uniqueKey) + (cqlr.Margin__c == NULL ? 0 : cqlr.Margin__c));
                else
                    marginMap.put(uniqueKey, cqlr.Margin__c == NULL ? 0 : cqlr.Margin__c);
                
                
                if(laborMap.containsKey(uniqueKey))
                    laborMap.put(uniqueKey, laborMap.get(uniqueKey) + (cqlr.Labor_Cost__c == NULL ? 0 : cqlr.Labor_Cost__c));
                else
                    laborMap.put(uniqueKey, cqlr.Labor_Cost__c == NULL ? 0 : cqlr.Labor_Cost__c);
                
                if(totalCostMap.containsKey(uniqueKey))
                    totalCostMap.put(uniqueKey, totalCostMap.get(uniqueKey) + (cqlr.Total_Cost__c == NULL ? 0 : cqlr.Total_Cost__c));
                else
                    totalCostMap.put(uniqueKey, cqlr.Total_Cost__c == NULL ? 0 : cqlr.Total_Cost__c);
                
                
            }
        }
        
        for(Current_Quote_Line_Result__c cqlr : cqlrList)
        {
            String uniqueKey = cqlr.Quote__c+'-'+Integer.valueOf(cqlr.sap_line_number__c)+'-'+cqlr.Opportunity_Forecast_Category_Order__c;
            
            cqlr.Is_Processed__c = true;
            updateProcessedFlag.add(cqlr);

            Quote_line_average__c qla 					= new Quote_line_average__c();
            qla.quote_line__c 							= cqlr.Quote_Line__c;
            qla.quote__c 								= cqlr.Quote__c;
            qla.Opportunity__c 							= cqlr.Opportunity__c;
            qla.Product__c 								= cqlr.Product__c;
            qla.SAP_Line_Number__c						= cqlr.SAP_Line_Number__c;
            qla.SAP_Quote_Number__c						= cqlr.Quote__r.SAP_Quote_Number_Truncated__c;
            qla.Requested_land_date_RLD__c 				= cqlr.Requested_land_date_RLD__c;
            qla.Opportunity_Forecast_Category__c 		= cqlr.Opportunity_Forecast_Category__c;
            qla.Opportunity_Forecast_Category_Order__c 	= cqlr.Opportunity_Forecast_Category_Order__c;
            qla.expected_booking__c 					= (cqlr.expected_booking__c == NULL ? 0 : cqlr.expected_booking__c) + (expectedBookingMap.containsKey(uniqueKey) ? expectedBookingMap.get(uniqueKey) : 0);
            qla.Cost__c 								= (cqlr.Cost__c == NULL ? 0 : cqlr.Cost__c) + (costMap.containsKey(uniqueKey) ? costMap.get(uniqueKey) : 0);
            qla.Overhead_Cost__c 						= (cqlr.Overhead_Cost__c == NULL ? 0 : cqlr.Overhead_Cost__c) + (overHeadMap.containsKey(uniqueKey) ? overHeadMap.get(uniqueKey) : 0);
            qla.Margin__c 								= (cqlr.Margin__c == NULL ? 0 : cqlr.Margin__c) + (marginMap.containsKey(uniqueKey) ? marginMap.get(uniqueKey) : 0);
            qla.Labor_Cost__c 							= (cqlr.Labor_Cost__c == NULL ? 0 : cqlr.Labor_Cost__c) + (laborMap.containsKey(uniqueKey) ? laborMap.get(uniqueKey) : 0);
            qla.Total_Cost_Currency__c					= (cqlr.Total_Cost__c == NULL ? 0 : cqlr.Total_Cost__c) + (totalCostMap.containsKey(uniqueKey) ? totalCostMap.get(uniqueKey) : 0);
            qla.quantity__c 							= cqlr.quantity__c;
            qla.Derived_Portfolio_Segment__c			= cqlr.Derived_Portfolio_Segment__c;
            qla.Valid_From__c = Date.today();
            qla.Valid_To__c = Date.newInstance(2999, 12, 31);
            
            insertQLAverageList.add(qla);
        }
        
        if(!insertQLAverageList.isEmpty())
            insert insertQLAverageList;
        
        if(!updateProcessedFlag.isEmpty())
            update updateProcessedFlag;
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        database.executebatch(new ResetCurrentQLProcessFlag(),5000);
    }
}