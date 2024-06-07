/*
*@author : Pabitra Tripathy
*/
@isTest
public class ScheduleSfUserAuditDontReplyBatch_Test {
   
    public static testMethod void testSchedule() {
        
       Test.StartTest();
       String cronTrigger = '0 55 23 L MAR,JUN,SEP,DEC ? *' ;
       System.schedule('SalesforceUserAuditDontReply Batch',cronTrigger,new ScheduleSfUserAuditDontReplyBatch());
       Test.stopTest(); 
    }
}