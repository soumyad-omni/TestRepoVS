/***********************************************************************************************************
Name:  AccountProductLine_Batch_NEW_Test
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
0.1          Sravan          19/09/2019                             INITIAL DEVELOPMENT
*************************************************************************************************************/
@isTest
public class AccountProductLine_Batch_NEW_Test {
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
        
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
    
    public testmethod static void accountProdLineBatchTest0(){
        AccountCreateController.isFirstRun= false; 
        accountTriggerHandler.TriggerDisabled = true;
        opportunityTriggerHandler.TriggerDisabled = true;
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        // pl.Cost__c = 100;
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        
        // pl.Opportunity__c = createOppWithAccount().Id;
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        
        //  Account acc = TestDataFactory.createTestAccountQuotePrint();
        //  //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //   //insert acc;
        //   
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.ExpectedInstallDate__c = System.Today();
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        insert opp;
        
        pl.Opportunity__c = opp.Id;
        
        pl.Quantity__c = 3;
        insert pl;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        //quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        //quote.ContactId= createTestContact(true, createUSTestAccount().id, 'Testnamett1',null).id;
        //Contact cont= createContactWithAccount_Integration();
        //   quote.OpportunityId = createOppWithAccount().Id;
        quote.OpportunityId = opp.Id;
        
        Opportunity opp2 = [select accountid from opportunity where id=:quote.opportunityId];//sravan 22feb
        
        // createProductLine(opp2.id);
        Product_Line__c pl2 = new Product_Line__c();
        pl2.Portfolio_Segment__c = 'IVX Workflow';
        pl2.Amount__c = 10000;
        pl2.Opportunity__c =opp2.id;    
        insert pl2;
        
        //  Contact cont = createContactForAcc(opp2.AccountId);//sravan 22feb
        TestDataFactory.castIronCSetting();//Haripriya
        TestDataFactory.dCurrencyCCodeCSetting();//Haripriya        
        Contact cont = new Contact();
        cont.LastName='Smith'+ system.now().millisecond();
        cont.Is_Active__c ='Y';
        cont.AccountId = opp2.AccountId;
        insert cont;
        
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        //quote.Bill_to_Account__c = createTestAccountQuotePrint().Id;
        quote.Bill_to_Account__c = opp.AccountId;//Sravan 22feb
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        
        pl.Quote__c = quote.Id;
        
        update pl;
        
        test.startTest();
        
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        AccountProductLine_Batch_NEW   aplb = new AccountProductLine_Batch_NEW (je);
        Id batchId = Database.executeBatch(aplb);
        
        AccountProductLine_Batch_NEW   aplb2 = new AccountProductLine_Batch_NEW ();
        
        test.stopTest();
        
        
    } 
    
