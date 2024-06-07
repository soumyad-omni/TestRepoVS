@isTest
public class marginQLAverageTest 
{ 
    public static testmethod void method1()
    {
        Process_ASP_Records__c aspCS = new Process_ASP_Records__c();
        aspCS.name = '5-';
        aspCS.Only_One_Time_Process__c = true;
        insert aspCS;
        
        SCP_TestDataFactory.createContact_Customsetting();    
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
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
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        Account_SendEmail_Off__c setting8 = new Account_SendEmail_Off__c();
        setting8.Name = 'Account SendEmail Off';
        setting8.Account_SendEmail_Off__c = false;
        insert setting8;

        
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
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today();
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        User oid = [Select Id, name from User where profile.name ='System Administrator' limit 1];
        opp.OwnerId= oid.Id;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'Frame',Portfolio_Segment__c='Automated Dispensing Cabinets');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Quote_Line__c ql1 = new Quote_Line__c();
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        
        ql1.Higher_Level_Item__c = 100;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 101;
        ql1.SAP_Line_Item_GUID__c = '400';
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = true;
        ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = 'TestProduct-SV';
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0003';
        ql1.Product__c = prod.id;
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c> ();
        
        test.startTest();
        insert quote;
        
        quote.Quote_Number__c = '5531288';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        ql1.Quote__c = quote.Id;
        
        qlList.add(ql);
        qlList.add(ql1);
        insert qlList;
        
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
        
        //database.executebatch(new marginCurrentQLBatch());
        
        Current_Quote_Line_Result__c cqlr = new Current_Quote_Line_Result__c();
        cqlr.Derived_Portfolio_Segment__c = 'Automated Dispensing Cabinets';
        cqlr.Opportunity_Forecast_Category__c = 'Booked';
        cqlr.expected_booking__c = 10;
        cqlr.Quote__c = quote.id;
        cqlr.Quote_Line__c = ql.id;
        cqlr.product__c = prod.id;
        insert cqlr;
        
        Current_Quote_Line_Result__c cqlr1 = new Current_Quote_Line_Result__c();
        cqlr1.Derived_Portfolio_Segment__c = 'Automated Dispensing Cabinets';
        cqlr1.Opportunity_Forecast_Category__c = 'Booked';
        cqlr1.expected_booking__c = 20;
        cqlr1.Quote__c = quote.id;
        cqlr1.Quote_Line__c = ql1.id;
        cqlr1.product__c = prod.id;
        insert cqlr1;
        Date dt = system.today();
        dt = dt.addYears(200);
        Quote_Line_Backlog__c qlb = new Quote_Line_Backlog__c();
        qlb.expected_booking__c = 10;
        qlb.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
        qlb.Derived_Portfolio_Segment__c = 'Automated Dispensing Cabinets';
        qlb.SAP_Quote_Number__c = '5531288';
        qlb.Product__c = prod.id;
        qlb.Higher_Level_Item__c = 0;
        qlb.Opportunity_Forecast_Category_Order__c = '5-Backlog';
        qlb.Valid_To__c = dt;
        insert qlb;
        
        Quote_Line_Backlog__c qlb1 = new Quote_Line_Backlog__c();
        qlb1.expected_booking__c = 20;
        qlb1.SAP_ORDER_LINE_ITEM_NUMBER__C = 101;
        qlb1.SAP_Quote_Number__c = '5531288';
        qlb1.Product__c = prod.id;
        qlb1.Higher_Level_Item__c = 100;
        qlb1.Valid_To__c = dt;
        qlb1.Opportunity_Forecast_Category_Order__c = '5-Backlog';
        insert qlb1;
        
