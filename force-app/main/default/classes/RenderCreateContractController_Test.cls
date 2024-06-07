/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-06-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-06-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class RenderCreateContractController_Test {

    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008662';
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
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
      Conga_Email_Template_Contract__c setting8 = new Conga_Email_Template_Contract__c();
        setting8.name = 'Contract Email Template';
      setting8.Email_Template_Id__c = '000000000000000';
        insert setting8;
        
        Conga_Contract_GPO_Check__c setting9 = new Conga_Contract_GPO_Check__c();
        setting9.name = 'Test';
        setting9.Template_Id__c = '0000000000000000';
        insert setting9;
        
        Conga_Summary_Smartsheet__c setting10 = new Conga_Summary_Smartsheet__c();
        setting10.Name = 'Smartsheet';
        setting10.Smartsheet_Id__c = '0000000000000000';
        insert setting10;
        
        Conga_Email_Template_Contract__c setting11 = new Conga_Email_Template_Contract__c();
        setting11.name = 'QuoteSignatureTemplate';
      setting11.Email_Template_Id__c = '000000000000000';
        insert setting11;
        
        Conga_Email_Template_Contract__c setting12 = new Conga_Email_Template_Contract__c();
        setting12.name = 'ConractSignatureTemplate';
      setting12.Email_Template_Id__c = '000000000000000';
        insert setting12;
        
        
        Conga_Print_Output__c profile1 = new Conga_Print_Output__c();
        profile1.Profile_Name__c = 'System Administrator';
        profile1.Name = 'System Admin';
        insert profile1;
     
        Conga_Print_Output__c profile2 = new Conga_Print_Output__c();
        profile2.Profile_Name__c = 'Business Administrator';
        profile2.Name = 'Business Admin';
        insert profile2;
        
        Conga_Print_Output__c profile3 = new Conga_Print_Output__c();
        profile3.Profile_Name__c = 'Booking Team';
        profile3.Name = 'Booking Team';
        insert profile3;
        
        Conga_Print_Output__c profile4 = new Conga_Print_Output__c();
        profile4.Profile_Name__c = 'Deal Desk';
        profile4.Name = 'Deal Desk';
        insert profile4;
        Conga_Print_Output__c profile5 = new Conga_Print_Output__c();
        profile5.Profile_Name__c = 'International Sales Ops';
        profile5.Name = 'International Sales Ops';
        insert profile5;
        
    }
    public static testmethod void getContractTest(){
        AccountTriggerHandler.triggerDisabled= true;
        Contracts__c c = TestDataFactory.createContract();
        RenderCreateContractController r = new RenderCreateContractController();
        List<String> res = RenderCreateContractController.getContract(c.Id);
        echosign_dev1__SIGN_Agreement__c eds = New echosign_dev1__SIGN_Agreement__c();
        eds.echosign_dev1__Status__c = 'Draft';
        eds.Contracts__c = c.id;
        insert eds;
        RenderCreateContractController.contractsignaturecheck(c.Id);
        RenderCreateContractController.getContractWf3(c.Id);
    }
    public static testmethod void getQuoteApprovalTest(){
        AccountTriggerHandler.triggerDisabled= true;
        contactTriggerHandler.triggerDisabled= true;
        Id recTypeQuoteApproval = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote' LIMIT 1].Id;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Region__c='Northeast';
        q.Pricing_Reference_Date__c=system.today();
        q.Requested_Delivery_Date__c = system.today();
        q.Booking_Date__c=system.today();
        q.ExpirationDate = system.today();
        q.SAP_Last_Line_Number__c = 200;
        q.EOL_Date__c = System.today()+200;
        q.Supplement_Version__c = 2;
        q.Status = 'E0009';
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        Quote_Approval__c qa = new Quote_Approval__c();
        
        qa.RecordTypeId = recTypeQuoteApproval;
        qa.Need_Manual_Approval__c = true;
        
        test.startTest();
        insert q;
        qa.Quote__c = q.Id;
        insert qa;
        List<String> res = RenderCreateContractController.getQuoteApproval(qa.Id);
        test.stopTest();
    }
    public static testmethod void getQuoteTest(){
        AccountTriggerHandler.triggerDisabled= true;
        contactTriggerHandler.triggerDisabled= true;
        Id recTypeQuoteApproval = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote' LIMIT 1].Id;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Region__c='Northeast';
        q.Pricing_Reference_Date__c=system.today();
        q.Requested_Delivery_Date__c = system.today();
        q.Booking_Date__c=system.today();
        q.ExpirationDate = system.today();
        q.SAP_Last_Line_Number__c = 200;
        q.EOL_Date__c = System.today()+200;
        q.Supplement_Version__c = 2;
        q.Status = 'E0009';
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        Quote_Approval__c qa = new Quote_Approval__c();
        
        qa.RecordTypeId = recTypeQuoteApproval;
        qa.Need_Manual_Approval__c = true;        
        
        test.startTest();
        insert q;
        qa.Quote__c = q.Id;
        insert qa;
        List<String> res = RenderCreateContractController.getQuote(q.Id);
        test.stopTest();
    }
    
    public static testmethod void getUserTest(){
        String res = RenderCreateContractController.getUser();
    }
    
    public static testmethod void getUserBookingTest(){
        String res = RenderCreateContractController.getUserBooking();
    }
    
     /* Added by Pavan Kumar for launching the Adobe sign url 
        IBA-1266
    */   
    @isTest public static void getAdobeSignUrlTest(){
        Contracts__c c = TestDataFactory.createContract();
        String res = RenderCreateContractController.getAdobeSignUrl(c.Id,'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    }
}