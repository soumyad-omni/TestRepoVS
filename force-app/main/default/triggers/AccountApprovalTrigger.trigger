trigger AccountApprovalTrigger on Account_Approval__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
  TriggerDispatcher.run(new AccountApprovalTriggerHandler());
}