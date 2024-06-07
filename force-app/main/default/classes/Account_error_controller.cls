public class Account_error_controller {

    @AuraEnabled
    Public static string getError(id aId){
        
        List<Account> a = [SELECT Id, Error__c FROM Account where id=:aId];
        return a[0].Error__c;
    }
    
}