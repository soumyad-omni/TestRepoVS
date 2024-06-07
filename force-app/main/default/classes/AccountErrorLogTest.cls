@isTest
private class AccountErrorLogTest {
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
       public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;    
       
	@isTest
    private static void logTest(){
        String clsName = 'TestClass';
        String errorType = 'Integration';
        String message = 'Test Message';
        accountTriggerHandler.TriggerDisabled = true;
        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
            acct.Facility_Type__c = 'Pharmacy';
            acct.BILLINGSTREET = '41 Moss';
            acct.BillingPostalCode = 'DY6 9HP';
        insert acct;
        
        Account acc1 = new Account(Name = 'Test Acc1');
        
        try{
            update acc1;
        }catch(Exception ex){
            try{
                AccountErrorLog.Log(ex, clsName, errorType);
            }catch(Exception ex1){
                
            }
            AccountErrorLog.Log(message, String.valueOf(acct.Id));
        }
    }
}