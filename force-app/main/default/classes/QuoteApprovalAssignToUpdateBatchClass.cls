Global class QuoteApprovalAssignToUpdateBatchClass implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {    
        BatchRunInterval__c runIntervalSetting = BatchRunInterval__c.getInstance('QuoteApprovalAssignToUpdateBatchClass');
        Decimal howFar = runIntervalSetting!=null ? runIntervalSetting.HowFarBackMinutes__c:-59; //default to 59 minutes
        Datetime hourBack = Datetime.now().addMinutes(howFar.intValue());
        //Below Query modified by Venu Kukkapalli as part of Additional Quote Approval
        return Database.getQueryLocator([SELECT Id, Status__c, Assigned_to__c,Deal_Desk_Started__c,(SELECT Id,Approval_Status__c, Assigned_To__c FROM  Additional_Quote_Approval__r WHERE Approval_Status__c = 'Waiting') FROM Quote_Approval__c WHERE Status__c = 'Waiting Approval'  AND LastModifiedDate >=: hourBack ORDER BY LastModifiedDate Desc]);
    }
 
    global void execute(Database.BatchableContext BC, List<Quote_Approval__c> scope)
    { 
        System.debug('inside batch class : '+scope[0].Assigned_to__c+' '+scope); 
        try {
            //Added by Venu Kukkapalli as part of Additional Quote Approval
            List<Additional_Quote_Approval__c> aqaList = [SELECT Id,Approval_Status__c, Assigned_To__c,Quote_Approval__c FROM  Additional_Quote_Approval__c WHERE Approval_Status__c = 'Waiting' AND Quote_Approval__c IN: scope];
            Map<Id,List<Additional_Quote_Approval__c>> aqaMap = new Map<Id, List<Additional_Quote_Approval__c>>();
            if(aqaList.size()>0){
                for(Additional_Quote_Approval__c aq : aqaList){
                    if(!aqaMap.containsKey(aq.quote_approval__c))
                        aqaMap.put(aq.quote_approval__c, new List<Additional_Quote_Approval__c>());
                    aqaMap.get(aq.quote_approval__c).add(aq);
                }
            }
            System.debug('aqaMap : '+aqaMap);
            //Modified below query by Venu Kukkapalli as part of Additional Quote Approval
            List<ProcessInstance> piList = [SELECT Id,TargetObjectid, Status,(select id,actor.name,originalActor.name from Workitems)
                                            FROM ProcessInstance where ( TargetObjectId in: scope OR TargetObjectId in: aqaList ) and Status = 'pending'];
            
            System.debug('piList : '+piList);
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
                System.debug('assigned to before : '+qa.assigned_to__c);
               // qa.Assigned_To__c='';
               // qa.Deal_Desk_Started__c = System.now();
                if(!qaList.contains(qa))
                    qaList.add(qa);
                System.debug('assigned to after : '+qa.assigned_to__c);
            }
            try{
                QuoteApprovalTriggerHandler.isbatchupdate = true;
                System.debug('qalist : '+qaList);
                Database.update(qaList,false);    
            }
            catch(Exception e){
                /*
                * Anil 4/25 - commented this code and added new code to send errors to Error Log
                *
                */
                //System.debug(e);
                System.debug('Exception : '+ e.getMessage() +' Line no. : '+ e.getLineNumber());
                ErrorLogging.IntegrationLog( 'Exception: ' + e.getTypeName() + ': ' + e.getMessage()    + ' -- ' + e.getStackTraceString(), 'QuoteApprovalAssignToUpdateBatchClass','App');
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
            //Added by Praneeth for sf bug 263
            System.debug('qaPIMap : '+qaPIMap);
            List<Id> originalactorids = new List<Id>();//Added by sravan
            
            List<ProcessInstanceWorkitem> lstPIWI = [SELECT OriginalActor.name,ProcessInstance.TargetObjectid,ActorId,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,Id,OriginalActorId,ProcessInstanceId 
                                                     FROM ProcessInstanceWorkitem where ( ProcessInstance.TargetObjectId in: scope OR ProcessInstance.TargetObjectId in: aqaList ) and ProcessInstance.Status = 'pending'];
            System.debug('lstPIWI : '+lstPIWI+' ACTOR NAME : '+lstPIWI[0].OriginalActor.name);
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
                originalactorids.add(objPIWI.OriginalActorId);
            }
            System.debug('mapPIWI : '+mapPIWI);
            // Added by Venu Kukkapalli as part of additional quote approval assigned to field update. Line - 68
            List<Additional_Quote_approval__c> aqaUpdateList = new List<Additional_Quote_approval__c>();
            
            //////////Added by Sravan on 29 July////////////
            Map<Id,String> groups = new map<Id,String>();
            List<Group> grps = [select id,name from Group where id=:originalactorids];
            for(Group g:grps){
                groups.put(g.id,g.name);
            }
            if(groups==null)
            {
            List<User> usrs = [select id,name from User where id=:originalactorids];
            for(User g:usrs){
                groups.put(g.id,g.name);
            }
            }
            system.debug('groups : '+groups);
            //////////Added by Sravan on 29 July////////////
            
            //Modified by Praneeth for sf bug 263
            for(Quote_Approval__c qa:scope){
                qa.assigned_to__c='';
                //if(qaPIMap.containsKey(qa.Id) && qaPIMap.get(qa.Id).size() > 0){
                    //for(ProcessInstance pi:qaPIMap.get(qa.Id)){
                if(mapPIWI.get(qa.id) != null){//Modified by Sravan for sf bug 263
                        for(ProcessInstanceWorkitem wi:mapPIWI.get(qa.id)){
                            //Group g = [select Id,Name from Group  where id=:wi.OriginalActorId];
                            //Modified by Sravan for sf bug 263////
                            system.debug('ORIG : '+groups.get(wi.OriginalActorId));
                            String actorname='';
                            if(groups.get(wi.OriginalActorId) != null)
                                actorname = groups.get(wi.OriginalActorId);
                            else
                                actorname = '';
                            //Modified by Sravan for sf bug 263////
                            system.debug('TESTTEST : '+qa.assigned_to__c+'ACTOR'+actorname);
                            if(qa.assigned_to__c!=''){
                                //qa.assigned_to__c = wi.OriginalActor.name+', '+qa.assigned_to__c;
                                qa.assigned_to__c = actorname+', '+qa.assigned_to__c;
                            }
                            else{
                                //qa.Assigned_To__c = wi.OriginalActor.name;
                                qa.Assigned_To__c = actorname;
                            }
                            System.debug('assigned to loop : '+qa.assigned_to__c);
                        }
                }
                    //}
                //}
                //else{
                //    qa.assigned_to__c='';
                //}
                //Added by Venu Kukkapalli as part of Additional Quote Approval
                //if(aqaMap.containsKey(qa.id)){
                if(aqaMap.size()>0 && aqaMap.get(qa.Id)!=null){
                    for(Additional_Quote_approval__c aq : aqaMap.get(qa.Id)){
                        //if(qaPIMap.containsKey(aq.Id) && qaPIMap.get(aq.Id).size() > 0){
                            //for(ProcessInstance pi:qaPIMap.get(aq.Id)){
                                for(ProcessInstanceWorkitem wi : mapPIWI.get(aq.id)){  
                                    if(qa.assigned_to__c!=NULL)
                                        qa.assigned_to__c = wi.OriginalActor.name+', '+qa.assigned_to__c;
                                    else
                                        qa.Assigned_To__c = wi.OriginalActor.name;
                                    // Added by Venu Kukkapalli as part of additional quote approval assigned to field update. Lines 94-96
                                    if(!aqaUpdateList.contains(aq)){
                                        aq.Assigned_To__c = wi.OriginalActor.name;
                                        aqaUpdateList.add(aq);
                                        system.debug('aqaUpdateList: '+aqaUpdateList);
                                    }
                                }
                            //}
                        //}
                    }
                }
                //}
                //
                if(!qapList.contains(qa))
                    qapList.add(qa);
            }
        /*    
            for(Quote_Approval__c qa:scope){
                if(qaPIMap.containsKey(qa.Id) && qaPIMap.get(qa.Id).size() > 0){
                    for(ProcessInstance pi:qaPIMap.get(qa.Id)){
                        for(ProcessInstanceWorkitem wi:pi.workitems){  
                            if(qa.assigned_to__c!=NULL)
                                qa.assigned_to__c = wi.OriginalActor.name+', '+qa.assigned_to__c;
                            else
                                qa.Assigned_To__c = wi.OriginalActor.name;
                        }
                    }
                }
                else{
                    qa.assigned_to__c='';
                }
                //Added by Venu Kukkapalli as part of Additional Quote Approval
                if(aqaMap.containsKey(qa.id)){
                    for(Additional_Quote_approval__c aq : aqaMap.get(qa.Id)){
                        if(qaPIMap.containsKey(aq.Id) && qaPIMap.get(aq.Id).size() > 0){
                            for(ProcessInstance pi:qaPIMap.get(aq.Id)){
                                for(ProcessInstanceWorkitem wi:pi.workitems){  
                                    if(qa.assigned_to__c!=NULL)
                                        qa.assigned_to__c = wi.OriginalActor.name+', '+qa.assigned_to__c;
                                    else
                                        qa.Assigned_To__c = wi.OriginalActor.name;
                                    // Added by Venu Kukkapalli as part of additional quote approval assigned to field update. Lines 94-96
                                    if(!aqaUpdateList.contains(aq)){
                                        aq.Assigned_To__c = wi.OriginalActor.name;
                                        aqaUpdateList.add(aq);
                                    }
                                }
                            }
                        }
                    }
                }
                //
                if(!qapList.contains(qa))
                    qapList.add(qa);
            }*/
            try{
                QuoteApprovalTriggerHandler.isbatchupdate = true;
                Database.update(qapList,false);
                //Approval.Lock(idunlockList);
                if(aqaUpdateList.size()>0)
                    Database.update(aqaUpdateList,false);
            }
            catch(Exception e){
                /*
                * Anil 4/25 - commented this code and added new code to send errors to Error Log
                *
                */
                //System.debug(e);
                System.debug('Exception : '+ e.getMessage() +' Line no. : '+ e.getLineNumber());
                ErrorLogging.IntegrationLog( 'Exception: ' + e.getTypeName() + ': ' + e.getMessage()    + ' -- ' + e.getStackTraceString(), 'QuoteApprovalAssignToUpdateBatchClass','App');
            }
        } catch(Exception e) {
            /*
            * Anil 4/25 - commented this code and added new code to send errors to Error Log
            *
            */
            //System.debug(e);
            System.debug('Exception : '+ e.getMessage() +' Line no. : '+ e.getLineNumber());
            ErrorLogging.IntegrationLog( 'Exception: ' + e.getTypeName() + ': ' + e.getMessage()    + ' -- ' + e.getStackTraceString(), 'QuoteApprovalAssignToUpdateBatchClass','App');
        }
    }  
    global void finish(Database.BatchableContext BC)
    {
        BatchRunInterval__c runIntervalSetting = BatchRunInterval__c.getInstance('QuoteApprovalAssignToUpdateBatchClass');
        Decimal runInterval = runIntervalSetting!=null ? runIntervalSetting.Run_Interval__c:20; //default to 20 minutes
        DateTime sysTime = DateTime.now().addMinutes(runInterval.intValue());
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        QuoteApprovalAssignToBatchScheduleUpdate qaub = new QuoteApprovalAssignToBatchScheduleUpdate();
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('QuoteApprovalAssignToUpdateBatchClass' + sysTime.getTime(),chron_exp,qaub);
    }
}