global class AccountProductLine_Schedule_NEW implements Schedulable {
    global String jobName;
    global void execute(SchedulableContext ctx) {
		Job_execution__c jobExec = JobMonitor.logJobStart(jobName, Datetime.now());
        AccountProductLine_Batch_NEW p = new AccountProductLine_Batch_NEW(jobExec);
        database.executeBatch(p);
        system.debug('job done');
	//	JobMonitor.logMessage(jobExec, 'AccountProductLine_Schedule_NEW : job done. jobExecid = ' + jobExec.Id, 'w');
	//	
   } 
    
    public AccountProductLine_Schedule_NEW (String name) {
        jobName = name;
    }
    
    public AccountProductLine_Schedule_NEW () {
        jobName = 'AccountProductLine';
    }
}