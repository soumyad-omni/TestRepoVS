@isTest
Public class SCP_OrderSubmitAPITest  {
    @testSetup 
    public static void dataSetup(){
        
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
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
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
        
        ccrz__E_TransactionPayment__c tPay = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c = 'Test PO',ccrz__AccountType__c = 'po',ccrz__CCOrder__c = order.id);
        insert tPay;
        System.assert(tPay.id != null);
        
        List<ccrz__E_Product__c> prd1 = SCP_TestDataFactory.createProducts(2);
        insert prd1;
        
        ccrz__E_OrderItem__c oitem = new ccrz__E_OrderItem__c(ccrz__Quantity__c=1,ccrz__UnitOfMeasure__c='a',ccrz__Order__c=order.Id,ccrz__Product__c=prd1[0].id,ccrz__Price__c=12,ccrz__SubAmount__c=123,ccrz__PricingType__c='auto');
        insert oitem;
        
        ccrz__E_Coupon__c coup = new ccrz__E_Coupon__c(ccrz__CouponName__c='Coupon Name',ccrz__MaxUse__c=10,ccrz__TotalUsed__c=0,ccrz__CouponCode__c='testcoup',ccrz__TargetRelation__c='Product',ccrz__TargetProduct__c=prd1[1].id,ccrz__TargetQty__c=10,ccrz__CouponType__c='Percentage');
        insert coup;
        
        ccrz__E_Attribute__c attrp1 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='NDC', ccrz__DisplayName__c='Drug Code', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__Sequence__c=11111);
        insert attrp1;
        ccrz__E_Attribute__c attr1 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='00005555', ccrz__DisplayName__c='00005555', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp1.id, ccrz__Sequence__c=12222);
        insert attr1;
        ccrz__E_Attribute__c attrp2 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='MACHINE', ccrz__DisplayName__c='MACHINE', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__Sequence__c=13333);
        insert attrp2;
        ccrz__E_Attribute__c attr2 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='11115555', ccrz__DisplayName__c='11115555', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp2.id, ccrz__Sequence__c=14444);
        insert attr2;
        ccrz__E_Attribute__c attrp3 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='TYPE', ccrz__DisplayName__c='TYPE', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__Sequence__c=15555);
        insert attrp3;
        ccrz__E_Attribute__c attr3 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='CANISTER', ccrz__DisplayName__c='Canister', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp3.id, ccrz__Sequence__c=16666);
        insert attr3;
        DrugCode__c drCode = new DrugCode__c(DrugCodes__c='8888888888888', Generic_Drug_Name__c='Test Drug 555', Brand_Name__c='Test Drug 555', Manufacturer_Name__c='Test Drug 555', Drug_Strength__c='555mg', Drug_Type__c='UPC', Dose_Unit__c='cell', Drug_Forms__c='AEROSOL (ML)-AEROSOL-AA');
		insert drCode;
		Machine__c mcCode = new Machine__c(Account_CSN__c=acc.Id, Machine_Type_Mapping__c='PACMED', Machine_Type_Category__c='Canister', Machine_Name__c='PACMED9988', Machine_Id__c=9988, New_Calibration_Allotment__c=100, Purchased__c=0, Recalibration_Allotment__c=100, Recalibrations_Purchased__c=0, Agreement_sign_date__c=Date.today());      

        ccrz__E_OrderItem__c orderitem = new ccrz__E_OrderItem__c(ccrz__Quantity__c=2.0, Discounted_Quantity__c=2,ccrz__Order__c=order.id,ccrz__Price__c=10.00,ccrz__Product__c =prd1[1].id,ccrz__Coupon__c =coup.id,ccrz__PricingType__c='auto',ccrz__PrimaryAttr__c=attr2.id,ccrz__SecondaryAttr__c=attr3.id,ccrz__TertiaryAttr__c=attr1.id,Machines__c=mcCode.id,Machine_Type__c='Canister', DrugCodes__c=drCode.id,ccrz__SubAmount__c=0);
        insert orderitem;
        
    }
    
    @isTest
    public static void sendOrderInformationToSAP(){
        
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
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(0));
        SCP_OrderSubmitAPI  ordersubmit = new SCP_OrderSubmitAPI();
        ordersubmit.sendOrderInformationToSAP(order.Id);
        Test.stopTest();
    }
    @isTest
    public static void sendOrderInformationToSAP1(){
        ccrz__E_Order__c order = [Select Id from ccrz__E_Order__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(1));
        SCP_OrderSubmitAPI  ordersubmit1 = new SCP_OrderSubmitAPI();
        ordersubmit1.sendOrderInformationToSAP(order.Id);
        Test.stopTest();
    }
    @isTest
    public static void test3(){
        
        ccrz__E_Order__c order = [Select Id,ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c,ccrz__OriginatedCart__r.SAP_SOLD_TO__c from ccrz__E_Order__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(0));
        SCP_OrderSubmitAPI  ordersubmit = new SCP_OrderSubmitAPI();
        ordersubmit.sendOrderInformationToSAP(order.Id);
        Test.stopTest();
    }
    
    @isTest
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
        System.debug('***'+ship_to+sold_to);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(1));
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(1));
        SCP_OrderSubmitAPI  ordersubmit = new SCP_OrderSubmitAPI();
      
        
        ordersubmit.sendOrderInformationToSAP(order.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void test5(){
        id ordId = [Select id From ccrz__E_Order__c Limit 1].id;
        id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
        id accid = [Select id from account limit 1].id;
        
        
        
        ccrz__E_CartItem__c cartitem2 = new ccrz__E_CartItem__c(ccrz__Quantity__c=5.0, Discounted_Quantity__c=0.0,ccrz__Cart__c=cartObjid,ccrz__Price__c=50.00);
        insert cartitem2;
        
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        insert Product1;
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
        insert coupon;

        ccrz__E_CartCoupon__c cartcou = new ccrz__E_CartCoupon__c();
        cartcou.ccrz__Cart__c = cartObjid;
        cartcou.ccrz__Coupon__c = coupon.id;
        insert cartcou;

        List<ccrz__E_Order__c> ordertoWrapList=[SELECT id
                                                            , Name, ccrz__CCSubscription__c 
                                                            , ccrz__OrderId__c, ccrz__RequestDate__c 
                                                            , ccrz__Account__r.SAP_Account_ID__c
                                                            , ccrz__Contact__r.SAP_Contact_ID__c 
                                                            , ccrz__ShipTo__r.SAP_Customer_Number__c
                                                            , ccrz__ShipTo__r.ccrz__ShippingComments__c
                                                            , ccrz__BillTo__r.SAP_Customer_Number__c
                                                            , ccrz__BillTo__r.SAP_Contact_ID__c 
                                                            , ccrz__ShipTo__r.SAP_Contact_ID__c
                                                            , ccrz__OriginatedCart__r.SAP_CONTACT_ID__c
                                                            , ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c
                                                            , ccrz__OriginatedCart__r.SAP_Billing_Customer_Number__c
                                                            , ccrz__OriginatedCart__r.SAP_SOLD_TO__c
                                                            , ccrz__Note__c
                                                            , ccrz__ShipAmount__c 
                                                            , SAP_Order_Number__c
                                                            , SHIP_COND__c
                                                            , ccrz__PONumber__c
                                                            , ccrz__OriginatedCart__c
                                                            , ccrz__TotalDiscount__c
                                                            , SCP_Retry_Count__c
                                                            , ET_MESSAGES__c
                                                            , EX_CR_BLOCK__c
                                                            , EX_EXCEPTION__c
                                                            , Integration_Status__c
                                                            , (SELECT id,ccrz__AccountNumber__c,ccrz__AccountType__c FROM ccrz__TransactionPayments__r WHERE ccrz__CCOrder__c=:ordId LIMIT 1)
                                                            //, (SELECT id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__OrderItemStatus__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c,Discounted_Quantity__c,ccrz__PricingType__c FROM ccrz__E_OrderItems__r)
                                                			, (SELECT id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__OrderItemStatus__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c,Discounted_Quantity__c,ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__SecondaryAttr__r.ccrz__DisplayName__c,ccrz__TertiaryAttr__r.ccrz__DisplayName__c,Material__c, DrugCodes__c, DrugCodes__r.DrugCodes__c,DrugCodes__r.Drug_Type__c,ccrz__Price__c,ccrz__SubAmount__c,ccrz__PricingType__c, Machines__r.Machine_Id__c, Machines__r.Original_Sales_order_Number__c FROM ccrz__E_OrderItems__r)
                                                            FROM ccrz__E_Order__c
                                                            WHERE id=:ordId LIMIT 1]; 
        List<ccrz__E_CartCoupon__c> cartCouponList=     [SELECT id,ccrz__Coupon__r.ccrz__RuleType__c FROM ccrz__E_CartCoupon__c WHERE ccrz__Cart__c=:cartObjid];
        
        String st = SCP_OrderSubmit_Req_Wrapper.createJSONRequestBody(ordertoWrapList,cartCouponList);
         
    }
    


  
   

}