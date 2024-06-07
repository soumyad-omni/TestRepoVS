@isTest
public class UpdateOnAccount_IsTop200Batch3_Test {
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
        insert setting7;}
    public testmethod static void testcase1(){
        //Map<Id, Target_Initiative_Account__c> map_Tag_Initiave_Account1 = new Map<Id, Target_Initiative_Account__c>();
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.Account_Status__c = 'Prospect';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        AccountTriggerHandler.TriggerDisabled = true;
        update acc;
                Target_Initiative__c ti = new Target_Initiative__c();
        ti.Name = 'Top Accounts';
        ti.Start_Date__c = Date.today();
        ti.End_Date__c = Date.today().addDays(3);
        ti.Type_of_account_propagation__c = 'Apply to entire hierarchy'; 
        insert ti;
        Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
        tia.Account__c = acc.Id;
        tia.Target_Initiative__c = ti.Id;
        insert tia;
        //map_Tag_Initiave_Account1.put(tia.Id, tia);
        //UpdateAccount_OnTop200.updateAccount_OnAfterInsert(map_Tag_Initiave_Account1);
        
                Test.startTest();
        UpdateOnAccount_IsTop200Batch3 batchjob1 = new UpdateOnAccount_IsTop200Batch3();
        Database.executeBatch(batchjob1);
        Test.stopTest();

    }
}