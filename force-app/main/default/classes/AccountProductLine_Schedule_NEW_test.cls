@istest
public class AccountProductLine_Schedule_NEW_test {
    
    public static testMethod void testschedule() {
		Test.StartTest();
        Job_list__c jl = JobMonitor_testDataFactory.getJobList('xyz');
		AccountProductLine_Schedule_NEW testsche = new AccountProductLine_Schedule_NEW(jl.Name);
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}