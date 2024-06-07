/* 
* Batch Class to delete change order debit and omnicell tableau records
*/ 
global class ChangeOrderDeleteNonCreditTableau implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Datetime lastRunDt = ChangeOrderChildOpportunitiesBatch.getBatchLastRunTime('ChangeOrderQuoteLineBatch');
        
        String query 	= 'SELECT id FROM Change_Order_Tableau__c WHERE Opportunity_Type__c IN (\'Change Order - Debit\',\'Omnicell Opportunity\')';
        //query			= query + ' AND Change_Order_Quote_Line__r.Quote_Line__r.Quote__r.Primary_Quote__c = FALSE';
        query			= query + ' AND Change_Order_Quote_Line__c = NULL';
        
        if(lastRunDt <> NULL)
        {
            lastRunDt = lastRunDt.addDays(-1);
            query		= query + ' AND (Change_Order_Quote_Line__r.Quote_Line__r.Lastmodifieddate >: lastRunDt OR Change_Order_Quote_Line__r.Quote_Line__r.Quote__r.Lastmodifieddate >: lastRunDt OR Change_Order_Quote_Line__r.Quote_Line__r.Quote__r.Opportunity.Lastmodifieddate >: lastRunDt)';
        }
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Tableau__c> cotList) 
    {
        delete cotList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        ChangeOrderChildOpportunitiesBatch.upsertBatchLastRunTime('ChangeOrderDeleteNonCreditTableau');
        database.executeBatch(new ChangeOrderQuoteLineBatch(null), 1000);    
    }
}