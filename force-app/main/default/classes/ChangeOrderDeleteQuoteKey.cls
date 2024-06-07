global class ChangeOrderDeleteQuoteKey implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query 	= 'SELECT id FROM Change_Order_Credit_Key__c';
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Credit_Key__c> coqlList) 
    {
        delete coqlList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        database.executeBatch(new ChangeOrderInsertQuoteKey(),100);
    }
}