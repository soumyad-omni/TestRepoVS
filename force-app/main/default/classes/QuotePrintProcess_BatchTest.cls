/**
 * @File Name          : QuotePrintProcess_BatchTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-08-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    15/4/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest 
public class QuotePrintProcess_BatchTest {
    
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
        
        Generic_Material_Product__c gmp = new Generic_Material_Product__c();
        gmp.Material__c = 'TEST-TEST1234';
        gmp.MatEntered__c = 'Testprodserv1';
        insert gmp;
        
        gmp = new Generic_Material_Product__c();
        gmp.Material__c = 'TEST-TESTREN1';
        gmp.MatEntered__c = 'Renewal-S1V';
        insert gmp;
        
        
        
        
    } 
    
    public static testmethod void quoteprocessbatchtest(){
        
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true; 
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;
        TestDataFactory.createProductLine(opp.id);
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        
        ql.Higher_Level_Item__c = 200;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 201;
        ql.Line_Status__c = 'E0001';
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = false; 
        ql.Customer_Price__c = 200;
        ql.Conga_Quantity__c = 0;
        ql.Conga_Product__c = 'TestProduct';
        ql.Conga_Higher_Product__c = 'TestProduct';
        ql.Conga_Higher_Product_1__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV');
        
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType1.id;
        
        //ql1.Higher_Level_Item__c = 0;
        ql1.Higher_Level_Item__c = 0;
        ql1.conga_higher_level_item__c = '300';
        ql1.Contract_List_Price__c = 200;
        ql1.Quantity__c = 1;
        ql1.Conga_Quantity__c = 0;
        ql1.Line_Status__c = 'E0001';
        ql1.SAP_Line_Number__c = 300;
        ql1.SAP_Line_Item_GUID__c = '401';
        ql1.Contract_List_Price__c = 200;
        ql1.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = FALSE; 
        ql1.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod1 = new Product2(Name = 'Test Prod',Family = 'test',External_ID__c = '1234567',ProductCode = 'Test Prod');
        
        ql1.Sales_Text__c = 'test';
        //System.debug('Prod : '+ql1.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        //ql2.conga_higher_level_item__c = '400';
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        //Added by Sravan
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        
        ql2.Sales_Text__c = 'test';
        ql2.Conga_Quantity__c = 0;
        ql2.Line_Status__c = 'E0001';
        //System.debug('Prod : '+ql2.product__r.productcode);
        
        
        Quote_Line__c ql3 = new Quote_Line__c();
        ql3.RecordTypeId = qlNonConfigRecordType1.id;
        ql3.par_location__c = 'test';
        ql1.conga_unit_price__c = 100;
        ql3.Higher_Level_Item__c = 0;
        ql3.conga_higher_level_item__c = '500';
        ql3.Contract_List_Price__c = 200;
        ql3.Quantity__c = 1;
        ql3.Conga_Quantity__c = 0;
        ql3.Line_Status__c = 'E0001';
        ql3.SAP_Line_Number__c = 500;
        ql3.USA_List_Price__c=1.00;
        ql2.Material_Type__c = 'PRODUCT';
        ql3.Total_Customer_Price__c=10.00;
        ql3.Conga_Extended_Service_summbypar__c=32.00;
        ql3.SAP_Line_Item_GUID__c = '401';
        ql3.Contract_List_Price__c = 200;
        ql3.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql3.Material_Type__c = 'PRODUCT';
        ql3.Part_of_a_Bundle__c = TRUE; 
        ql3.Customer_Price__c = 200;
        ql1.Customer_Price_Recalculate__c = 100;
        Product2 prod3 = new Product2(Name = 'Test Prod1',Family = 'test1',External_ID__c = '1234567890',ProductCode = 'Test Prod1');
        
        ql3.Sales_Text__c = 'test';
        
        
        
        
        Quote_Line__c ql4 = new Quote_Line__c();
        ql4.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql4.Higher_Level_Item__c = 0;
        ql4.Quantity__c = 1;
        ql4.SAP_Line_Number__c = 1000;
        //ql2.conga_higher_level_item__c = '400';
        ql4.SAP_Line_Item_GUID__c = '502';
        ql4.Contract_List_Price__c = 200;
        ql4.Conga_product__c = 'Test Test Test';
        //Added by Sravan
        ql4.Material_Type__c = 'SERVICE';
        ql4.Part_of_a_Bundle__c = FALSE; 
        ql4.Customer_Price__c = 200;
        ql1.Conga_Higher_Product__c = 'TestProduct';
        ql1.Conga_Higher_Product_1__c = 'TestProduct';
        Product2 prod4 = new Product2(Name = 'Test Test Test',Family = 'test',External_ID__c = '1234567809867',ProductCode = 'Test Test Test');
        
        ql4.Sales_Text__c = 'test';
        ql4.Conga_Quantity__c = 0;
        ql4.Line_Status__c = 'E0001';
        
        
        Quote_Line__c ql5 = new Quote_Line__c();
        ql5.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql5.Higher_Level_Item__c = 500;
        ql5.Quantity__c = 1;
        ql5.SAP_Line_Number__c = 502;
        //ql2.conga_higher_level_item__c = '400';
        ql5.SAP_Line_Item_GUID__c = '505';
        ql5.Contract_List_Price__c = 200;
        ql5.Conga_product__c = 'Testprodserv';
        ql5.Conga_Higher_Product__c = 'Testprodserv';  
        ql5.Conga_Higher_Product_1__c = 'Testprodserv';
        //Added by Sravan
        ql5.Material_Type__c = 'SERVICE';
        ql5.Part_of_a_Bundle__c = FALSE; 
        ql5.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod5 = new Product2(Name = 'Testprodserv-SV',Family = 'test',External_ID__c = '123',ProductCode = 'Testprodserv-SV');
        
        ql5.Sales_Text__c = 'test';
        ql5.Conga_Quantity__c = 0;
        ql5.Line_Status__c = 'E0001';
        
        Quote_Line__c ql6 = new Quote_Line__c();
        ql6.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql6.Higher_Level_Item__c = 500;
        ql6.Quantity__c = 1;
        ql6.SAP_Line_Number__c = 501;
        //ql2.conga_higher_level_item__c = '400';
        ql6.SAP_Line_Item_GUID__c = '505';
        ql6.Contract_List_Price__c = 200;
        ql6.Conga_product__c = 'Testprodserv';
        //Added by Sravan
        ql6.Material_Type__c = 'PRODUCT';
        ql6.Total_Customer_Price__c=10.00;
        ql6.Part_of_a_Bundle__c = TRUE; 
        ql6.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod6 = new Product2(Name = 'Testprodserv',Family = 'test',External_ID__c = '12',ProductCode = 'Testprodserv');
        
        ql6.Sales_Text__c = 'test';
        ql6.Conga_Quantity__c = 0;
        ql6.Line_Status__c = 'E0001';
        
        Quote_Line__c ql7 = new Quote_Line__c();
        ql7.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql7.Higher_Level_Item__c = 0;
        ql7.Quantity__c = 1;
        ql7.SAP_Line_Number__c = 601;
        //ql2.conga_higher_level_item__c = '400';
        ql7.SAP_Line_Item_GUID__c = '605';
        ql7.Contract_List_Price__c = 0;
        ql7.Conga_product__c = 'Testprodserv1';
        //Added by Sravan
        ql7.Material_Type__c = 'PRODUCT';
        ql7.Total_Customer_Price__c=10.00;
        ql7.Customer_Price__c = 0;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod7 = new Product2(Name = 'Testprodserv1',Family = 'test',External_ID__c = '14',ProductCode = 'Testprodserv1');
        
        ql7.Sales_Text__c = 'test';
        ql7.Conga_Quantity__c = 0;
        ql7.Line_Status__c = 'E0001';
        
        
        Quote_Line__c ql8 = new Quote_Line__c();
        ql8.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql8.Higher_Level_Item__c = 0;
        ql8.conga_higher_level_item__c = '900';
        ql8.Quantity__c = 1;
        ql8.SAP_Line_Number__c = 900;
        ql8.SAP_Line_Item_GUID__c = '62124214134';
        ql8.Contract_List_Price__c = 0;
        ql8.Conga_product__c = 'testpr';
        ql8.conga_higher_product__c = 'testpr';
        //Added by Sravan
        ql8.Material_Type__c = 'PRODUCT';
        ql8.Total_Customer_Price__c=10.00;
        ql8.Customer_Price__c = 0;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod8 = new Product2(Name = 'testpr',Family = 'test',External_ID__c = '2234324',ProductCode = 'testpr');
        
        ql8.Sales_Text__c = 'test';
        ql8.Conga_Quantity__c = 0;
        ql8.Line_Status__c = 'E0001';
        
        
        Quote_Line__c ql9 = new Quote_Line__c();
        ql9.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql9.Higher_Level_Item__c = 900;
        ql9.conga_higher_level_item__c = '900';
        ql9.Quantity__c = 1;
        ql9.SAP_Line_Number__c = 901;
        ql9.SAP_Line_Item_GUID__c = '602123313';
        ql9.Contract_List_Price__c = 100;
        //Added by Sravan
        ql9.Material_Type__c = 'SERVICE';
        ql9.Total_Customer_Price__c=10.00;
        ql9.Customer_Price__c = 100;
        ql9.Conga_Product__c = 'testpr';
        ql9.Conga_Higher_Product__c = 'testpr';
        ql9.Conga_Higher_Product_1__c = 'testpr';
        Product2 prod9 = new Product2(Name = 'testpr-SV',Family = 'test',External_ID__c = '99999',ProductCode = 'testpr-SV');
        
        ql9.Sales_Text__c = 'test';
        ql9.Conga_Quantity__c = 0;
        ql9.Line_Status__c = 'E0001';     
        
        Quote_Line__c ql31 = new Quote_Line__c();
        ql31.RecordTypeId = qlNonConfigRecordType1.id;
        ql31.par_location__c = 'test1';
        ql31.conga_unit_price__c = 100;
        ql31.Higher_Level_Item__c = 0;
        ql31.conga_higher_level_item__c = '1100';
        ql31.Contract_List_Price__c = 200;
        ql31.Quantity__c = 1;
        ql31.Conga_Quantity__c = 0;
        ql31.Line_Status__c = 'E0001';
        ql31.SAP_Line_Number__c = 1100;
        ql31.USA_List_Price__c=1.00;
        ql31.Material_Type__c = 'PRODUCT';
        ql31.Total_Customer_Price__c=10.00;
        ql31.Conga_Extended_Service_summbypar__c=32.00;
        ql31.SAP_Line_Item_GUID__c = '1101';
        ql31.Contract_List_Price__c = 200;
        ql31.Conga_product__c = 'Test Prod';
        ql31.Material_Type__c = 'PRODUCT';
        ql31.Part_of_a_Bundle__c = false; 
        ql31.Customer_Price__c = 200;
        ql31.Customer_Price_Recalculate__c = 100;
        Product2 prod31 = new Product2(Name = 'Test Prod11',Family = 'test11',External_ID__c = '1234567822',ProductCode = 'Test Prod11');
        
        ql3.Sales_Text__c = 'test';
        
        Quote_Line__c ql30 = new Quote_Line__c();
        ql30.RecordTypeId = qlNonConfigRecordType1.id;
        ql30.par_location__c = 'test2';
        ql30.conga_unit_price__c = 100;
        ql30.Higher_Level_Item__c = 0;
        ql30.conga_higher_level_item__c = '1100';
        ql30.Contract_List_Price__c = 200;
        ql30.Quantity__c = 1;
        ql30.Conga_Quantity__c = 0;
        ql30.Line_Status__c = 'E0001';
        ql30.SAP_Line_Number__c = 1100;
        ql30.USA_List_Price__c=1.00;
        ql30.Material_Type__c = 'SERVICE';
        ql30.Total_Customer_Price__c=10.00;
        ql30.Conga_Extended_Service_summbypar__c=32.00;
        ql30.SAP_Line_Item_GUID__c = '1101';
        ql30.Contract_List_Price__c = 200;
        ql30.Conga_product__c = 'Test Prod';
        ql30.Material_Type__c = 'PRODUCT';
        ql30.Part_of_a_Bundle__c = false; 
        ql30.Customer_Price__c = 200;
        ql30.Customer_Price_Recalculate__c = 100;
        ql30.Sales_Text__c = 'test';
        ql30.Part_of_a_Bundle__c = false;
        ql30.conga_product__c = 'Test Prod';
        ql30.Conga_Higher_Product_1__c = 'Test Prod';
        
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        //  qlList.add(qlq);
        //qlList.add(ql4);
        test.startTest();
        insert prod;
        ql.Product__c = prod.id;
        insert prod1;
        ql1.Product__c = prod1.id;
        insert prod2;
        ql2.Product__c = prod2.id;
        insert prod3;
        ql3.Product__c = prod3.id;
        insert prod4;
        ql4.Product__c = prod4.id;
        insert prod5;
        ql5.Product__c = prod5.id;
        insert prod6;
        ql6.Product__c = prod6.id;
        insert prod7;
        ql7.Product__c = prod7.id;
        insert prod8;
        ql8.Product__c = prod8.id;
        insert prod9;
        ql9.Product__c = prod9.id;
        insert prod31;
        ql31.Product__c = prod31.id;
        ql30.Product__c = prod31.id;
        
        insert quote;
        ql.Quote__c = quote.id;
        ql1.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        ql3.Quote__c = quote.id;
        ql4.Quote__c = quote.id;
        ql5.Quote__c = quote.id;
        ql6.Quote__c = quote.id;
        ql7.Quote__c = quote.id;
        ql8.Quote__c = quote.id;
        ql9.Quote__c = quote.id;
        ql31.Quote__c = quote.id;
        ql30.Quote__c = quote.id;
        qlList.add(ql);
        qlList.add(ql1);
        qlList.add(ql2);
        qlList.add(ql3);
        qlList.add(ql4);
        qlList.add(ql5);
        qlList.add(ql6);
        qlList.add(ql7);
        qlList.add(ql8);
        qlList.add(ql9);
        qlList.add(ql31);
        insert qlList;
        System.debug('QLList : '+qlList);
        QuoteLineTriggerHandler.isFirst = true;
        
        
        //insert ql;
        QuotePrintProcess_Batch_1_Of_6 b = new QuotePrintProcess_Batch_1_Of_6(quote.id,true,true);
        database.executeBatch(b);
        
        QuotePrintProcess_Batch_1_Of_6 b1 = new QuotePrintProcess_Batch_1_Of_6(quote.id);
        
        qlList[0].conga_Renewal_grouped_product__c = true;
        QuotePrintProcess_Batch_7_Of_7 qclass = new QuotePrintProcess_Batch_7_Of_7(quote.id);
        quote.Free_Month_Service__c = 12;
        quote.Service_Duration__c = 12;
        update quote;
        qclass.setRenewalData(qlList);        
        
        
        QuotePrintProcess_Batch_3_Of_6 b2 = new QuotePrintProcess_Batch_3_Of_6(quote.id,true,true,true);
        database.executeBatch(b2);
        QuotePrintProcess_Batch_3_Of_6 b3 = new QuotePrintProcess_Batch_3_Of_6(quote.id,true,true);
        database.executeBatch(b3);
        QuotePrintProcess_Batch_3_Of_6 b4 = new QuotePrintProcess_Batch_3_Of_6(quote.id,true);
        database.executeBatch(b4);
        QuotePrintProcess_Batch_3_Of_6 b5 = new QuotePrintProcess_Batch_3_Of_6(quote.id,true,true,true,true);
        database.executeBatch(b5);
        QuotePrintProcess_Batch_2_Of_6 b2_1 = new QuotePrintProcess_Batch_2_Of_6(quote.id);
        database.executeBatch(b5);
         QuotePrintProcess_Batch_2_Of_6 b2_2 = new QuotePrintProcess_Batch_2_Of_6(quote.id,true,true);
        database.executeBatch(b5);
         QuotePrintProcess_Batch_2_Of_6 b2_3 = new QuotePrintProcess_Batch_2_Of_6(quote.id,true,true,true);
        database.executeBatch(b5);
        //Quote_Line__c freightQuoteLine = TestDataFactory.CreatTestQuoteLineFreight_Integration();
        test.stopTest();
    }
    
    public static testmethod void quoteprocessbatchtest1(){
          OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true; 
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;        
        TestDataFactory.createProductLine(opp.id);
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 200;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 201;
        ql.Line_Status__c = 'E0001';
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = false; 
        ql.Customer_Price__c = 200;
        ql.Conga_Quantity__c = 0;
        ql.Conga_Product__c = 'Testprodserv';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType1.id;
        
        //ql1.Higher_Level_Item__c = 0;
        ql1.Higher_Level_Item__c = 0;
        ql1.conga_higher_level_item__c = '300';
        ql1.Contract_List_Price__c = 200;
        ql1.Quantity__c = 1;
        ql1.Conga_Quantity__c = 0;
        ql1.Line_Status__c = 'E0001';
        ql1.SAP_Line_Number__c = 300;
        ql1.SAP_Line_Item_GUID__c = '401';
        ql1.Contract_List_Price__c = 200;
        ql1.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = FALSE; 
        ql1.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod1 = new Product2(Name = 'Test Prod',Family = 'test',External_ID__c = '1234567',ProductCode = 'Test Prod');
        insert prod1;
        ql1.Product__c = prod1.id;
        ql1.Sales_Text__c = 'test';
        System.debug('Prod : '+ql1.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        //ql2.conga_higher_level_item__c = '400';
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        //Added by Sravan
        ql2.Material_Type__c = 'PRODUCT';
        ql2.Total_Customer_Price__c=10.00;
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
        ql2.Product__c = prod2.id;
        ql2.Sales_Text__c = 'test';
        ql2.Conga_Quantity__c = 0;
        ql2.Line_Status__c = 'E0001';
        System.debug('Prod : '+ql2.product__r.productcode);
        Quote_Line__c ql3 = new Quote_Line__c();
        ql3.RecordTypeId = qlNonConfigRecordType1.id;
        
        //ql1.Higher_Level_Item__c = 0;
        ql3.Higher_Level_Item__c = 0;
        ql3.conga_higher_level_item__c = '500';
        ql3.Contract_List_Price__c = 200;
        ql3.Quantity__c = 1;
        ql3.Conga_Quantity__c = 0;
        ql3.Line_Status__c = 'E0001';
        ql3.SAP_Line_Number__c = 500;
        ql3.SAP_Line_Item_GUID__c = '401';
        ql3.Contract_List_Price__c = 200;
        ql3.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql3.Material_Type__c = 'PRODUCT';
        ql3.Part_of_a_Bundle__c = TRUE; 
        ql3.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod3 = new Product2(Name = 'Test Prod1',Family = 'test1',External_ID__c = '1234567890',ProductCode = 'Test Prod1');
        insert prod3;
        ql3.Product__c = prod3.id;
        ql3.Sales_Text__c = 'test';
        
        
        
        
        Quote_Line__c ql4 = new Quote_Line__c();
        ql4.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql4.Higher_Level_Item__c = 0;
        ql4.Quantity__c = 1;
        ql4.SAP_Line_Number__c = 1000;
        //ql2.conga_higher_level_item__c = '400';
        ql4.SAP_Line_Item_GUID__c = '502';
        ql4.Contract_List_Price__c = 200;
        ql4.Conga_product__c = 'Test Test Test';
        //Added by Sravan
        ql4.Material_Type__c = 'SERVICE';
        ql4.Part_of_a_Bundle__c = FALSE; 
        ql4.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod4 = new Product2(Name = 'Test Test Test',Family = 'test',External_ID__c = '1234567809867',ProductCode = 'Test Test Test');
        insert prod4;
        ql4.Product__c = prod4.id;
        ql4.Sales_Text__c = 'test';
        ql4.Conga_Quantity__c = 0;
        ql4.Line_Status__c = 'E0001';
        
        
        Quote_Line__c ql5 = new Quote_Line__c();
        ql5.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql5.Higher_Level_Item__c = 500;
        ql5.Quantity__c = 1;
        ql5.SAP_Line_Number__c = 502;
        //ql2.conga_higher_level_item__c = '400';
        ql5.SAP_Line_Item_GUID__c = '505';
        ql5.Contract_List_Price__c = 200;
        ql5.Conga_product__c = 'Testprodserv';
        //Added by Sravan
        ql5.Material_Type__c = 'SERVICE';
        ql5.Part_of_a_Bundle__c = FALSE; 
        ql5.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod5 = new Product2(Name = 'Testprodserv-SV',Family = 'test',External_ID__c = '123',ProductCode = 'Testprodserv-SV');
        insert prod5;
        ql5.Product__c = prod5.id;
        ql5.Sales_Text__c = 'test';
        ql5.Conga_Quantity__c = 0;
        ql5.Line_Status__c = 'E0001';
        
        Quote_Line__c ql6 = new Quote_Line__c();
        ql6.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql6.Higher_Level_Item__c = 500;
        ql6.Quantity__c = 1;
        ql6.SAP_Line_Number__c = 501;
        //ql2.conga_higher_level_item__c = '400';
        ql6.SAP_Line_Item_GUID__c = '505';
        ql6.Contract_List_Price__c = 200;
        ql6.Conga_product__c = 'Testprodserv';
        //Added by Sravan
        ql6.Material_Type__c = 'PRODUCT';
        ql6.Part_of_a_Bundle__c = TRUE; 
        ql6.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod6 = new Product2(Name = 'Testprodserv',Family = 'test',External_ID__c = '12',ProductCode = 'Testprodserv');
        insert prod6;
        ql6.Product__c = prod6.id;
        ql6.Sales_Text__c = 'test';
        ql6.Conga_Quantity__c = 0;
        ql6.Line_Status__c = 'E0001';
        
        Quote_Line__c ql7 = new Quote_Line__c();
        ql7.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql7.Higher_Level_Item__c = 600;
        ql7.Quantity__c = 1;
        ql7.SAP_Line_Number__c = 601;
        //ql2.conga_higher_level_item__c = '400';
        ql7.SAP_Line_Item_GUID__c = '605';
        ql7.Contract_List_Price__c = 0;
        ql7.Conga_product__c = 'Testprodserv1';
        //Added by Sravan
        ql7.Material_Type__c = 'PRODUCT'; 
        ql7.Customer_Price__c = 0;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod7 = new Product2(Name = 'Testprodserv1',Family = 'test',External_ID__c = '14',ProductCode = 'Testprodserv1');
        insert prod7;
        ql7.Product__c = prod7.id;
        ql7.Sales_Text__c = 'test';
        ql7.Conga_Quantity__c = 0;
        ql7.Line_Status__c = 'E0001';
        
        Quote_Line__c ql77 = new Quote_Line__c();
        ql77.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql77.Higher_Level_Item__c = 0;
        ql77.Quantity__c = 1;
        ql77.SAP_Line_Number__c = 602;
        //ql2.conga_higher_level_item__c = '400';
        ql77.SAP_Line_Item_GUID__c = '605';
        ql77.Contract_List_Price__c = 0;
        ql77.Conga_product__c = 'Testprodserv1';
        ql77.Conga_Higher_Product__c = 'Testprodserv1';
        ql77.Conga_Higher_Product_1__c = 'Testprodserv1';
        //Added by Sravan
        ql77.Material_Type__c = 'PRODUCT'; 
        ql77.Customer_Price__c = 0;
        
        ql77.Product__c = prod7.id;
        ql77.Sales_Text__c = 'test';
        ql77.Conga_Quantity__c = 0;
        ql77.Line_Status__c = 'E0001';
        
        Quote_Line__c ql8 = new Quote_Line__c();
        ql8.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql8.Higher_Level_Item__c = 0;
        ql8.conga_higher_level_item__c = '900';
        ql8.Quantity__c = 1;
        ql8.SAP_Line_Number__c = 900;
        ql8.SAP_Line_Item_GUID__c = '62124214134';
        ql8.Contract_List_Price__c = 0;
        ql8.Conga_product__c = 'testpr';
        ql8.conga_higher_product__c = 'testpr';
        //Added by Sravan
        ql8.Material_Type__c = 'PRODUCT';
        ql8.Total_Customer_Price__c=10.00;
        ql8.Customer_Price__c = 0;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod8 = new Product2(Name = 'testpr',Family = 'test',External_ID__c = '2234324',ProductCode = 'testpr');
        insert prod8;
        ql8.Product__c = prod8.id;
        ql8.Sales_Text__c = 'test';
        ql8.Conga_Quantity__c = 0;
        ql8.Line_Status__c = 'E0001';
        
        
        Quote_Line__c ql9 = new Quote_Line__c();
        ql9.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql9.Higher_Level_Item__c = 900;
        ql9.conga_higher_level_item__c = '900';
        ql9.Quantity__c = 1;
        ql9.SAP_Line_Number__c = 901;
        ql9.SAP_Line_Item_GUID__c = '602123313';
        ql9.Contract_List_Price__c = 100;
        //Added by Sravan
        ql9.Material_Type__c = 'SERVICE';
        ql9.Total_Customer_Price__c=10.00;
        ql9.Customer_Price__c = 100;
        ql9.Conga_Product__c = 'testpr';
        ql9.Conga_Higher_Product__c = 'testpr';
        ql9.Conga_Higher_Product_1__c = 'testpr';
        Product2 prod9 = new Product2(Name = 'testpr-SV',Family = 'test',External_ID__c = '99999',ProductCode = 'testpr-SV');
        insert prod9;
        ql9.Product__c = prod9.id;
        ql9.Sales_Text__c = 'test';
        ql9.Conga_Quantity__c = 0;
        ql9.Line_Status__c = 'E0001';     
        test.startTest();
        insert quote;
        ql.Quote__c = quote.id;
        ql1.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        ql3.Quote__c = quote.id;
        ql4.Quote__c = quote.id;
        ql5.Quote__c = quote.id;
        ql6.Quote__c = quote.id;
        ql7.Quote__c = quote.id;
        ql8.Quote__c = quote.id;
        ql9.Quote__c = quote.id;
        ql77.Quote__c = quote.id;
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        qlList.add(ql);
        qlList.add(ql1);
        qlList.add(ql2);
        qlList.add(ql3);
        qlList.add(ql4);
        qlList.add(ql5);
        qlList.add(ql6);
        qlList.add(ql7);
        qlList.add(ql77);
        qlList.add(ql8);
        qlList.add(ql9);
        //  qlList.add(qlq);
        //qlList.add(ql4);
        
        insert qlList;
        System.debug('QLList : '+qlList);
        QuoteLineTriggerHandler.isFirst = true;
        QuotePrintProcess_Batch_0_Of_initialize	b11 = new QuotePrintProcess_Batch_0_Of_initialize(quote.id,true,true,true,false,false);
        database.executeBatch(b11);
        QuotePrintProcess_Batch_0_Of_6 b1 = new QuotePrintProcess_Batch_0_Of_6(quote.id,true,true,true,false);
        QuotePrintProcess_Batch_0_Of_6 b2 = new QuotePrintProcess_Batch_0_Of_6(quote.id,true,true);
        //insert ql;
        QuotePrintProcess_Batch_0_Of_6 b = new QuotePrintProcess_Batch_0_Of_6(quote.id,true,true,true);
        database.executeBatch(b);
        
        //QuotePrintProcess_Batch_9_Of_9 b1 = new QuotePrintProcess_Batch_9_Of_9(q.id,true);
        //b1.getDDM(ql77);
        
        //Quote_Line__c freightQuoteLine = TestDataFactory.CreatTestQuoteLineFreight_Integration();
        test.stopTest();
    }
    
    public static testmethod void quoteprocessbatchtest2(){
          OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true; 
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;        
        TestDataFactory.createProductLine(opp.id);
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        
        ql.Higher_Level_Item__c = 200;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 201;
        ql.Line_Status__c = 'E0001';
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = false; 
        ql.Customer_Price__c = 200;
        ql.Conga_Quantity__c = 0;
        ql.Conga_Product__c = 'TestProduct';
        ql.Conga_Higher_Product__c = 'TestProduct';
        ql.Conga_Higher_Product_1__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql1.Higher_Level_Item__c = 0;
        ql1.conga_higher_level_item__c = '300';
        ql1.Contract_List_Price__c = 200;
        ql1.Quantity__c = 1;
        ql1.Conga_Quantity__c = 0;
        ql1.Line_Status__c = 'E0001';
        ql1.SAP_Line_Number__c = 300;
        ql1.SAP_Line_Item_GUID__c = '401';
        ql1.Contract_List_Price__c = 200;
        ql1.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = FALSE; 
        ql1.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod1 = new Product2(Name = 'Test Prod',Family = 'test',External_ID__c = '1234567',ProductCode = 'Test Prod');
        insert prod1;
        ql1.Product__c = prod1.id;
        ql1.Sales_Text__c = 'test';
        System.debug('Prod : '+ql1.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        //ql2.conga_higher_level_item__c = '400';
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        //Added by Sravan
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
        ql2.Product__c = prod2.id;
        ql2.Sales_Text__c = 'test';
        ql2.Conga_Quantity__c = 0;
        ql2.Line_Status__c = 'E0001';
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        
        
        test.startTest();
        insert quote;
        ql.Quote__c = quote.id;
        ql1.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql);
        qlList.add(ql1);
        qlList.add(ql2);
        insert qlList;
        QuoteLineTriggerHandler.isFirst = true;
        QuotePrintProcess_Batch_1_Of_6 b1 = new QuotePrintProcess_Batch_1_Of_6(quote.id,false,false,false,true);
        database.executeBatch(b1);
        test.stopTest();
    }
    
    public static testmethod void quoteprocessbatchtest3(){
          OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true; 
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;
        TestDataFactory.createProductLine(opp.id);
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        
        ql.Higher_Level_Item__c = 0;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 400;
        ql.Line_Status__c = 'E0001';
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = false; 
        ql.Customer_Price__c = 200;
        ql.Conga_Quantity__c = 0;
        ql.Conga_Product__c = 'TestProduct';
        ql.Conga_Higher_Product__c = 'TestProduct';
        ql.Conga_Higher_Product_1__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-S1V');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql1.Higher_Level_Item__c = 0;
        ql1.conga_higher_level_item__c = '300';
        ql1.Contract_List_Price__c = 200;
        ql1.Quantity__c = 1;
        ql1.Conga_Quantity__c = 0;
        ql1.Line_Status__c = 'E0001';
        ql1.SAP_Line_Number__c = 300;
        ql1.SAP_Line_Item_GUID__c = '401';
        ql1.Contract_List_Price__c = 200;
        ql1.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = FALSE; 
        ql1.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod1 = new Product2(Name = 'Test Prod',Family = 'test',External_ID__c = '1234567',ProductCode = 'Test Prod');
        insert prod1;
        ql1.Product__c = prod1.id;
        ql1.Sales_Text__c = 'test';
        System.debug('Prod : '+ql1.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        //ql2.conga_higher_level_item__c = '400';
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        //Added by Sravan
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
        ql2.Product__c = prod2.id;
        ql2.Sales_Text__c = 'test';
        ql2.Conga_Quantity__c = 0;
        ql2.Line_Status__c = 'E0001';
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        
        
        test.startTest();
        insert quote;
        ql.Quote__c = quote.id;
        ql1.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql);
        qlList.add(ql1);
        qlList.add(ql2);
        insert qlList;
        QuoteLineTriggerHandler.isFirst = true;
        QuotePrintProcess_Batch_1_Of_6 b1 = new QuotePrintProcess_Batch_1_Of_6(quote.id,false,false,false,false,true);
        database.executeBatch(b1);
        test.stopTest();
    }
    
    public static testmethod void quoteprocessbatchtest4(){
          OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true; 
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;
        TestDataFactory.createProductLine(opp.id);
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 0;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 400;
        ql.Line_Status__c = 'E0001';
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = false; 
        ql.Customer_Price__c = 200;
        ql.Conga_Quantity__c = 0;
        ql.Conga_Product__c = 'TestProduct';
        ql.Conga_Higher_Product__c = 'TestProduct';
        ql.Conga_Higher_Product_1__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-S1V');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql1.Higher_Level_Item__c = 0;
        ql1.conga_higher_level_item__c = '300';
        ql1.Contract_List_Price__c = 200;
        ql1.Quantity__c = 1;
        ql1.Conga_Quantity__c = 0;
        ql1.Line_Status__c = 'E0001';
        ql1.SAP_Line_Number__c = 300;
        ql1.SAP_Line_Item_GUID__c = '401';
        ql1.Contract_List_Price__c = 200;
        ql1.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = FALSE; 
        ql1.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod1 = new Product2(Name = 'Test Prod',Family = 'test',External_ID__c = '1234567',ProductCode = 'Test Prod');
        insert prod1;
        ql1.Product__c = prod1.id;
        ql1.Sales_Text__c = 'test';
        System.debug('Prod : '+ql1.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 0;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 0;
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
        ql2.Product__c = prod2.id;
        ql2.Sales_Text__c = 'test';
        ql2.Conga_Quantity__c = 0;
        ql2.Line_Status__c = 'E0001';
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        
        
        test.startTest();
        insert quote;
        ql.Quote__c = quote.id;
        ql1.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql);
        qlList.add(ql1);
        qlList.add(ql2);
        insert qlList;
        QuoteLineTriggerHandler.isFirst = true;
        QuotePrintProcess_Batch_0_Of_initialize	b11 = new QuotePrintProcess_Batch_0_Of_initialize(quote.id,false,false,true,false,true);
        database.executeBatch(b11);
        QuotePrintProcess_Batch_1_Of_6 b1 = new QuotePrintProcess_Batch_1_Of_6(quote.id,false,false,true,false,true);
        database.executeBatch(b1);
        QuotePrintProcess_Batch_5_Of_6 b = new QuotePrintProcess_Batch_5_Of_6(quote.id);
        database.executeBatch(b);
        QuotePrintProcess_Batch_5_Of_6 b2 = new QuotePrintProcess_Batch_5_Of_6(quote.id,false);
        database.executeBatch(b2);
        QuotePrintProcess_Batch_5_Of_6 b3 = new QuotePrintProcess_Batch_5_Of_6(quote.id,false,false);
        database.executeBatch(b3);
        test.stopTest();
    }
    
    
    
}