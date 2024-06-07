@istest
public class SCP_CartPDFCntrl_Test {

    @testsetup
    Public static void SCP_CartPDFCntrl_Test_setup(){
       SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        cart.ccrz__EffectiveAccountID__c = acc.id;
        insert cart;
        cart.ccrz__EncryptedId__c=cart.Id;
        update cart;
        
        ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123',ccrz__ShortDescRT__c=null);
        insert productObj;
        
        ccrz__E_CartItem__c cItem = new ccrz__E_CartItem__c(ccrz__Price__c=9.0,ccrz__Product__c=productObj.Id,ccrz__Cart__c=cart.Id,ccrz__AbsoluteDiscount__c=null);
        insert cItem;
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
        
        ccrz__E_TransactionPayment__c tPay = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c = 'Test PO',ccrz__AccountType__c = 'po',ccrz__CCOrder__c = order.id,ccrz__VerificationCode__c='1234',ccrz__Token__c='12567');
        insert tPay;
        System.assert(tPay.id != null);
        
        ccrz__E_OrderItem__c oitem = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a',ccrz__Order__c=order.Id,ccrz__Price__c=12,ccrz__SubAmount__c=123);
        insert oitem;
        
        ccrz__E_OrderShipment__c orderShip = new ccrz__E_OrderShipment__c(ccrz__Carrier__c='test',ccrz__DeliveryDate__c=System.TODAY(),ccrz__Order__c=order.Id,ccrz__ShipmentDate__c=System.TODAY(),Tracking_URL__c='google.com');
        insert orderShip; 
    }
    
    @istest
    Public static void SCP_CartPDFCntrl_Test_Method(){
        ccrz__E_Cart__c cart = [Select Id From ccrz__E_Cart__c Limit 1];
        
        Test.startTest();
            PageReference myVfPage = Page.SCP_EmailCartPDF;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('recordId',cart.Id);
            SCP_CartPDFCntrl ctrl = new SCP_CartPDFCntrl();
            SCP_CartPDFCntrl.wrapCartItems cartItems = new SCP_CartPDFCntrl.wrapCartItems('a','b','c','d','e','f','g');
            //.send();
        Test.stopTest();
        
    }
}