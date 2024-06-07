global class ScheduledBatchToDeleteDealModelPDF implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executebatch( new BatchToDeleteDealModelPDF(), 200);
    }
}