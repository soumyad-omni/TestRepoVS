global class ScheduleSfUserAuditDontReplyBatch implements Schedulable{
   
    global void execute(SchedulableContext ctx) {
        SalesforceUserAuditDontReplyBatch suauditdrep=new SalesforceUserAuditDontReplyBatch();
        Database.executeBatch(suauditdrep);
    }
}

/*
ScheduleSfUserAuditDontReplyBatch schUaudit=new ScheduleSfUserAuditDontReplyBatch();
String cronTrigger = '0 55 23 L MAR,JUN,SEP,DEC ? *' ;
System.schedule('SalesforceUserAuditDontReply Batch',cronTrigger,schUaudit);
*/