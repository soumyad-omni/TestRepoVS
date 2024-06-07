trigger ContactWhereUsedTrigger on ContactWhereUsed__c (after insert) {
    if (trigger.isAfter){
        ContactWhereUsedTriggerHandler.afterInsert(Trigger.new);
    }
	
}