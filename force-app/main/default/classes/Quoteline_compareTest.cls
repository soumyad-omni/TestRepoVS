@isTest(seeAllData=false)
public class Quoteline_compareTest {
    
    static testmethod void compareResponse1(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        setting.compare_button_endpoint__c = 'https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT';
        setting.compare_button_timeout__c = '120000';
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
        
        Compare_Integration_Creds__c testsetting = new Compare_Integration_Creds__c(Name = 'Compare Creds',
                                                                               Endpoint__c='https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT',
                                                                               Timeout__c='120000');
        insert testsetting;
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
        
        SCP_Integration_Details__c  setting8 = new SCP_Integration_Details__c ();
        setting8.Name = 'SCP_Mulesoft_Authorization';
        setting8.SCP_Method_Type__c = 'POST';
        setting8.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting8.SCP_Timeout__c = 120000;
        setting8.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting8.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting8.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting8.SCP_Is_Active__c = true;
        insert setting8;
        
        
        Test.setMock(HttpCalloutMock.class, new Compare_MockCallout_API_Response());
        AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
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
            Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
            quote.OpportunityId = opp.Id;
        	quote.Service_PO_Number__c = '1234';
        	quote.Product_PO_Number__c = '1234';
        	quote.Supplement_Generated__c = '01';
            QuoteTriggerHandler.TriggerDisabled = true;
            
            insert quote;
            quote.Status = 'E0001';
            quote.Quote_Number__c = '1234';
            quote.Create_Sales_Order__c = true;
           	quote.SAP_Sales_Order_Number__c = '0010327200';
            update quote;
        
        
        Product2 pr = new Product2();
        pr.Name = 'CPA-CAR-069';
        pr.ProductCode = 'CPA-CAR-069';
        pr.CurrencyIsoCode = 'USD';
        pr.External_ID__c='CPA-CAR-069';
        insert pr;
        
        Quote_Line__c Qline= new Quote_Line__c();
        Quote_Line__c QlineList;
      //  Qline.RecordTypeId = '0124F0000004OQ9QAM';
        
        Qline.Customer_Price__c = 123;
        Qline.Product__c = pr.Id;
        Qline.Conga_Grouped_Product__c =true;
        
          
		Qline.Conga_Quantity__c= 2.000;
		Qline.Conga1_USA_List_Price__c =332150.00;
		Qline.Conga_List_Price__c= 276250.00;
		Qline.Conga_Unit_Price__c = 276250.00;
		Qline.Conga_Extended_Price_Materials__c =276250; 
        
        
        Quote_Print_Status__c qpt = new Quote_Print_Status__c();
        
        qpt.Revision_Number__c='6';
        
        Qline.Quote__c = quote.Id;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        insert Qline;
        qpt.Quote__c =quote.Id;
        insert qpt;
        
        
        
        Test.startTest();
        
        Quoteline_compare.compareQuoteLine(quote.id);
        Test.stopTest();
    }
}