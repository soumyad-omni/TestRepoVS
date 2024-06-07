public class OrderInfoToNetSuiteBatchForQuote implements Database.Batchable<SObject>,Database.Stateful{//IBA-4831
    Set<Id> allQuoteId = new Set<Id>();
    public Database.queryLocator start(Database.BatchableContext bc){
        Set<String> oppRTforNetSuite = new Set<String>();
        List<NetSuite_Opp_RecordType__c> allnetsuiteRecType = NetSuite_Opp_RecordType__c.getall().values();
        for(NetSuite_Opp_RecordType__c rdType: allnetsuiteRecType){
            oppRTforNetSuite.add(rdType.Name);
        }
        Set<String> quoteOrderTypeforNetSuite = new Set<String>();
        List<NetSuite_Quote_Order_Type__c> allnetsuitequoteOrderTypes = NetSuite_Quote_Order_Type__c.getall().values();
        for(NetSuite_Quote_Order_Type__c qtOrdType: allnetsuitequoteOrderTypes){
            quoteOrderTypeforNetSuite.add(qtOrdType.Name);
        }
        
        return Database.getQueryLocator('Select Id from Quote where NetSuite_ID__c = \'\' AND Status = \'E0024\' AND '+
                                        +'Opportunity.OpportunityGroup__c = \'Advanced Services\' '+
                                        +'AND Order_Type__c IN :quoteOrderTypeforNetSuite AND Opportunity.StageName = \'6 Closed Won\' '+
                                        +'AND ECC_Sales_Order_Number__c != \'\''); 
    }
    public void execute (Database.BatchableContext BC, List<Quote> quoteList){
        for(Quote qt :quoteList){
            allQuoteId.add(qt.Id);
        }
    }
    public void finish(Database.BatchableContext BC){
        OrderInfoToNetSuiteBatchForQuoteLine orderQuoteLine = new OrderInfoToNetSuiteBatchForQuoteLine (allQuoteId);
        database.executeBatch(orderQuoteLine);
    }
}