/* 
* Batch Class to get non primary quotes
*/ 
global class ChangeOrderNonPrimaryQuoteBatch implements Database.Batchable<sObject>, Database.Stateful {
    public List<String> nonPrimaryQuoteNumbers = new List<String>();
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        Datetime lastRunDt = ChangeOrderChildOpportunitiesBatch.getBatchLastRunTime('ChangeOrderNonPrimaryQuoteBatch');
        
        //getting list of all Change_Order_Quote_Line__c
        String query 	= 'SELECT id, SAP_Quote_Number_Truncated__c FROM Quote WHERE Primary_Quote__c = FALSE';
        
        if(lastRunDt <> NULL)
        {
            lastRunDt = lastRunDt.addDays(-1);
            query		= query + ' AND (Lastmodifieddate >: lastRunDt OR Opportunity.Lastmodifieddate >: lastRunDt)';
        }
        
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote> qtList) 
    {
        for(Quote qt : qtList)
        {
            if(qt.SAP_Quote_Number_Truncated__c <> NULL)
            {
                nonPrimaryQuoteNumbers.add(qt.SAP_Quote_Number_Truncated__c);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('inside final Quote Line Delete batch');
        ChangeOrderChildOpportunitiesBatch.upsertBatchLastRunTime('ChangeOrderNonPrimaryQuoteBatch');
        database.executebatch(new ChangeOrderDeleteQuoteLineBatch(nonPrimaryQuoteNumbers),2000);
    }
}