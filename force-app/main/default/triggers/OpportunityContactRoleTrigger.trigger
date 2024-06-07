trigger OpportunityContactRoleTrigger on OpportunityContactRole (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	TriggerDispatcher.run(new OpportunityContactRoleTriggerHandler());
}