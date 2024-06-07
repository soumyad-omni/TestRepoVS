global class MarginReportsScheduleJob implements Database.Batchable<SObject>, schedulable{
    global Database.queryLocator start(Database.BatchableContext bc){
        /*CleanForecastCategoryBatch cleanBooked = new CleanForecastCategoryBatch();
        cleanBooked.processForecastCategoryData();
        CleanForecastCategoryForOpenOpps cleanOpen = new CleanForecastCategoryForOpenOpps();
        cleanOpen.processForecastCategoryData();*/
        if(Test.isRunningTest()){
            return Database.getQueryLocator('Select id, Name from Opportunity_Usage_History__c limit 1');
        }else{
            return Database.getQueryLocator('Select id, Name from Opportunity_Usage_History__c');
        }
        
    }
    global void execute (Database.BatchableContext BC, List<Opportunity_Usage_History__c> usageHistory){
        if(!usageHistory.isEmpty()){
            delete usageHistory;
        }
    }
    global void execute(SchedulableContext SC) {
        database.executebatch(new MarginReportsScheduleJob());
    }
    global void finish(Database.BatchableContext BC){
        //Call Development batch from here
         AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            database.executebatch(new marginDevelopmentSchedulableBatch(),500);
        }
        
    }
}