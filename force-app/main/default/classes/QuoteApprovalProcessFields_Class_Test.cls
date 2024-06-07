@isTest
public class QuoteApprovalProcessFields_Class_Test {
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
       	
    }
    public static testMethod void QuoteApprovalProgressControllertest1(){
        AccountCreateController.isFirstRun= false;
        accountTriggerHandler.TriggerDisabled = true;
        contactTriggerHandler.TriggerDisabled = true;
        quoteTriggerHandler.TriggerDisabled = true;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.Quote__c=qt.Id;
        qa.Requires_Deal_Desk_Approval__c = true;
        qa.Requires_Legal_Approval__c = true;
        qa.Requires_RX_Config_Approval__c = true;
        qa.Requires_Sales_Finance_Approval__c = true;
        qa.Requires_Tech_Svcs_Approval__c = true;
        Test.startTest();
        insert qa;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(qa.id);
        req1.setSubmitterId(userinfo.getUserId());
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        req1.setNextApproverIds(users);
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());
        List<Quote_Approval__c> qaList = new List<Quote_Approval__c>();
        qaList.add(qa);
        QuoteApprovalProcessFields_Class qapf = new QuoteApprovalProcessFields_Class();
        qapf.updateQuoteApprovalFields(qaList);        
        Test.stopTest();
    }
}