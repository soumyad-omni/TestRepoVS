/**
* @File Name          : QuoteTriggerHandlerTest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 5/6/2020, 6:02:51 pm
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    5/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class QuoteTriggerHandlerTest {
    
    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();      
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
    
    @isTest
    public static void quoteAfterInsert(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        userTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        Test.startTest();
        Quote quote = TestDataFactory.createTestQuote1();   
        Test.stopTest();
    }
    
    @isTest
    public static void quoteAfterupdate(){
        userTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1();
        Quote.Supplement_Version__c = 2;
        Quote.Name = 'Test Update Quote';        
        Quote.Master_Agreement__c = '123456';
        Quote.Shipping_Instructions__c = 'Test shipp inst';
        Quote.Service_Level__c = 'GD';
        Quote.Net_Weight__c = 20.5;
        Quote.Total_Cost__c = 100;
        Quote.Overhead_Cost__c = 50;
        Quote.Labor_Cost__c = 10;
        Quote.Net_Value__c = 100;
        Quote.Posting_Date__c = Date.newInstance(2019, 5, 11);
        Quote.Exchange_Rate__c = 2.0;
        Quote.EOL_Date__c = System.now()+2000;
        Quote.Fee_Increase__c = 10;
        Quote.SAP_Expected_Bookings__c = 200;
        Quote.SAP_NPV__c = 20;        
        Quote.Freight_Price__c = 10;        
        Quote.Supplement_Generated__c = '01';
        Quote.Status = 'E0018';
        Quote.Primary_Quote__c = true;
        Quote.From__c = Date.newInstance(2019, 2, 11);
        Quote.ExpirationDate = Date.newInstance(2021, 2, 11);
        Quote.Has_Critical_Errors__c = true;        
        Quote.Region__c = 'Northeast';
        Quote.Description = 'Test Desc';
        Quote.Currency__c = 'AWG';        
        Quote.Quote_Margin__c = 10;
        Quote.Freight_Price__c = 20;        
        Quote.Tax = 30;        
        Quote.Total_Net__c = 200;        
        Quote.Terms_of_Payment__c = 'MD20'; 
        Quote.Incoterms_1__c = 'COL';
        Quote.Incoterms_2__c = 'test'; 
        Quote.Order_Net_Price__c = 200;
        Quote.GSA_Result1__c = 'Test GSA';        
        Quote.GSA_Net_Price__c = 20;
        Quote.GSA_Price_Difference__c = 12;
        Quote.Quote_Revision__c = '2';
        Quote.Quote_Number__c = '12345';
        Quote.SAP_Sales_Order_Number__c = '12345';
        Quote.Quote_Margin_Comments__c = 'test comments';        
        Quote.Product_PO_Number__c = '12345';
        Quote.Service_PO_Number__c = '12345';
        Quote.Re_Opened__c = true;
        Quote.Reopen_Reason__c = 'Test Reason';        
        Quote.Exchange_Rate_Override__c = False;
        Quote.Sales_Org__c = 'OM01';        
        Quote.Lease_Duration__c = 20;
        Quote.Free_Month_for_Lease__c = 2.5;        
        Quote.Shipping_Conditions__c = 'AE';
        Quote.Service_Escalator__c = 20;
        Quote.Free_Month_Service__c = 2.5;
        Quote.Renewal_Revenue__c = 200;
        Quote.Service_Duration__c = 25;        
        Quote.Service_Start_Date__c = Date.newInstance(2019,02,13);        
        Quote.Net_Interest_Rate__c = 12;
        Quote.Monthly_Product_Lease_Payment__c = 50;
        Quote.Monthly_Service_Lease_payment__c = 20;        
        Quote.Booking_Date__c = Date.newInstance(2019,02,14);        
        Quote.Pricing_Reference_Date__c = Date.newInstance(2019,2,15);
        Quote.Requested_Delivery_Date__c = Date.newInstance(2019,12,15);        
        Quote.Email = 'test@test.com';
        Quote.Phone = '9999999999';        
        Quote.ProductChangeError__c = 'Test Error';
        Quote.SAPError__c = 'Test Error';        
        Quote.Hospital_Contact_Notes__c = 'test notes';
        Quote.Inv_Text_Notes__c = 'test notes';
        Quote.Quote_Printout_Standard_Text__c = 'Test Notes';
        Quote.Other_Notes__c = 'Test notes';
        Quote.Quote_Text__c = 'Test text';
        Quote.Special_Instructions__c = 'Test spcl Inst';
        Quote.Sales_Ops_Notes__c = 'Test Notes';
        Quote.Rework_Comments__c = 'test comm';
        Quote.Status = 'E0013';
        Quote.Print_Currency__c = ''; 
        Test.startTest();
        Quote.IDN_Price_List__c = 'AS';
        Quote.GPO_Price_Lists__c = 'PC';
        	update Quote;
        Test.stopTest();
    }
    
    @isTest
    public static void quoteAfterupdate2(){
        userTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1();
        Quote.SAP_Expected_Bookings__c = 2000;
        Quote.Service_PO_Date__c = system.today();
        Test.startTest();
            update Quote;
            Quote.Status = 'E0013';
            Quote.Primary_Quote__c = True;
            Quote.Supplement_Generated__c = '01';
            Quote.Product_PO_Number__c = '12345';
            Quote.Service_PO_Number__c = '12345';
            QuoteTriggerHandler.updatefromqa = False;
            update Quote;
        Test.stopTest();
        
    }
    
    @isTest
    public static void quoteAfterupdate3(){
        userTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1(); 
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT',DW_Product_Family__c='test');
        insert prod;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = Quote.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1; 
        ql.Product__c = prod.Id;
        insert ql;
        Test.startTest();
        Quote.Order_Type__c = 'ZQRS';
        	update Quote;
        Test.stopTest();
    }
    
    @isTest
    public static void quotebeforeupdate(){
        AccountCreateController.isFirstRun= false;
        userTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1();
        Quote.Supplement_Version__c = 2;
        Quote.status = 'E0018';
        Quote.Name = 'Test Update Quote';
        Quote.Master_Agreement__c = '123456';
        Quote.Shipping_Instructions__c = 'Test shipp inst';
        Quote.Service_Level__c = 'GD';
        Quote.Net_Weight__c = 20.5;
        Quote.Total_Cost__c = 100;
        Quote.Overhead_Cost__c = 50;
        Quote.Labor_Cost__c = 10;
        Quote.Net_Value__c = 100;
        Quote.Posting_Date__c = Date.newInstance(2019, 5, 11);
        Quote.Exchange_Rate__c = 2.0;
        Quote.EOL_Date__c = System.now()+2000;
        Quote.Fee_Increase__c = 10;
        Quote.SAP_Expected_Bookings__c = 200;
        Quote.SAP_NPV__c = 20;
        Quote.Freight_Price__c = 10;
        Quote.Supplement_Generated__c = '01';     
        Quote.Status = 'E0018';
        Quote.Primary_Quote__c = true;
        Quote.From__c = Date.newInstance(2019, 2, 11);
        Quote.ExpirationDate = Date.newInstance(2021, 2, 11);
        Quote.Has_Critical_Errors__c = true;
        Quote.Region__c = 'Northeast';
        Quote.Description = 'Test Desc';
        Quote.Currency__c = 'AWG';
        Quote.Print_Currency__c = 'AED';
        Quote.Quote_Margin__c = 10;
        Quote.Freight_Price__c = 20;
        Quote.Tax = 30;
        Quote.Total_Net__c = 200;
        Quote.IDN_Price_List__c = 'AS';
        Quote.GPO_Price_Lists__c = 'PC';
        Quote.Terms_of_Payment__c = 'MD20'; 
        Quote.Incoterms_1__c = 'COL';
        Quote.Incoterms_2__c = 'test';
        Quote.Order_Net_Price__c = 200;
        Quote.GSA_Result1__c = 'Test GSA';
        Quote.GSA_Net_Price__c = 20;
        Quote.GSA_Price_Difference__c = 12;
        Quote.Quote_Revision__c = '2';
        Quote.Quote_Number__c = '12345';
        Quote.SAP_Sales_Order_Number__c = '12345';
        Quote.Quote_Margin_Comments__c = 'test comments';
        Quote.Product_PO_Number__c = '12345';
        Quote.Service_PO_Number__c = '12345';
        Quote.Re_Opened__c = true;
        Quote.Reopen_Reason__c = 'Test Reason';
        Quote.Lease_Duration__c = 20;
        Quote.Free_Month_for_Lease__c = 2.5;
        Quote.Shipping_Conditions__c = 'AE';
        Quote.Service_Escalator__c = 20;
        Quote.Free_Month_Service__c = 2.5;
        Quote.Renewal_Revenue__c = 200;
        Quote.Service_Duration__c = 25;
        Quote.Service_Start_Date__c = Date.newInstance(2019,02,13);
        Quote.Net_Interest_Rate__c = 12;
        Quote.Monthly_Product_Lease_Payment__c = 50;
        Quote.Monthly_Service_Lease_payment__c = 20;
        Quote.Booking_Date__c = Date.newInstance(2019,02,14);
        Quote.Pricing_Reference_Date__c = Date.newInstance(2019,2,15);
        Quote.Requested_Delivery_Date__c = Date.newInstance(2019,12,15);
        Quote.Email = 'test@test.com';
        Quote.Phone = '9999999999';
        Quote.ProductChangeError__c = 'Test Error';
        Quote.SAPError__c = 'Test Error';
        Quote.Hospital_Contact_Notes__c = 'test notes';
        Quote.Inv_Text_Notes__c = 'test notes';
        Quote.Quote_Printout_Standard_Text__c = 'Test Notes';
        Quote.Other_Notes__c = 'Test notes';
        Quote.Quote_Text__c = 'Test text';
        Quote.Special_Instructions__c = 'Test spcl Inst';
        Quote.Sales_Ops_Notes__c = 'Test Notes';
        Quote.Rework_Comments__c = 'test comm';
        Quote.Legacy_SAP_Created_Date__c = Date.newInstance(2019,2,15);
        Quote.Print_Exchange_Rate__c = 10;
        Quote.Quote_Type_Changed__c = True;
        Quote.Service_Duration__c = 60;
        Quote.Lease_Duration__c = 12;
        Quote.GPO_Price_Lists__c = 'HB';
        Quote.Posting_Date__c = Date.newInstance(2019,2,15);
        Quote.From__c = Date.newInstance(2019,2,25);
        Quote.Name = 'BBBBB';
        Quote_Field_History__c qfh = new Quote_Field_History__c();
        qfh.FIELD__c = 'Corporate_Agreement_Pricing_Expiration__c';
        qfh.Quote__c = Quote.Id;        
        Map<Id, Quote> newItems= new Map<Id, Quote>();
        newItems.put(Quote.Id, Quote);
        Map<Id, Quote> oldItems=  new Map<Id, Quote>();
        oldItems.put(Quote.Id, Quote);
        QuoteTriggerHandler qr = new QuoteTriggerHandler();
        qr.checkSelectedChange(newItems, oldItems);
        List<Quote> oldquoteList = new List<Quote>();
        oldquoteList.add(Quote);
        List<Quote> quoteList = new List<Quote>();
        Quote qlist = new Quote();
        quoteList.add(qlist);
        Quote_Line__C ql = TestDataFactory.createTestQuoteLineForQuote(quote.id);
        QuoteTriggerHandler qr1= new QuoteTriggerHandler();
        Test.startTest();
        	update quote;    
        Test.stopTest();
    }   
    
    @isTest
    public static void quotebeforeupdate2(){
        AccountCreateController.isFirstRun= false;
        userTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1();
        quote.Milestone_Invoice_Term__c = '01';
        quote.Region__c = 'Central';
        quote.Exchange_Rate_Override__c = True;
        quote.GSA_Result__c = 'Yes';
        quote.Email = 'anc@none.com';
        quote.Phone = '1234567125';
        Test.startTest();
        	update quote;    
        Test.stopTest();
    }
    
    @isTest
    public static void testCheckOldAndNewQuote(){
        
        Quote oldqte = new Quote();
        Quote newqte = new Quote();
        QuoteTriggerHandler.checkOldAndNewQuote(oldqte, newqte);
        AccountCreateController.isFirstRun= false;
        userTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1();
        quote.Milestone_Invoice_Term__c = '01';
        quote.Region__c = 'Central';
        quote.Exchange_Rate_Override__c = True;
        quote.GSA_Result__c = 'Yes';
        quote.Email = 'anc@none.com';
        quote.Phone = '1234567125';
        Test.startTest();
        	QuoteTriggerHandler.TriggerDisabled = True;
        	update quote;    
        	QuoteTriggerHandler.TriggerDisabled = False;
        	quote.Region__c = 'Northeast';
        	quote.Exchange_Rate_Override__c = False;
        	update quote; 
        Test.stopTest();
    }
    
    @isTest
    public static void quoteAfterupdate4(){
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Representative' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles'); 
        UserTriggerHandler.TriggerDisabled = True;
        insert u;
        System.RunAs(u)
        {
            userTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1();
        Quote.Name = 'Test Update Quote';        
        
        Test.startTest();
        	update Quote;
        Test.stopTest();
        }
    }
}