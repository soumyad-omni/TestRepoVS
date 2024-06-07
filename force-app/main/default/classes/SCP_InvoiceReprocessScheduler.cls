public with sharing class SCP_InvoiceReprocessScheduler implements Schedulable, Database.AllowsCallouts {
    public void execute(SchedulableContext context) {
        Database.executeBatch(new SCP_InvoiceReprocessBatch(), 100); 
    }
}