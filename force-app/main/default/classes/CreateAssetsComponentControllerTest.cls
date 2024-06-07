@isTest
public class CreateAssetsComponentControllerTest {
    @testsetup
    static void testdatasetup(){
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
    public static void testCode1() {
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Account a = TestDataFactory.createTestAccountQuotePrint();
        C4C_Assets__c c1 = new C4C_Assets__c();
        C4C_Assets__c c2 = new C4C_Assets__c();
        c1.Account__C = a.id;
        c1.Unique_ID__c = '11556770';
        insert c1;
        c2.Account__C = a.id;
        c2.Unique_ID__c = '1556770';
        insert c2;
        Quote q = TestDataFactory.createTestQuote1();
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT');
        insert prod;
        ql.Product__c = prod.id;
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = q.Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.Unit_of_Measure__c = 'EA';
        insert ql;
        
        Set<String> uniqId = new Set<String>();
        uniqId.add('12684950');
        uniqId.add('11556770');
        system.debug('rt...' +uniqId);
        
        List<C4C_Assets__c> listAssets = [Select id,Name,Unique_ID__c from C4C_Assets__c where Account__c =:a.id AND Unique_ID__c IN:uniqId];
        System.debug('rjp..' +listAssets.size());
        
        /*CreateAssetsComponentController.fieldWrapper2 fr= new CreateAssetsComponentController.fieldWrapper2();
        fr.status = 'TT';
        fr.uniqueValue = '12345';
        String jsonStr = '[{"uniqueId":"12684950"},{"uniqueId":"11556770"}]';
        CreateAssetsComponentController.insertData(ql.id, jsonStr);*/
         String jsonStr = '[{"uniqueId":"12684950"},{"uniqueId":"11556770"}]';
        List<CreateAssetsComponentController.fieldWrapper2> fr = CreateAssetsComponentController.insertData(ql.Id, jsonStr);
        CreateAssetsComponentController c = new CreateAssetsComponentController();
            c.queryRecords();
    }
    
}