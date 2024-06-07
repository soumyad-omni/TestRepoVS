@isTest
public class ChangeOrderInsertQuoteKeyTest
{
    public static testMethod void method1()
    {
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
        insert obj;
        
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
        insert obj1;
        
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        
        Account_DataLoad__c  adSettings = new Account_DataLoad__c ();
        adSettings.Name = 'Dataload';
        adSettings.isDisabled__c = false;
        insert adSettings;
        
        Account_SendEmail_Off__c  asoSettings = new Account_SendEmail_Off__c ();
        asoSettings.Name = 'Account SendEmail Off';
        asoSettings.Account_SendEmail_Off__c = false;
        insert asoSettings;
        
        AccountTriggerHandler.TriggerDisabled = True;
        OpportunityTriggerHandler.TriggerDisabled = True;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        insert acc;
        
        Id oppRecordType = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'NAA_Opportunity' limit 1].id;//IBA-5024
        
        Opportunity opp = new Opportunity();
        opp.name = 'opp';
        opp.RecordTypeId = oppRecordType;
        opp.stageName = '6 Closed Won';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Fully Booked';
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Opportunity__c = 'Omnicell Opportunity';
        opp.Services_Enablement_Owner__c = 'Adam Barrios';
        insert opp;
        
        Opportunity opp1 = new Opportunity();
        opp1.name = 'opp1';
        opp1.RecordTypeId = oppRecordType;
        opp1.stageName = '6 Closed Won';
        opp1.CloseDate = System.today();
        opp1.AccountId = acc.id;
        opp1.OppStatus__c = 'Fully Booked';
        opp1.Associated_Opportunity__c = opp.Id;
        opp1.ExpectedInstallDate__c = System.today()+60;
        opp1.Opportunity__c = 'Omnicell Opportunity';
        opp1.Services_Enablement_Owner__c = 'Adam Barrios';
        insert opp1;
        
        Opportunity opp2 = new Opportunity();
        opp2.name = 'opp2';
        opp2.RecordTypeId = oppRecordType;
        opp2.stageName = '6 Closed Won';
        opp2.CloseDate = System.today();
        opp2.AccountId = acc.id;
        opp2.OppStatus__c = 'Fully Booked';
        opp2.Associated_Opportunity__c = opp1.Id;
        opp2.ExpectedInstallDate__c = System.today()+60;
        opp2.Opportunity__c = 'Omnicell Opportunity';
        opp2.Services_Enablement_Owner__c = 'Adam Barrios';
        insert opp2;
        
        Opportunity opp3 = new Opportunity();
        opp3.name = 'opp2';
        opp3.RecordTypeId = oppRecordType;
        opp3.stageName = '6 Closed Won';
        opp3.CloseDate = System.today();
        opp3.AccountId = acc.id;
        opp3.OppStatus__c = 'Fully Booked';
        opp3.Associated_Opportunity__c = opp2.Id;
        opp3.ExpectedInstallDate__c = System.today()+60;
        opp3.Opportunity__c = 'Omnicell Opportunity';
        opp3.Services_Enablement_Owner__c = 'Adam Barrios';
        insert opp3;
        
        Opportunity opp4 = new Opportunity();
        opp4.name = 'opp2';
        opp4.RecordTypeId = oppRecordType;
        opp4.stageName = '6 Closed Won';
        opp4.CloseDate = System.today();
        opp4.AccountId = acc.id;
        opp4.OppStatus__c = 'Fully Booked';
        opp4.Associated_Opportunity__c = opp3.Id;
        opp4.ExpectedInstallDate__c = System.today()+60;
        opp4.Opportunity__c = 'Change Order - Credit';
        opp4.Services_Enablement_Owner__c = 'Adam Barrios';
        insert opp4;

        List<Quote> quoteList = new List<Quote>();
        List<Quote_Line__c> quoteLineList = new List<Quote_Line__c>();
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.OpportunityId = opp.Id;
        quote.Primary_Quote__c = TRUE;
        quote.Order_Type__c = 'ZHQR';
        quoteList.add(quote);
        
        Quote quote1 = new Quote();
        quote1.name = 'Test Quote';
        quote1.Pricebook2Id = Test.getStandardPricebookId();
        quote1.OpportunityId = opp1.Id;
        quote1.Primary_Quote__c = TRUE;
        quote1.Order_Type__c = 'ZHQR';
        quoteList.add(quote1);
        
        Quote quote2 = new Quote();
        quote2.name = 'Test Quote';
        quote2.Pricebook2Id = Test.getStandardPricebookId();
        quote2.OpportunityId = opp2.Id;
        quote2.Primary_Quote__c = TRUE;
        quote2.Order_Type__c = 'ZHQR';
        quoteList.add(quote2);
        
