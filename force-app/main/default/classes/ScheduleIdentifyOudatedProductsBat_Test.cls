@isTest
public class ScheduleIdentifyOudatedProductsBat_Test {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        ScheduleIdentifyOudatedProductsBatch sch1 = new ScheduleIdentifyOudatedProductsBatch();
        
        String sch = '0 15 1 * * ?'; system.schedule('Test Identify Oudated Products Batch', sch, sch1);
        Test.stopTest(); 
    }
}