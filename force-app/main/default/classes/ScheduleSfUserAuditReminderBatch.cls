/*
*@author : Pabitra Tripathy
*/
global class ScheduleSfUserAuditReminderBatch implements Schedulable{
   
    global void execute(SchedulableContext ctx) {
        SalesforceUserAuditReminderBatch suauditrem=new SalesforceUserAuditReminderBatch();
        Database.executeBatch(suauditrem);
    }
}

/*
ScheduleSfUserAuditReminderBatch schUaudit=new ScheduleSfUserAuditReminderBatch();
String cronTrigger = '0 0 0 19,23,27 MAR,JUN,SEP,DEC ? *';
System.schedule('SalesforceUserAuditReminder Batch',cronTrigger,schUaudit);
*/