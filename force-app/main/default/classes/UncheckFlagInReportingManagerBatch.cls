global class UncheckFlagInReportingManagerBatch implements Database.Batchable<sObject>,Database.Stateful{
    private Set<Id> allReportingManagerId;
    
    public UncheckFlagInReportingManagerBatch(Set<Id> allReportingManagerId) {
        this.allReportingManagerId = allReportingManagerId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id, Updated__c from Reporting_Manager__c where Id IN :allReportingManagerId');
    }
    
    global void execute(Database.BatchableContext BC, List<Reporting_Manager__c> allReportingManagers) {
        for (Reporting_Manager__c reportManager : allReportingManagers) {
            reportManager.Updated__c = false;
        }
        try {
            Database.update(allReportingManagers, false);
            System.debug('Flag set to False successfully');
        } catch (Exception e) {
            System.debug('Error processing record: '+ e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}