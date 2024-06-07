@istest
public class SCP_OrderSubmitReprocessBatch_Test {

    @testsetup
    public static void SCP_OrderSubmitReprocessBatch_Test_Setup(){
        
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        SCP_TestDataFactory.createIntDetails_Auth();
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        AccountTriggerHandler.TriggerDisabled = True;
       insert acc;
        ContactTriggerHandler.TriggerDisabled = True;
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
        
        ccrz__E_TransactionPayment__c tPay = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c = 'Test PO',ccrz__AccountType__c = 'po',ccrz__CCOrder__c = order.id);
        insert tPay;
        System.assert(tPay.id != null);
        
        ccrz__E_OrderItem__c oitem = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a',ccrz__Order__c=order.Id,ccrz__Price__c=12,ccrz__SubAmount__c=123);
        insert oitem;
        
        ccrz__E_OrderItem__c orderItems = [Select Id,Name From ccrz__E_OrderItem__c];
        ccrz__E_Order__c order1 = [Select Id,Integration_Status__c,SAP_Order_Number__c from ccrz__E_Order__c];
        order1.Integration_Status__c = 'Error';
        order1.SAP_Order_Number__c = '';
        update order1; 
    }
    
    @istest
    public static void SCP_OrderSubmitReprocessBatch_Test_Method1(){
        ccrz__E_Order__c order = [Select Id,ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c,ccrz__OriginatedCart__r.SAP_SOLD_TO__c from ccrz__E_Order__c Limit 1];
        ccrz__E_Cart__c orgCart = [Select Id,SAP_Shipping_Customer_Number__c,SAP_SOLD_TO__c From ccrz__E_Cart__c Where id =: order.ccrz__OriginatedCart__c limit 1];
        //System.debug('***'+order.ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c+order.ccrz__OriginatedCart__r.SAP_SOLD_TO__c);
        orgCart.SAP_Shipping_Customer_Number__c = '123456';
        orgCart.SAP_SOLD_TO__c = '123456';
        update orgCart;
        order.ccrz__OriginatedCart__c = orgCart.id;
        update order;
        
        String ship_to,sold_to;
            ship_to = order.ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c != null ? order.ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c : '';
        	sold_to = order.ccrz__OriginatedCart__r.SAP_SOLD_TO__c!=null ? order.ccrz__OriginatedCart__r.SAP_SOLD_TO__c : '';
        String str = '{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "","": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}}';
        SCP_OrderSimulate_Res_Parser responseMule = (SCP_OrderSimulate_Res_Parser)System.JSON.deserialize(str, SCP_OrderSimulate_Res_Parser.class);
        String sch = '0 0 23 * * ?'; 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(0));
            SCP_OrderReprocessScheduler sh1 = new SCP_OrderReprocessScheduler();
            system.schedule('Test Indexing Scheduler', sch, sh1);
            SCP_OrderSubmitReprocessBatch batch = new SCP_OrderSubmitReprocessBatch();
            batch.errorDetails(order, responseMule);
        Test.stopTest();    
    }
    @istest
    public static void SCP_OrderSubmitReprocessBatch_Test_Method2(){

        String sch = '0 0 23 * * ?'; 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(1));
            SCP_OrderReprocessScheduler sh2 = new SCP_OrderReprocessScheduler();
            system.schedule('Test Indexing Scheduler', sch, sh2);
        Test.stopTest();
    }
    
    @istest
    public static void SCP_OrderSubmitReprocessBatch_Test_Method3(){
        ccrz__E_OrderItem__c orderItems = [Select Id,Name From ccrz__E_OrderItem__c Limit 1];
        String sch = '0 0 23 * * ?'; 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(3,orderItems.Name.right(6)));
            SCP_OrderReprocessScheduler sh3 = new SCP_OrderReprocessScheduler();
            system.schedule('Test Indexing Scheduler', sch, sh3);
        Test.stopTest();
    }
    @istest
    public static void SCP_OrderSubmitReprocessBatch_Test_Method4(){
        ccrz__E_Order__c order = [Select Id,Integration_Status__c,SAP_Order_Number__c from ccrz__E_Order__c LIMIT 1];
        
            
        List<ccrz__E_OrderItem__c> orderItems = [Select id From ccrz__E_OrderItem__c Where ccrz__Order__c =: order.Id];
        delete orderItems;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(4));
            
            Database.executeBatch(new SCP_OrderSubmitReprocessBatch(), 10);
        Test.stopTest();    
    }
    @istest
    public static void SCP_OrderSubmitReprocessBatch_Test_Method5(){
        ccrz__E_Order__c order = [Select Id,ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c,ccrz__OriginatedCart__r.SAP_SOLD_TO__c from ccrz__E_Order__c Limit 1];
        ccrz__E_Cart__c orgCart = [Select Id,SAP_Shipping_Customer_Number__c,SAP_SOLD_TO__c From ccrz__E_Cart__c Where id =: order.ccrz__OriginatedCart__c limit 1];
        System.debug('***'+order.ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c+order.ccrz__OriginatedCart__r.SAP_SOLD_TO__c);
        orgCart.SAP_Shipping_Customer_Number__c = '123456';
        orgCart.SAP_SOLD_TO__c = '123456';
        update orgCart;
        order.ccrz__OriginatedCart__c = orgCart.id;
        update order;
        
        String ship_to,sold_to;
            ship_to = order.ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c != null ? order.ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c : '';
        	sold_to = order.ccrz__OriginatedCart__r.SAP_SOLD_TO__c!=null ? order.ccrz__OriginatedCart__r.SAP_SOLD_TO__c : '';
            
        List<ccrz__E_OrderItem__c> orderItems = [Select id From ccrz__E_OrderItem__c Where ccrz__Order__c =: order.Id];
        delete orderItems;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(6));
            
            Database.executeBatch(new SCP_OrderSubmitReprocessBatch(), 10);
        Test.stopTest();    
    }
    
}