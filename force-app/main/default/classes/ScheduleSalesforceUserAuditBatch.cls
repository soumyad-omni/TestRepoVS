global class ScheduleSalesforceUserAuditBatch  implements Schedulable {
   
    global void execute(SchedulableContext ctx) {
        SalesforceUserAuditBatch suaudit=new SalesforceUserAuditBatch();
        Database.executeBatch(suaudit);
    }

}