global class IsNACAccountFieldUpdateSchedulerApex implements Schedulable {
    global void execute(SchedulableContext ctx) {
        IsNACAccountFieldUpdate_Batch batch = new IsNACAccountFieldUpdate_Batch();
        database.executebatch(batch);
    }
}