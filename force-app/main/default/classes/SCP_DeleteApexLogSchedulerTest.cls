/*** 
Test Class For - SCP_DeleteApexLogScheduler and SCP_DeleteApexLogBatch 
Developer - Sanjana K.R 
***/

@isTest
public class SCP_DeleteApexLogSchedulerTest {

    public static testMethod void testschedule() {
        
        Test.StartTest();
        SCP_DeleteApexLogScheduler sch1 = new SCP_DeleteApexLogScheduler();
        
        String sch = '0 0 1 * * ?'; system.schedule('Test SCP_DeleteApexLogScheduler Batch', sch, sch1);
        List<SCP_Apex_Debug_Logs__c> scp_apex = new List<SCP_Apex_Debug_Logs__c>();
        scp_apex.add(SCP_TestDataFactory.createApexDebugLogs(true));
        SCP_DeleteApexLogBatch batch1 = new SCP_DeleteApexLogBatch();
        batch1.execute(null,scp_apex);
        Test.stopTest(); 
    }
}