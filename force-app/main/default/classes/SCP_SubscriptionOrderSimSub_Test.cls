@isTest
    private class SCP_SubscriptionOrderSimSub_Test
    {
        public static String CRON_EXP = '0 0 0 15 4 ? 2022';

          @testSetup 
    public static void dataSetup(){
        
        SCP_TestDataFactory.createIntDetails_order_simulate();
        SCP_TestDataFactory.createCastIron();
        SCP_TestDataFactory.createIntDetails_Auth();
       Account acc = SCP_TestDataFactory.createAccounts(1)[0];
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
        insert subscription;
            
        ccrz__E_Order__c parentOrder = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        parentOrder.ccrz__ShipMethod__c = 'SHIP - Priority Overnight';        
        insert parentOrder;
        
        ccrz__E_Order__c childOrder = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        childOrder.Process_OrderSimulate__c = True;
        childOrder.ccrz__CCSubscription__c = subscription.id;
        childOrder.ccrz__EncryptedId__c = 'childOrder';
        childOrder.ccrz__Name__c = 'childOrder';
        childOrder.ccrz__OrderNumber__c = 123;
        childOrder.ccrz__Order__c = parentOrder.id;
        childOrder.ccrz__ShipMethod__c = 'SHIP - Priority Overnight';
        insert childOrder;
        
     
    }
    
        static testmethod void SCP_SubscriptionOrderSimSub_TestMethod() 
        {

         ccrz__E_Order__c order = [Select Id,ccrz__Order__r.ccrz__OriginatedCart__c,ccrz__ShipMethod__c from ccrz__E_Order__c where ccrz__EncryptedId__c = 'childOrder' Limit 1];
         List<ccrz__E_Cart__c> cartrec = new List<ccrz__E_Cart__c>([SELECT id, ccrz__Note__c, Name, ccrz__TaxAmount__c, ccrz__Account__r.SAP_Account_ID__c,ccrz__EffectiveAccountID__c,SAP_SOLD_TO__c  
                                                                        , ccrz__BillTo__r.SAP_Customer_Number__c
                                                                        , ccrz__ShipTo__r.SAP_Customer_Number__c
                                                                        , ccrz__Contact__r.SAP_Contact_ID__c, SAP_CONTACT_ID__c, SAP_Shipping_Customer_Number__c,SAP_Billing_Customer_Number__c 
                                                                        , WS_Credit_Block__c
                                                                        , WS_ErrorMessages__c
                                                                        , WS_Exception__c
                                                                        , ccrz__ShipMethod__c
                                                                        , (SELECT id,ccrz__Enabled__c,ccrz__Coupon__r.ccrz__CouponCode__c,ccrz__Coupon__r.ccrz__RuleType__c FROM ccrz__E_CartCoupons__r )
                                                                        , (SELECT Id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c FROM ccrz__E_CartItems__r)
                                                                        FROM ccrz__E_Cart__c
                                                                        LIMIT 1]);
         String str = '{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "","": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}}';
         SCP_OrderSimulate_Res_Parser responseMule = (SCP_OrderSimulate_Res_Parser)System.JSON.deserialize(str, SCP_OrderSimulate_Res_Parser.class);        
         
         Test.StartTest();   
         Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
         Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(3));         
         String jobId = System.schedule('SCP_SubscriptionOrderSimSub_TestMethod1' +System.now(),CRON_EXP, new SCP_SubscriptionOrderSimSub());
         Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(2));
         jobId = System.schedule('SCP_SubscriptionOrderSimSub_TestMethod2'+System.now(),CRON_EXP, new SCP_SubscriptionOrderSimSub());
         
         SCP_OrderSimulate ords = new SCP_OrderSimulate();
         ords.updateCartAndCartItems(responseMule,cartrec);
         Test.StopTest();
         }  
                              
}