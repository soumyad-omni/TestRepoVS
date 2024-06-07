@istest
public class AcctSndAllCntctsToCstIrn_mntr_schdl_test {
    public static testMethod void testschedule() {
		Test.StartTest();
		AcctSendAllContactsToCastIron_mntr_schdl testsche = new AcctSendAllContactsToCastIron_mntr_schdl();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}