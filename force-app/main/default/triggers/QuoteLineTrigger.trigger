/**********************************************************************
Name:  QuoteLineTrigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Quote_Line__c Object for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Amruta Dhumal                    ?       INITIAL DEVELOPMENT
***********************************************************************/
trigger QuoteLineTrigger on Quote_Line__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerDispatcher.run(new QuoteLineTriggerHandler());
}