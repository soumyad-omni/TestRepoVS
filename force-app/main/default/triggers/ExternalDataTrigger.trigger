/**********************************************************************
Name:  ExternalDataTrigger
======================================================
======================================================
Purpose: Trigger on External_Data__c Object for 'before insert' event
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sahid Hussain             01/03/2022       INITIAL DEVELOPMENT
***********************************************************************/
trigger ExternalDataTrigger on External_Data__c (before insert, before delete, before update, after delete, after undelete, after insert, after update) {
    TriggerDispatcher.run(new ExternalDataTriggerHandler());
}