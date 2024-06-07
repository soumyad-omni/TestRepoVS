public class TopLevelParent_update2 implements Queueable{

    public static boolean UpdateChildDisabled= false;
    public list<account> accounts;
    public set<string> paccounts;
    //public list<id> newPid;
    public Set<Id> topChilds;//IBA-3677
    public Set<Id> oldTopChilds;//IBA-3677
    public boolean isRunOldParent;//IBA-3677
    public Set<String> accountIdsT;//IBA-3677
    public boolean runTer;//IBA-3677
    public boolean runTI;//IBA-3677
    public void execute(QueueableContext context) {
        
        //IBA-3937 starts
        Boolean RATRisDisabled; 
        Class_Configuration__c cc = Class_Configuration__c.getInstance('RunAccountTerritoryRules');
        if(cc != null) RATRisDisabled = cc.isDisabled__c;
        //IBA-3937 ends
        
        if(!UpdateChildDisabled){
            system.debug(paccounts);
                list<account> checkParent = [select id,ParentId,Top_level_1__c,Top_level_2__c from account where Top_level_1__c =: paccounts or Top_Level_CaseSafeID__c=: paccounts];
                map<id,list<account>> parentChildmap = new map<id,list<account>>();
                //map<id,id> parentMap = new map<id,id>();
                list<id> parentDetailsId = new list<id>();
                for(account a:checkParent){
                    if(a.ParentId != null){
                        //parentMap.put(a.id,a.ParentId);
                        parentDetailsId.add(a.ParentId);
                        if(parentChildmap.containsKey(a.ParentId)){
                            List<account> proList=parentChildmap.get(a.ParentId);
                            proList.add(a);
                            parentChildmap.put(a.ParentId, proList);
                        }
                        else{
                            parentChildmap.put(a.ParentId, new List<account>{a});
                        }
                    }
                }
            
                map<id,account> parentDetails = new map<id,account>([select id,Top_level_1__c,Top_level_2__c,Top_Level_Parent_CSN_Number__c from account where id =:parentDetailsId]);
                //list<Account_History__c> aHistList = new list<Account_History__c>();
            for(account acc:accounts){
                    /*Account_History__c accHistory = new Account_History__c() ;
                    accHistory.Account__c = acc.id;                    
                    accHistory.ORIGINAL_VALUE__c = acc.Top_level_2__c;
                    accHistory.User__c = UserInfo.getUserId();*/
                    if(acc.ParentId != null){
                        if(parentChildmap.containsKey(acc.id)){ //have parent and child
                            account getdetailA = parentDetails.get(acc.ParentId);
                            acc.Top_level_1__c = getdetailA.Top_level_1__c;
                            acc.Top_level_2__c = getdetailA.Top_level_2__c;
                            acc.Top_Level_Parent_CSN_Number__c = getdetailA.Top_Level_Parent_CSN_Number__c;
                            
                            list<Id> accountids = new list<Id>();
                            accountids.add(acc.id);
                            TopLevelParent_update3 updatechild = new TopLevelParent_update3(accountids,parentChildmap,getdetailA,topChilds,oldTopChilds,isRunOldParent,runTer,accountIdsT,runTI);
                            Database.executeBatch(updatechild, 1);
                        }else{ //have parent but no child
                            account getdetailA = parentDetails.get(acc.ParentId);
                            if(getdetailA != null){
                                acc.Top_level_1__c = getdetailA.Top_level_1__c;
                                acc.Top_level_2__c = getdetailA.Top_level_2__c;
                                acc.Top_Level_Parent_CSN_Number__c = getdetailA.Top_Level_Parent_CSN_Number__c;
                                /* IBA-3712if(runTI == true){//IBA-3677                                
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
                    }else{
                        if(parentChildmap.containsKey(acc.id)){ //do not have parent but has child
                            acc.Top_level_1__c = acc.Id;
                            acc.Top_level_2__c = acc.Name;
                            acc.Top_Level_Parent_CSN_Number__c = acc.SAP_Customer_Number__c;
                            
                            list<Id> accountids = new list<Id>();
                            accountids.add(acc.id);
                            TopLevelParent_update3 updatechild = new TopLevelParent_update3(accountids,parentChildmap,acc,topChilds,oldTopChilds,isRunOldParent,runTer,accountIdsT,runTI);
                            Database.executeBatch(updatechild, 1);
                        }else{ //do not have parent and child
                            acc.Top_level_1__c = acc.Id;
                            acc.Top_level_2__c = acc.Name;
                            acc.Top_Level_Parent_CSN_Number__c = acc.SAP_Customer_Number__c;
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
                    /*accHistory.NEW_VALUE__c = acc.Top_level_2__c;
                    accHistory.Field__c = 'Top Level Parent Text Name';
                    aHistList.add(accHistory);*/
                    
                }
            AccountTriggerHandler.TriggerDisabled = true;
            List<Database.SaveResult> results = Database.update(accounts, false);
            updateOppHealthSystemGrouping.updateOpp(accounts); //IBA-4074
        }
        
    }
}