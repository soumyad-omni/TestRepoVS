@isTest 
public class AutoAddQuoteLineTest {
    
    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();    
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
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2(Name ='OCE-LIC-001',Family = 'test',External_ID__c = '1234567',ProductCode = 'OCE-LIC-001',Portfolio_Segment__c = 'Central Pharmacy Dispensing Service');
        prodList.add(prod);
        Product2 prod2 = new Product2(Name = 'IVS-LIC-008',Family = 'test',External_ID__c = '123456789',ProductCode = 'IVS-LIC-008',Portfolio_Segment__c = 'IVX Workflow');
        prodList.add(prod2);
        Product2 prod3 = new Product2(Name ='OCE-LIC-002',Family = 'test',External_ID__c = '12345670',ProductCode = 'OCE-LIC-002',Portfolio_Segment__c = 'Inventory Optimization Service and Platform');
        prodList.add(prod3);
        insert prodList;
        
    } 
    @isTest 
    static void testAutoAddQuoteLine1()
    {
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
		OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = TestDataFactory.createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        Product2 prod = new Product2(Name ='TEST-XR2-RBT',Family = 'test',External_ID__c = '123456',ProductCode = 'TEST-XR2-RBT',Portfolio_Segment__c = 'Central Pharmacy Dispensing Service');
        insert prod;
        ql.Product__c = prod.id;
        
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
      	Product2 prod2 = new Product2(Name = 'TEST-XR2-RBT',Family = 'test',External_ID__c = '12345678',ProductCode = 'TEST-IVS-SUB',Portfolio_Segment__c = 'IVX Workflow');
        insert prod2;
        ql2.Product__c = prod2.id;
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        qlList.add(ql);
        qlList.add(ql2);
        //QuoteLineTriggerHandler.updatequotelinewithtotalvaluesupdate(ql.Quote__c);
        
        test.startTest();
        insert qlList;
        Set<Id> qlId = new Set<Id>();
        for(Quote_Line__c qtln : [Select Id,Quote__c from Quote_Line__c]){
       		qlId.add(qtln.Id); 	    
        }
        System.enqueueJob(new AutoAddQuoteLine(qlId)); 
        test.stopTest();
    }
    @isTest 
     static void testAutoAddQuoteLine2()
    {
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
		OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = TestDataFactory.createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.Product__c = [Select Id, ProductCode, Portfolio_Segment__c from Product2 where ProductCode = 'OCE-LIC-001'].id;
        
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.Product__c = [Select Id, ProductCode, Portfolio_Segment__c from Product2 where ProductCode = 'IVS-LIC-008'].id;
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        qlList.add(ql);
        qlList.add(ql2);
        //QuoteLineTriggerHandler.updatequotelinewithtotalvaluesupdate(ql.Quote__c);
        test.startTest();
        insert qlList;
        Set<Id> qlId = new Set<Id>();
        for(Quote_Line__c qtln : [Select Id,Quote__c from Quote_Line__c]){
       		qlId.add(qtln.Id); 	    
        }
        System.enqueueJob(new AutoAddQuoteLine(qlId)); 
        test.stopTest();
    }
}