global class UpdatePLBatch implements Database.Batchable<sObject>, Database.Stateful{
    Private list<Id> qtId = new list<id>();
    global Database.QueryLocator start(Database.BatchableContext BC){
       
        //list<product2> pd = [SELECT Id FROM Product2 WHERE Segment_Changed__c = true];
        /*list<id> pid = new list<id>();
        for(product2 p: pd){
            pid.add(p.id);
        }*/
        //list<quote_line__c> ql = [select id, quote__c from quote_line__c where Product__c=: pid and Quote__r.Status = 'E0013' and Quote__r.opp_status__c= 'Fully Booked'];
        
        String query = 'SELECT Id,Segment_Changed__c FROM Product2 WHERE Segment_Changed__c = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<product2> pd){
        ///
        system.debug(qtid.size());
        list<id> pid = new list<id>();
        for(product2 p: pd){
            p.Segment_Changed__c = false;
            pid.add(p.id);
        }
        update pd;
        /*AggregateResult[] ql = [select quote__c qtt from quote_line__c where Product__c=: pid and Quote__r.Status = 'E0013' and Quote__r.opp_status__c= 'Fully Booked' group by quote__c];
        list<id> qid=new List<id>();
        
        for(AggregateResult q: [select quote__c qtt from quote_line__c where Product__c=: pid and Quote__r.Status = 'E0013' and Quote__r.opp_status__c= 'Fully Booked' group by quote__c]){
            qid.add((String)q.get('qtt'));
        }*/
        Integer recordCount = [select count() from quote_line__c where Product__c=: pid and Quote__r.Status = 'E0013' and Quote__r.opp_status__c= 'Fully Booked'];
        if(recordCount > 0){
            Integer sizeBlock = recordCount/2000 + (math.mod(recordCount,2000)!=0?1:0) ;
            list<id> qid=new List<id>(); 

            //Iterate aggregate result with blocks of 2000 to avoid exception
            for(Integer i=0;i<sizeBlock;i++){            
                for(AggregateResult q : [select quote__c qtt from quote_line__c where Product__c=: pid 
                                          and Quote__r.Status = 'E0013' and Quote__r.opp_status__c= 'Fully Booked' and id not in :qid 
                                          group by quote__c limit 2000]) {
                    qid.add((String)q.get('qtt'));
                }
            }
        
        Set<id> myset = new Set<id>();
        List<id> result = new List<id>();
        myset.addAll(qid);
        qtid.addAll(myset);
        system.debug(qtid.size());
        /*list<quote> query = [SELECT Id,Primary_Quote__c,Booking_Date__c,OpportunityId,Order_Type__c,Status FROM Quote WHERE id =: result];
        ///
        for(quote q: query){
            qtid.add(q.id);
        }*/
        
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        Set<id> myset = new Set<id>();
        List<id> result = new List<id>();
        myset.addAll(qtid);
        result.addAll(myset);
        system.debug(result.size());
        if(result.size() > 0){
        UpdatePLBatch_quoteProcess s = new UpdatePLBatch_quoteProcess(result);
		DataBase.executeBatch(s,1);
        }
       /* list<product2> pd = [SELECT Id,Segment_Changed__c FROM Product2 WHERE Segment_Changed__c = true];
        for(product2 p: pd){
            p.Segment_Changed__c = false;
        }
        
        update pd;
        
        Run_Product_line_Update__c rpl = [select id,Run_Product_line_Update__c from Run_Product_line_Update__c where name = 'Run Product line Update'];
        if(rpl.Run_Product_line_Update__c == true){
            rpl.Run_Product_line_Update__c = false;
            update rpl;
        }*/
        
    }

}