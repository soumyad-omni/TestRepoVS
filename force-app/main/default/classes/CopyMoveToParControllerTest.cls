@isTest
public class CopyMoveToParControllerTest {
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
    public static void testCopyMovePar()
    {
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled=true;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = TestDataFactory.createTestQuote_Integration().Id;
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
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT');
        insert prod;
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
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
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
        
        //------------
        //id quote2Id = TestDataFactory.createTestQuote_Integration().Id;
        Quote quote = new Quote();
        quote.name = 'Test Quote2';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration().Id;
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
        quote.Shipping_Contact__c= [SELECT Id FROM Contact LIMIT 1][0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount();	
        quote.OpportunityId = opp.Id;
        insert quote;
        
        quote.Quote_Number__c = '12345';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        
        Quote_Line__c newQl = new Quote_Line__c(Quote__c = quote.Id,
                                               Product__c = prod2.Id,
                                               Add_to_cart__c= true,
                                                SAP_Line_Number__c = 700,
                                                SAP_Line_Item_GUID__c = '702',
                                                Higher_Level_Item__c = 0,
                                                Part_of_a_Bundle__c = false,
                                                Customer_Price__c = 50
                                                
                                               );
        insert newQl;
        list<Quote_Line__c> quoteLines = [SELECT Id,Name,Par_Location__c,Quote__c,Quantity__c,Product_Code__c,Product__c,Add_to_cart__c, Interim_flag__c,SAP_Line_Number__c,Higher_Level_Item__c FROM Quote_Line__c WHERE Quote__c = :ql.Quote__c AND Par_Location__c='par 1'];
        
        
        CopyMoveToParController.fetchQuoteLines('Par 1', ql.Quote__c);
        CopyMoveToParController.copyMovePars(quoteLines, new list<string>{'Par 2'}, 'Par 1' , ql.Quote__c, 'copy');
        quoteLines = [SELECT Id,Name,Par_Location__c,Quote__c,Quantity__c,Product_Code__c,Product__c,Add_to_cart__c, Interim_flag__c,SAP_Line_Number__c,Higher_Level_Item__c FROM Quote_Line__c WHERE Quote__c = :ql.Quote__c AND Par_Location__c='par 1'];
        CopyMoveToParController.copyMovePars(quoteLines, new list<string>{'Par 2'}, 'Par 1' , ql.Quote__c, 'move');
    }

}