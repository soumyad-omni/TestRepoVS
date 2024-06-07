global class ResetInflowOutFlowObjectData implements Database.Batchable<SObject>, schedulable{
    global Database.queryLocator start(Database.BatchableContext bc){
        if(Test.isRunningTest()){
            return Database.getQueryLocator('Select id, Name from Backlog_Inflow_Outflow__c limit 1');
        }else{
            return Database.getQueryLocator('Select id, Name from Backlog_Inflow_Outflow__c');
        }
    }
    global void execute (Database.BatchableContext BC, List<Backlog_Inflow_Outflow__c> inflowOutFlowData){
        if(!inflowOutFlowData.isEmpty()){
            delete inflowOutFlowData;
        }
    }
    global void execute(SchedulableContext SC) {
        database.executebatch(new ResetInflowOutFlowObjectData());
    }
    global void finish(Database.BatchableContext BC){
        //Call Development batch from here
         AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            database.executebatch(new ProcessQuoteLineBacklogToBacklogIFOF(),5000);
        }
        
    }
}