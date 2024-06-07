public class TIParentSegment2 implements Queueable { 
    Set<Id> topChilds;
    Set<Id> oldTopChilds;
    boolean isRunOldParent;
    integer step;
    map<integer,Set<Id>> allHier = new map<integer,Set<Id>>();
    public TIParentSegment2(Set<Id> topChilds,Set<Id> oldTopChilds,boolean isRunOldParent,integer step,map<integer,Set<Id>> allHier){
        this.topChilds = topChilds;
        this.oldTopChilds = oldTopChilds;
        this.isRunOldParent =  isRunOldParent;
        this.step = step;
        this.allHier = allHier;
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
            TiAccountSegmentUpdateBatch2 tiAcctUpBatch= new TiAccountSegmentUpdateBatch2(topChilds,oldTopChilds,isRunOldParent,step,allHier);
            Database.executeBatch(tiAcctUpBatch,1);
            
        }
    }//
}