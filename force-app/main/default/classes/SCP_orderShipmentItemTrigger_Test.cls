@isTest
public class SCP_orderShipmentItemTrigger_Test {

    static testmethod void test_trigger(){
    
         SCP_TestDataFactory.createCastIron();
         
        ccrz__E_Product__c objprod = new ccrz__E_Product__c();
        objprod.Name = 'Test';
        objprod.ccrz__SKU__c = 'test1234';
        objprod.ccrz__Quantityperunit__c= 10;
        objprod.ccrz__StartDate__c = System.Today();
        objprod.ccrz__EndDate__c= System.Today().addDays(100);
        insert objprod;
        
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
       insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
  
        ccrz__E_OrderShipment__c orderShip = new ccrz__E_OrderShipment__c();
        orderShip.ccrz__Order__c=order.Id;
        insert orderShip;
    
        ccrz__E_OrderShipmentItem__c OrderShipItem = new ccrz__E_OrderShipmentItem__c();
        OrderShipItem.ccrz__OrderShipment__c =orderShip.id;
        OrderShipItem.ccrz__SKU__c ='test1234';
        OrderShipItem.ccrz__Quantity__c=1;
        insert OrderShipItem;
        
        ccrz__E_OrderShipmentItem__c oLshipItem = new ccrz__E_OrderShipmentItem__c();
        oLshipItem=[select id,Product_Name__c from ccrz__E_OrderShipmentItem__c where id =:OrderShipItem.id];
        System.assertEquals(oLshipItem.Product_Name__c,objprod.Name);

    }
    
}