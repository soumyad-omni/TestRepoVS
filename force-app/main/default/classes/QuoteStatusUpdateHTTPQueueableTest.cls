@isTest
public class QuoteStatusUpdateHTTPQueueableTest {
    private class MockHttpResponseSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"QuoteNo": "123", "RevisionNo": "1", "ItemCount": 2}');
            return res;
        }
    }
    private class MockHttpResponseFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Simulated error"}');
            return res;
        }
    }
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();    
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        setting.Print_Compare_End_Point__c = 'https://appconnazdev.omnicell.com/QuoteRevNoItemCountSFDCtoSAPtoSFDCDEV';
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
        
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
    }
    @isTest
    public static void testQueueableSuccess() {
        CastIronIntegration__c  setting1 = new CastIronIntegration__c ();
        setting1.Name = 'CastIronIntegration';
        setting1.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting1.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        setting1.Print_Compare_End_Point__c = 'https://appconnazdev.omnicell.com/QuoteRevNoItemCountSFDCtoSAPtoSFDCDEV';
        insert setting1;
        Compare_Integration_Creds__c testsetting = new Compare_Integration_Creds__c(Name = 'Compare Creds',
                                                                               Endpoint__c='https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT',
                                                                               Timeout__c='120000');
        insert testsetting;
        ProductLineTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.Account_Status__c = 'Prospect';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        AccountTriggerHandler.TriggerDisabled = true;
        update acc;
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp.name = 'Test Opp';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+20;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        insert opp;
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 1;
        insert pl;
        
        QuoteTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.status='E0001';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        quote.Order_Type__c = 'ZHQR';
        quote.OpportunityId = opp.Id;
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        quote.Bill_to_Account__c = opp.AccountId;
        insert quote;
        
        opp.stageName = '7 Closed Lost';
        opp.OppStatus__c = 'Lost';
        update opp;
        Quote testQuote = new Quote();
        testQuote.name = 'Primary Test Quote';
        testQuote.Quote_Number__c = 'test112';
        testQuote.status='E0001';
        testQuote.Primary_Quote__c=true;
        testQuote.Region__c='Northeast';
        testQuote.Order_Type__c = 'ZHQR';
        testQuote.OpportunityId = opp.Id;
        Contact cont1 = TestDataFactory.createContactForAcc(opp.AccountId);
        testQuote.ContactId= cont.id;
        testQuote.Shipping_Contact__c= cont1.Id;
        testQuote.Bill_to_Account__c = opp.AccountId;
        insert testQuote;
        Test.startTest();
        CastIronIntegration__c csValue1 = [Select Print_Compare_End_Point__c FROM CastIronIntegration__c Where Name = 'CastIronIntegration' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess());
        QuoteStatusUpdateHTTPQueueable queueable = new QuoteStatusUpdateHTTPQueueable(new List<Quote>{quote}, String.ValueOf(testQuote.Id));
        System.enqueueJob(queueable);
        Test.stopTest();
    }
    @isTest
    public static void testCallingQueueable() {
        ProductLineTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.Account_Status__c = 'Prospect';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        AccountTriggerHandler.TriggerDisabled = true;
        update acc;
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp.name = 'Test Opp';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+20;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        insert opp;
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 1;
        insert pl;
        
        QuoteTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.status='E0001';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        quote.Order_Type__c = 'ZHQR';
        quote.OpportunityId = opp.Id;
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        quote.Bill_to_Account__c = opp.AccountId;
        insert quote;
        
        opp.stageName = '7 Closed Lost';
        opp.OppStatus__c = 'Lost';
        update opp;
        Quote testQuote = new Quote();
        testQuote.name = 'Primary Test Quote';
        testQuote.Quote_Number__c = 'test112';
        testQuote.status='E0001';
        testQuote.Primary_Quote__c=true;
        testQuote.Region__c='Northeast';
        testQuote.Order_Type__c = 'ZHQR';
        testQuote.OpportunityId = opp.Id;
        Contact cont1 = TestDataFactory.createContactForAcc(opp.AccountId);
        testQuote.ContactId= cont.id;
        testQuote.Shipping_Contact__c= cont1.Id;
        testQuote.Bill_to_Account__c = opp.AccountId;
        insert testQuote;
        
		Quote quote1 = new Quote();
        quote1.name = 'Test Quote1';
        quote1.Quote_Number__c = 'test113';
        quote1.status='E0001';
        quote1.Primary_Quote__c=true;
        quote1.Region__c='Northeast';
        quote1.Order_Type__c = 'ZQRL';
        //quote1.IDN_Price_List__c = 'E6';
        quote1.OpportunityId = opp.Id;
        quote1.ContactId= cont.id;
        quote1.Shipping_Contact__c= cont.Id;
        quote1.Bill_to_Account__c = opp.AccountId;
        insert quote1;

        Quote_Cancel_Status__c qtupd = new Quote_Cancel_Status__c();
        qtupd.QuoteId__c = quote.Id;
        qtupd.Status__c = '';
        qtupd.Updated_Date__c = System.Today();
        insert qtupd;
        
        Quote_Cancel_Status__c qtupd1 = new Quote_Cancel_Status__c();
        qtupd1.QuoteId__c = quote1.Id;
        qtupd1.Status__c = '';
        qtupd1.Updated_Date__c = System.Today();
        insert qtupd1;
        
        Test.startTest();
        QuoteStatusUpdateQueueable queue1 = new QuoteStatusUpdateQueueable(new List<Quote>{quote});
        System.enqueueJob(queue1);
        try{
            quote1.IDN_Price_List__c = 'E6';
            update quote1;
        }catch(Exception e) {
            QuoteStatusUpdateQueueable queue2 = new QuoteStatusUpdateQueueable(new List<Quote>{quote1});
        	System.enqueueJob(queue2);
        }
        
        Test.stopTest();
    }
}