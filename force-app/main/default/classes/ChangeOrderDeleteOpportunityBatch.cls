/* 
* Batch Class to delete Change Order Opportunity details
*/ 
global class ChangeOrderDeleteOpportunityBatch implements Database.Batchable<sObject>, schedulable, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query 	= 'SELECT id FROM Change_Order_Opportunity__c';
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Opportunity__c> coolList) 
    {
        delete coolList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final Quote Line Delete batch');
        //database.executebatch(new ChangeOrderDeleteQuoteLineBatch(),10000);
        database.executebatch(new ChangeOrderChildOpportunitiesBatch(),10);
    }
    
    global void execute(SchedulableContext SC) {
        database.executebatch(new ChangeOrderDeleteOpportunityBatch(),10000);
    }
}