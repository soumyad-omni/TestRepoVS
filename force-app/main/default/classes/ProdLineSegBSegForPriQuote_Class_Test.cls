/***********************************************************************************************************
Name:  ProdLineSegBSegForPriQuote_Class_Test
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Test class for ProdLineSegBSegForPriQuote_Class
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Venu Kukkapalli          10/08/2018                             INITIAL DEVELOPMENT
*************************************************************************************************************/
@isTest
public class ProdLineSegBSegForPriQuote_Class_Test {
    
    @TestSetup
    public static void testDataSetup() 
    {
        // SCP_TestDataFactory.createIntDetails();
        // SCP_TestDataFactory.createCastIron();
        SCP_TestDataFactory.createContact_Customsetting();      
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        /*SCP_TestDataFactory.createContact_Customsetting();
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
        */
        
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
        
        
        TestDataFactory.eccSOrgToCRMCSetting();
        AccountCreateController.isFirstRun= false;
        //Opportunity opp = TestDataFactory.createOppWithAccount();
        QuoteTriggerHandler.TriggerDisabled=True;//IBA-3745
        Quote quote = TestDataFactory.createPrimaryTestQuote();
        Opportunity opp = [select oppStatus__c from opportunity where id=:quote.opportunityId];
        opp.oppStatus__c = Label.Fully_Booked;
        //Quote_Line__c ql = TestDataFactory.createQuoteLineItem();
        System.debug('quote.Id : '+quote.Id);
        //ql.Quote__c = quote.Id;
        //ql.Cost__c = 222;
        //ql.Quantity = 5;
        //insert ql;   
        // System.debug('Quote lineitem Id : '+ql);
       
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Material_Type__c = 'PRODUCT';
        //insert ql;
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV',DW_Product_Line__c='Test DW',Business_line__c='IV Product Solutions');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('quote.Id : '+quote.Id);
        ql.Quote__c = quote.Id;
        ql.SAP_Expected_Bookings__c = 1000;
        ql.Total_Cost__c = 2000;
        insert ql;   
        
        Quote_Line__c q2 = new Quote_Line__c();
        q2.RecordTypeId = qlNonConfigRecordType.id;
        q2.Higher_Level_Item__c = 1;
        q2.Quantity__c = 1;
        q2.Material_Type__c = 'PRODUCT';
        //insert ql;
        Product2 prod1 = new Product2(Name = 'Renewal',Family = 'test1',External_ID__c = '123450',ProductCode = 'Renewal-SV',DW_Product_Line__c='Test DW1',Business_line__c='IV Product Solutions');
        insert prod1;
        q2.Product__c = prod1.id;
        System.debug('quote.Id : '+quote.Id);
        q2.Quote__c = quote.Id;
        q2.SAP_Expected_Bookings__c = 1000;
        q2.Total_Cost__c = 2000;
        insert q2;   
    }
    
    

    static testmethod void initiateProductUpdates(){
        QuoteLineTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
         OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;  
        ProdLineSegBSegForPriQuote_Class.productLineWrapper plw = new ProdLineSegBSegForPriQuote_Class.productLineWrapper();
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new MockCalloutResponse());
        HTTPResponse res =null;
        //OmnicellConnectToCastIron_Class.deserializeResponse d = new OmnicellConnectToCastIron_Class.deserializeResponse();
        //d.id='1234';
        //d.success = true;
        Quote quote= [ select Id,Description,Name from Quote where Name=: 'Primary Test Quote' ];
        quote.Description='test description';
        quote.Supplement_Generated__c = '01';
        quote.Milestone_Invoice_Term__c = '00';
        quote.Product_PO_Number__c	 = '1234';
        quote.Service_PO_Number__c	 = '234234';
        quote.status = 'E0013';
        quote.SAP_Expected_Bookings__c = 2000;
        update quote;    

        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
       	Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Material_Type__c = 'PRODUCT';
        //insert ql;
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '3890',ProductCode = 'Renewal-SV',DW_Product_Line__c='Test DW',Business_line__c='IV Product Solutions');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('quote.Id : '+quote.Id);
        ql.Quote__c = quote.Id;
        ql.SAP_Expected_Bookings__c = 1000;
        ql.Total_Cost__c = 2000;
        insert ql;   
        quote.status = 'E0013';
        update quote;
        
        quote.Description='test description1';
        quote.SAP_Expected_Bookings__c = 3000;
        quote.Re_create_Product_Line__c = true;
        update quote;
        Test.stopTest();
    }
    
