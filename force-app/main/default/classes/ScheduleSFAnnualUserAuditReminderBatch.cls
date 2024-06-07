global class ScheduleSFAnnualUserAuditReminderBatch implements Schedulable{
   
    global void execute(SchedulableContext ctx) {
        SFAnnualUserAuditReminderBatch sfauditrem = new SFAnnualUserAuditReminderBatch();
        Database.executeBatch(sfauditrem);
    }
}

/*
ScheduleSFAnnualUserAuditReminderBatch schUaudit=new ScheduleSFAnnualUserAuditReminderBatch();
String cronTrigger = '0 0 0 18,21,24 JAN ? *';
System.schedule('ScheduleSFAnnualUserAuditReminder',cronTrigger,schUaudit);
*/