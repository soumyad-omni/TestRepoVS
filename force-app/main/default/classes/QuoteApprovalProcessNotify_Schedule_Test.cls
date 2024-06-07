@isTest
public class QuoteApprovalProcessNotify_Schedule_Test {

    public static testMethod void testschedule() {
        
        Test.StartTest();
        QuoteApprovalProcessNotify_Schedule sch1 = new QuoteApprovalProcessNotify_Schedule();
        
        String sch = '0 0 1 * * ?'; system.schedule('Test QuoteApprovalProcessNotify_Schedule Batch', sch, sch1);
        Test.stopTest(); 
    }
}