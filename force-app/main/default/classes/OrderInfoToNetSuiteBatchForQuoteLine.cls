public class OrderInfoToNetSuiteBatchForQuoteLine implements Database.Batchable<SObject>,Database.Stateful,Database.AllowsCallouts{//IBA-4831
    public Set<Id> allQuoteId;
    public OrderInfoToNetSuiteBatchForQuoteLine(Set<Id> allQuoteId){
        this.allQuoteId = allQuoteId;
    }
    public Database.queryLocator start(Database.BatchableContext bc){
        Set<String> oppRTforNetSuite = new Set<String>();//IBA-4831 Start
        List<NetSuite_Opp_RecordType__c> allnetsuiteRecType = NetSuite_Opp_RecordType__c.getall().values();
        for(NetSuite_Opp_RecordType__c rdType: allnetsuiteRecType){
            oppRTforNetSuite.add(rdType.Name);
        }
        Set<String> quoteOrderTypeforNetSuite = new Set<String>();
        List<NetSuite_Quote_Order_Type__c> allnetsuitequoteOrderTypes = NetSuite_Quote_Order_Type__c.getall().values();
        for(NetSuite_Quote_Order_Type__c qtOrdType: allnetsuitequoteOrderTypes){
            quoteOrderTypeforNetSuite.add(qtOrdType.Name);
        }
        return Database.getQueryLocator('Select Id,Quote__c from Quote_line__c where NetSuite_Line_ID__c = \'\' AND Quote__r.Status = \'E0024\' AND '+
                                        +'Quote__r.Opportunity.OpportunityGroup__c = \'Advanced Services\' '+
                                        +'AND Quote__r.Order_Type__c IN :quoteOrderTypeforNetSuite AND Quote__r.Opportunity.StageName = \'6 Closed Won\' '+
                                        +'AND Quote__r.ECC_Sales_Order_Number__c != \'\' '); 
    }
    public void execute (Database.BatchableContext BC, List<Quote_Line__c> quoteLineList){
        for(Quote_Line__c qtLine :quoteLineList){
            if(!allQuoteId.contains(qtLine.Quote__c)){
                allQuoteId.add(qtLine.Quote__c);
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        System.debug(allQuoteId);
        if(allQuoteId.size()>0){
            system.enqueueJob(new OrderInfoSendToNetSuiteQueueable(allQuoteId));
        }
    }
}