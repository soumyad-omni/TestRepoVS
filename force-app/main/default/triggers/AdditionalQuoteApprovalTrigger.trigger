/**********************************************************************
Name:  QuoteTrigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Quote Object for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Supriya Ambre                     ?       INITIAL DEVELOPMENT
***********************************************************************/
trigger AdditionalQuoteApprovalTrigger on Additional_Quote_Approval__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerDispatcher.run(new AdditionalQuoteApprovalTriggerHandler());
}