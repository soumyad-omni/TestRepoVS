/***********************************************************************************************************
Name:  AccountProductLine_Batch_Test
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Test class for AccountProductLine_Batch and respective Batch Classes (AccountProductSegment_Batch,AccountBusinessSegment_Batch,
AccountQuoteLineItemType_Batch)
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Venu Kukkapalli          9/08/2018                             INITIAL DEVELOPMENT
*************************************************************************************************************/
@isTest
public class AccountProductLine_Batch_Test {
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
    }
    public testmethod static void accountProdLineBatchTest(){
        AccountCreateController.isFirstRun= false; 
        quoteTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        accountTriggerHandler.TriggerDisabled = true;
        contactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        //pl.Cost__c = 100;
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.id;
        pl.Quantity__c = 3;
        insert pl;
        test.startTest();
       	AccountProductLine_Batch aplb = new AccountProductLine_Batch();
        Id batchId = Database.executeBatch(aplb);
        test.stopTest();
    }   
    /*public testmethod static void accountBusinessSegBatchTest(){
        AccountCreateController.isFirstRun= false; 
         //Account acc = TestDataFactory.createTestAccountQuotePrint();
        //Product_Segment__c ps = TestDataFactory.createTestProdSegment(acc);
        Business_Segment__c bs = TestDataFactory.createTestBusinessSegment();
        //Quote_Line_Type__c ql = TestDataFactory.createTestQuoteLineItemType();
        
       // Product_Line__c pl = TestDataFactory.createTestProdLine();
       // System.debug('Pl Date Booked : '+pl.Date_Booked__c);
        test.startTest();
       	AccountBusinessSegment_Batch aplb = new AccountBusinessSegment_Batch();
        Id batchId = Database.executeBatch(aplb, 1);
        test.stopTest();
    }*/
    /*public testmethod static void accountProductSegBatchTest(){
        AccountCreateController.isFirstRun= false; 
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        Product_Segment__c ps = TestDataFactory.createTestProdSegment(acc);
        //Business_Segment__c bs = TestDataFactory.createTestBusinessSegment();
        //Quote_Line_Type__c ql = TestDataFactory.createTestQuoteLineItemType();
        
       // Product_Line__c pl = TestDataFactory.createTestProdLine();
       // System.debug('Pl Date Booked : '+pl.Date_Booked__c);
        test.startTest();
       	AccountProductSegment_Batch aplb = new AccountProductSegment_Batch();
        Id batchId = Database.executeBatch(aplb, 1);
        test.stopTest();
    }*/
    /*public testmethod static void accountQuoteLineItemTypeBatchTest(){
        AccountCreateController.isFirstRun= false; 
        //Account acc = TestDataFactory.createTestAccountQuotePrint();
        //Product_Segment__c ps = TestDataFactory.createTestProdSegment(acc);
        //Business_Segment__c bs = TestDataFactory.createTestBusinessSegment();
        Quote_Line_Type__c ql = TestDataFactory.createTestQuoteLineItemType();
        
       // Product_Line__c pl = TestDataFactory.createTestProdLine();
       // System.debug('Pl Date Booked : '+pl.Date_Booked__c);
        test.startTest();
       	AccountQuoteLineItemType_Batch aplb = new AccountQuoteLineItemType_Batch();
        Id batchId = Database.executeBatch(aplb, 1);
        test.stopTest();
    }*/
    
    
    /*public testmethod static void accountProdLineBatchTest(){
        AccountCreateController.isFirstRun=false;
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';

        System.assertEquals(setting.Name, 'CastIronIntegration');
        System.assertEquals(setting.EndPoint__c,'https://castirondev.omnicell.com');
        test.startTest();
        Product_Segment__c ps = TestDataFactory.createTestProdSegment();
        Business_Segment__c bs = TestDataFactory.createTestBusinessSegment();
        Quote_Line_Type__c ql = TestDataFactory.createTestQuoteLineItemType();
         AccountCreateController.isFirstRun= false; 

        
            Product_Line__c pl = TestDataFactory.createTestProdLine();
        System.debug('Pl Date Booked : '+pl.Date_Booked__c);
            AccountProductLine_Batch aplb = new AccountProductLine_Batch();
            Id batchId = Database.executeBatch(aplb, 1);
        test.stopTest();
    }*/
}