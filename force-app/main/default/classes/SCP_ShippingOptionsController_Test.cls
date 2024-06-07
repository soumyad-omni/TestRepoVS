@istest
public class SCP_ShippingOptionsController_Test {

    @testsetup
    public static void SCP_TaxCalculation_TestSetup(){
        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        ContactTriggerHandler.TriggerDisabled = True;
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        ccrz__E_ContactAddr__c contAdd1 = SCP_TestDataFactory.getContactAddress();
        insert contAdd1;
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        cart.ccrz__EffectiveAccountID__c=acc.Id;
        cart.ccrz__EncryptedId__c=cart.Id;
        cart.SAP_Shipping_Customer_Number__c=acc.SAP_Account_ID__c;
        update cart;
    }
    @istest
    public static void updateReferenceNumber_test(){
        List<ccrz__E_ContactAddr__c> contAddr = [Select Id from ccrz__E_ContactAddr__c];
        ccrz__E_Cart__c cart = [Select Id From ccrz__E_Cart__c Limit 1];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.Id;
        Test.startTest();
        SCP_ShippingOptionsController controller = new SCP_ShippingOptionsController();
        String str = '{"contactId":"","shippingCustomerNumber":"123","shippingcompanyName2":"ABC","billingCustomerNumber":"123","billingcompanyName2":"ASD","shippingDt":"01/01/2099"}';
        SCP_ShippingOptionsController.updateReferenceNumber(ctx,'ABC');
        SCP_ShippingOptionsController.updateCCContactAddress(ctx,contAddr[0].Id,contAddr[1].Id,str);
        cart.ccrz__ShipTo__c = null;
        update cart;
        SCP_ShippingOptionsController controller1 = new SCP_ShippingOptionsController();
        String str1 = '{"contactId":"","shippingCustomerNumber":"123","shippingcompanyName2":"ABC","billingCustomerNumber":"123","billingcompanyName2":"ASD","shippingDt":"01/01/2099"}';
        SCP_ShippingOptionsController.updateReferenceNumber(ctx,'ABC');
        SCP_ShippingOptionsController.updateCCContactAddress(ctx,contAddr[0].Id,contAddr[1].Id,str);
        
        Test.stopTest();
        
    }
    @istest
    Public static void SCP_CartEmailController_Test_Method(){
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        String emailData='{"email_to":"test@test.com","email_cc":"test1.test.com","subject":"Test mail","description":"Desc"}';
        SCP_ShippingOptionsController.sendEmail(ctx,emailData);
    }
}