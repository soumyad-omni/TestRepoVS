@isTest
public class ChangeOrderChildOpportunitiesBatchTest
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
        opp.RecordTypeId = oppRecordType;
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Development';
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Adam Barrios';
        insert opp;
        
        
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
        //Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;
        quote.Primary_Quote__c = TRUE;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 100;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Line_Status__c = 'E0003';
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap',Portfolio_Segment__c='Carousels');
        insert prod;
        ql.Product__c = prod.id;
        quote.Quote_Number__c = '5531288';
        quote.Create_Sales_Order__c = true;
        System.debug('Prod : '+ql.product__r.productcode);
        insert quote;
        
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Line__c childQl = ql.clone();
        childQl.Higher_Level_Item__c = 100;
        childQl.SAP_Line_Number__c = 101;
        insert childQl;
        
        opp.StageName = '6 Closed Won';
        opp.OppStatus__c = 'Fully Booked';
        opp.Opportunity__c = 'Omnicell Opportunity';
        opp.PrimaryQuote__c = quote.Id;
        update opp;
        test.startTest();
        Opportunity oppTest = [SELECT ID, StageName,OppStatus__c, recordtype.developerName, Opportunity__c FROM opportunity where id = :opp.Id];
        system.debug('oppTest-->'+oppTest);
        Opportunity opp1 = new Opportunity();
        opp1.name = 'Test Opportunity for update';
        opp1.stageName = '1 Solution Design';
        opp1.CloseDate = System.today();
        opp1.AccountId = acc.id;
        opp1.OppStatus__c = 'Open';
        opp1.Pipeline_Category__c = 'Development';
        opp1.ExpectedInstallDate__c = System.today()+60;
        opp1.Associated_Opportunity__c = opp.Id;
        opp1.StageName = '6 Closed Won';
        opp1.OppStatus__c = 'Fully Booked';
        opp1.Opportunity__c = 'Change Order - Credit';
        opp1.Services_Enablement_Owner__c = 'Adam Barrios';
        insert opp1;

        Quote quote1 = new Quote();
        quote1.name = 'Test Quote1';
        quote1.Pricebook2Id = Test.getStandardPricebookId();
        quote1.Region__c='Northeast';
        quote1.Pricing_Reference_Date__c=system.today();
        quote1.Requested_Delivery_Date__c = system.today();
        quote1.Booking_Date__c=system.today();
        quote1.ExpirationDate = system.today();
        quote1.OpportunityId = opp1.Id;
        quote1.Primary_Quote__c = TRUE;
        quote1.Quote_Number__c = '5531289';
        quote1.Create_Sales_Order__c = true;
        quote1.Order_Type__c = 'ZHQR';
        insert quote1;
        Quote_Line__c ql1 = new Quote_Line__c();
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 100;
        ql1.SAP_Line_Item_GUID__c = '400';
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = true;
        ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = 'TestProduct-SV';
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0003';
        ql1.Product__c = prod.id;
        System.debug('Prod : '+ql1.product__r.productcode);
        
        //insert quote1;
        
        
        ql1.Quote__c = quote1.Id;
        insert ql1;
        
        opp1.StageName = '6 Closed Won';
        opp1.OppStatus__c = 'Fully Booked';
        opp1.Opportunity__c = 'Change Order - Credit';
        opp1.PrimaryQuote__c = quote1.Id;
        update opp1;
        
        Change_Order_Opportunity__c coo = new Change_Order_Opportunity__c();
        insert coo;
        
        Change_Order_Quote_Line__c coql = new Change_Order_Quote_Line__c();
        coql.Quote_Line__c = ql.Id;
        insert coql;
        
        Change_Order_Tableau__c cot = new Change_Order_Tableau__c();
        cot.Opportunity_Type__c = 'Change Order - Debit';
        insert cot;
        
        Change_Order_Tableau__c cot1 = new Change_Order_Tableau__c();
        cot1.Opportunity_Type__c = 'Change Order - Credit';
        cot1.Backlog_Status__c = 'Backlog';
        cot1.Primary_Quote_Number__c = '1234';
        cot1.Higher_Level_Item__c = 100;
        cot1.SAP_Line_Number__c = 10;
        insert cot1;
        
        Change_Order_Tableau__c cot2 = new Change_Order_Tableau__c();
        cot2.Opportunity_Type__c = 'Change Order - Credit';
        cot2.Backlog_Status__c = 'Backlog';
        cot2.Primary_Quote_Number__c = '1234';
        cot2.Higher_Level_Item__c = 101;
        cot2.SAP_Line_Number__c = 100;
        insert cot2;
        
        Quote quote2 = new Quote();
        quote2.name = 'Test Quote2';
        quote2.Pricebook2Id = Test.getStandardPricebookId();
        quote2.Region__c='Northeast';
        quote2.Pricing_Reference_Date__c=system.today();
        quote2.Requested_Delivery_Date__c = system.today();
        quote2.Booking_Date__c=system.today();
        quote2.ExpirationDate = system.today();
        quote2.OpportunityId = opp1.Id;
        quote2.Primary_Quote__c = FALSE;
        quote2.Quote_Number__c = '5531290';
        quote2.Create_Sales_Order__c = true;
        quote2.Order_Type__c = 'ZHQR';
        insert quote2;
        
        Backlog_Inflow_Outflow_Tableau__c inflow = new Backlog_Inflow_Outflow_Tableau__c();
        inflow.WBS_Code__c = '50';
        inflow.Quote__c = quote.id;
        inflow.SAP_Line_Number__c = 100;
        inflow.Opportunity_Forecast_Category_Order__c = '7-Backlog As Of Today';
        inflow.SAP_Quote_Number__c = '1234';
        insert inflow;
        
        ChangeOrderChildOpportunitiesBatch sc = new ChangeOrderChildOpportunitiesBatch();
        //database.executebatch(new ChangeOrderDeleteOpportunityBatch());
        sc.execute(null);
        test.stopTest();
    }
}