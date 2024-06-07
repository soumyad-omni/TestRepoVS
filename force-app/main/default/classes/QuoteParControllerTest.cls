@isTest
public class QuoteParControllerTest {
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
    } 
    
    @isTest()
    public static void testCopyMovePar1()
    {
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = TestDataFactory.createTestQuote_Integration().Id;
        QuoteParController.getQuotePar(ql.Quote__c, 'Yes');
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
        //QuoteLineTriggerHandler.updatequotelinewithtotalvaluesupdate(ql.Quote__c);
        test.startTest();
        insert qlList;
        QuoteLineTriggerHandler.TriggerDisabled = true;
		
        QuoteParController.getQuotePar(ql.Quote__c, 'Yes');
        list<QuoteParMap__c> parMaps = [SELECT Par__c,Quote__c FROM  QuoteParMap__c WHERE Quote__c = :ql.Quote__c AND Par__c = 'Par 1' LIMIT 1];
        parMaps[0].Par__c = 'Par 6';
        QuoteParController.renameQuotePar(parMaps[0], ql.Quote__c);
        QuoteParController.saveInterimOff(ql.Quote__c);
        QuoteParController.deleteQuotePar(parMaps[0], ql.Quote__c);
        QuoteParController.createQuotePar(new list<QuoteParMap__c>{new QuoteParMap__c(Par__c='par10', Quote__c=ql.Quote__c)}, ql.Quote__c);
    }
    
    @isTest()
    public static void testCopyMovePar2()
    {
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        
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
        ql2.Par_Location__c = 'par 11';
        qlList.add(ql2);
        //QuoteLineTriggerHandler.updatequotelinewithtotalvaluesupdate(ql.Quote__c);
        
        QuoteLineTriggerHandler.TriggerDisabled = true;
        insert qlList;
		
        QuoteParController.getQuotePar(ql.Quote__c, 'Yes');
    }
}