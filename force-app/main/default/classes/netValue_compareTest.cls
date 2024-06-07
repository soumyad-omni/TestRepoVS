/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-14-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-08-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class netValue_compareTest {
    
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting13 = new CastIronIntegration__c ();
        setting13.Name = 'CastIronIntegration';
        setting13.Net_Value_endpoint__c = 'https://appconndatadev.omnicell.com/AccountSFtoSAPDEV';
        setting13.Accountendpoint__c= 'https://appconndatadev.omnicell.com/AccountSFtoSAPDEV';
        setting13.EndPoint__c = 'https://castirondev.omnicell.com';
        setting13.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting13.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        setting13.compare_button_timeout__c= '1200';
        insert setting13;       
        
        Net_Value_endpoint_url__c  setting14 = new Net_Value_endpoint_url__c ();
        setting14.Name = 'test';
        setting14.Net_Value_endpoint__c = 'https://appconndatadev.omnicell.com/SalesOrderSFDCtoSAPtoSFDC';
        insert setting14;
        
        
        
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008662';
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
        
       Default_Currency_by_Country_Code__c	  setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'US';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        Default_Currency_by_Country_Code__c	  setting8 = new Default_Currency_by_Country_Code__c();
        setting8.Name = 'AZ';
        setting8.Currency_Code__c = 'USD';
        insert setting8;
        
               
    }
     
   
    @isTest 
    private static void Test1() {
        
            OpportunityTriggerHandler.TriggerDisabled = true;
            AccountTriggerHandler.TriggerDisabled = true; 
        ContactTriggerHandler.TriggerDisabled = true;
            Test.setMock(HttpCalloutMock.class, new netValue_mock());      
        	        	        
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
            quote.Primary_Quote__c = true;
            QuoteTriggerHandler.TriggerDisabled = true;
            
            insert quote;
            quote.Status = 'E0013';
            quote.Quote_Number__c = '1234';
            quote.Create_Sales_Order__c = true;
           	quote.SAP_Sales_Order_Number__c = '0010327200';
            update quote;
            test.startTest();
            netValue_compare.getvalue(quote.id);
        	netValue_compare.isrendered(quote.id);
            Test.stopTest();
            
            
        
        
    }

}