/*********************************************************************
Name:      DrugCodeTrigger
Purpose:   Trigger on DrugCode__c for various events related to trigger
Copyright © 2023
=======================================================================
History :
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Sourav  Das              5/16/2023         Initial Creation
************************************************************************/

trigger DrugCodeTrigger on DrugCode__c (before insert,before update,after insert,after update, before delete,after delete,after undelete) {
    
    TriggerDispatcher.run(new DrugCodeTriggerHandler());
}