    public testmethod static void accountProdLineBatchTest(){
        AccountCreateController.isFirstRun= false; 
        accountTriggerHandler.TriggerDisabled = true;
        contactTriggerHandler.TriggerDisabled = true;
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        //Product_Line__c pl = TestDataFactory.createTestProdLine();
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        Product_Line__c pl11 = new Product_Line__c();
        pl11.Amount__c = 1000;
        pl11.Product_Line_Picklist2__c = 'Anesthesia';
        // pl11.Cost__c = 100;
        pl11.Date_Booked__c = System.today()-10;
        pl11.Estimate__c = true;
        pl11.Opportunity__c = opp.Id;
        
        pl11.Quantity__c = 3;
        insert pl11;
        q.OpportunityId = opp.Id;
        
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        //pl.Cost__c = 100;
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.id;
        pl.Quantity__c = 3;
        
        Quote_Line_Type__c qlt = new Quote_Line_Type__c();
        qlt.Amount__c = 1000;
        //qlt.Cost__c = 100;
        qlt.Date_Booked__c = System.today()-5;
        qlt.Estimate__c = true;
        opp.AccountId = acc.id;
        qlt.Opportunity__c = opp.Id;
        qlt.Quantity__c = 3;
        
        Account_Product_Line__c actProdLine = new Account_Product_Line__c();
        actProdLine.Account__c = acc.id;
        actProdLine.Amount_Booked__c = 1000;
        actProdLine.Amount_Estimated__c = 1000;
        actProdLine.Last_Product_Sold_Date__c = System.today()-5;
        
        actProdLine.createddate = System.today()-10;
        
        test.startTest();
        insert q;
        pl.Quote__c = q.Id;
        insert pl;
        qlt.Quote__c = q.Id;
        insert qlt;
        actProdLine.Product_Line__c = pl.Id;
        insert actProdLine;
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        AccountProductLine_Batch_NEW   aplb = new AccountProductLine_Batch_NEW (je);
        Id batchId = Database.executeBatch(aplb);
        
        AccountProductLine_Batch_NEW   aplb2 = new AccountProductLine_Batch_NEW ();
        
        test.stopTest();
        
        
    }
    public testmethod static void accountProdLineBatchTest1(){
        AccountCreateController.isFirstRun= false; 
        accountTriggerHandler.TriggerDisabled = true; 
        contactTriggerHandler.TriggerDisabled = true;
        //Account acc = TestDataFactory.createTestAccountQuotePrint();
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        //Product_Line__c pl = TestDataFactory.createTestProdLine();
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        q.OpportunityId = opp.Id;
        Product_Line__c pl11 = new Product_Line__c();
        pl11.Amount__c = 1000;
        pl11.Product_Line_Picklist2__c = 'Anesthesia';
        // pl11.Cost__c = 100;
        pl11.Date_Booked__c = System.today()-10;
        pl11.Estimate__c = true;
        pl11.Opportunity__c = opp.Id;
        
        pl11.Quantity__c = 3;
        insert pl11;
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        //pl.Cost__c = 100;
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.id;
        pl.Quantity__c = 3;
        
        Quote_Line_Type__c qlt = new Quote_Line_Type__c();
        qlt.Amount__c = 1000;
        qlt.Cost__c = 100;
        qlt.Date_Booked__c = System.today()-5;
        qlt.Estimate__c = true;
        opp.AccountId = acc.id;
        qlt.Opportunity__c = opp.Id;
        qlt.Quantity__c = 3;
        Business_Segment__c bs = new Business_Segment__c();
        bs.Amount__c = 1000;
        bs.Cost__c = 100;
        bs.Date_Booked__c = System.today()-5;
        bs.Estimate__c = true;
        
        Account_Business_Segment__c actbusSeg = new Account_Business_Segment__c();
        actbusSeg.Account__c = acc.id;
        actbusSeg.Amount_Booked__c = 1000;
        actbusSeg.Amount_Estimated__c = 1000;
        actbusSeg.Last_Product_Sold_Date__c = System.today()-5;
        actbusSeg.Business_Segment__c = bs.id;
        actbusSeg.createddate = System.today()-10;
        insert actbusSeg;
        
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        
        test.startTest();
        insert q;
        pl.Quote__c = q.Id;
        insert pl;
        qlt.Quote__c = q.Id;
        insert qlt;
        bs.Quote__c = q.Id;
        insert bs;
        AccountProductLine_Batch_NEW aplb = new AccountProductLine_Batch_NEW(je);
        Id batchId = Database.executeBatch(aplb, 100);
        test.stopTest();
    }
    
