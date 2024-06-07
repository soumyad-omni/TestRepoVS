@isTest
public class ScheduleQuoteApprovalNotification_Test {

    public testmethod static void scheduleQuoteApprovalProcessTriggerNotificationTest(){
    	Test.StartTest();
            ScheduleQuoteApprovalNotification sh1 = new ScheduleQuoteApprovalNotification();
        	String sch = '0 0 23 * * ?'; 
        	system.schedule('Test ScheduleQuoteApprovalProcessTrigger', sch, sh1);
        Test.stopTest();

    }
}