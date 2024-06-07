@isTest
public class OrderInfoToNetSuiteBatchForQuoteTest {
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static Id recTypeOppUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'NAA_Opportunity' LIMIT 1].Id;
    @TestSetup
    static void makeData(){
        AccountTriggerHandler.TriggerDisabled = true;
		OpportunityTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        Account acc = TestDataFactory.createUSTestAccount();
        Contact cont = TestDataFactory.createTestContact(true, acc.id, 'Test Contact', UserInfo.getUserId());
        Opportunity opp = new Opportunity();
        opp.name = 'Test IBA-4831 Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Non Comm. Book - No Service PO';
        opp.Credit_Approved_For__c = acc.id;
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
        opp.OpportunityGroup__c = 'Advanced Services';
        opp.StageName = '6 Closed Won';
        insert opp;
        OpportunityContactRoleTriggerHandler.TriggerDisabled = true;
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = cont.id;
        oppContRole.OpportunityId = opp.id;
        oppContRole.IsPrimary = false;
        oppContRole.Role = 'S-Shipping Contact';
        insert oppContRole;
        List<Product2> products = new List<Product2>();
        Product2 prod1 = new Product2(Name = 'MED-FRM-101',Family = 'Medication Systems',External_ID__c = 'MED-FRM-101',ProductCode = 'MED-FRM-101');
        Product2 prod2 = new Product2(Name = 'RENEWAL',Family = 'Finance',External_ID__c = 'RENEWAL',ProductCode = 'RENEWAL',
                                    DW_Product_Line__c = 'Inventory Optimization Service');
        Product2 prod3 = new Product2(Name = 'MSA-SUB-006',Family = 'Shared Systems',External_ID__c = 'MSA-SUB-006',ProductCode = 'MSA-SUB-006',
                                    DW_Product_Type__c = 'Subscription',DW_Product_Line__c = 'Professional Services');
        Product2 prod4 = new Product2(Name = 'MED-FRM-101-SV',Family = 'Medication Systems',External_ID__c = 'MED-FRM-101-SV',
                                    ProductCode = 'MED-FRM-101-SV');

        Product2 prod5 = new Product2(Name = 'FREIGHT',Family = 'FREIGHT',External_ID__c = 'FREIGHT',ProductCode = 'FREIGHT');
        
        products.add(prod1);
        products.add(prod2);
        products.add(prod3);
        products.add(prod4);
        products.add(prod5);
        insert products;
        NetSuite_Opp_RecordType__c netOppRec = new NetSuite_Opp_RecordType__c();
        netOppRec.Name = 'U.S & Canada Opportunity';
        insert netOppRec;
        NetSuite_Quote_Order_Type__c netsuiteOrderType = new NetSuite_Quote_Order_Type__c();
        netsuiteOrderType.name = 'ZQR';
        insert netsuiteOrderType;
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

        SCP_Integration_Details__c  setting2 = new SCP_Integration_Details__c ();
        setting2.Name = 'NetSuite_MuleSoft_Authorization';
        setting2.SCP_Method_Type__c = 'POST';
        setting2.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting2.SCP_Timeout__c = 120000;
        setting2.SCP_End_Point__c = 'https://uat-sfdc-netsuite-api.us-w1.cloudhub.io/api/migrate';
        setting2.SCP_Is_Active__c = true;
        insert setting2;
    }
    
    @IsTest
    static void methodName1(){   
        QuoteTriggerHandler.TriggerDisabled = true;   
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        Account acc = [Select Id From Account Limit 1];
        Opportunity opp = [Select Id From Opportunity Where AccountId =: acc.Id];  
        quote.OpportunityId = opp.Id;
        Contact con = [Select Id From Contact Where AccountId =: acc.Id];
        quote.ContactId= con.id;
        quote.Bill_to_Account__c = acc.Id;
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.SAP_Expected_Bookings__c=0;
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0024';
        quote.Shipping_Contact__c= con.Id;
        quote.Order_Type__c = 'ZQR';
        quote.subscription_Months__c = 1;
        quote.Quote_Number__c = '0000012345';
        quote.Create_Sales_Order__c = true;  
        quote.Service_Duration__c = 10;  
        quote.Booking_Date__c = Date.today();    
        quote.SAP_Sales_Order_Number__c = '0000012345';
        quote.ECC_Sales_Order_Number__c = '0000012345';
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Milestone_Invoice_Term__c='01';
        quote.Supplement_Generated__c='01';
        quote.Product_PO_Number__c='123456';
        quote.Service_PO_Number__c='123456';
        insert quote;  
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Product2 prod3 = [Select Id,External_ID__c,ProductCode,DW_Product_Type__c From Product2 Where ProductCode = 'MSA-SUB-006'];
        Product2 prod = [Select Id,External_ID__c,ProductCode From Product2 Where ProductCode = 'MED-FRM-101'];
        Quote_Line__c ql4 = new Quote_Line__c();
        ql4.RecordTypeId = qlNonConfigRecordType.id;
        ql4.Quote__c = quote.Id;
        ql4.Higher_Level_Item__c = 0;
        ql4.Quantity__c = 1;
        ql4.SAP_Line_Number__c = 200;
        ql4.SAP_Line_Item_GUID__c = '402';
        ql4.Contract_List_Price__c = 200;
        ql4.Conga_product__c = 'MSA-SUB-006';
        ql4.Rebate_Buyout_Adjustment__c = 400.00;
        ql4.Material_Type__c = 'Product';
        ql4.Part_of_a_Bundle__c = FALSE; 
        ql4.Customer_Price__c = 200;
        ql4.Par_Location__c = 'PAR 2';
        ql4.Product__c = prod3.id;
        ql4.Sales_Text__c = 'test';
        ql4.Total_Customer_Price__c = 100;
        ql4.Line_Item_Description__c = 'Test';
        insert ql4;
        Test.setMock(HttpCalloutMock.class, new NetSuite_Mock());
        Test.startTest();
        	ScheduleOrderInfoToNetSuiteBatch schnetSuitejob =new ScheduleOrderInfoToNetSuiteBatch();
            String cronTrigger = '0 0 0 15 JAN ? *';
            System.schedule('ScheduleOrderInfoToNetSuiteBatch',cronTrigger,schnetSuitejob);
        Test.stopTest();
    }

}