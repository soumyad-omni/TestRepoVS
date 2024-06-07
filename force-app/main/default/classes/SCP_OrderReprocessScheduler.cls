public with sharing class SCP_OrderReprocessScheduler implements Schedulable, Database.AllowsCallouts {
    public void execute(SchedulableContext context) {
        Database.executeBatch(new SCP_OrderSubmitReprocessBatch(), 10); 
    }
}