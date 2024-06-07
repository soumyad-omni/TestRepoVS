@istest
public class CopyConfigFromQuoteCtrlTest 
{
    @testsetup
    static void testdatasetup(){
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
    } 
    
    @isTest()
    public static void testCopyConfig()
    {
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled=true;
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT');
        insert prod;
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = TestDataFactory.createTestQuote_Integration().Id;
        
        CopyConfigFromQuoteCtrl.addFreightLineRecord(ql.Quote__c);
        
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        
        ql2.Product__c = prod2.id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        qlList.add(ql);
        ql2.Add_to_cart__c = true;
        ql2.Interim_flag__c = true;
        ql2.Par_Location__c = 'par 1';
        qlList.add(ql2);
        
        test.startTest();
        QuoteLineTriggerHandler.TriggerDisabled = true;
        insert qlList;
        
        Quote quote1 = [SELECT Id,QuoteNumber FROM Quote WHERE Id =:ql2.Quote__c ];
        CopyConfigFromQuoteCtrl.searchQuote('Par 1', quote1.QuoteNumber);
        CopyConfigFromQuoteCtrl.copyQuoteLines(ql2.Quote__c, qlList);
        test.stopTest();
    }
}