@isTest
public class SendEmailUserForzenListBatchTest
{
    public static testMethod void method1()
    {
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;

        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;

        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;

        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = 'DY6 9HP';
        insert acct;

        Profile pf= [Select Id from profile where Name='System Administrator' Limit 1]; 

        User usr1 = new User(LastName = 'usr1',
                             Email = 'usr1@test.com',
                             ProfileId = pf.Id,
                             Username = 'usr1@test.com' + System.currentTimeMillis(),
                             CompanyName = 'TEST',
                             Title = 'title',
                             Alias = 'alias',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                            Term_Date__c = system.today());
        insert usr1;

        UserLogin usrLogin = [select userId,IsFrozen from UserLogin Where userId =: usr1.Id Limit 1];
        usrLogin.isFrozen = true;
        update usrLogin;

        test.startTest();
        SendEmailUserForzenListBatch sc = new SendEmailUserForzenListBatch();
        sc.execute(null);
        //Database.executeBatch(new SendEmailUserForzenListBatch());
        test.stopTest();
    }
}