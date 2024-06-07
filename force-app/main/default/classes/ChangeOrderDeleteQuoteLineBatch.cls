/* 
* Batch Class to delete change order quote line details
*/ 
global class ChangeOrderDeleteQuoteLineBatch implements Database.Batchable<sObject>, Database.Stateful {
    public List<String> nonPrimaryQuoteNumbers = new List<String>();
    
    public ChangeOrderDeleteQuoteLineBatch(List<String> quoteNumbersList) {
        nonPrimaryQuoteNumbers = quoteNumbersList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Datetime lastRunDt = ChangeOrderChildOpportunitiesBatch.getBatchLastRunTime('ChangeOrderQuoteLineBatch');
        
        //getting list of all Change_Order_Quote_Line__c
        //String query 	= 'SELECT id FROM Change_Order_Quote_Line__c WHERE Quote_Line__r.SAP_Quote_Number__c IN  :nonPrimaryQuoteNumbers';
        String query 	= 'SELECT id FROM Change_Order_Quote_Line__c WHERE Quote_Number__c IN  :nonPrimaryQuoteNumbers';
        if(lastRunDt <> NULL)
        {
            lastRunDt = lastRunDt.addDays(-1);
            //query		= query + ' AND (Quote_Line__r.Lastmodifieddate >: lastRunDt OR Quote_Line__r.Quote__r.Lastmodifieddate >: lastRunDt OR Quote_Line__r.Quote__r.Opportunity.Lastmodifieddate >: lastRunDt)';
        }
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Change_Order_Quote_Line__c> coqlList) 
    {
        delete coqlList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final Quote Line Delete batch');
        ChangeOrderChildOpportunitiesBatch.upsertBatchLastRunTime('ChangeOrderDeleteQuoteLineBatch');
        database.executeBatch(new ChangeOrderDeleteNonCreditTableau(), 10000);    
    }
}