        Quote quote3 = new Quote();
        quote3.name = 'Test Quote';
        quote3.Pricebook2Id = Test.getStandardPricebookId();
        quote3.OpportunityId = opp3.Id;
        quote3.Primary_Quote__c = TRUE;
        quote3.Order_Type__c = 'ZHQR';
        quoteList.add(quote3);
        
        Quote quote4 = new Quote();
        quote4.name = 'Test Quote';
        quote4.Pricebook2Id = Test.getStandardPricebookId();
        quote4.OpportunityId = opp4.Id;
        quote4.Primary_Quote__c = TRUE;
        quote4.Order_Type__c = 'ZHQR';
        quoteList.add(quote4);
        
        insert quoteList;
        
        opp1.PrimaryQuote__c = quote1.id;
        update opp1;
        
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap',Portfolio_Segment__c='Carousels');
        insert prod;
        
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.Line_Expected_Booking__c = 200;
        ql.Par_Location__c = 'TestProduct-SV';
        ql.Product__c = prod.id;
        ql.Quote__c = quote.Id;
        quoteLineList.add(ql);
        
        Quote_Line__c ql1 = new Quote_Line__c();
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.Line_Expected_Booking__c = 200;
        ql1.Par_Location__c = 'TestProduct-SV';
        ql1.Product__c = prod.id;
        ql1.Quote__c = quote1.Id;
        quoteLineList.add(ql1);
        
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.Line_Expected_Booking__c = 200;
        ql2.Par_Location__c = 'TestProduct-SV';
        ql2.Product__c = prod.id;
        ql2.Quote__c = quote2.Id;
        quoteLineList.add(ql2);
        
        Quote_Line__c ql3 = new Quote_Line__c();
        ql3.RecordTypeId = qlNonConfigRecordType.id;
        ql3.Higher_Level_Item__c = 0;
        ql3.Quantity__c = 1;
        ql3.Line_Expected_Booking__c = 200;
        ql3.Par_Location__c = 'TestProduct-SV';
        ql3.Product__c = prod.id;
        ql3.Quote__c = quote3.Id;
        quoteLineList.add(ql3);
        
        Quote_Line__c ql4 = new Quote_Line__c();
        ql4.RecordTypeId = qlNonConfigRecordType.id;
        ql4.Higher_Level_Item__c = 0;
        ql4.Quantity__c = 1;
        ql4.Line_Expected_Booking__c = 200;
        ql4.Par_Location__c = 'TestProduct-SV';
        ql4.Product__c = prod.id;
        ql4.Quote__c = quote4.Id;
        quoteLineList.add(ql4);
        
        Quote_Line__c ql5 = new Quote_Line__c();
        ql5.RecordTypeId = qlNonConfigRecordType.id;
        ql5.Higher_Level_Item__c = 0;
        ql5.Quantity__c = 1;
        ql5.Line_Expected_Booking__c = 200;
        ql5.Par_Location__c = 'TestProduct-SV';
        ql5.Product__c = prod.id;
        ql5.Quote__c = quote4.Id;
        quoteLineList.add(ql5);
        insert quoteLineList;
        
        Change_Order_Opportunity__c coo = new Change_Order_Opportunity__c();
        coo.Associated_Opportunity__c = opp4.Associated_Opportunity__c;
        coo.Opportunity__c = opp4.Id;
        coo.Opportunity_Name__c = opp4.name;
        coo.Opportunity_Type__c = opp4.Opportunity__c;
        coo.Primary_Quote__c = opp4.PrimaryQuote__c;
        insert coo;
        
        Change_Order_Quote_Line__c coql = new Change_Order_Quote_Line__c();
        coql.Quote_Line__c = ql4.Id;
        coql.Change_Order_Opportunity__c = coo.Id;
        coql.Line_Expected_Booking__c = ql.Line_Expected_Booking__c;
        coql.Par_Location__c = ql.Par_Location__c;
        coql.Product_Code__c = ql.Product_Code__c;
        coql.Quantity__c = ql.Quantity__c;
        insert coql;
        
        Change_Order_Quote_Line__c coql1 = new Change_Order_Quote_Line__c();
        coql1.Quote_Line__c = ql5.Id;
        coql1.Change_Order_Opportunity__c = coo.Id;
        coql1.Line_Expected_Booking__c = ql.Line_Expected_Booking__c;
        coql1.Par_Location__c = ql.Par_Location__c;
        coql1.Product_Code__c = ql.Product_Code__c;
        coql1.Quantity__c = ql.Quantity__c;
        insert coql1;
        
        Change_Order_Credit_Key__c key = new Change_Order_Credit_Key__c();
        insert key;
        test.startTest();
        database.executeBatch(new ChangeOrderDeleteQuoteKey());
        
        
        test.stopTest();
    }
}