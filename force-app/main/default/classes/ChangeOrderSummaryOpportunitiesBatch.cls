/* 
* Batch Class to Update Top Level Change Order Opportunity records with summary fields
*/ 
global class ChangeOrderSummaryOpportunitiesBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //getting list of all top level opportunities(i.e., Associated_Opportunity__c = NULL)
        String query 	= 'SELECT id, Opportunity__c, Top_Level_Opportunity__c, Sum_of_Credit_Opportunities__c, Sum_of_Debit_Opportunities__c, ';
        query 			= query + ' Summary_Expected_Bookings__c, Summary_Grand_Total__c, Summary_Total_Product__c, Summary_Total_Shipping_Handling__c,';
        query 			= query + ' Summary_Total_Support_Services__c, Summary_Credit_Expected_Bookings__c, Summary_Debit_Expected_Bookings__c';
        query 			= query + ' FROM Change_Order_Opportunity__c';
        query 			= query + ' WHERE Associated_Opportunity__c = NULL';
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Opportunity__c> cooList) 
    {
        List<Id> toplevelIds = new List<Id>();
        
        Map<Id, Decimal> creditExpectedBookingsSummaryMap 		= new Map<Id, Decimal>();
        Map<Id, Decimal> debitExpectedBookingsSummaryMap 		= new Map<Id, Decimal>();
        Map<Id, Decimal> expectedBookingsSummaryMap 			= new Map<Id, Decimal>();
        Map<Id, Decimal> grandTotalSummaryMap 					= new Map<Id, Decimal>();
        Map<Id, Decimal> totalProductSummaryMap 				= new Map<Id, Decimal>();
        Map<Id, Decimal> totalShippingHandlingSummaryMap 		= new Map<Id, Decimal>();
        Map<Id, Decimal> totalSupportServicesSummaryMap 		= new Map<Id, Decimal>();
        Map<Id, Integer> creditSumMap 							= new Map<Id, Integer>();
        Map<Id, Integer> debitSumMap 							= new Map<Id, Integer>();
        
        for(Change_Order_Opportunity__c coo : cooList)
        {
            //Caturing Ids for Top Level Opportunity
            topLevelIds.add(coo.Top_Level_Opportunity__c);
        }
        
        if(!topLevelIds.isEmpty())
        {
            List<Change_Order_Opportunity__c> cooChildList 		= new List<Change_Order_Opportunity__c>();
            
            //Retrieving child of all top level opportunities
            cooChildList = [SELECT id, Primary_Quote_Total_Product__c, Primary_Quote_Total_Shipping_Handling__c, Primary_Quote_Total_Support_Services__c,
                            Primary_Quote_Grand_Total__c, Top_Level_Opportunity__c, Opportunity_Type__c, Opportunity_Expected_Bookings__c
                            FROM Change_Order_Opportunity__c
                            WHERE Top_Level_Opportunity__c IN :topLevelIds];
            
            for(Change_Order_Opportunity__c cooChild : cooChildList)
            {
                //Capturing the summary values into respective maps with Top level opportunity as key
                expectedBookingsSummaryMap.put(cooChild.Top_Level_Opportunity__c, (cooChild.Opportunity_Expected_Bookings__c == NULL ? 0 : cooChild.Opportunity_Expected_Bookings__c) + (expectedBookingsSummaryMap.containsKey(cooChild.Top_Level_Opportunity__c) ? expectedBookingsSummaryMap.get(cooChild.Top_Level_Opportunity__c) : 0));
                
                grandTotalSummaryMap.put(cooChild.Top_Level_Opportunity__c, (cooChild.Primary_Quote_Grand_Total__c == NULL ? 0 : cooChild.Primary_Quote_Grand_Total__c) + (grandTotalSummaryMap.containsKey(cooChild.Top_Level_Opportunity__c) ? grandTotalSummaryMap.get(cooChild.Top_Level_Opportunity__c) : 0));
                
                totalProductSummaryMap.put(cooChild.Top_Level_Opportunity__c, (cooChild.Primary_Quote_Total_Product__c == NULL ? 0 : cooChild.Primary_Quote_Total_Product__c) + (totalProductSummaryMap.containsKey(cooChild.Top_Level_Opportunity__c) ? totalProductSummaryMap.get(cooChild.Top_Level_Opportunity__c) : 0));                
                
                totalShippingHandlingSummaryMap.put(cooChild.Top_Level_Opportunity__c, (cooChild.Primary_Quote_Total_Shipping_Handling__c == NULL ? 0 : cooChild.Primary_Quote_Total_Shipping_Handling__c) + (totalShippingHandlingSummaryMap.containsKey(cooChild.Top_Level_Opportunity__c) ? totalShippingHandlingSummaryMap.get(cooChild.Top_Level_Opportunity__c) : 0));
                
                totalSupportServicesSummaryMap.put(cooChild.Top_Level_Opportunity__c, (cooChild.Primary_Quote_Total_Support_Services__c == NULL ? 0 : cooChild.Primary_Quote_Total_Support_Services__c) + (totalSupportServicesSummaryMap.containsKey(cooChild.Top_Level_Opportunity__c) ? totalSupportServicesSummaryMap.get(cooChild.Top_Level_Opportunity__c) : 0));
                system.debug('cooChild.Opportunity_Type__c-->'+cooChild.Opportunity_Type__c);
                if(cooChild.Opportunity_Type__c == 'Change Order - Credit')
                {
                    creditExpectedBookingsSummaryMap.put(cooChild.Top_Level_Opportunity__c,(cooChild.Opportunity_Expected_Bookings__c == NULL ? 0 : cooChild.Opportunity_Expected_Bookings__c) + (creditExpectedBookingsSummaryMap.containsKey(cooChild.Top_Level_Opportunity__c) ? creditExpectedBookingsSummaryMap.get(cooChild.Top_Level_Opportunity__c) : 0));
                    
                    creditSumMap.put(cooChild.Top_Level_Opportunity__c,1 + (creditSumMap.containsKey(cooChild.Top_Level_Opportunity__c) ? creditSumMap.get(cooChild.Top_Level_Opportunity__c) : 0));
                }
                
                if(cooChild.Opportunity_Type__c == 'Change Order - Debit')
                {
                    debitExpectedBookingsSummaryMap.put(cooChild.Top_Level_Opportunity__c,(cooChild.Opportunity_Expected_Bookings__c == NULL ? 0 : cooChild.Opportunity_Expected_Bookings__c) + (debitExpectedBookingsSummaryMap.containsKey(cooChild.Top_Level_Opportunity__c) ? debitExpectedBookingsSummaryMap.get(cooChild.Top_Level_Opportunity__c) : 0));
                    
                    debitSumMap.put(cooChild.Top_Level_Opportunity__c,1 + (debitSumMap.containsKey(cooChild.Top_Level_Opportunity__c) ? debitSumMap.get(cooChild.Top_Level_Opportunity__c) : 0));                
                }
            }
            
            List<Change_Order_Opportunity__c> cooUpdateList = new List<Change_Order_Opportunity__c>();
            for(Change_Order_Opportunity__c coo : cooList)
            {
                Boolean isChanged = false;
                
                if(coo.Summary_Expected_Bookings__c <> expectedBookingsSummaryMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Summary_Expected_Bookings__c = expectedBookingsSummaryMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(coo.Summary_Grand_Total__c <> grandTotalSummaryMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Summary_Grand_Total__c = grandTotalSummaryMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(coo.Summary_Total_Product__c <> totalProductSummaryMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Summary_Total_Product__c = totalProductSummaryMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(coo.Summary_Total_Shipping_Handling__c <> totalShippingHandlingSummaryMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Summary_Total_Shipping_Handling__c = totalShippingHandlingSummaryMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(coo.Summary_Total_Support_Services__c <> totalSupportServicesSummaryMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Summary_Total_Support_Services__c = totalSupportServicesSummaryMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(creditExpectedBookingsSummaryMap.containsKey(coo.Top_Level_Opportunity__c) && coo.Summary_Credit_Expected_Bookings__c <> creditExpectedBookingsSummaryMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Summary_Credit_Expected_Bookings__c = creditExpectedBookingsSummaryMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(debitExpectedBookingsSummaryMap.containsKey(coo.Top_Level_Opportunity__c) && coo.Summary_Debit_Expected_Bookings__c <> debitExpectedBookingsSummaryMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Summary_Debit_Expected_Bookings__c = debitExpectedBookingsSummaryMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(creditSumMap.containsKey(coo.Top_Level_Opportunity__c) && coo.Sum_of_Credit_Opportunities__c <> creditSumMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Sum_of_Credit_Opportunities__c = creditSumMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(debitSumMap.containsKey(coo.Top_Level_Opportunity__c) && coo.Sum_of_Debit_Opportunities__c <> debitSumMap.get(coo.Top_Level_Opportunity__c))
                {
                    coo.Sum_of_Debit_Opportunities__c = debitSumMap.get(coo.Top_Level_Opportunity__c);
                    isChanged = true;
                }
                
                if(isChanged)
                {
                    cooUpdateList.add(coo);
                }
            }
            
            if(!cooUpdateList.isEmpty())
            {
                update cooUpdateList;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final summary batch');
        ChangeOrderChildOpportunitiesBatch.upsertBatchLastRunTime('ChangeOrderSummaryOpportunitiesBatch');
        database.executebatch(new ChangeOrderNonPrimaryQuoteBatch(),2000);
    }
}