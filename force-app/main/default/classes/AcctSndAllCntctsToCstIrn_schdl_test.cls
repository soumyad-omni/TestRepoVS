@istest
public class AcctSndAllCntctsToCstIrn_schdl_test {
    public static testMethod void testschedule() {
		Test.StartTest();
        Job_list__c jl = JobMonitor_testDataFactory.getJobList('xyz');
		AcctSendAllContactsToCastIron_Schedule testsche = new AcctSendAllContactsToCastIron_Schedule(jl.Name);
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}