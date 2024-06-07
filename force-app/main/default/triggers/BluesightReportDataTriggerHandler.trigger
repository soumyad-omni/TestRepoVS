trigger BluesightReportDataTriggerHandler on Bluesight_Report_Data__c(before insert, before delete, before update, after delete, after undelete, after insert, after update) {
TriggerDispatcher.run(new BluesightReportDataTriggerHandler());
}