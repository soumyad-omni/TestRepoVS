@istest
private class SCP_CartTriggerHandlerTest {
    @istest 
    private Static Void SCP_CartTriggerHandler_TestMethod(){
        SCP_TestDataFactory.createCastIron();
        AccountTriggerHandler.TriggerDisabled = True;
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        ContactTriggerHandler.TriggerDisabled = True;
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        SCP_TestDataFactory.createApexDebugLogs(true);
        List<ccrz__E_Product__c> products = SCP_TestDataFactory.createProducts(1);
        List<ccrz__E_CartItem__c> cartItem = SCP_TestDataFactory.createCartItems(1,cart);
        cartItem[0].ccrz__Product__c = products[0].Id;
        insert cartItem;
        ccrz__E_Coupon__c coupon = SCP_TestDataFactory.createValidCoupon(products[0].Id, 'TestF32');
        cartItem[0].ccrz__Coupon__c = coupon.Id;
        cartItem[0].Discounted_Quantity__c = 10;
        update cartItem;
        SCP_TestDataFactory.createCartCoupon(coupon,cart);
    }
}