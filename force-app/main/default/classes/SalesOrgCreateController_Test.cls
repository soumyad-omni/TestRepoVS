@isTest
public class SalesOrgCreateController_Test{

    @testSetup private static void dataSetup(){
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = True;
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
    }

    private static testmethod  void CreateNewSalesOrg_Test(){
    	SAP_Sales_Org__c sso = [select id,Account__c from SAP_Sales_Org__c limit 1];
        string ssoJson = JSON.serialize(sso);
        system.debug(ssoJson);
        SAP_Sales_Org__c rec = (SAP_Sales_Org__c)Json.deserialize(ssoJson,SAP_Sales_Org__c.class);
    	system.debug(rec);
        Test.startTest();
        SalesOrgCreateController.CreateNewSalesOrg(ssoJson, ssoJson);
        Test.stopTest();
    }
}