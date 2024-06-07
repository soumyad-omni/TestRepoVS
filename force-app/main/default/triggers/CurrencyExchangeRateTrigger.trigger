trigger CurrencyExchangeRateTrigger on Currency_Exchange_Rate__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerDispatcher.run(new CurrencyExchangeRateTriggerHandler());
}