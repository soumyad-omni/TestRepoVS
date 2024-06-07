public class DeleteInvalidAccountsBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
        String accStatus = 'Invalid';
        String accId = '0013l00002VnedKAAR';
        return Database.getQueryLocator('Select id,Validation_Status__c,createddate from Account where Id NOT IN (SELECT AccountId from Opportunity) AND'+ 
                                        ' createddate < N_DAYS_AGO:30 AND Validation_Status__c = :accStatus AND id != :accId AND RecordtypeId !=:recordTypeId');
    }
    
    public void execute(Database.BatchableContext BC, List<Account> listAccs) {
       Database.delete(listAccs,false);
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
}