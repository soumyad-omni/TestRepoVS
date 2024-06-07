/**********************************************************************
Name:  TargetInitiativeOpp
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Target_Initiative_Opportunity__c Object for after insert event
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Haripriya Maturi         1/31/2019       INITIAL DEVELOPMENT
***********************************************************************/

trigger TargetInitiativeOpp on Target_Initiative_Opportunity__c (before insert, after insert, after delete, before update) {
    TriggerDispatcher.run(new TIOppTriggerHandler());
}