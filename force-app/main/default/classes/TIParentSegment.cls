/**
*@Description	: This class is responsible for reset Segment in External_Data for new Accounts hierarchy
* 
*@File Name     : TIParentSegment.cls
*@Author        : Pabitra Tripathy
**/
public class TIParentSegment implements Queueable { 
    Set<Id> topChilds;
    Set<Id> oldTopChilds;
    boolean isRunOldParent;
    Set<String> accountIds;//IBA-3677
    boolean runTer;//IBA-3677
    
    public TIParentSegment(Set<Id> topChilds,Set<Id> oldTopChilds,boolean isRunOldParent,boolean runTer,Set<String> accountIds){//IBA-3677
        this.topChilds = topChilds;
        this.oldTopChilds = oldTopChilds;
        this.isRunOldParent =  isRunOldParent;
        this.runTer = runTer;//IBA-3677
        this.accountIds = accountIds;//IBA-3677
        
    }
    
    public void execute(QueueableContext context){
       // System.debug('topChilds '+topChilds.size()+'Ti topChild '+topChilds);
        Set<Id> tiIdSet = new Set<Id>();
        Map<Id,Id> parentAcctIdMap = new Map<Id,Id>(); 
        //delete account's current hierarchy all segment data
        if(topChilds.size()>0){
            List<External_Data__c>  extDataList= [SELECT Id,AccountID__c,Account_Segment__c,Own_Segment__c,isTiSegmentChanged__c FROM  
                                                  External_Data__c WHERE AccountID__c IN :topChilds];
            //  System.debug('Ti extDataList'+extDataList.size());
            for (External_Data__c exData:extDataList){
                exData.isTiSegmentChanged__c = true;
                exData.Account_Segment__c = null;
            }
            if(!extDataList.isEmpty()) {
                ExternalDataTriggerHandler.TriggerDisabled= true; 
                update extDataList;
            }
            TiAccountSegmentUpdateBatch tiAcctUpBatch= new TiAccountSegmentUpdateBatch(topChilds,oldTopChilds,isRunOldParent,runTer,accountIds);//IBA-3677
            Database.executeBatch(tiAcctUpBatch,1);
            
        }else if(runTer == true){//IBA-3677
            AccountTriggerHandler.isTriggerExecuted = true;
            RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
            job.accntIds = accountIds; 
            if(!Test.isRunningTest()){
            System.enqueueJob(job);
            }
        }
    }//
}