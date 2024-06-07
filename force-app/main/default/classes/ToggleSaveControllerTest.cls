/**********************************************************************
Name:  ToggleSaveControllerTest
Copyright © 2019
======================================================
======================================================
Purpose: 
This is the test class for ToggleSaveController
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Capgemini Team             02/07/2019      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/

@isTest
public class ToggleSaveControllerTest{
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
        
    }
    
    public static testmethod void toggletest(){
       AccountCreateController.isFirstRun= false;
       
        Opportunity opp = TestDataFactory.createOppWithAccount();
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        testQuote.Shipping_Contact__c= c[0].Id;
        testQuote.Order_Type__c = 'ZHQR';
        insert testQuote;
        
        SAP_Sales_Org__c sso = TestDataFactory.createSAPSAlesOrg();
        sso.Account__c = opp.AccountId;
        testQuote.Sales_Org__c = sso.Sales_Org__c;
        Test.startTest();
          PageReference pageRef = Page.ToggleSave;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('Id', testQuote.Id);
          //ApexPages.currentPage().getParameters().put('accid', opp.accountId);
          ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
          ToggleSaveController ts =new ToggleSaveController(sc);
          ts.save();
          
       Test.stopTest();
    }
    
}