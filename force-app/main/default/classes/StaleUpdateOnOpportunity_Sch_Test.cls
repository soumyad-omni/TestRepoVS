@isTest
public class StaleUpdateOnOpportunity_Sch_Test {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        StaleUpdateOnOpportunity_Sch sch1 = new StaleUpdateOnOpportunity_Sch();
        String sch = '0 0 12 * * ?'; system.schedule('Testing Stale', sch, sch1);
        Test.stopTest(); 
    }
}