@isTest
public Class SAP_Sales_OrgTriggerHandler_Test{
    public static testmethod void SAPSalesOrgTriggerHandlertest(){
        accountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        SAP_Sales_Org__c sso = TestDataFactory.createSAPSAlesOrg_Integration();
        SAP_Sales_Org__c sso1 = TestDataFactory.createSAPSAlesOrgForAccount(sso.Account__c);
        sso1.Pricing_Date__c = Date.today().addDays(-10);
        update sso1;
        sso.Terms_of_Payment__c = 'MD31';
        update sso;
        sso.Terms_of_Payment__c = 'MD26'; 
        update sso;
        sso1.Pricing_Date__c = Date.today().addDays(-12);
        update sso1;
        sso1.Terms_of_Payment__c = 'MD31';
        update sso1;
        sso1.Terms_of_Payment__c = 'MD26'; 
        update sso;
        delete sso;
        //insert sso;
    }
    
}