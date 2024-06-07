/**********************************************************************
Name:  AvoidDuplicateAccounts
Copyright © 2018
======================================================================
======================================================================
Purpose: Trigger on Target_Initiative_Account__c for various events related to trigger
-------                                                             
=======================================================================
=======================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1        Hari Priya                       ?       INITIAL DEVELOPMENT
***********************************************************************/
trigger AvoidDuplicateAccounts on Target_Initiative_Account__c (before insert, before update,after insert, after update, after delete, after undelete) {
  
   if(Trigger.isBefore & Trigger.isInsert){
       TargetInitiativeTriggerHandler process = new TargetInitiativeTriggerHandler ();
       process.beforeInsert(Trigger.new, Trigger.old);
   }
    if(Trigger.isBefore && Trigger.isUpdate){
       TargetInitiativeTriggerHandler process = new TargetInitiativeTriggerHandler ();
       process.beforeUpdate(Trigger.new, Trigger.old);
   }
  
   if(Trigger.isAfter)
   {
       if(Trigger.isInsert) {
            TargetInitiativeTriggerHandler process = new TargetInitiativeTriggerHandler ();//IBA-1748 Pabitra
            process.afterInsert(Trigger.new, Trigger.old);//IBA-1748 Pabitra
           TargetInitiativeTriggerHandler.createTargetInitiativesAuditRecords(Trigger.NEW);
           //SF-BUG-519 Changes Start
          /* if (!trigger.newMap.keySet().isEmpty()) {
                UpdateAccount_OnTop200.updateAccount_OnAfterInsert(trigger.newMap);              
           }*/
          
           //SF-BUG-519 Changes End
           //UpdateAccount_OnTop200.updateAccount_OnAfterInsert(trigger.newMap);
           //System.debug('UpdateAccount_OnTop200::trigger.newMap.Size ' + trigger.newMap.size());
       }
       else if(Trigger.isDelete) {
           TargetInitiativeTriggerHandler.createTargetInitiativesAuditRecords(Trigger.OLD);
          // UpdateAccount_OnTop200.updateAccount_OnAfterUnDelete(trigger.oldMap); //IBA-2820

           TargetInitiativeTriggerHandler process = new TargetInitiativeTriggerHandler ();
           process.afterDelete(Trigger.old);    
           //System.debug('UpdateAccount_OnTop200::trigger.oldMap.Size ' + trigger.oldMap.size());
       }
       else if(Trigger.isUndelete) {
           TargetInitiativeTriggerHandler.createTargetInitiativesAuditRecords(Trigger.NEW);
           //UpdateAccount_OnTop200.updateAccount_OnAfterUnDelete(trigger.newMap);
           //System.debug('UpdateAccount_OnTop200::trigger.newMap.Size ' + trigger.newMap.size());
       }
   }
}