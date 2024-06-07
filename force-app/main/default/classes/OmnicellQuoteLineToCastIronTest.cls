/**********************************************************************
Name:  OmnicellQuoteLineToCastIronTest
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for OmnicellQuoteLineToCastIron_Class
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              9/21/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class OmnicellQuoteLineToCastIronTest
{
    @testsetup
    static void testdatasetup(){
        
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.QuoteLineInsertEndpoint__c = 'https://castirondatadev.omnicell.com/QuoteItemSFToCRM';
        setting.QuoteLineUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/QuoteItemSFToCRMUpdate';
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
    private static testmethod void testQuoteLine() {
        Test.startTest();
        OpportunityTriggerHandler.TriggerDisabled = true;
         AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        //Opportunity opp = TestDataFactory.createOppWithAccount_Integration();
        // Quote quote = TestDataFactory.createTestQuote_Integration();
        set<Id> newqlid = new set<Id>();
        for(Integer i = 0 ; i < 4 ; i++){
           //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_Integration();
            //ID qlid = ql.Id;   
 			
            //newqlid.add(qlid);
        }
       // OmnicellQuoteLineToCastIron_Class.callOutMethodInsert(newqlid);
       // OmnicellQuoteLineToCastIron_Class.callOutMethodUpdate(newqlid);
        //OmnicellQuoteLineToCastIron_Class.callOutMethodDelete(newqlid);
        test.stopTest();
        
    } 
    @isTest
    public static void testQuoteLineDelete(){
        QuoteTriggerHandler.TriggerDisabled = true;
        opportunityTriggerHandler.TriggerDisabled = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = True;
        AccountTriggerHandler.TriggerDisabled = True;
        test.startTest();
       Quote quote = new Quote();
        quote.name = 'IBA-1401 Test Quote';
        
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        quote.OpportunityId = opp.Id;
        
        List<Contact> cont = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.Primary_Quote__c = true;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Milestone_Invoice_Term__c='01';
        quote.Supplement_Generated__c='01';
        quote.Product_PO_Number__c='123456';
        quote.Service_PO_Number__c='123456';
      
        quote.Shipping_Contact__c= cont[0].Id;
        quote.Order_Type__c = 'ZHQR';
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
         ql.Higher_Level_Item__c = null ;
        ql.SAP_Line_Item_GUID__c = null;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Line_Status__c = 'E0006';

        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        insert quote;
        quote.Status = 'E0013';
        update quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        
        ql.Quote__c = quote.Id;
       
        
        Quote_Line__c ql1 = new Quote_Line__c();
        ql1.RecordTypeId = qlNonConfigRecordType.id;

        ql1.SAP_Line_Item_GUID__c = null;        
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 0;
        ql1.SAP_Line_Item_GUID__c = '400';
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = 'SERVICE';
        ql1.Part_of_a_Bundle__c = true;
        ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = 'TestProduct-SV';
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0006';
        ql1.Quote__c = quote.Id;
        
        list<Quote_Line__c> qline = new list<Quote_Line__c>();
        qline.add(ql);
        qline.add(ql1);
        insert qline;
        set<Id> newqlid = new set<Id>();
        newqlid.add(qline[0].Id);
        newqlid.add(qline[1].Id);
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.QuoteLineInsertEndpoint__c = 'https://castirondatadev.omnicell.com/QuoteItemSFToCRM';
        setting.QuoteLineUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/QuoteItemSFToCRMUpdate';
        insert setting;
        Test.setMock(HTTPCalloutMock.class, new OmnicellQuoteLineToCastIronMock());
        
        /*SingleRequestMock fakeAccountResp = new SingleRequestMock(200,
                                                         'Complete',
                                                         '[{"Name": "sForceTest1"}]',
                                                         null);
 
        SingleRequestMock fakeContactsResp = new SingleRequestMock(200,
                                                  'Complete',
                                                  '[{"LastName": "Test Last Name"}]',
                                                   null);
 
        Map<String, HttpCalloutMock> endpoint2TestResp =
                                   new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put('https://castirondatadev.omnicell.com/QuoteItemSFToCRM',fakeAccountResp);
        endpoint2TestResp.put('https://castirondatadev.omnicell.com/QuoteItemSFToCRMUpdate',fakeContactsResp);
 
        HttpCalloutMock multiCalloutMock =
                                   new MultiRequestMock(endpoint2TestResp);
 
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);*/

        OmnicellQuoteLineToCastIron_Class.callOutMethodDelete(newqlid);
        OmnicellQuoteLineToCastIron_Class.callOutMethodInsert(newqlid);
        OmnicellQuoteLineToCastIron_Class.callOutMethodUpdate(newqlid);
        OmnicellQuoteLineToCastIron_Class.callOutMethodInsertUpdate(newqlid);
        OmnicellQuoteLineToCastIron_Class.callOutMethodDeleteUpdate(newqlid);
        Test.stopTest();
    }
}