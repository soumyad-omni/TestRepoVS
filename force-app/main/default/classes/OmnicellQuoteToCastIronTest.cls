/**********************************************************************
Name:  OmnicellQuoteToCastIronTest
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for OmnicellQuoteToCastIron_Class                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              9/21/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class OmnicellQuoteToCastIronTest
{
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
        
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
    } 
    private static testmethod void testQuote() {
        
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = true;
        
       
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        //pl.Cost__c = 100;
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        quote.OpportunityId = opp.Id;
        test.starttest();
        insert quote;
        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ID quoteid = quote.Id;
        set<Id> newqteid = new set<Id>();
        newqteid.add(quoteid);
        
        Map<string,String> qtOrderTypechangeMap = new Map<string,String> ();
        qtOrderTypechangeMap.put(quote.id,'0');
        OmnicellQuoteToCastIron_Class.callOutMethodInsert(newqteid);
        OmnicellQuoteToCastIron_Class.callOutMethodUpdate(newqteid,qtOrderTypechangeMap);
        OmnicellQuoteToCastIron_Class.formatempNum('1234');
        test.stoptest();
    } 
}