@istest
public class AccountProductLine_Batch_mntr_schdl_test {
    public static testMethod void testschedule() {
		Test.StartTest();
		AccountProductLine_Batch_mntr_schdl testsche = new AccountProductLine_Batch_mntr_schdl();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}