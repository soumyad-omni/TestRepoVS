@isTest
public class SCP_cc_batch_subscriptionProcessor_test {
    
    @testSetup 
    public static void dataSetup(){
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_Order_Submit';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'https://mulesoft.omnicell.com/';
        insert setting;
        
        SCP_TestDataFactory.createIntDetails_order_simulate();
        SCP_TestDataFactory.createCastIron();
        SCP_TestDataFactory.createIntDetails_Auth();
        //Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                            Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                            Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                            BillingCountryCode = 'US',
                                            Account_Status__c = 'Active',IsDeleted__c = false,  
                                            Transport_Zone__c='US00000001',Partner_Type__c= '0015');
            acc.SAP_Account_ID__c = '500300';
            acc.Validation_Status__c = 'Validated';
            acc.Facility_Type__c = 'Pharmacy';
            acc.BILLINGSTREET = '41 Moss';
            acc.BillingPostalCode = '77777';
            
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        cart.ccrz__EffectiveAccountID__c = acc.id;
        insert cart;
        
        
        ccrz__E_Subscription__c subscription= new ccrz__E_Subscription__c();
        subscription.ccrz__Sequence__c= 100;
        subscription.ccrz__Storefront__c= 'OmnicellB2BStore';
        subscription.ccrz__SubscriptionStartDate__c= Date.parse('04/26/21');
        subscription.ccrz__SubscriptionStatus__c= 'Active';
        subscription.ccrz__OrderNextDate__c= Date.parse('04/26/21');
        subscription.ccrz__OrderCountRemaining__c= 2;
        subscription.ccrz__InstallmentNextDate__c= Date.parse('04/26/21');
        subscription.ccrz__InstallmentCountRemaining__c =1;
        subscription.ccrz__SPTInstallmentFrequencyUOM__c = 'Weekly';
        insert subscription;
        
        ccrz__E_Subscription__c subscription1= new ccrz__E_Subscription__c();
        subscription1.ccrz__Sequence__c= 100;
        subscription1.ccrz__Storefront__c= 'OmnicellB2BStore';
        subscription1.ccrz__SubscriptionStartDate__c= Date.parse('04/26/21');
        subscription1.ccrz__SubscriptionStatus__c= 'Active';
        subscription1.ccrz__OrderNextDate__c= Date.parse('04/26/21');
        subscription1.ccrz__OrderCountRemaining__c= 2;
        subscription1.ccrz__InstallmentCountRemaining__c =1;
        subscription1.ccrz__SPTInstallmentFrequencyUOM__c = 'Monthly';
        subscription1.ccrz__InstallmentNextDate__c= Date.parse('04/26/21');
        insert subscription1;
            
        ccrz__E_Order__c parentOrder = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        parentOrder.ccrz__ShipMethod__c = 'SHIP - Priority Overnight';        
        insert parentOrder;
        ccrz__E_OrderItem__c oitem = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a',ccrz__Order__c=parentOrder.Id,ccrz__Price__c=12,ccrz__SubAmount__c=123);
        insert oitem;
        
        
        List<ccrz__E_Order__c> childOrder = SCP_TestDataFactory.createOrders(2,cart,acc,con,contAdd);
        childOrder[0].Process_OrderSimulate__c = True;
        childOrder[0].ccrz__CCSubscription__c = subscription.id;
        childOrder[0].ccrz__EncryptedId__c = 'childOrder';
        childOrder[0].ccrz__Name__c = 'childOrder';
        childOrder[0].ccrz__OrderNumber__c = 123;
        childOrder[0].ccrz__Order__c = parentOrder.id;
        childOrder[0].ccrz__ShipMethod__c = 'SHIP - Priority Overnight';
        insert childOrder[0];
        
        //ccrz__E_Order__c childOrder1 = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        childOrder[1].Process_OrderSimulate__c = True;
        childOrder[1].ccrz__CCSubscription__c = subscription1.id;
        childOrder[1].ccrz__EncryptedId__c = 'childOrder1';
        childOrder[1].ccrz__Name__c = 'childOrder1';
        childOrder[1].ccrz__OrderNumber__c = 1234;
        childOrder[1].ccrz__Order__c = parentOrder.id;
        childOrder[1].ccrz__ShipMethod__c = 'SHIP - Priority Overnight';
        insert childOrder[1];
        
