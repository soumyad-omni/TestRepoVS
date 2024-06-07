global class UpdateProdLineBatch implements Database.Batchable<sObject> {
	private Set<Id> quoteIdSet;
    public UpdateProdLineBatch(Set<Id> qtId){
        quoteIdSet = qtId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	String query = 'SELECT Id,Primary_Quote__c,Status,OpportunityId FROM Quote WHERE id IN :quoteIdSet';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<quote> quoteList){
        List<Quote> oldQuoteList = new List<Quote>();
        ProductLineTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        
        ProdLineSegBSegForPriQuote_Class obj = new ProdLineSegBSegForPriQuote_Class();
       // ProdLineSegBSegForPriQuote_Class.isQuoteUpdated=true;
        obj.initiateProductUpdates(quoteList,oldQuoteList);
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}