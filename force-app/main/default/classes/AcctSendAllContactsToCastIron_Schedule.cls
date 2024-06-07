/***********************************************************************************************************
Name:  AcctSendAllContactsToCastIron_Schedule
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This is schedule class for batch class - AcctSendAllContactsToCastIron_Batch
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Capgemin Dev Team          12/13/2018                           INITIAL DEVELOPMENT
*************************************************************************************************************/

global class AcctSendAllContactsToCastIron_Schedule implements Schedulable {
	global String jobName;
   global void execute(SchedulableContext ctx) {
		Job_execution__c jobExec = JobMonitor.logJobStart(jobName, Datetime.now());
		AcctSendAllContactsToCastIron_Batch p = new AcctSendAllContactsToCastIron_Batch(jobExec);
        database.executeBatch(p,20);
        system.debug('job done');
		JobMonitor.logMessage(jobExec, 'AcctSendAllContactsToCastIron_Schedule : job done. jobExecid = ' + jobExec.Id, 'l');
   }   
   
    public AcctSendAllContactsToCastIron_Schedule (String name) {
        jobName = name;
    }
    
    public AcctSendAllContactsToCastIron_Schedule () {
        jobName = 'AcctSendAllContactsToCastIron';
    }
}