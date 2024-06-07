@isTest
public class updateOppFromQuote_Test {
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
    public static void test1(){
         OpportunityTriggerHandler.TriggerDisabled = true;
         userTriggerHandler.TriggerDisabled = true;
         AccountTriggerHandler.TriggerDisabled = true;
         AccountCreateController.isFirstRun= false;
       quotetriggerhandler.triggerdisabled = true;
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
        
        Quote.Sales_Operation_Counterpart__c = TestDataFactory.createUser(true,'TestUser','SalesOper').Id;
        Quote.Consultant__c = TestDataFactory.createUser(true,'TestUser','Consultant').Id;
        Quote.Sales_Consultant__c = TestDataFactory.createUser(true,'TestUser','SalesConsultant').Id;
        Quote.SSM_RD__c = TestDataFactory.createUser(true,'TestUser','SSMRD').Id;
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
        
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        Quote.Ship_to_Account__c = acc.id;
        Quote.Fax = '1234567890';
        Quote.Bill_to_Account__c = acc.id; 
        Quote.GPO_Account__c = acc.id;
        Quote.IDN_Account__c = acc.id;
        
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
        

        Test.startTest();
        update quote;    
        Update_Opportunity_From_Quote__c oq = new Update_Opportunity_From_Quote__c(Opportunity__c=Quote.OpportunityId,Project_Name__c = 'blank',Ship_to_Account_Name_ML__c = Quote.AccountId);
        insert oq;
        updateOppFromQuote_Scheduler testsche = new updateOppFromQuote_Scheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test Check', sch, testsche );
        Test.stopTest();
        

    }

}