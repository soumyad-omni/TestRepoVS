@isTest
public class ScheduleSalesforceUserAuditBatch_Test {
   
    public static testMethod void testSchedule() {
        
       Test.StartTest();
       String cronTrigger = '0 0 0 15 MAR,JUN,SEP,DEC ? *';
       System.schedule('Salesforce User Audit Quarter End Batch',cronTrigger,new ScheduleSalesforceUserAuditBatch());
       Test.stopTest(); 
    }
}