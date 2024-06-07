@istest
public class SCP_TaxCalculation_Test {
    
    @testsetup
    public static void SCP_TaxCalculation_TestSetup(){
		AccountTriggerHandler.triggerdisabled = true;
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;

        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        SCP_TestDataFactory.createIntDetails_Auth();
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        cart.ccrz__EffectiveAccountID__c=acc.Id;
        cart.SAP_Shipping_Customer_Number__c='12345';
        update cart;
        
        SCP_TestDataFactory.createIntDetails_order_simulate();
        
        /*SCP_Integration_Details__c connection = new SCP_Integration_Details__c();
        connection.Name = 'SCP_Order_Simulate';  
        connection.SCP_Method_Type__c='POST';
        connection.SCP_Timeout__c = 120000;
        connection.SCP_End_Point__c = 'http://sfdc-sap-prc-api.us-w1.cloudhub.io/api/orders/simulate';
        insert connection;*/
        
        ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123');
        insert productObj;
        
        ccrz__E_CartItem__c oitem = new ccrz__E_CartItem__c(ccrz__Cart__c=cart.Id,ccrz__Price__c=123,ccrz__Product__c=productObj.Id);
        insert oitem;
        
    }
    @istest
    public static void getTaxAmount_test(){
        AccountTriggerHandler.triggerdisabled = true;
        ccrz__E_Cart__c cartObj = [Select Id From ccrz__E_Cart__c Limit 1];
        Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.cc_hk_TaxCalculation.PARAM_CARTID,cartObj.Id);
        Test.startTest();
        SCP_TaxCalculation taxCalculation = new SCP_TaxCalculation();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(0));
        taxCalculation.getTaxAmount(inputdata);
        
        SCP_TaxCalculation taxCalculation1 = new SCP_TaxCalculation();
        taxCalculation1.getTaxAmount(inputdata);
        Test.stopTest();
    }

}