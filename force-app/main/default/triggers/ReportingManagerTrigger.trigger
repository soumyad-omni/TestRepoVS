trigger ReportingManagerTrigger on Reporting_Manager__c (before insert, before update) {
	TriggerDispatcher.run(new ReportingManagerTriggerHandler());
}