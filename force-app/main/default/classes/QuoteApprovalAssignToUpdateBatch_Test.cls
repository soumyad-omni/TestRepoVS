@isTest
public class QuoteApprovalAssignToUpdateBatch_Test {
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
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
        
        BatchRunInterval__c setting8 = new BatchRunInterval__c();
        setting8.Name = 'QuoteApprovalAssignToUpdateBatchClass';
        setting8.HowFarBackMinutes__c = -59;
        setting8.Run_Interval__c = 10;
        insert setting8;
    }
    public testmethod static void checkboxAutomation1(){
        AccountCreateController.isFirstRun= false;
        accountTriggerHandler.TriggerDisabled = true;
        contactTriggerHandler.TriggerDisabled = true;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        qta.Need_Manual_Approval__c=true;
        //qta.Status__c='Waiting Approval';
        Test.startTest();
        insert qta;
 		Additional_Quote_Approval__c aqa = new Additional_Quote_Approval__c();
        aqa.Quote_Approval__c = qta.id;
        insert aqa;
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(qta.id);
        app.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(app);
        
        Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitRequest();
        app1.setObjectId(aqa.id);
        app1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result1 = Approval.process(app1);
        QuoteApprovalAssignToUpdateBatchClass qauc=new QuoteApprovalAssignToUpdateBatchClass();
        DataBase.executeBatch(qauc);
        //System.assertEquals(qta.Assigned_To__c,Userinfo.getName()+',');
        Test.stopTest();
    }
}