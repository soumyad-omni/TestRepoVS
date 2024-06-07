@isTest
public class SalesforceAuditRequestEmailHandlerTest {
	public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @testSetup
    static void setupData(){
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
        User usrManager = new User(LastName = 'Manager',
                                   Email = 'manager@test.com',
                                   ProfileId = UserInfo.getProfileId(),
                                   Username = 'manager@test.com' + System.currentTimeMillis(),
                                   CompanyName = 'TEST',
                                   Title = 'title',
                                   Alias = 'alias',
                                   TimeZoneSidKey = 'America/Los_Angeles',
                                   EmailEncodingKey = 'UTF-8',
                                   LanguageLocaleKey = 'en_US',
                                   LocaleSidKey = 'en_US');
        insert usrManager;
        
        SalesforceUserAudit__c newAuditRer = new SalesforceUserAudit__c(Email__c = 'test@salesforceauditapplication.com',
                                                                        EmailNotificationSent__c = true,
                                                                        LastDatetoCompleteAudit__c = Date.today().addDays(10),
                                                                        FiscalYear__c = '2021',
                                                                        Quarter__c = 'Q1',
                                                                        Status__c = 'Pending Review',
                                                                        Manager__c = usrManager.Id,
                                                                       	Audit_Purpose__c = 'Quarterly');
        insert newAuditRer;
        
        // Create an approval request for the Salesforce Audit Request
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(newAuditRer.Id);
        req.setProcessDefinitionNameOrId('Default_Manager');
        req.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req);
        System.debug('pab '+newAuditRer.Id);
    }
    
    @isTest static void parseApprovedEmailResponse(){    
        
        SalesforceUserAudit__c sau = [Select Id From SalesforceUserAudit__c LIMIT 1];
        // Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Create the email body
        email.htmlBody = 'I am Approving this requiews ref:_'+sau.Id+':ref';
        email.fromAddress = 'test@test.com';
        String contactEmail = 'test@test.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'APPROVED';
                   
        SalesforceAuditRequestEmailHandler sareh = new SalesforceAuditRequestEmailHandler();
        
        Test.startTest();
        // pass email & enveloper object as parameters here
        Messaging.InboundEmailResult result = sareh.handleInboundEmail(email, env);
        Test.stopTest();        
    }
    
    @isTest static void parseRejectedEmailResponse(){    
        
         SalesforceUserAudit__c sau = [Select Id From SalesforceUserAudit__c LIMIT 1];
        // Create a new email and envelope object (Mandatory)
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Create the email body
        email.plainTextBody = 'I am Rejecting this requiews ref:_'+sau.Id+':ref';
        email.fromAddress = 'test@test.com';
        String contactEmail = 'test@test.com';
        email.ccAddresses = new String[] {'Test Domain <' + contactEmail + '>'};
        email.subject = 'REJECTED';
                   
        SalesforceAuditRequestEmailHandler sareh = new SalesforceAuditRequestEmailHandler();
        
        Test.startTest();
        // pass email & enveloper object as parameters here
        Messaging.InboundEmailResult result = sareh.handleInboundEmail(email, env);
        Test.stopTest();        
    }
}