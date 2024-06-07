global class UpdatePLBatch_quoteProcess implements Database.Batchable<sObject>{
    
    Private list<Id> qId;
    
    public UpdatePLBatch_quoteProcess(list<Id> quoteid){
        qId=quoteid;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
       
        //list<product2> pd = [SELECT Id FROM Product2 WHERE Segment_Changed__c = true];
        /*list<id> pid = new list<id>();
        for(product2 p: pd){
            pid.add(p.id);
        }*/
        //list<quote_line__c> ql = [select id, quote__c from quote_line__c where Product__c=: pid and Quote__r.Status = 'E0013' and Quote__r.opp_status__c= 'Fully Booked'];
        
        String query = 'SELECT Id,Primary_Quote__c,Status,OpportunityId FROM Quote WHERE id =: qid';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<quote> qt){
 
        ProdLineSegBSegForPriQuote_Class obj = new ProdLineSegBSegForPriQuote_Class();
        obj.initiateProductUpdates(qt,qt);
                
    }
    
    global void finish(Database.BatchableContext BC){
        
        
       /*list<product2> pd = [SELECT Id,Segment_Changed__c FROM Product2 WHERE Segment_Changed__c = true];
        for(product2 p: pd){
            p.Segment_Changed__c = false;
        }
        
        update pd;*/
        
        Run_Product_line_Update__c rpl = [select id,Run_Product_line_Update__c from Run_Product_line_Update__c where name = 'Run Product line Update'];
        if(rpl.Run_Product_line_Update__c == true){
            rpl.Run_Product_line_Update__c = false;
            update rpl;
        }
        
    }

}