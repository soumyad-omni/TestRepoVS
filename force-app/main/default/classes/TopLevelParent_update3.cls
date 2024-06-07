global class TopLevelParent_update3 implements Database.Batchable<SObject>, Database.Stateful{
    private list<Id> accounts;
    private map<id,list<account>> parentChildmap;
    private account getdetailA;
    private list<Id> accountids = new list<Id>();
    private Set<Id> topChilds;//IBA-3677
    private Set<Id> oldTopChilds;//IBA-3677
    private boolean isRunOldParent;//IBA-3677
    private Set<String> accountIdsT;//IBA-3677
    private boolean runTer;//IBA-3677
    private boolean runTI;//IBA-3677
    public TopLevelParent_update3(list<Id> accounts, map<id,list<account>> parentChildmap, account getdetailA,Set<Id> topChilds,Set<Id> oldTopChilds,boolean isRunOldParent,boolean runTer,Set<String> accountIdsT,boolean runTI){
        this.accounts = accounts;
        this.parentChildmap = parentChildmap;
        this.getdetailA = getdetailA;
        this.topChilds = topChilds;
        this.oldTopChilds = oldTopChilds;
        this.isRunOldParent = isRunOldParent;
        this.accountIdsT = accountIdsT;
        this.runTer = runTer;
        this.runTI = runTI;
    }
    global Database.queryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select id, Top_level_1__c, Top_level_2__c, Top_Level_Parent_CSN_Number__c from Account where id =:accounts');
    }
    
    global void execute (Database.BatchableContext BC, List<Account> AccountL){
        list<account> accToUpdate = new list<account>();
        for(account aa: accountL){
            list<account> childList = new list<account>();
            
            childList.addall(parentChildmap.get(aa.id));
            for(account a:childList){
                
                a.Top_level_1__c = getdetailA.Top_level_1__c;
                a.Top_level_2__c = getdetailA.Top_level_2__c;
                a.Top_Level_Parent_CSN_Number__c = getdetailA.Top_Level_Parent_CSN_Number__c;
                if(parentChildmap.containsKey(a.id)){
                    accountids.add(a.id);
                }
                accToUpdate.add(a);
            }
        }
        AccountTriggerHandler.TriggerDisabled = true;
        List<Database.SaveResult> results = Database.update(accToUpdate, false);
        updateOppHealthSystemGrouping.updateOpp(accToUpdate); //IBA-4074
    }
    
    global void finish(Database.BatchableContext BC){
        
        //IBA-3937 starts
        Boolean RATRisDisabled; 
        Class_Configuration__c cc = Class_Configuration__c.getInstance('RunAccountTerritoryRules');
        if(cc != null) RATRisDisabled = cc.isDisabled__c;
        //IBA-3937 ends
        
        if(accountids.size() > 0){
            TopLevelParent_update3 updatechild = new TopLevelParent_update3(accountids,parentChildmap,getdetailA,topChilds,oldTopChilds,isRunOldParent,runTer,accountIdsT,runTI);
            Database.executeBatch(updatechild, 1);
        }else{
            /* IBA-3712 if(runTI == true){//IBA-3677
                System.enqueueJob(new TIParentSegment(topChilds,oldTopChilds,isRunOldParent,runTer,accountIdsT));
            }else*/ if(runTer == true && RATRisDisabled == false){ //added RATRisDisabled == false as part of IBA-3937
                AccountTriggerHandler.isTriggerExecuted = true;
                
                    RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
                    job.accntIds = accountIdsT; 
                    if(!Test.isRunningTest()){
                        System.enqueueJob(job);
                    }
                
            }
        }
        
    }

}