/**********************************************************************
Name:  RequestforProposalTrigger
======================================================
======================================================
Purpose: Trigger on 'Request for Proposal' Object for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
    AUTHOR                   DATE             Description
 Saptarsha Panthi           08/24/2023           Creation
***********************************************************************/

trigger RequestforProposalTrigger on Request_for_Proposal__c (after delete, after insert, after update, before delete, before insert, before update) {
        TriggerDispatcher.run(new RequestforProposal_TriggerHandler());
}