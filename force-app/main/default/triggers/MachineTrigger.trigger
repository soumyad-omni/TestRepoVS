/*********************************************************************
Name:      MachineTrigger
Purpose:   Trigger on Machine__c for various events related to trigger
Copyright © 2023
=======================================================================
History :
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Sourav  Das              5/16/2023         Initial Creation
************************************************************************/
trigger MachineTrigger on Machine__c (before insert,before update,after insert,after update, before delete,after delete,after undelete) {
    
    TriggerDispatcher.run(new MachineTriggerHandler());
    
}