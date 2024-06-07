Global class QuoteApprovalAssignToBatchScheduleUpdate implements Schedulable{
    global void execute(SchedulableContext sc){
        QuoteApprovalAssignToUpdateBatchClass qaub= new QuoteApprovalAssignToUpdateBatchClass();
        database.executebatch(qaub,200);
    }
}