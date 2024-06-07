//test class for SCP_SubsOrderSimulateBatch and SCP_SubscriptionOrderSubmitBatch
// Developer: Subramanyam Gopinath


@istest
public class SCP_SubscriptionOrderSubmitBatch_Test {
    @testsetup
    public static void SCP_OrderSubmitReprocessBatch_Test_Setup(){
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
        
        ccrz__E_Subscription__c subscription= new ccrz__E_Subscription__c();
        subscription.ccrz__Sequence__c= 100;
        subscription.ccrz__Storefront__c= 'OmnicellB2BStore';
        subscription.ccrz__SubscriptionStartDate__c= Date.parse('04/26/21');
        subscription.ccrz__SubscriptionStatus__c= 'Active';
        insert subscription;
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        order.Process_OrderSubmit__c = True;
        order.ccrz__CCSubscription__c = subscription.id;
        insert order;
        
        ccrz__E_TransactionPayment__c tPay = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c = 'Test PO',ccrz__AccountType__c = 'po',ccrz__CCOrder__c = order.id);
        insert tPay;
        System.assert(tPay.id != null);
        
        ccrz__E_OrderItem__c oitem = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a', ccrz__Order__c=order.Id,ccrz__Price__c=12,ccrz__SubAmount__c=123);
        insert oitem;
        
        ccrz__E_OrderItem__c orderItems = [Select Id,Name From ccrz__E_OrderItem__c];
        ccrz__E_Order__c order1 = [Select Id,Integration_Status__c,SAP_Order_Number__c from ccrz__E_Order__c];
        order1.Integration_Status__c = 'Error';
        order1.SAP_Order_Number__c = '';
        update order1;
    }
    
    
    @istest
    public static void SCP_SubscriptionOrderSubmitBatch_Test_Method1(){
        
        String sch = '0 0 23 * * ?'; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(1));
        SCP_SubscriptionOrderSubmitScheduler sh2 = new SCP_SubscriptionOrderSubmitScheduler();
        system.schedule('Test Indexing Scheduler', sch, sh2);
        Test.stopTest();
    } 
    @istest
    public static void SCP_SubscriptionOrderSubmitBatch_Test_Method2(){
        ccrz__E_OrderItem__c orderItems = [Select Id,Name From ccrz__E_OrderItem__c Limit 1];
        String sch = '0 0 23 * * ?';            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(3,orderItems.Name.right(6)));
        SCP_SubscriptionOrderSubmitScheduler sh1 = new SCP_SubscriptionOrderSubmitScheduler();
        system.schedule('Test Indexing Scheduler', sch, sh1);
        Test.stopTest();
    }
    
    
}