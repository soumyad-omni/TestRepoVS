/* 
 * Batch Class to Update Change Order Opportunity records with TOP LEVEL OPPORTUNITY
 */ 
global class ChangeOrderTopLevelOpportunitiesBatch implements Database.Batchable<sObject>, Database.Stateful {
    //to capture Ids and close date sent from previous class
    public Map<Id, Id> topLevelOppIdMap 			= new Map<Id, Id>();
    public Map<Id, Date> topLevelOppCloseDateMap 	= new Map<Id, Date>();
    
    //To capture the Opportunity Id and close date to check grandchild in next batch class 
    public Map<Id, Id> newTopLevelOppIdMap 			= new Map<Id, Id>();
    public Map<Id, Date> newTopLevelOppCloseDateMap = new Map<Id, Date>();
    
    //stop executing this batch class if we are at bottom of hierarchy
    public Boolean foundChildRecords 				= false;
    
    public ChangeOrderTopLevelOpportunitiesBatch(Map<Id, Id> topLevelMap, Map<Id, Date> topLevelCloseDateMap) {
        if(topLevelMap <> NULL)
            topLevelOppIdMap = topLevelMap;
        if(topLevelCloseDateMap <> NULL)
            topLevelOppCloseDateMap = topLevelCloseDateMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Set<id> tempIds = new Set<id>();
        if(!topLevelOppIdMap.isEmpty())
        {
            for(Id ids : topLevelOppIdMap.keyset())
            {
                tempIds.add(ids);
            }
        }
        //Getting child opportunities for given assiciated opportunties from previous batch class
        String query 	= 'SELECT id, Associated_Opportunity__c, Top_Level_Opportunity__c, Opportunity__c, Top_Level_Opportunity_Closed_Date__c, Opportunity_Expected_Close_Date__c, Top_Level_Opportunity_Closed_Date_Quater__c FROM Change_Order_Opportunity__c';
        if(tempIds.isEmpty())
            query 		= query + ' WHERE Associated_Opportunity__c = NULL';
        else
            query 		= query + ' WHERE Associated_Opportunity__c IN :tempIds';
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Opportunity__c> cooList) 
    {
        List<Change_Order_Opportunity__c> cooUpdateList = new List<Change_Order_Opportunity__c>();
        for(Change_Order_Opportunity__c coo : cooList)
        {
            Boolean isChanged = false;
            
            if(topLevelOppIdMap.isEmpty() && coo.Top_Level_Opportunity__c <> coo.Opportunity__c)
            {
                coo.Top_Level_Opportunity__c = coo.Opportunity__c;
                isChanged = true;
            }
            else if(topLevelOppIdMap.containsKey(coo.Associated_Opportunity__c) && coo.Top_Level_Opportunity__c <> topLevelOppIdMap.get(coo.Associated_Opportunity__c))
            {
                coo.Top_Level_Opportunity__c = topLevelOppIdMap.get(coo.Associated_Opportunity__c);
                isChanged = true;
            }
            
            if(topLevelOppCloseDateMap.isEmpty() && coo.Top_Level_Opportunity_Closed_Date__c <> coo.Opportunity_Expected_Close_Date__c)
            {
                coo.Top_Level_Opportunity_Closed_Date__c = coo.Opportunity_Expected_Close_Date__c;
                isChanged = true;
            }
            else if(topLevelOppCloseDateMap.containsKey(coo.Associated_Opportunity__c) && coo.Top_Level_Opportunity_Closed_Date__c <> topLevelOppCloseDateMap.get(coo.Associated_Opportunity__c))
            {
                coo.Top_Level_Opportunity_Closed_Date__c = topLevelOppCloseDateMap.get(coo.Associated_Opportunity__c);
                isChanged = true;
            }
            
            if(coo.Top_Level_Opportunity_Closed_Date_Quater__c <> ChangeOrderChildOpportunitiesBatch.returnQuater(coo.Top_Level_Opportunity_Closed_Date__c))
            {
                coo.Top_Level_Opportunity_Closed_Date_Quater__c 	= ChangeOrderChildOpportunitiesBatch.returnQuater(coo.Top_Level_Opportunity_Closed_Date__c);  
                isChanged = true;
            }
            
            //coo.Top_Level_Opportunity__c 						= (topLevelOppIdMap.isEmpty() ? coo.Opportunity__c : topLevelOppIdMap.get(coo.Associated_Opportunity__c));
            //coo.Top_Level_Opportunity_Closed_Date__c 			= (topLevelOppCloseDateMap.isEmpty() ? coo.Opportunity_Expected_Close_Date__c : topLevelOppCloseDateMap.get(coo.Associated_Opportunity__c));
            //coo.Top_Level_Opportunity_Closed_Date_Quater__c 	= ChangeOrderChildOpportunitiesBatch.returnQuater(coo.Top_Level_Opportunity_Closed_Date__c);
            
            //capturing current opportunity and top level opportunity
            newTopLevelOppIdMap.put(coo.Opportunity__c, coo.Top_Level_Opportunity__c);
            newTopLevelOppCloseDateMap.put(coo.Opportunity__c, coo.Top_Level_Opportunity_Closed_Date__c);
            
            if(isChanged)
            {
                cooUpdateList.add(coo);
            }
        }
        
        if(!cooUpdateList.isEmpty())
        {
            update cooUpdateList;
        }
        foundChildRecords = true;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final parent batch');
        if(foundChildRecords && !test.isRunningTest())//if more child found, execute the same batch class with new map (the last batch should return 0 records)
        {
            database.executeBatch(new ChangeOrderTopLevelOpportunitiesBatch(newTopLevelOppIdMap, newTopLevelOppCloseDateMap), 50); 
        }
        else if(newTopLevelOppIdMap.isEmpty() || test.isRunningTest())//continue with summary batch if no child found
        {
            ChangeOrderChildOpportunitiesBatch.upsertBatchLastRunTime('ChangeOrderTopLevelOpportunitiesBatch');
            database.executeBatch(new ChangeOrderSummaryOpportunitiesBatch(), 50);   
        }
    }
}