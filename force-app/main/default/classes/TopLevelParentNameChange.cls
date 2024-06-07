global class TopLevelParentNameChange implements Database.Batchable<SObject>, Database.Stateful{
    private map<id,string> actid1;
    public TopLevelParentNameChange(map<id,string> actid1){
        this.actid1 = actid1;
    }
    
    global Database.queryLocator start(Database.BatchableContext bc){
        set<id> aid = actid1.keySet();
        return Database.getQueryLocator('select id,Top_level_1__c,Top_Level_CaseSafeID__c,Top_level_2__c from account where Top_level_1__c =: aid or Top_Level_CaseSafeID__c=: aid');
    }
    
    global void execute (Database.BatchableContext BC, List<Account> allAcchi){
        if(allAcchi.size()>0){
            for(account a:allAcchi){
                string name = '';
                if(actid1.containsKey(a.Top_level_1__c)){
                    name = actid1.get(a.Top_level_1__c);
                }else{
                    name = actid1.get(a.Top_Level_CaseSafeID__c);
                }
                 
                a.Top_level_2__c = name;
            }
            accounttriggerhandler.triggerdisabled = true;
            List<Database.SaveResult> results = Database.update(allAcchi, false);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}