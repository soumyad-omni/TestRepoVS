@istest
public class SCP_ProcessInvoiceHandler_Test {

    @testsetup
    Public static void SCP_ProcessInvoiceHandler_Test_Setup(){
        //SCP_TestDataFactory.createIntDetails();
        //SCP_TestDataFactory.createCastIron();
        SCP_TestDataFactory.createContact_Customsetting();
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_Cybersource_Capture';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'https://ics2wstesta.ic3.com/commerce/1.x/transactionProcessor';
        setting.SCP_Key_Client_Id__c='mckauto';
        setting.SCP_Password_Client_Secret__c='Fl4HlUfqcU3vONBMuZbn/unYriTqd7jOI9ccHYtsMRAveUQ6gCBB9OOvXqm8oZvJpPehC5rFq+ejH4QJQEu/N2gxdI6qlnjbRblXq0BLaJGxS5cITTDJ+5tdMMgG7S9gaiYRzGugFs966pM0wF92ZCgw6p+S3FY75EYwZOKmKu+AFBHJN9OOO7uy9/u8QzQ3rrAvYZ12u8/aFGPb3diV0vMLSmBofu4YizdLNfIWFwj7QiAfMj85SbQ7K96RIzC';
        insert setting;
        
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
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
    Public static void SCP_ProcessInvoiceHandler_Test_method(){
        ccrz__E_TransactionPayment__c tpay = [Select Id,ccrz__AccountNumber__c,ccrz__AccountType__c,ccrz__CCOrder__c,ccrz__VerificationCode__c,ccrz__Token__c from ccrz__E_TransactionPayment__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(0));
        try{
        SCP_ProcessInvoiceHandler.sendCreditSettlementToCybersource(tpay);
        }
        catch(exception e){}
        Test.stoptest();
    }
}