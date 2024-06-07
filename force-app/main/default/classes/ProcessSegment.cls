global class ProcessSegment implements Database.Batchable<sObject> , Database.Stateful{
    
    public set<string> aid = new set<string>();
    public list<Account_Segment_ParentId__c> aspL = new list<Account_Segment_ParentId__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query ='Select id,ParentId__c FROM Account_Segment_ParentId__c' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account_Segment_ParentId__c> aspList){
        set<id> accid = new set<id>();
        for(Account_Segment_ParentId__c asp:aspList){
            accid.add(asp.ParentId__c);
            aspL.add(asp);
        }
        list<account> accTopLvl = [Select id,Top_Level_CaseSafeID__c FROM account where id =:accid];
        for(account a:accTopLvl){
            aid.add(a.Top_Level_CaseSafeID__c);
        }
        delete aspList;
    }
    
    global void finish(Database.BatchableContext bc){
        if(aspL.size() > 0){
            //delete aspL;
            ProcessSegment2 b = new ProcessSegment2(aid);
        	Database.executeBatch(b, 1);
        }
        
    }

}