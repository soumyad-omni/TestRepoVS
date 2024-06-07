/**********************************************************************
Name:  AdditionalQuoteApprovalTriggerHandler
Copyright © 2018
======================================================
====================================================== 
Purpose: Handler contains method for AdditionalQuoteApprovalTrigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Venu Kukkapalli           ?          INITIAL DEVELOPMENT 
***********************************************************************/
public class AdditionalQuoteApprovalTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public static Boolean isFirstTime = true;
    public static boolean workflowupdate = false;
    
    public boolean IsDisabled(){     
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('AdditionalQuoteApprovalTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;       
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        
    }
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Additional_Quote_Approval__c> newList = newItems.values();
        List<Additional_Quote_Approval__c> aqStatusList = new List<Additional_Quote_Approval__c>();
        set<Id> setQAPId = new Set<ID>();//SF-Bug-1055
        setQAPId.add(newList[0].Quote_Approval__c);//SF-Bug-1055
        System.debug('********'+newList[0].Quote_Approval__c);
        for(Additional_Quote_Approval__c aq:newList){
            Additional_Quote_Approval__c aqa = (Additional_Quote_Approval__c)oldItems.get(aq.id);
            if(aq.Approval_Status__c!=aqa.Approval_Status__c && !aqStatusList.contains(aq) && aq.Approval_Status__c != 'New' )
                aqStatusList.add(aq);
        }
        if( aqStatusList.size() > 0 ){
            updateQA(aqStatusList, true);
            updateAssignedTo(aqStatusList);
        }
        QuoteApprovalAssignToFuture.AssignToQueue(setQAPId);//SF-Bug-1055
        
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        
    }
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Additional_Quote_Approval__c> newList = newItems.values();
        List<Additional_Quote_Approval__c> aqStatusList = new List<Additional_Quote_Approval__c>();
        
        for(Additional_Quote_Approval__c aq:newList){
            Additional_Quote_Approval__c aqa = (Additional_Quote_Approval__c)oldItems.get(aq.id);
            if(aq.Approval_Status__c!=aqa.Approval_Status__c && !aqStatusList.contains(aq) && aq.Approval_Status__c != 'New' )
                aqStatusList.add(aq);
        }
        if( aqStatusList.size() > 0 ){
            updateQA(aqStatusList, false);
        }
    }
    public static void updateQA(List<Additional_Quote_Approval__c> newList, Boolean beforeEvent){
        List<Id> qaIdList = new List<Id>();
        List<Quote_approval__c> qaUpdateList = new List<Quote_approval__c>();
        Map<Id, Quote_Approval__c> qaMap = new Map<Id,Quote_approval__c>();
        Map<Id, List<ProcessInstanceStep>> pisMap = new Map<Id, List<ProcessInstanceStep>>();
        
        for(ProcessInstanceStep pis : [SELECT Actor.name,Actorid,OriginalActorid,createdDate,StepStatus, comments,ProcessInstance.TargetObjectId FROM ProcessInstanceStep where ProcessInstance.TargetObjectId In:newList Order by CreatedDate desc]){
            if(!pisMap.containskey(pis.ProcessInstance.TargetObjectId))
                pisMap.put(pis.ProcessInstance.TargetObjectId, new List<ProcessInstanceStep>());
            pisMap.get(pis.ProcessInstance.TargetObjectId).add(pis);
        }
        System.debug(pisMap);
        List<Additional_Quote_Approval__c> aqaList1 = new List<Additional_Quote_Approval__c>();
        Boolean checkIdBlank;
        checkIdBlank = FALSE;
        for(Additional_Quote_Approval__c aq:newList){
            if(!qaIdList.contains(aq.Quote_Approval__c))
                qaIdList.add(aq.Quote_Approval__c);
            if(aq.id!=NULL){
                if(aq.LastModifiedById !=NULL){
                    if(aq.Quote_Approval__c!=NULL){
                        aqaList1.add(aq);
                        if(aqaList1.size()>0)
                            checkIdBlank = false;
                    }
                }
            }
        }
        
        //System.debug(qaIdList);
        for(Quote_approval__c qa : [SELECT Id,Additional_Manual_Approval_Notes__c, Recent_Additional_Approver__c,Recent_Additional_Approver_Comments__c, Recent_Additional_Approval_Status__c FROM Quote_Approval__c WHERE Id IN: qaIdList]){
            qaMap.put(qa.id, qa);
        }
        
        List<ProcessInstanceWorkitem> lstPIWI = [SELECT OriginalActor.name,ProcessInstance.TargetObjectid,ActorId,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,Id,OriginalActorId,ProcessInstanceId 
                                                     FROM ProcessInstanceWorkitem where ( ProcessInstance.TargetObjectId in: qaIdList) and ProcessInstance.Status = 'pending'];
        Map<id,List<ProcessInstanceWorkitem>> mapPIWI=new Map<id,List<ProcessInstanceWorkitem>>();
        For(ProcessInstanceWorkitem objPIWI:lstPIWI){
                if(mapPIWI.containsKey(objPIWI.ProcessInstance.TargetObjectid)){
                    List<ProcessInstanceWorkitem> proList=mapPIWI.get(objPIWI.ProcessInstance.TargetObjectId);
                    proList.add(objPIWI);
                    mapPIWI.put(objPIWI.ProcessInstance.TargetObjectId, proList);
                }
                else{
                    mapPIWI.put(objPIWI.ProcessInstance.TargetObjectId, new List<ProcessInstanceWorkitem>{objPIWI});
                }
            }    
        //System.debug(qaMap);
        if(beforeEvent == FALSE){
            for(Additional_Quote_Approval__c aq: newList){
                if(pisMap.containsKey(aq.id) && aq.Approval_Status__c !='Waiting'){
                    Quote_approval__c qat =  qaMap.get(aq.Quote_Approval__c);
                    if(pisMap.get(aq.id)[0].StepStatus == 'Approved' || pisMap.get(aq.id)[0].StepStatus =='Rejected'){
                        if(mapPIWI.get(qat.Id) == null){
                        	if(pisMap.get(aq.id)[0].StepStatus == 'Approved')
                            	qat.status__c='Approved';	
                        }
                        qat.Recent_Additional_Approval_Status__c = pisMap.get(aq.id)[0].StepStatus;
                        qat.Recent_Additional_Approver__c = pisMap.get(aq.id)[0].actorid;
                        qat.Recent_Additional_Approver_Comments__c = pisMap.get(aq.id)[0].comments;
                        qat.Currently_with_Additional_Approver__c = FALSE;
                        if(qat.Additional_Manual_Approval_Notes__c != NULL){
                            if(pisMap.get(aq.id)[0].comments != NULL)
                                qat.Additional_Manual_Approval_Notes__c = qat.Additional_Manual_Approval_Notes__c+'<Html><body><p>'+pisMap.get(aq.id)[0].StepStatus+'  '+pisMap.get(aq.id)[0].createdDate+'  '+pisMap.get(aq.id)[0].actor.name+'  '+pisMap.get(aq.id)[0].comments+'</p><br/></Html></body>';
                            else
                                qat.Additional_Manual_Approval_Notes__c = qat.Additional_Manual_Approval_Notes__c+'<Html><body><p>'+pisMap.get(aq.id)[0].StepStatus+'  '+pisMap.get(aq.id)[0].createdDate+'  '+pisMap.get(aq.id)[0].actor.name+'  '+'</p><br/></Html></body>';
                        }
                        else{
                            if(pisMap.get(aq.id)[0].comments != NULL)
                                qat.Additional_Manual_Approval_Notes__c = '<Html><body><p>'+pisMap.get(aq.id)[0].StepStatus+'  '+pisMap.get(aq.id)[0].createdDate+'  '+pisMap.get(aq.id)[0].actor.name+'  '+pisMap.get(aq.id)[0].comments+'</p><br/></Html></body>';
                            else
                                qat.Additional_Manual_Approval_Notes__c = '<Html><body><p>'+pisMap.get(aq.id)[0].StepStatus+'  '+pisMap.get(aq.id)[0].createdDate+'  '+pisMap.get(aq.id)[0].actor.name+'  '+'</p><br/></Html></body>';
                        }
                        if(!qaUpdateList.contains(qat))
                            qaUpdateList.add(qat);
                    }
                }
                else if(aq.Approval_Status__c =='Waiting'){
                    Boolean checkCon2;
                    checkCon2 =TRUE;
                    Quote_approval__c qat =  qaMap.get(aq.Quote_Approval__c);
                    qat.Status__c = 'Waiting Approval';
                    qat.Recent_Additional_Approval_Status__c = 'Waiting';
                    qat.Currently_with_Additional_Approver__c = TRUE;
                    qat.Recent_Additional_Approver__c = NULL;
                    qat.Recent_Additional_Approver_Comments__c = '';
                    checkCon2 = TRUE;
                    if(!qaUpdateList.contains(qat))
                        qaUpdateList.add(qat);
                    checkCon2 = FALSE;
                }
            }
            try{
                update qaUpdateList;
            }
            catch(Exception e){
                System.debug(e);
            }
        }
        else if(beforeEvent == TRUE){
            Boolean checkCon1;
            checkCon1 =TRUE;
            for(Additional_Quote_Approval__c aq: newList){
                checkCon1 =FALSE;
                if(pisMap.containsKey(aq.id) && aq.Approval_Status__c !='Waiting'){
                    Quote_approval__c qat =  qaMap.get(aq.Quote_Approval__c);
                    if(pisMap.get(aq.id)[0].StepStatus == 'Approved' || pisMap.get(aq.id)[0].StepStatus =='Rejected'){
                        aq.Approval_Date__c = pisMap.get(aq.id)[0].createdDate;
                        aq.Approval_Notes__c = pisMap.get(aq.id)[0].comments;
                        aq.Approved_By__c = pisMap.get(aq.id)[0].actorId;
                    }
                }
            }
        }
    }
    public static void updateAssignedTo(List<Additional_Quote_approval__c> aqaList){
        for(Additional_Quote_Approval__c aqa:aqaList){
            if(aqa.Approval_status__c == 'Approved' || aqa.Approval_status__c == 'Rejected')	
                aqa.Assigned_To__c = '';
        }
    }
}