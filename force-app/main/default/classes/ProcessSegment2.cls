global class ProcessSegment2 implements Database.Batchable<sObject> , Database.Stateful{
    Set<string> aid;
    map<integer,Set<Id>> allHier = new map<integer,Set<Id>>();
    integer step=0;
    public ProcessSegment2(Set<string> aid1 ){        
        this.aid = aid1;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query ='Select id,Top_Level_CaseSafeID__c FROM account where id =:aid' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<account> aList){
        set<id> accid = new set<id>();
        for(account a:aList){ //batch size is 1 so only one soql will run at a time
            map<id,account> amap=new map<id,account>([select Id,name,SAP_Customer_number__c from Account where Top_Level_CaseSafeID__c =: a.Top_Level_CaseSafeID__c]);
            accid = amap.keySet();
        }
        
		Set<string> accountIds = new Set<string>();
        allHier.put(step,accid);
        step=step+1;
        /*System.enqueueJob(new TIParentSegment(accid,oldTopChilds,false,false,accountIds));
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 9000) {
            //sleep for 9s
            finishTime = DateTime.now().getTime();
        }
        System.debug('>>> Done from ' + startTime + ' to ' + finishTime);*/
    }
    
    global void finish(Database.BatchableContext bc){
        Set<Id> oldTopChilds;
        step=0;
        system.debug(' '+allHier);
        System.enqueueJob(new TIParentSegment2(allHier.get(0),oldTopChilds,false,step,allHier));
    }

}