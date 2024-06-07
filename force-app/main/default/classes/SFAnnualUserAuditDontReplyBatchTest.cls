@isTest(seeAllData=false)
public class SFAnnualUserAuditDontReplyBatchTest {
    public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @testSetup
    static void SetupData(){
        
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        
        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = 'DY6 9HP';
        insert acct;
        List<User> usrList = new List<User>();
        
        User usr1 = new User(LastName = 'usr1',
                             Email = 'usr1@test.com',
                             ProfileId = UserInfo.getProfileId(),
                             Username = 'usr1@test.com' + System.currentTimeMillis(),
                             CompanyName = 'TEST',
                             Title = 'title',
                             Alias = 'alias',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                             ManagerId = UserInfo.getUserId(), 
                             PreviousProfileName__c = 'Business Administrator');
        usrList.add(usr1);
        
        User usr2 = new User(LastName = 'usr2',
                             Email = 'usr2@test.com',
                             ProfileId = UserInfo.getProfileId(),
                             Username = 'usr2@test2.com' + System.currentTimeMillis(),
                             CompanyName = 'TEST',
                             Title = 'title',
                             Alias = 'alias',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                             ManagerId = UserInfo.getUserId(),
                             PreviousCostCenter__c = '12345');
        usrList.add(usr2);
        
        insert usrList;
        List<SalesforceUserAudit__c> auditList=new List<SalesforceUserAudit__c>();
        SalesforceUserAudit__c auditRec1 = new SalesforceUserAudit__c(Manager__c = UserInfo.getUserId(),
                                   Quarter__c = 'Q1',
                                   LastDatetoCompleteAudit__c = Date.today().addMonths(1).toStartOfMonth().addDays(-5),
                                   FiscalYear__c = String.valueOf(Date.today().Year()),
                                   Status__c = 'Pending Review',
                                   Audit_Purpose__c = 'Annual');
        SalesforceUserAudit__c auditRec2 = new SalesforceUserAudit__c(Manager__c = UserInfo.getUserId(),
                                   Quarter__c = 'Q1',
                                   LastDatetoCompleteAudit__c = Date.today().addMonths(1).toStartOfMonth().addDays(-5),
                                   FiscalYear__c = String.valueOf(Date.today().Year()),
                                   Status__c = 'Pending Review',
                                   Audit_Purpose__c = 'Annual');
     
        auditList.add(auditRec1);
        auditList.add(auditRec2);
        insert auditList;
       
        auditRec2.Status__c='Completed';
        update auditRec2;
    }
    
    @isTest static void startSalesforceAuditReminderBatch(){
        
        Test.startTest();
        Database.executeBatch(new SFAnnualUserAuditDontReplyBatch());
        ScheduleSFAnnualUserAuditDontReplyBatch schUaudit=new ScheduleSFAnnualUserAuditDontReplyBatch();
        String cronTrigger = '0 55 23 L JAN ? *' ;
        System.schedule('ScheduleSFAnnualUserAuditDontReply',cronTrigger,schUaudit);
        Test.stopTest();
    }
}