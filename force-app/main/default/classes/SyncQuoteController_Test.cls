@isTest(seeAllData=false)
public class SyncQuoteController_Test {
    
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        setting.Print_Compare_End_Point__c = 'https://castirondatadev.omnicell.com/QuoteRevNoItemCountSFDCtoSAPtoSFDC';
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
        
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;        
    } 
    
    @isTest
    public static void syncquotetest(){
        
        userTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = True;
        UserTriggerHandler.TriggerDisabled = True;
        Account act = new Account();
        act.name='Test Account';
        act.Account_Role__c = 'ZCSN';
        act.CurrencyIsoCode= 'USD';
        act.Partner_Type__c = '0007';
        act.Country_Cluster__c='US&CA';
        act.Division_Account__c='Atlantic';
        act.Region__c='Central';
        act.Account_Territory__c='Central IN and West OH';
        act.Facility_Type__c = 'Correctional Facilities';
        Insert act;  
        
        Contact ct = new Contact();
        ct.LastName ='testname';
        ct.Is_Active__c='Y';
        ct.LeadSource='Attended Event';
        ct.AccountId = act.Id;
        ct.Phone = '1234567891';
        insert ct;
        
        Quote quote = TestDataFactory.createTestQuote1();
        Quote.Supplement_Version__c = 2;
        Quote.Name = 'Test Update Quote';
        Quote.Master_Agreement__c = '12345';
        Quote.Shipping_Instructions__c = 'Test shipp inst';
        Quote.Service_Level__c = 'GD';
        Quote.Net_Weight__c = 20.5;
        Quote.Total_Cost__c = 100;
        Quote.Overhead_Cost__c = 50;
        Quote.Milestone_Invoice_Term__c = '10';
        Quote.Region__c = 'Texas';
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
        Quote.Ship_to_Account__c = act.id;
        Quote.Fax = '1234567890';
        Quote.Bill_to_Account__c = act.id; 
        Quote.GPO_Account__c = act.id;
        Quote.IDN_Account__c = act.id;
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
        
        Product2 pr = new Product2();
        pr.Name = 'CPA-CAR-069';
        pr.ProductCode = 'CPA-CAR-069';
        pr.CurrencyIsoCode = 'USD';
        pr.External_ID__c='CPA-CAR-069';
        insert pr;
        
        Quote_Line__c Qline= new Quote_Line__c();
        Quote_Line__c QlineList;
        Qline.Quote__c = Quote.Id;
        Qline.Customer_Price__c = 123;
        Qline.Product__c = pr.Id;
        Qline.Conga_Grouped_Product__c =true;        
          
		Qline.Conga_Quantity__c= 2.000;
		Qline.Conga1_USA_List_Price__c =332150.00;
		Qline.Conga_List_Price__c= 276250.00;
		Qline.Conga_Unit_Price__c = 276250.00;
		Qline.Conga_Extended_Price_Materials__c =276250; 
        insert Qline;
        
        Quote_Print_Status__c qpt = new Quote_Print_Status__c();
        qpt.Quote__c =Quote.Id;
        qpt.Revision_Number__c='6';
        insert qpt;      
        
        SyncQuoteController.sendQuotetocastiron(Quote.id);
        SyncQuoteController.checkStatus(Quote.Id);
        Quote.Status = 'E0019';
        update Quote;
        SyncQuoteController.checkStatus(Quote.Id);
        SyncQuoteController.checkfuturejob(Quote.Id);
        Test.setMock(HttpCalloutMock.class, new Compare_MockCallout_API_Response());
        Test.startTest();
			SyncQuoteController.getRevisionNum(Quote.Id);
        Test.stopTest();
    }
    
}