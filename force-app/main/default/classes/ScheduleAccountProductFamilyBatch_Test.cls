@isTest
public class ScheduleAccountProductFamilyBatch_Test {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        ScheduleAccountProductFamilyBatch sch1 = new ScheduleAccountProductFamilyBatch();
        
        String sch = '0 0 1 * * ?'; system.schedule('Test Product Line Batch', sch, sch1);
        Test.stopTest(); 
    }
}