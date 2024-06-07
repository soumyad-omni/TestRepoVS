/**********************************************************************
Name:  TargetInitiative
======================================================
======================================================
Purpose: Trigger on Target_Initiative__c Object for after delete, after insert, after undelete, after update, before delete, before insert, before update event
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sahid Hussain             8/17/2019       INITIAL DEVELOPMENT
***********************************************************************/
trigger TargetInitiative on Target_Initiative__c (before insert, before delete, before update, after delete, after undelete, after insert, after update) {
	TriggerDispatcher.run(new TITriggerHandler());
}