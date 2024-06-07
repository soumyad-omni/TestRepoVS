public with sharing class ReportingManagerJobButtonController {
    
    @AuraEnabled
    public static void startRMBatchJob() {
        ReportingManagerUpdateOnUserBatch reportingManagerBatch = new ReportingManagerUpdateOnUserBatch();
        Database.executeBatch(reportingManagerBatch);
    }
}