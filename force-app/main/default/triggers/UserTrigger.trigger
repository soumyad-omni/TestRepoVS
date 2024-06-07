trigger UserTrigger on User (after insert, after update, before insert, before update) 
{
        TriggerDispatcher.run(new UserTriggerHandler());
}