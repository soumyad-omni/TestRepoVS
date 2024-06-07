global class ScheduleSFAnnualUserAuditDontReplyBatch implements Schedulable{
   
    global void execute(SchedulableContext ctx) {
        SFAnnualUserAuditDontReplyBatch sfauditdrep=new SFAnnualUserAuditDontReplyBatch();
        Database.executeBatch(sfauditdrep);
    }
}

/*
ScheduleSFAnnualUserAuditDontReplyBatch schUaudit=new ScheduleSFAnnualUserAuditDontReplyBatch();
String cronTrigger = '0 55 23 L JAN ? *' ;
System.schedule('ScheduleSFAnnualUserAuditDontReply',cronTrigger,schUaudit);
*/