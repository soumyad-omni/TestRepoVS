@isTest
public class UpdateProdLineBatch_Test {
  	@testsetup 
    static void testDataSetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        setting.Print_Compare_End_Point__c = 'https://printcastirondev.omnicell.com';
        insert setting;
        
        CastIronIntegration__c  compsetting = new CastIronIntegration__c ();
        compsetting.Name = 'CastIronIntegration';
        compsetting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        compsetting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert compsetting;
        
        Compare_Integration_Creds__c testsetting = new Compare_Integration_Creds__c(Name = 'Compare Creds',
                                                                               Endpoint__c='https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT',
                                                                               Timeout__c='120000');
        insert testsetting;
        
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

    public static testmethod void testBKDQuoteEmptyProdLineUpdate() {

       AccountTriggerHandler.TriggerDisabled = true;
		OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = True;
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
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Milestone_Invoice_Term__c='01';
        quote.Supplement_Generated__c='01';
        quote.Product_PO_Number__c='123456';
        quote.Service_PO_Number__c='123456';
        quote.Status = 'E0013';
        quote.Shipping_Contact__c= cont[0].Id;
        quote.Order_Type__c = 'ZHQR';
        quote.Primary_Quote__c = true;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
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
        test.startTest();
        insert quote;
        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        
        List<Product_Line__c> prodlineList= [SELECT Quote__c FROM Product_Line__c WHERE Date_Booked__c=LAST_N_DAYS:1 LIMIT 2];
        delete prodlineList;
        Set<Id> quoteId = new Set<Id> ();
        quoteId.add(quote.Id);
        UpdateProdLineBatch bkdQtProdSegObj= new UpdateProdLineBatch(quoteId);
        Id batchId = Database.executeBatch(bkdQtProdSegObj);
        test.stopTest();
    }    
}