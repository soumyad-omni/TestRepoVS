/**********************************************************************
Name:  ExternalDataTrigger
======================================================
======================================================
Purpose: Trigger on Quote_Line_Assests__c Object for events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sahid Hussain             04/25/2022       INITIAL DEVELOPMENT
***********************************************************************/
trigger QuoteLineAssetTrigger on Quote_Line_Assests__c (before insert, before delete, before update, after delete, after undelete, after insert, after update) {
    TriggerDispatcher.run(new QuoteLineAssetTriggerHandler());
}