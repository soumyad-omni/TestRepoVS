@isTest
public class marginCurrentQLBatchTest 
{
    @testsetup
    static void testdatasetup(){
        ExternalDataTriggerHandler.TriggerDisabled=True;
        SCP_TestDataFactory.createContact_Customsetting();    
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
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
         Account_SendEmail_Off__c setting8 = new Account_SendEmail_Off__c();
        setting8.Name = 'Account SendEmail Off';
        setting8.Account_SendEmail_Off__c = false;
        insert setting8;
    }
    public static testmethod void method1(){
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Division_Account__c ='Atlantic';
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()-100;
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Booked';
        opp.OppStatus__c = 'Fully Booked';
        opp.ExpectedInstallDate__c = System.today()+60;
        
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        insert opp;
        
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap',Portfolio_Segment__c='Supply');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert quote;
        
        quote.Quote_Number__c = '5531288';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        
        Forecast_Dimension__c fc = new Forecast_Dimension__c();
        fc.Opportunity_Name__c = 'Test Opp';
        fc.Primary_Quote_ID__c = quote.id;
        fc.Primary_Quote_SAP_Number__c = 5531288;
        fc.Opportunity_ID__c = opp.Id;
        fc.Opportunity_Forecast_Category__c = 'Booked';
        datetime myDate = datetime.newInstance(2022, 2, 17);
        datetime newDate = mydate.addDays(2);
        fc.Opportunity_Change_Datetime__c = newDate;
        fc.Opportunity_Created_Date__c = myDate;
        insert fc;
        database.executebatch(new marginCurrentQLBatch());
        
        Current_Quote_Line_Result__c cqlr = new Current_Quote_Line_Result__c();
        cqlr.Derived_Portfolio_Segment__c = 'Advance Services';
        cqlr.Opportunity_Forecast_Category__c = 'Booked';
        cqlr.expected_booking__c = 10;
        cqlr.Quote__c = quote.id;
        cqlr.Valid_To__c = Date.newInstance(2999, 12, 31);
        cqlr.Quote_Line__c = ql.id;
        insert cqlr;
            
        Product2 prod1 = new Product2(Name = 'TestProduct-SV123',Family = 'test123',External_ID__c = '1234567890123123',ProductCode = 'TestProduct-SV123',DW_Product_Line__c = 'testdw123',SAP_Product_Type__c = 'testsap123');
        insert prod1;
        
        Quote_Line_Backlog__c qlb = new Quote_Line_Backlog__c();
        qlb.expected_booking__c = 0;
        qlb.SAP_Line_Number__c = 100;
        qlb.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
        qlb.SAP_Quote_Number__c = '5531288';
        qlb.Product__c = prod1.Id;
        insert qlb;
        
        Quote_line_average__c qla = new Quote_line_average__c();
        insert qla;
        
        MarginQLReportsScheduleJob sc = new MarginQLReportsScheduleJob();
        sc.execute(null);
        test.stopTest();
    }
    
    public static testmethod void method2(){
        
        
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Division_Account__c ='Atlantic';
        insert acc;
     
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Booked';
        opp.OppStatus__c = 'Fully Booked';
        opp.ExpectedInstallDate__c = System.today()+60;
        
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        insert opp;
        
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
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
        ql.Line_Expected_Booking__c = 500;
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'Frame',Portfolio_Segment__c='IVX Workflow');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert quote;
        
        quote.Quote_Number__c = '5531288';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        
        Forecast_Dimension__c fc = new Forecast_Dimension__c();
        fc.Opportunity_Name__c = 'Test Opp';
        fc.Primary_Quote_ID__c = quote.id;
        fc.Primary_Quote_SAP_Number__c = 5531288;
        fc.Opportunity_ID__c = opp.Id;
        fc.Opportunity_Forecast_Category__c = 'Booked';
        datetime myDate = datetime.newInstance(2022, 2, 17);
        datetime newDate = mydate.addDays(2);
        fc.Opportunity_Change_Datetime__c = newDate;
        fc.Opportunity_Created_Date__c = myDate;
        insert fc;
        database.executebatch(new marginCurrentQLBookedQTDBatch());
        
        Current_Quote_Line_Result__c cqlr = new Current_Quote_Line_Result__c();
        cqlr.Derived_Portfolio_Segment__c = 'Advanced Services';
        cqlr.Opportunity_Forecast_Category__c = 'Booked';
        cqlr.expected_booking__c = 10;
        cqlr.Quote__c = quote.id;
        cqlr.Quote_Line__c = ql.id;
        insert cqlr;
            
