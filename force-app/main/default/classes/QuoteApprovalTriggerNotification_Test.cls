@isTest
private class QuoteApprovalTriggerNotification_Test {
    @testSetup 
    static void setup() {
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008654';
        insert setting2;
        ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
        setting3.Name = 'Omnicell - St.Petes';
        setting3.CRM_Code__c = 'O 50008663';
        insert setting3;
        ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c ();
        setting4.Name = 'Omnicell Inc.';
        setting4.CRM_Code__c = 'O 50000029';
        insert setting4;
        ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c ();
        setting5.Name = 'Omnicell Ltd';
        setting5.CRM_Code__c = 'O 50008655';
        insert setting5;
        ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c ();
        setting6.Name = 'Omnicell SAS';
        setting6.CRM_Code__c = 'O 50011128';
        insert setting6;
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        
        /*Account acc = TestDataFactory.createTestAccountQuotePrint();
AccountCreateController.isFirstRun= false;
//Account acc=new Account(name='Test account',Account_role__c='ZCSN',Account_Territory__c='AZ', Region__c='Northeast');
//insert acc;
Opportunity opp = new Opportunity(name='test opp',stageName='Budget Approval',closeDate=system.today());
opp.AccountId = acc.id;
opp.OwnerId= UserInfo.getuserid();
insert opp;
Quote qt=new Quote(name='Test Quote', region__c='Northeast');
qt.opportunityid=opp.Id;
insert qt;*/
        accountTriggerHandler.TriggerDisabled = true;
        contactTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.Quote__c=qt.Id;
        Test.startTest();
        insert qa;  
        
        /*Quote_Approval__c qa=new Quote_Approval__c(New_Customer_ContainConfigCabinet_Supply__c = true, RecordTypeid='0121k0000008YENAA2');
qa.Quote__c=qt.Id;
//qt.region__c='Texas';
//Added by Sravan line 18 
qt.Region__c = 'Central';
insert qa;*/
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(qa.id);
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(userinfo.getUserId());
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        req1.setNextApproverIds(users);
        // Submit the record to specific process and skip the criteria evaluation
        //req1.setProcessDefinitionNameOrId('PTO_Request_Process');
        //req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        Test.stopTest();
        System.assert(result.isSuccess());
        
        
    }
    static testmethod void test() {  
        contactTriggerHandler.TriggerDisabled = true;
        accountTriggerHandler.TriggerDisabled = true;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'Reminder after 48 hours on Quote Approval1';
            validEmailTemplate.DeveloperName = 'Reminder_after_48_hours_on_Quote_Approval1';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            validEmailTemplate.Subject = 'Your Subject Here';
            insert validEmailTemplate;
        }
        List<String> toAddresses = new List<String>();
        toAddresses.add('test@test.com');
        EmailTemplate et = [select id from EmailTemplate where Name='Reminder after 48 hours on Quote Approval1'];
        /* EmailConfiguration__c setting= new EmailConfiguration__c();
setting.Name = 'ReminderEmailTemplate';
setting.EmailTemplateId__c=validEmailTemplate.id;
insert setting;*/
        Test.startTest();
        EmailConfiguration__c setting= new EmailConfiguration__c();
        setting.Name = 'ReminderEmailTemplate';
        setting.EmailTemplateId__c=et.id;
        insert setting;
        QuoteApprovalProcessTriggerNotification QAPT=new QuoteApprovalProcessTriggerNotification();
        Id batchId = Database.executeBatch(QAPT);
        QuoteApprovalProcessTriggerNotification.sendEmailNotification(toAddresses);
        Test.stopTest();
        
    }
    
}