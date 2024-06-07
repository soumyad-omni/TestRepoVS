global class ScheduledBatchToDeleteInvalidAccounts implements Schedulable{
    global void execute(SchedulableContext sc) {
            Database.executebatch( new DeleteInvalidAccountsBatch(), 200);
    }
}