/**
Product lines should only be updated on an oppty when the oppty is in
OppStatus__c in (:Label.Non_Comissionable_Booking,:Label.Commissionable_Book_No_Service_PO,
:Label.Non_Comm_Book_No_Service_PO,:Label.Non_Comm_Book_No_Proj_Plan,:Label.Fully_Booked)
*/
    static testmethod void testProductLineUpdates() {
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;    
        Test.startTest();
        //create an oppty
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        Account acc = TestDataFactory.createUSTestAccount();
        opp.AccountId = acc.id;
       // opp.OppStatus__c = 'Fully Booked';
        opp.ExpectedInstallDate__c = date.today();
         opp.Expected_Bookings__c=9000;
        insert opp;
        
        //add a few PLs to it
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        
        Product_Line__c pl2 = new Product_Line__c();
        pl2.Amount__c = 6000;
        pl2.Product_Line_Picklist2__c = 'Autogen';
        // pl2.Cost__c = 100;
        pl2.Estimate__c = true;
        pl2.Opportunity__c = opp.Id;
        pl2.Quantity__c = 3;
        insert pl2;
        
        
        //assert the expected bookings
        List<Opportunity> oppUpdated = [select Expected_Bookings__c from Opportunity where id=:opp.id];
       System.assertEquals(9000, oppUpdated[0].Expected_Bookings__c);
        
        //assert the number of product lines
        List<Product_Line__c> plList = [select id from Product_Line__c where Opportunity__c=:opp.id];
        System.assertEquals(2, plList.size());
        
        //create a primary quote
        Quote quote = new Quote();
        DateTime sysTime = DateTime.now();
        String chron_exp = ''+ sysTime.second() + sysTime.minute() + sysTime.hour() + sysTime.day() + sysTime.month() + sysTime.year();
        quote.name = 'Primary Test Quote' + chron_exp;
        quote.Quote_Number__c = 'test111' + chron_exp;
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        quote.Order_Type__c = 'ZHQR';
        quote.OpportunityId = opp.id;
        
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        quote.Bill_to_Account__c = opp.AccountId;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        
        //assert the expected bookings - should not change
        List<Opportunity> oppUpdated1 = [select Expected_Bookings__c from Opportunity where id=:opp.id];
        System.assertEquals(9000, oppUpdated1[0].Expected_Bookings__c);
        
        //assert the number of product lines - should not change
        List<Product_Line__c> plList1 = [select id from Product_Line__c where Opportunity__c=:opp.id];
        System.assertEquals(2, plList1.size());
        
        Test.stopTest();
    }
    
    
    static testmethod void initiateProductUpdates2(){
         OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;  
        
        QuoteLineTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        ProdLineSegBSegForPriQuote_Class.productLineWrapper plw = new ProdLineSegBSegForPriQuote_Class.productLineWrapper();
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new MockCalloutResponse());
        HTTPResponse res =null;
        productlinetriggerhandler.TriggerDisabled = true;
        Quote quote= [ select Id,Description,Name from Quote where Name=: 'Primary Test Quote' ];
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        pl.Estimate__c = true;
        pl.Quote__c = quote.Id;
        pl.Quantity__c = 3;
        insert pl;
        
        Product_Line__c pl2 = new Product_Line__c();
        pl2.Amount__c = 6000;
        pl2.Product_Line_Picklist2__c = 'Autogen';
        pl2.Estimate__c = true;
        pl2.Quote__c = quote.Id;
        pl2.Quantity__c = 3;
        insert pl2;
        
        quote.Description='test description';
        quote.Supplement_Generated__c = '01';
        quote.Milestone_Invoice_Term__c = '00';
        quote.Product_PO_Number__c	 = '1234';
        quote.Service_PO_Number__c	 = '234234';
        quote.status = 'E0013';
        quote.SAP_Expected_Bookings__c = 2000;
        quote.Re_create_Product_Line__c = true;
        update quote;    

        
        
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
       	Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Material_Type__c = 'PRODUCT';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '3890',ProductCode = 'Renewal-SV',DW_Product_Line__c='Test DW',Business_line__c='IV Product Solutions');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('quote.Id : '+quote.Id);
        ql.Quote__c = quote.Id;
        ql.SAP_Expected_Bookings__c = 1000;
        ql.Total_Cost__c = 2000;
        insert ql;   
        quote.status = 'E0013';
        update quote;
        
        quote.Description='test description1';
        quote.SAP_Expected_Bookings__c = 3000;
        quote.Re_create_Product_Line__c = true;
        update quote;
        
         
        Test.stopTest();
    }
    
}