        database.executebatch(new MarginQLReportsScheduleJob());
        test.stopTest();
    }
    public static testmethod void method2()
    {
        Process_ASP_Records__c aspCS = new Process_ASP_Records__c();
        aspCS.name = '5-';
        aspCS.Only_One_Time_Process__c = true;
        insert aspCS;
        
        SCP_TestDataFactory.createContact_Customsetting();    
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
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
                Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        Account_SendEmail_Off__c setting8 = new Account_SendEmail_Off__c();
        setting8.Name = 'Account SendEmail Off';
        setting8.Account_SendEmail_Off__c = false;
        insert setting8;

        
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
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today();
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        User oid = [Select Id, name from User where profile.name ='System Administrator' limit 1];
        opp.OwnerId= oid.Id;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'Frame',Portfolio_Segment__c='Automated Dispensing Cabinets');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Quote_Line__c ql1 = new Quote_Line__c();
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        
        ql1.Higher_Level_Item__c = 100;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 101;
        ql1.SAP_Line_Item_GUID__c = '400';
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = true;
        ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = 'TestProduct-SV';
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0003';
        ql1.Product__c = prod.id;
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c> ();
        
        test.startTest();
        insert quote;
        
        quote.Quote_Number__c = '5531288';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        ql1.Quote__c = quote.Id;
        
        qlList.add(ql);
        qlList.add(ql1);
        insert qlList;
        
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
        
        //database.executebatch(new marginCurrentQLBatch());
        
        Current_Quote_Line_Result__c cqlr = new Current_Quote_Line_Result__c();
        cqlr.Derived_Portfolio_Segment__c = 'Automated Dispensing Cabinets';
        cqlr.Opportunity_Forecast_Category__c = 'Booked';
        cqlr.expected_booking__c = 10;
        cqlr.Quote__c = quote.id;
        cqlr.Quote_Line__c = ql.id;
        cqlr.product__c = prod.id;
        insert cqlr;
        
        Current_Quote_Line_Result__c cqlr1 = new Current_Quote_Line_Result__c();
        cqlr1.Derived_Portfolio_Segment__c = 'Automated Dispensing Cabinets';
        cqlr1.Opportunity_Forecast_Category__c = 'Booked';
        cqlr1.expected_booking__c = 20;
        cqlr1.Quote__c = quote.id;
        cqlr1.Quote_Line__c = ql1.id;
        cqlr1.product__c = prod.id;
        insert cqlr1;
        Date dt = system.today();
        dt = dt.addYears(200);
        Quote_Line_Backlog__c qlb = new Quote_Line_Backlog__c();
        qlb.expected_booking__c = Null;
        qlb.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
        qlb.Derived_Portfolio_Segment__c = 'Advanced Services';
        qlb.SAP_Quote_Number__c = '5531288';
        qlb.Product__c = prod.id;
        qlb.Higher_Level_Item__c = 0;
        qlb.Opportunity_Forecast_Category_Order__c = '5-Backlog';
               

        qlb.Valid_To__c = dt;
        insert qlb;
        
        Quote_Line_Backlog__c qlb1 = new Quote_Line_Backlog__c();
        qlb1.expected_booking__c = Null;
        qlb1.SAP_ORDER_LINE_ITEM_NUMBER__C = 101;
        qlb1.SAP_Quote_Number__c = '5531288';
        qlb1.Product__c = prod.id;
        qlb1.Higher_Level_Item__c = 100;
        qlb1.Valid_To__c = dt;
        qlb1.Opportunity_Forecast_Category_Order__c = '5-Backlog';
        qlb1.Derived_Portfolio_Segment__c='Advanced Services';
        insert qlb1;
       // system.debug('qlb1.Derived_Portfolio_Segment__c'+qlb1.Derived_Portfolio_Segment__c);
              //  system.debug('qlb1.Derived_Portfolio_Segment__c'+qlb1.expected_booking__c );

        
       // String query = 'SELECT id, expected_booking__c, SAP_Line_Number__c, SAP_Quote_Number__c, Copied_From_Quote_Lines__c  FROM Quote_Line_Backlog__c';
       // query = query +' WHERE (expected_booking__c = NULL OR expected_booking__c = 0)';
       // query = query +' AND Derived_Portfolio_Segment__c =\'Advanced Services\'';
       
        
        database.executebatch(new marginCurrentQLAdvanceServices());
        test.stopTest();
    }
}