@isTest
public class AdditionalQuoteApprovalHandler_Test {
    @testsetup
    static void testdatasetup(){
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
    }
    @isTest
    static void testMethod1(){
    	Trigger_Configuration__c tc = new Trigger_Configuration__c();
        tc.name = 'AdditionalQuoteApprovalTriggerDisabled';
        test.startTest();
        insert tc;
        AdditionalQuoteApprovalTriggerHandler aqa = new AdditionalQuoteApprovalTriggerHandler();
        aqa.IsDisabled();
        Test.stopTest();
    }
    @isTest
    static void testMethod2(){
    	Trigger_Configuration__c tc = new Trigger_Configuration__c();
        tc.name = 'AdditionalQuoteApprovalTriggerDisabled';
        tc.isDisabled__c = TRUE;
        test.startTest();
        insert tc;
        AdditionalQuoteApprovalTriggerHandler aqa = new AdditionalQuoteApprovalTriggerHandler();
        aqa.IsDisabled();
        Test.stopTest();
    }
    @isTest
    static void testMethod3(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
    	AccountCreateController.isFirstRun= false;
        Quote q = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRecForQuote(q.Id);
        qa.Recent_Additional_Approval_Status__c = 'Waiting';
        insert qa;
        
        Additional_Quote_Approval__c aqa = new Additional_Quote_Approval__c();
        aqa.quote_Approval__c = qa.id;
        Test.startTest();
        insert aqa;
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req.setObjectId(aqa.Id);

        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);
        aqa.Approval_Status__c = 'Waiting';
        
        update aqa;
        delete aqa;
        undelete aqa;
        Test.stopTest();
        OpportunityTriggerHandler.TriggerDisabled = false;
        AccountTriggerHandler.TriggerDisabled = false;
    }
    @isTest
    static void testMethod4(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
    	AccountCreateController.isFirstRun= false;
        Quote q = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRecForQuote(q.Id);
        qa.Recent_Additional_Approval_Status__c = 'Waiting';
        insert qa;
        Additional_Quote_Approval__c aqa = new Additional_Quote_Approval__c();
        aqa.quote_Approval__c = qa.id;
        Test.startTest();
        insert aqa;
        aqa.Approval_Status__c = 'Approved';
        update aqa;
        delete aqa;
        undelete aqa;
        Test.stopTest();
        OpportunityTriggerHandler.TriggerDisabled = false;
        AccountTriggerHandler.TriggerDisabled = false;
    }
    @isTest
    static void testMethod5(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
    	AccountCreateController.isFirstRun= false;
        Quote q = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRecForQuote(q.Id);
        qa.Recent_Additional_Approval_Status__c = 'Waiting';
        insert qa;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(qa.id);
        req1.setSubmitterId(userinfo.getUserId());
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req1.setSkipEntryCriteria(true);
        //Approval.ProcessResult result = Approval.process(req1);
        Additional_Quote_Approval__c aqa = new Additional_Quote_Approval__c();
        aqa.quote_Approval__c = qa.id;
        aqa.Approval_Status__c = 'Approved';
        insert aqa;
        Test.startTest();
        Approval.ProcessResult result = Approval.process(req1);
        Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitRequest();
        app1.setObjectId(aqa.id);
        app1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result1 = Approval.process(app1);
        aqa.Approval_Status__c = 'Approved';
        update aqa;
        Test.stopTest();
        OpportunityTriggerHandler.TriggerDisabled = false;
        AccountTriggerHandler.TriggerDisabled = false;
    }
}