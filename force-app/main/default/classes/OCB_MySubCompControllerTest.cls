@isTest
public class OCB_MySubCompControllerTest {
    
    @testsetup
    public static void Data_TestSetup(){
        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
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
        update cart;
    }
	@isTest
    public static void test1(){
        List<ccrz__E_ContactAddr__c> contAddr = [Select Id from ccrz__E_ContactAddr__c];
        ccrz__E_Cart__c cart = [Select Id,ccrz__EffectiveAccountID__c From ccrz__E_Cart__c Limit 1];
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ctx.currentCartId = cart.Id;
        ctx.effAccountId = cart.ccrz__EffectiveAccountID__c;
        Test.startTest();
        	OCB_MySubscriptionComponentController cont = new OCB_MySubscriptionComponentController();
        	OCB_MySubscriptionComponentController.getAllSubscriptions(ctx);
		Test.stopTest();
    }
}