    public testmethod static void accountProdLineBatchTest2(){
        AccountCreateController.isFirstRun= false; 
        opportunityTriggerHandler.TriggerDisabled = true;
        accountTriggerHandler.TriggerDisabled = true;
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        
        //   Product_Segment__c ps = TestDataFactory.createTestProdSegment(acc);
        
        Product_Segment__c ps = new Product_Segment__c();
        ps.Amount__c = 1000;
        ps.Cost__c = 100;
        ps.Date_Booked__c = System.today()-5;
        ps.Estimate__c = true;
        Opportunity opp = new Opportunity();
        opp.ExpectedInstallDate__c = System.Today();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        //Account acc = new Account(name='Test Acc for Opp for Product Segment',Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        // Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        insert opp;
        Product_Line__c pl11 = new Product_Line__c();
        pl11.Amount__c = 1000;
        pl11.Product_Line_Picklist2__c = 'Anesthesia';
        // pl11.Cost__c = 100;
        pl11.Date_Booked__c = System.today()-10;
        pl11.Estimate__c = true;
        pl11.Opportunity__c = opp.Id;
        
        pl11.Quantity__c = 3;
        insert pl11;
        ps.Opportunity__c = opp.Id;
        ps.Quantity__c = 3;
        
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        //quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        //quote.ContactId= createTestContact(true, createUSTestAccount().id, 'Testnamett1',null).id;
        //Contact cont= createContactWithAccount_Integration();
        quote.OpportunityId = TestDataFactory.createOppWithAccount().Id;
        Opportunity opp2 = [select accountid from opportunity where id=:quote.opportunityId];//sravan 22feb
        TestDataFactory.createProductLine(opp2.id);
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);//sravan 22feb
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        //quote.Bill_to_Account__c = createTestAccountQuotePrint().Id;
        quote.Bill_to_Account__c = opp.AccountId;//Sravan 22feb
        quote.Pricebook2Id = Test.getStandardPricebookId();
        
        // ===
        ps.Product_Segment__c='Test';
        
        Account_Product_Segment__c actProdSeg = new Account_Product_Segment__c();
        actProdSeg.Account__c = acc.id;
        actProdSeg.Amount_Booked__c = 1000;
        actProdSeg.Amount_Estimated__c = 1000;
        actProdSeg.Last_Product_Sold_Date__c = System.today()-5;
        actProdSeg.Product_Segment__c = ps.id;
        actProdSeg.createddate = System.today()-10;
        // ====
        
        test.startTest();
        insert quote;
        
        ps.Quote__c = quote.Id;
        /*    ps.Product_Segment__c='Test';

Account_Product_Segment__c actProdSeg = new Account_Product_Segment__c();
actProdSeg.Account__c = acc.id;
actProdSeg.Amount_Booked__c = 1000;
actProdSeg.Amount_Estimated__c = 1000;
actProdSeg.Last_Product_Sold_Date__c = System.today()-5;
actProdSeg.Product_Segment__c = ps.id;
actProdSeg.createddate = System.today()-10; */
        insert actProdSeg;
        
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        
        //  test.startTest();
        AccountProductSegment_DELETE_Bacth aplb = new AccountProductSegment_DELETE_Bacth(je);
        Id batchId = Database.executeBatch(aplb, 100);
        
