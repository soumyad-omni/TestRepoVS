global class ChangeOrderDeleteBacklogStatus implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query 	= 'SELECT id, Backlog_Status__c FROM Change_Order_Tableau__c WHERE Backlog_Status__c = \'Backlog\'';

        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Tableau__c> coTList) 
    {
        for(Change_Order_Tableau__c cot : cotList)
        {
            cot.Backlog_Status__c = '';
        }
        
        update cotList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        database.executeBatch(new ChangeOrderBacklogMergeBatch(), 10);    
    }
}