        ccrz__E_OrderItem__c oitem1 = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a',ccrz__Order__c=childOrder[0].Id,ccrz__Price__c=12,ccrz__SubAmount__c=123);
        insert oitem1;
        
        ccrz__E_OrderItem__c oitem12 = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a',ccrz__Order__c=childOrder[1].Id,ccrz__Price__c=12,ccrz__SubAmount__c=123);
        insert oitem12;
     
    }
    @istest
    public static void test1(){
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
        System.debug('***'+ship_to+sold_to);
        String str = '{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "","": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}}';
        //SCP_OrderSimulate_Res_Parser responseMule = (SCP_OrderSimulate_Res_Parser)System.JSON.deserialize(str, SCP_OrderSimulate_Res_Parser.class);
        Test.StartTest();   
         Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
         
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(0));
        /*List<ccrz__E_Order__c> orderLst = [SELECT id,Name,Process_OrderSubmit__c,ccrz__CCSubscription__c,ccrz__CCSubscription__r.ccrz__InstallmentCountRemaining__c,ccrz__OrderId__c,ccrz__Account__r.SAP_Account_ID__c,ccrz__Contact__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Customer_Number__c,ccrz__ShipTo__r.ccrz__ShippingComments__c,ccrz__BillTo__r.SAP_Customer_Number__c,ccrz__BillTo__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Contact_ID__c,ccrz__Note__c,ccrz__ShipAmount__c,SAP_Order_Number__c,SHIP_COND__c,ccrz__PONumber__c,ccrz__OriginatedCart__c,ccrz__TotalDiscount__c FROM ccrz__E_Order__c limit 100];
        SCP_SubsOrderSubmitUpdate orderSubAPI = new SCP_SubsOrderSubmitUpdate();
        orderSubAPI.OrderSubmitUpdateCall(orderLst);
        orderSubAPI.errorDetails(order, responseMule);*/
        SCP_cc_batch_subscriptionProcessor  s = new SCP_cc_batch_subscriptionProcessor();
        DataBase.executeBatch(s);
        Test.stopTest();
    }
    
    /*
    @istest
    public static void test2(){
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
        Test.StartTest();   
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(5));
        List<ccrz__E_OrderItem__c> orderItemList = SCP_TestDataFactory.createOrderItems(5,order); 
        List<ccrz__E_Order__c> orderLst = new List<ccrz__E_Order__c>();
        orderLst.add(order);
        SCP_SubsOrderSubmitUpdate orderSubAPI = new SCP_SubsOrderSubmitUpdate();
        orderSubAPI.OrderSubmitUpdateCall(orderLst);
        Test.stopTest();
    }
    
    @istest
    public static void test3(){
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
        Test.StartTest();   
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(6));
        List<ccrz__E_OrderItem__c> orderItemList = SCP_TestDataFactory.createOrderItems(5,order); 
        List<ccrz__E_Order__c> orderLst = new List<ccrz__E_Order__c>();
        orderLst.add(order);
        SCP_SubsOrderSubmitUpdate orderSubAPI = new SCP_SubsOrderSubmitUpdate();
        orderSubAPI.OrderSubmitUpdateCall(orderLst);
        Test.stopTest();   
    }
    
    @istest
    public static void test4(){
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
        Test.StartTest();   
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(1));
        List<ccrz__E_OrderItem__c> orderItemList = SCP_TestDataFactory.createOrderItems(5,order); 
        List<ccrz__E_Order__c> orderLst = new List<ccrz__E_Order__c>();
        orderLst.add(order);
        SCP_SubsOrderSubmitUpdate orderSubAPI = new SCP_SubsOrderSubmitUpdate();
        orderSubAPI.OrderSubmitUpdateCall(orderLst);
        Test.stopTest();   
    }
	*/
}