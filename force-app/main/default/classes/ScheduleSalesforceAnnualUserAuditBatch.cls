global class ScheduleSalesforceAnnualUserAuditBatch implements Schedulable{
    global void execute(SchedulableContext ctx) {
        SalesforceAnnualUserAuditBatch sfannuaudit = new SalesforceAnnualUserAuditBatch();
        Database.executeBatch(sfannuaudit);
    }
}


/*
ScheduleSalesforceAnnualUserAuditBatch schUaudit=new ScheduleSalesforceAnnualUserAuditBatch();
String cronTrigger = '0 0 0 15 JUL ? *';
System.schedule('ScheduleSalesforceAnnualUserAudit',cronTrigger,schUaudit);
*/