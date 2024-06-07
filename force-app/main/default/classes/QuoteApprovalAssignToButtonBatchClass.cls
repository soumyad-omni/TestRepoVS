Global class QuoteApprovalAssignToButtonBatchClass implements Database.Batchable<sObject>{
    global static boolean fromBatch = true;   
    global Database.QueryLocator start(Database.BatchableContext BC)
    {    
        return Database.getQueryLocator([SELECT Id, Status__c, Assigned_to__c FROM Quote_Approval__c WHERE Status__c = 'Waiting Approval']);
    }
 
    global void execute(Database.BatchableContext BC, List<Quote_Approval__c> scope)
    { 
        List<ProcessInstance> piList = [SELECT Id,TargetObjectid, Status,(select id,actor.name,originalActor.name from Workitems)
                                        FROM ProcessInstance where TargetObjectId in: scope and Status = 'pending'];
        List<Quote_Approval__c> qapList=new List<Quote_Approval__c>();
        List<Id> idLockList=new List<Id>();
        List<Id> idunLockList=new List<Id>();
        for(Quote_Approval__c qa:scope){
            if(approval.isLocked(qa.Id) && !idlockList.contains(qa.Id)){
                idLockList.add(qa.Id);
            }
        }
        idunlockList=idLockList;
        Approval.Unlock(idLockList);
     
        List<Quote_Approval__c> qaList=new List<Quote_Approval__c>();
        For(Quote_Approval__c qa:scope){
            qa.Assigned_To__c='';
            qaList.add(qa);
        }
        try{
            Database.update(qaList);    
        }
        catch(Exception e){
            System.debug(e);
        }
        Map<id,List<ProcessInstance>> qaPIMap=new Map<id,List<ProcessInstance>>();
        For(ProcessInstance pi:pilIst){
            if(qaPIMap.containsKey(pi.TargetObjectid)){
                List<ProcessInstance> proList=qaPIMap.get(pi.TargetObjectId);
                proList.add(pi);
                qaPIMap.put(pi.TargetObjectId, proList);
            }
            else{
                qaPIMap.put(pi.TargetObjectId, new List<ProcessInstance>{pi});
            }
        }
        for(Quote_Approval__c qa:scope){
            if(qaPIMap.containsKey(qa.Id) && qaPIMap.get(qa.Id).size() > 0){
                for(ProcessInstance pi:qaPIMap.get(qa.Id)){
                    for(ProcessInstanceWorkitem wi:pi.workitems){
                        qa.assigned_to__c = qa.assigned_to__c!=NULL ? wi.OriginalActor.name+', '+qa.assigned_to__c :  wi.OriginalActor.name;
                    }
                }
            }
            else{                qa.assigned_to__c='';            }
            qapList.add(qa);
        }
        try{
            Integer count = 0;
            Database.SaveResult[] failedList = Database.update(qapList,false);
            for(Database.SaveResult sr: failedList){
                if(sr.isSuccess()){
                    count++;
                }
                else
                	System.debug('Failed with this error*********'+sr.getErrors());
            }
            System.debug('Success Count-------------------'+count);
            Approval.Lock(idunlockList);
        }
        catch(Exception e){
            System.debug(e);
        }
    }  
    global void finish(Database.BatchableContext BC)
    {
        
    }
}