        Quote_Line_Backlog__c qlb = new Quote_Line_Backlog__c();
        qlb.expected_booking__c = 0;
        qlb.SAP_Line_Number__c = 100;
        qlb.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
        qlb.Higher_Level_Item__c = 0;
        qlb.Valid_From__c=date.today();
        qlb.Valid_To__c = system.today().addYears(50);
        qlb.SAP_Quote_Number__c = '5531288';
        qlb.Opportunity_Forecast_Category_Order__c = '7-Backlog As Of Today';
        qlb.product__c = prod.id;
        qlb.Derived_Portfolio_Segment__c = 'Advanced Services';
        insert qlb;
        
        Quote_Line_Backlog__c qlb1 = new Quote_Line_Backlog__c();
        qlb1.expected_booking__c = 0;
        qlb1.Higher_Level_Item__c = 100;
        qlb1.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
		qlb1.SAP_Line_Number__c = 200;
        qlb1.SAP_Quote_Number__c = '5531288';
        qlb1.Valid_To__c = system.today().addYears(50);
        qlb1.Valid_From__c=date.today();
        qlb1.Opportunity_Forecast_Category_Order__c = '7-Backlog As Of Today';
        qlb1.product__c = prod.id;
        qlb1.Derived_Portfolio_Segment__c = 'Advanced Services';
        insert qlb1;
        List<Quote_Line_Backlog__c> data = [Select id,SAP_Quote_Number__c, SAP_Line_Number__c,Quote_Line__c,CreatedDate,Quote__c from Quote_Line_Backlog__c where (expected_booking__c = NULL OR expected_booking__c = 0) and Derived_Portfolio_Segment__c ='Advanced Services'];
        System.debug('Data Size:'+data.size());
        Quote_line_average__c qla = new Quote_line_average__c();
        qla.Valid_To__c = Date.newInstance(2999, 12, 31);
        insert qla;
        
        database.executebatch(new marginCurrentQLAdvanceServices());
        
        test.stopTest();
    }
    
    public static testmethod void method3(){
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Division_Account__c ='Atlantic';
        insert acc;
     
        OpportunityTriggerHandler.TriggerDisabled = True;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.Pipeline_Category__c = 'Booked';
        opp.OppStatus__c = 'Fully Booked';
        opp.ExpectedInstallDate__c = System.today()+60;
        
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        insert opp;
        
        
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
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
        
        quote.OpportunityId = opp.Id;
        quote.Primary_Quote__c = false;
        
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'Frame',Portfolio_Segment__c='Supply');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert quote;
        
        quote.Quote_Number__c = '5531288';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        
        database.executebatch(new marginCurrentQLNonPrimary());
        
        test.stopTest();
    }
    
    public static testmethod void method4(){
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Division_Account__c ='Atlantic';
        insert acc;
        OpportunityTriggerHandler.TriggerDisabled = True;
        
        Opportunity opp1 = new Opportunity();
        opp1.name = 'Test Opportunity for update Ass';
        opp1.stageName = '1 Solution Design';
        opp1.CloseDate = System.today();
        opp1.AccountId = acc.id;
        opp1.Pipeline_Category__c = 'Booked';
        opp1.OppStatus__c = 'Fully Booked';
        opp1.ExpectedInstallDate__c = System.today()+60;
        
        opp1.Services_Enablement_Owner__c = 'Tara Bakker';
        opp1.Self_Install_Desired__c = 'No';
        opp1.Professional_Services_Notes__c = 'Test';
        opp1.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp1.Lease_Expiration_Date__c = System.Today()+1;
        opp1.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp1.How_many_contract_years__c = '2';
        opp1.Contract_Year__c = '2';
        opp1.Specialty_Open_Date__c = System.Today();
        opp1.Seismic_Restraint_Required__c = 'No';
        insert opp1;
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.Associated_Opportunity__c = opp1.Id;
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.Pipeline_Category__c = 'Booked';
        opp.OppStatus__c = 'Fully Booked';
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Opportunity__c = 'Change Order - Credit';
        
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        insert opp;
        
        
        
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        ContactTriggerHandler.TriggerDisabled = True;
        AccountTriggerHandler.TriggerDisabled = True;
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
        quote.OpportunityId = opp.Id;
        quote.Primary_Quote__c = false;
        
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'Frame',Portfolio_Segment__c='Supply');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert quote;
        
        quote.Quote_Number__c = '5531288';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        
        database.executebatch(new marginCurrentQLNonPrimary());
        
        test.stopTest();
    }
}