        AccountProductSegment_DELETE_Bacth aplb2 = new AccountProductSegment_DELETE_Bacth();
        test.stopTest();
    }
    
    public testmethod static void accountProdLineBatchTest3(){
        AccountCreateController.isFirstRun= false;
        accountTriggerHandler.TriggerDisabled = true;
        opportunityTriggerHandler.TriggerDisabled = true;
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        
        //  Quote_Line_Type__c ql = TestDataFactory.createTestQuoteLineItemType();
        Quote_Line_Type__c qlt = new Quote_Line_Type__c();
        qlt.Amount__c = 1000;
        qlt.Cost__c = 100;
        qlt.Date_Booked__c = System.today()-5;
        qlt.Estimate__c = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.Today();
        //Account acc = new Account(name='Test Acc for Opp for QuoteLineItemType',Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        opp.AccountId = acc.id;
        insert opp;
        Product_Line__c pl11 = new Product_Line__c();
        pl11.Amount__c = 1000;
        pl11.Product_Line_Picklist2__c = 'Anesthesia';
        // pl11.Cost__c = 100;
        pl11.Date_Booked__c = System.today()-10;
        pl11.Estimate__c = true;
        pl11.Opportunity__c = opp.Id;
        
        pl11.Quantity__c = 3;
        insert pl11;
        qlt.Opportunity__c = opp.Id;
        qlt.Quantity__c = 3;
        
        //  qlt.Quote__c = createPrimaryTestQuote().Id;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        //quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        //quote.ContactId= createTestContact(true, createUSTestAccount().id, 'Testnamett1',null).id;
        //Contact cont= createContactWithAccount_Integration();
        quote.OpportunityId = TestDataFactory.createOppWithAccount().Id;
        Opportunity opp2 = [select accountid from opportunity where id=:quote.opportunityId];//sravan 22feb
        TestDataFactory.createProductLine(opp2.id);
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);//sravan 22feb
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        //quote.Bill_to_Account__c = createTestAccountQuotePrint().Id;
        quote.Bill_to_Account__c = opp.AccountId;//Sravan 22feb
        quote.Pricebook2Id = Test.getStandardPricebookId();
        
        //  insert quote;
        //  qlt.Quote__c = quote.Id;
        
        //  insert qlt;
        
        Account_Quote_Line_Item_Type__c actqtlinetype = new Account_Quote_Line_Item_Type__c();
        actqtlinetype.Account__c = acc.id;
        actqtlinetype.Amount_Booked__c = 1000;
        actqtlinetype.Amount_Estimated__c = 1000;
        actqtlinetype.Last_Product_Sold_Date__c = System.today()-5;
        //   actqtlinetype.Quote_Line_Type__c = qlt.id;
        actqtlinetype.createddate = System.today()-10;
        //    insert actqtlinetype;
        
        test.startTest();
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        
        insert quote;
        qlt.Quote__c = quote.Id;
        
        insert qlt;
        actqtlinetype.Quote_Line_Type__c = qlt.id;
        
        insert actqtlinetype;
        
        AccountQuoteLineItemType_DELETE_Batch aplb = new AccountQuoteLineItemType_DELETE_Batch(je);
        Id batchId = Database.executeBatch(aplb, 100);
        
        AccountQuoteLineItemType_DELETE_Batch aplb2 = new AccountQuoteLineItemType_DELETE_Batch();
        //test.stopTest();
        
        //Test.startTest();
        /*   ScheduleAccountProductFamilyBatch_New sh1 = new ScheduleAccountProductFamilyBatch_New();
String sch = '0 0 2 * * ?'; 
system.schedule('Account Product Line Batch New1', sch, sh1); 
*/
        Test.stopTest();
    }
    
    public testmethod static void accountProdLineBatchTest4(){
        AccountCreateController.isFirstRun= false; 
        opportunityTriggerHandler.TriggerDisabled = true;
        accountTriggerHandler.TriggerDisabled = true;
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        
        //  Business_Segment__c bs = TestDataFactory.createTestBusinessSegment();
        Business_Segment__c ps = new Business_Segment__c();
        ps.Amount__c = 1000;
        ps.Cost__c = 100;
        ps.Date_Booked__c = System.today()-5;
        ps.Estimate__c = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.Today();
        //Account acc = new Account(name='Test Acc for Opp for Business Segment',Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        opp.AccountId = acc.id;
        insert opp;
        Product_Line__c pl11 = new Product_Line__c();
        pl11.Amount__c = 1000;
        pl11.Product_Line_Picklist2__c = 'Anesthesia';
        // pl11.Cost__c = 100;
        pl11.Date_Booked__c = System.today()-10;
        pl11.Estimate__c = true;
        pl11.Opportunity__c = opp.Id;
        
        pl11.Quantity__c = 3;
        insert pl11;
        ps.Opportunity__c = opp.Id;
        ps.Quantity__c = 3;
        
        // ps.Quote__c = TestDataFactory.createPrimaryTestQuote().Id;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        //quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        //quote.ContactId= createTestContact(true, createUSTestAccount().id, 'Testnamett1',null).id;
        //Contact cont= createContactWithAccount_Integration();
        quote.OpportunityId = TestDataFactory.createOppWithAccount().Id;
        Opportunity opp2 = [select accountid from opportunity where id=:quote.opportunityId];//sravan 22feb
        TestDataFactory.createProductLine(opp2.id);
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);//sravan 22feb
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        //quote.Bill_to_Account__c = createTestAccountQuotePrint().Id;
        quote.Bill_to_Account__c = opp.AccountId;//Sravan 22feb
        quote.Pricebook2Id = Test.getStandardPricebookId();
        
        //insert quote;
        
        //  ps.Quote__c = quote.Id;
        
        ps.Business_Segment__c='Test';
        //  insert ps;
        
        Account_Business_Segment__c actbusSeg = new Account_Business_Segment__c();
        actbusSeg.Account__c = acc.id;
        actbusSeg.Amount_Booked__c = 10;
        actbusSeg.Amount_Estimated__c = 10;
        actbusSeg.Last_Product_Sold_Date__c = System.today()-5;
        //   actbusSeg.Business_Segment__c = ps.id;
        actbusSeg.createddate = System.today()-10;
        //   insert actbusSeg;
        test.startTest();
        
        insert quote;
        ps.Quote__c = quote.Id;
        
        insert ps;
        actbusSeg.Business_Segment__c = ps.id;
        
        insert actbusSeg;
        
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        
        AccountBusinessSegment_DELETE_Bacth aplb = new AccountBusinessSegment_DELETE_Bacth(je);
        Id batchId = Database.executeBatch(aplb, 100);
        
        AccountBusinessSegment_DELETE_Bacth aplb2 = new AccountBusinessSegment_DELETE_Bacth();
        test.stopTest();
    }
    
    public testmethod static void accountProdLineBatchTest5(){
        contactTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false; 
        accountTriggerHandler.TriggerDisabled = true;
        opportunityTriggerHandler.TriggerDisabled = true;
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        // pl.Cost__c = 100;
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        
        // pl.Opportunity__c = createOppWithAccount().Id;
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        //  Account acc = TestDataFactory.createTestAccountQuotePrint();
        //  //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //   //insert acc;
        //   
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.ExpectedInstallDate__c = System.Today();
        insert opp;
        
        pl.Opportunity__c = opp.Id;
        
        pl.Quantity__c = 3;
        insert pl;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        //quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        //quote.ContactId= createTestContact(true, createUSTestAccount().id, 'Testnamett1',null).id;
        //Contact cont= createContactWithAccount_Integration();
        //   quote.OpportunityId = createOppWithAccount().Id;
        quote.OpportunityId = opp.Id;
        
        Opportunity opp2 = [select accountid from opportunity where id=:quote.opportunityId];//sravan 22feb
        
        // createProductLine(opp2.id);
        Product_Line__c pl2 = new Product_Line__c();
        pl2.Portfolio_Segment__c = 'IVX Workflow';
        pl2.Amount__c = 10000;
        pl2.Opportunity__c =opp2.id;   
        pl2.Date_Booked__c = System.Today();
        pl2.Product_Line_Picklist2__c = 'Anesthesia';
        insert pl2;
        Quote_Line_Type__c qlt = new Quote_Line_Type__c();
        qlt.Amount__c = 1000;
        qlt.Cost__c = 100;
        qlt.Date_Booked__c = System.today()-5;
        qlt.Estimate__c = true;
        qlt.Opportunity__c = opp.Id;
        qlt.Quantity__c = 3;
        //  Contact cont = createContactForAcc(opp2.AccountId);//sravan 22feb
        TestDataFactory.castIronCSetting();//Haripriya
        TestDataFactory.dCurrencyCCodeCSetting();//Haripriya        
        Contact cont = new Contact();
        cont.LastName='Smith'+ system.now().millisecond();
        cont.Is_Active__c ='Y';
        cont.AccountId = opp2.AccountId;
        insert cont;
        
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        //quote.Bill_to_Account__c = createTestAccountQuotePrint().Id;
        quote.Bill_to_Account__c = opp.AccountId;//Sravan 22feb
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        qlt.Quote__c = quote.Id;
        
        insert qlt;
        
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Quote__c = quote.Id;
        pl.Date_Booked__c = System.Today();
        update pl;
        Account_Product_Line__c actProdLine = new Account_Product_Line__c();
        actProdLine.Account__c = acc.id;
        actProdLine.Amount_Booked__c = 1000;
        actProdLine.Amount_Estimated__c = 1000;
        actProdLine.Last_Product_Sold_Date__c = System.today()-5;
        actProdLine.Product_Line__c = pl.Id;
        actProdLine.createddate = System.today()-10;
        insert actProdLine;
        
        
        test.startTest();
        
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        ScheduleAccountProductFamilyBatch_New sh1 = new ScheduleAccountProductFamilyBatch_New();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Account Product Line Batch New1', sch, sh1); 
        
        test.stopTest();
        
        
    }   
}