/*
*@author : Pabitra Tripathy
*/
@isTest
public class ScheduleSfUserAuditReminderBatch_Test {
   
    public static testMethod void testSchedule() {
        
       Test.StartTest();
       String cronTrigger = '0 0 0 19,23,27 MAR,JUN,SEP,DEC ? *';
       System.schedule('Salesforce User Audit Quarter End Batch',cronTrigger,new ScheduleSfUserAuditReminderBatch());
       Test.stopTest(); 
    }
}