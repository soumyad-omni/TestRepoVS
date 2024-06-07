global class ReportingManagerUpdateOnUserBatch implements Database.Batchable<sObject>,Database.Stateful{
	Set<Id> allReportingManagerId = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Reporting_Business_Unit_Manager__c,Reporting_Division_Manager__c,'+
            'Reporting_Regional_Manager__c,Reporting_Manager__c,User__c FROM Reporting_Manager__c WHERE Updated__c  = true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Reporting_Manager__c> allReportingManagers) {
        Map<Id,Reporting_Manager__c> userReportingManagerMap = new Map<Id,Reporting_Manager__c>();
        for (Reporting_Manager__c reportManager : allReportingManagers) {
            allReportingManagerId.add(reportManager.Id);
            userReportingManagerMap.put(reportManager.User__c, reportManager);
        }
        List<User> allUserList = [Select Id,Report_Business_Unit_Manager__c,Reporting_Division_Manager__c, 
                                  Reporting_Region_Manager__c,Reportng_Manager__c From User Where Id IN :userReportingManagerMap.keySet()];
        for(User usr: allUserList){
            Reporting_Manager__c currReportingManager = userReportingManagerMap.get(usr.Id);
            if(currReportingManager.Reporting_Business_Unit_Manager__c != ''){
                usr.Report_Business_Unit_Manager__c = currReportingManager.Reporting_Business_Unit_Manager__c;
            }
            else{
                usr.Report_Business_Unit_Manager__c = '';
            }
            if(currReportingManager.Reporting_Division_Manager__c != ''){
                usr.Reporting_Division_Manager__c = currReportingManager.Reporting_Division_Manager__c;
            }
            else{
                usr.Reporting_Division_Manager__c = '';
            }
            if(currReportingManager.Reporting_Regional_Manager__c != ''){
                usr.Reporting_Region_Manager__c = currReportingManager.Reporting_Regional_Manager__c;
            }
            else{
                usr.Reporting_Region_Manager__c = '';
            }
            if(currReportingManager.Reporting_Manager__c != ''){
                usr.Reportng_Manager__c = currReportingManager.Reporting_Manager__c;
            }
            else{
                usr.Reportng_Manager__c = '';
            }
        }
        try {
            update allUserList;
        } catch (Exception e) {
            System.debug('Error processing record: '+ e.getMessage());
        }        
    }
    
    global void finish(Database.BatchableContext BC) {
        UncheckFlagInReportingManagerBatch batch = new UncheckFlagInReportingManagerBatch(allReportingManagerId);
        Database.executeBatch(batch, 200);
    }
}