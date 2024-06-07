/*** 
Test Class For - SCP_cc_hk_Order
Developer - Sanjana K.R 
***/
@isTest
public class SCP_cc_hk_OrderTest{
    
    @testSetup 
    public static void dataSetup(){
    
        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        order.ccrz__PaymentMethod__c = 'card';
        order.ccrz__OrderStatus__c =  'Completed';
        order.ccrz__PONumber__c ='1234';
        insert order;
        
        ccrz__E_TransactionPayment__c tPay = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c = 'Test PO',ccrz__AccountType__c = 'po',ccrz__CCOrder__c = order.id);
        insert tPay;
        System.assert(tPay.id != null);
        
    }
    
    @isTest
    public static void testOrderHook(){
    
        List<ccrz__E_Order__c> order = [select id,SAP_Order_Number__c,ccrz__BuyerCompanyName__c,ccrz__ShipStructure__c,ccrz__ExtShipTrackNo__c,ccrz__BuyerPhone__c,ccrz__OrderStatus__c,ccrz__BuyerEmail__c,ccrz__BuyerFirstName__c,ccrz__BuyerLastName__c,ccrz__BuyerMobilePhone__c,ccrz__OriginatedCart__c,ccrz__CurrencyISOCode__c,ccrz__ShipComplete__c,ccrz__EncryptedId__c,ccrz__OrderId__c,Name,ccrz__OrderDate__c,ccrz__OrderNumber__c,ccrz__ShipAmount__c,ccrz__SubtotalAmount__c,ccrz__TaxAmount__c,ccrz__TotalSurcharge__c,ccrz__ShipMethod__c,Owner.id,ccrz__RequestDate__c,ccrz__TotalAmount__c,ccrz__PaymentMethod__c,ccrz__PONumber__c,PO_Number__c,ccrz__BillTo__c,ccrz__ShipTo__c FROM ccrz__E_Order__c where ccrz__Name__c = 'Test Order' ];
        
        ccrz__E_Product__c recalib = SCP_TestDataFactory.createCassetteCanisterProduct('RECALIB');
        List<ccrz__E_OrderItem__c> majorOrderItem = SCP_TestDataFactory.createOrderItems(1,order[0]);
        insert majorOrderItem;
        SCP_TestDataFactory.createMinorOrderItems(1,order[0],majorOrderItem[0].Id,recalib.Id);
        
        ccrz__E_TransactionPayment__c tPay = [select id,ccrz__AccountType__c,ccrz__AccountNumber__c FROM ccrz__E_TransactionPayment__c where ccrz__CCOrder__c =: order[0].id LIMIT 1];
        System.assert(tPay.id != null);
        
        ccrz.cc_bean_MockOrder mockOrder = new ccrz.cc_bean_MockOrder(order[0]);
        List<ccrz.cc_bean_MockOrder> listMock = new List<ccrz.cc_bean_MockOrder>();
        listMock.add(mockOrder);
        Map<string,Object> inputData=new Map<string,Object>();        
        inputData.put(ccrz.cc_hk_Order.PARAM_ORDERS,listMock);            
        inputData.put(ccrz.cc_hk_Order.PARAM_SEARCH_ORDER_STATUS,'Completed');    
        
        Test.startTest();
        SCP_cc_hk_Order hookOrd = new SCP_cc_hk_Order();
        hookOrd.fetchOrderHistory(inputData);
        Test.stopTest();
        
    }
    
}