trigger AttachmentTrigger on Attachment (before insert, after insert) {
	TriggerDispatcher.run(new AttachmentTriggerHandler());
}