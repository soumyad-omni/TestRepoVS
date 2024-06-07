global class coveredFlagUpdateBatch_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        coveredFlagUpdateBatch b = new coveredFlagUpdateBatch();
        Database.executeBatch(b,100);
    }
}