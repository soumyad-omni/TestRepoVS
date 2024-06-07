/**
* @File Name          : NewQuoteCreateLayoutController_Test.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 5/6/2020, 6:04:21 pm
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    5/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class NewQuoteCreateLayoutController_Test {
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
        
        Default_Currency_by_Country_Code__c	  setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        ECC_Sales_Org_to_CRM__c  setting8 = new ECC_Sales_Org_to_CRM__c ();
        setting8.Name = 'GPOPricelist-None';
        setting8.GPOPricelist__c = '--XX--';
        insert setting8;
        
        Account_DataLoad__c  setting9 = new Account_DataLoad__c ();
        setting9.name = 'Dataload';
        setting9.isDisabled__c = false;
        insert setting9;
        
        
    }
    
    public static testmethod void newQuoteCreateLayoutControllerTest(){
        ContactTriggerHandler.TriggerDisabled=true;
        
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        //opp.OppStatus__c = 'Lost';
        //update opp;
        Quote testQuote = new Quote(Name='Test Quote');
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        testQuote.OpportunityId = opp.Id;
        testQuote.Pricebook2Id = Test.getStandardPricebookId();
        testQuote.Region__c='Northeast';
        testQuote.Pricing_Reference_Date__c=system.today();
        testQuote.Requested_Delivery_Date__c = system.today();
        testQuote.Booking_Date__c=system.today();
        testQuote.ExpirationDate = system.today();
        testQuote.SAP_Last_Line_Number__c = 200;
        testQuote.EOL_Date__c = System.today()+200;
        List<Sap_Sales_Org__c> sso = [select id,Sales_Org__c,name from SAP_Sales_Org__c where Account__c =:opp.AccountId];
        testQuote.SAP_Sales_Org__c = sso[0].Id;
        testQuote.Sales_Org__c = sso[0].Sales_Org__c;
        testQuote.Shipping_Contact__c= c[0].Id;
        testQuote.Order_Type__c = 'ZQRL';
        AccountTriggerHandler.TriggerDisabled = True;
        Relationship__c r = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        r.Relationship__c = 'ZG';
        Test.startTest();
        PageReference pageRef = Page.NewQuoteCreateLayout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppid', opp.Id);
        System.debug('Opportunity Id '+opp.Id);
        ApexPages.currentPage().getParameters().put('accid', opp.accountId);
        System.debug('Account Id '+opp.accountId);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        NewQuoteCreateLayoutController nq =new NewQuoteCreateLayoutController(sc);
        List<SelectOption> selectList = nq.getIDNPriceList();
        nq.conname = 'test Contact';
        nq.conId = c[0].id;
        nq.overridebillto = false;
        nq.overridepayer = false;
        nq.overrideshipto = false;
        nq.clinicalconsultantName = '';
        nq.salesconsultantName = '';
        nq.idnName = 't';
        nq.ssoName = '';
        nq.getOppName();
        nq.getpricelists();
        nq.updateSalesOrg();
        nq.getSOS();
        nq.save();
        nq.cancel();
        nq.showleaseduration();
        nq.getoppOwner();
        nq.getShiptocount();
        nq.getBilltocount();
        nq.getPayercount();
        nq.getGpocount();
        nq.getIdncount();
        nq.getDealDeskcount();
        nq.getClinicalConsultantcount();
        nq.getSalesConsultantcount();
        nq.updateshipto();
        nq.getpricelists_Old();
        nq.setPageMessageForSecondaryAccount();
        nq.showleaseduration();
        test.stopTest();
        System.assert(testQuote.Name!=null,testQuote.Name);
    }
    
    public static testmethod void newQuoteCreateLayoutControllerTest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Representative' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles'); 
        UserTriggerHandler.TriggerDisabled = True;
        insert u;
        System.RunAs(u)
        {
            AccountCreateController.isFirstRun= false;
            ContactTriggerHandler.TriggerDisabled=true;
            quotetriggerhandler.TriggerDisabled=true;
            Opportunity opp = TestDataFactory.createOppWithAccount();
            //opp.OppStatus__c = 'Lost';
            //update opp;
            Quote testQuote = new Quote(Name='Test Quote');
            List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
            testQuote.OpportunityId = opp.Id;
            testQuote.Pricebook2Id = Test.getStandardPricebookId();
            testQuote.Region__c='Northeast';
            testQuote.Pricing_Reference_Date__c=system.today();
            testQuote.Requested_Delivery_Date__c = system.today();
            testQuote.Booking_Date__c=system.today();
            testQuote.ExpirationDate = system.today();
            testQuote.SAP_Last_Line_Number__c = 200;
            testQuote.EOL_Date__c = System.today()+200;
            List<Sap_Sales_Org__c> sso = [select id,Sales_Org__c,name from SAP_Sales_Org__c where Account__c =:opp.AccountId];
            testQuote.SAP_Sales_Org__c = sso[0].Id;
            testQuote.Sales_Org__c = sso[0].Sales_Org__c;
            testQuote.Shipping_Contact__c= c[0].Id;
            testQuote.Order_Type__c = 'ZQRL';
            AccountTriggerHandler.TriggerDisabled = True;
            
            
            Test.startTest();
            Relationship__c r = TestDataFactory.createRelationshipForAccount(opp.AccountId);
            r.Relationship__c = 'ZG';
            PageReference pageRef = Page.NewQuoteCreateLayout;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('oppid', opp.Id);
            System.debug('Opportunity Id '+opp.Id);
            ApexPages.currentPage().getParameters().put('accid', opp.accountId);
            System.debug('Account Id '+opp.accountId);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
            NewQuoteCreateLayoutController nq =new NewQuoteCreateLayoutController(sc);
            List<SelectOption> selectList = nq.getIDNPriceList();
            nq.conname = 'test Contact';
            nq.conId = c[0].id;
            nq.overridebillto = false;
            nq.overridepayer = false;
            nq.overrideshipto = false;
            nq.dealDeskuserName = '';
            nq.clinicalconsultantName = '';
            nq.salesconsultantName = '';
            nq.idnName = '';
            nq.ssoName = '';
            nq.getOppName();
            nq.getpricelists();
            nq.updateSalesOrg();
            nq.getSOS();
            nq.save();
            nq.cancel();
            nq.showleaseduration();
            nq.getoppOwner();
            nq.getShiptocount();
            nq.getBilltocount();
            nq.getPayercount();
            nq.getGpocount();
            nq.getIdncount();
            nq.getDealDeskcount();
            nq.getClinicalConsultantcount();
            nq.getSalesConsultantcount();
            nq.updateshipto();
            nq.getpricelists_Old();
            nq.setPageMessageForSecondaryAccount();
            nq.showleaseduration();
            test.stopTest();
            System.assert(testQuote.Name!=null,testQuote.Name);
        }
    }
}