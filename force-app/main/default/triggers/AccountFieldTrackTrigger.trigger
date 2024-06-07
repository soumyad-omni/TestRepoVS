trigger AccountFieldTrackTrigger on Account_History__c (before insert) {
	AccountFieldTrackTriggerHandler.handleBeforeinsert(Trigger.new);
}