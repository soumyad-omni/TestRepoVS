/**********************************************************************
Name:  ContractTrigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Contract Object to update Assigned To and Status fields from approval process
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL                 Description
0.1       Haripriya Maturi            7/26/2018       INITIAL DEVELOPMENT
***********************************************************************/
trigger ContractsTrigger on Contracts__c (before insert, after insert, before update, after update) {
    TriggerDispatcher.run(new ContractTriggerHandler());
 }