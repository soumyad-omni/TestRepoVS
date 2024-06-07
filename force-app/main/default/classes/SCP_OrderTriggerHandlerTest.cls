@istest
    private class SCP_OrderTriggerHandlerTest {
 @testSetup 
    public static void dataSetup(){
        accounttriggerhandler.triggerdisabled = true;
        SCP_TestDataFactory.createIntDetails();
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;        
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c(Name = 'SCP_Mulesoft_Authorization', SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token',SCP_Key_Client_Id__c='ooooiiii',SCP_Method_Type__c='POST',SCP_Password_Client_Secret__c='xxxxxxxbbbbbbbbbxx',SCP_Grant_Type__c='CLIENT_CREDENTIALS');
		insert obj2;
        SCP_TestDataFactory.createCastIron();
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
       insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        SCP_TestDataFactory.createIntDetails_order_simulate();
        SCP_TestDataFactory.createTransactionPayment();
        SCP_TestDataFactory.createApexDebugLogs(true);
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        order.ccrz__OriginatedCart__c = cart.id;
        order.Integration_Status__c ='Submitted';
        insert order;
        
         ccrz__E_ContactAddr__c contAdd1 = SCP_TestDataFactory.getContactAddress();
         ccrz__E_ContactAddr__c contAdd2 = SCP_TestDataFactory.getContactAddress();
       
        ccrz__E_Order__c ord = new ccrz__E_Order__c();
            ord.ccrz__Account__c         = acc.Id;
            ord.ccrz__Name__c = 'TestOrdertest1';
       // ord.name = 'TestOrdertest';
            ord.ccrz__OrderNumber__c     = 1;
            ord.ccrz__OrderStatus__c ='Pending';
            ord.SHIP_COND__c  = 'Test';
            ord.ccrz__ShipAmount__c = 12.222;
            ord.ccrz__Storefront__c      = 'OmnicellB2BStore';
            ord.ccrz__BillTo__c          = contAdd2.Id;
            ord.ccrz__ShipTo__c          = contAdd2.Id;
            ord.ccrz__OrderDate__c       = Date.Today();
            
            ord.ccrz__OriginatedCart__c  = cart.Id;
            ord.ccrz__EncryptedId__c    = 'testEncryptedId12123432q';
            ord.ccrz__Note__c           = 'test class';
            ord.ccrz__ShipComplete__c   = false;
            ord.ccrz__ShipMethod__c     = 'SHIP - PRIORITY OVERNIGHT';
            ord.ccrz__RequestDate__c    = system.today()+3;
            ord.ccrz__Order__c=order.Id;
            insert ord;
        
        List<ccrz__E_Product__c> prd1 = SCP_TestDataFactory.createProducts(2);
        prd1[1].ccrz__SKU__c = 'NEW-CALIB';
        insert prd1;

        ccrz__E_Coupon__c coup = new ccrz__E_Coupon__c(ccrz__CouponName__c='Coupon Name',ccrz__MaxUse__c=10,ccrz__TotalUsed__c=0,ccrz__CouponCode__c='testcoup',ccrz__TargetRelation__c='Product',ccrz__TargetProduct__c=prd1[0].id,ccrz__TargetQty__c=10,ccrz__CouponType__c='Percentage');
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
        ccrz__E_Attribute__c attr30 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='CANISTER', ccrz__DisplayName__c='Canister', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp3.id, ccrz__Sequence__c=16666);
        insert attr30;
        ccrz__E_Attribute__c attr31 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='CASSETTE', ccrz__DisplayName__c='Cassette', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp3.id, ccrz__Sequence__c=17777);
        insert attr31;
        DrugCode__c drCode = new DrugCode__c(DrugCodes__c='8888888888888', Generic_Drug_Name__c='Test Drug 555', Brand_Name__c='Test Drug 555', Manufacturer_Name__c='Test Drug 555', Drug_Strength__c='555mg', Drug_Type__c='UPC', Dose_Unit__c='cell', Drug_Forms__c='AEROSOL (ML)-AEROSOL-AA');
		insert drCode;
		Machine__c mcCode1 = new Machine__c(Account_CSN__c=acc.Id, Machine_Type_Mapping__c='PACMED',Machine_Style__c='JV-100BX6',Machine_Type_Category__c='Canister', Machine_Name__c='PACMED9988', Machine_Id__c=9988, New_Calibration_Allotment__c=100, Purchased__c=0, Recalibration_Allotment__c=100, Recalibrations_Purchased__c=0, Agreement_sign_date__c=Date.today());      
		insert mcCode1;
		Machine__c mcCode2 = new Machine__c(Account_CSN__c=acc.Id, Machine_Type_Mapping__c='Acuflex',Machine_Style__c='Acuflex II',Machine_Type_Category__c='Base', Machine_Name__c='Accuflex889', Machine_Id__c=889, New_Calibration_Allotment__c=100, Purchased__c=0, Recalibration_Allotment__c=100, Recalibrations_Purchased__c=0, Agreement_sign_date__c=Date.today());      
		insert mcCode2;
        
        List<ccrz__E_OrderItem__c> orderItem = SCP_TestDataFactory.createOrderItems(2,order);
        orderItem[0].ccrz__Quantity__c=2.0;
        orderItem[0].Discounted_Quantity__c=2;
        //orderItem[0].ccrz__Order__c=order.id;
        orderItem[0].ccrz__Price__c=10.00;
        //orderItem[0].ccrz__Product__c =prd1[0].id;
        orderItem[0].ccrz__Coupon__c =coup.id;
        orderItem[0].ccrz__PricingType__c='auto';
        orderItem[0].ccrz__PrimaryAttr__c=attr2.id;
        orderItem[0].ccrz__SecondaryAttr__c=attr30.id;
        orderItem[0].ccrz__TertiaryAttr__c=attr1.id;
        orderItem[0].Machines__c=mcCode1.id;
        orderItem[0].Machine_Type__c='Canister';
        orderItem[0].Drug_Code_Exists_in_SAP__c=FALSE;
        orderItem[0].DrugCodes__c=drCode.id;
        orderItem[0].ccrz__SubAmount__c=0;

        orderItem[1].ccrz__Quantity__c=2.0;
        orderItem[1].Discounted_Quantity__c=2;
        //orderItem[1].ccrz__Order__c=order.id;
        orderItem[1].ccrz__Price__c=10.00;
        //orderItem[1].ccrz__Product__c =prd1[1].id;
        orderItem[1].ccrz__Coupon__c =coup.id;
        orderItem[1].ccrz__PricingType__c='auto';
        orderItem[1].ccrz__PrimaryAttr__c=attr2.id;
        orderItem[1].ccrz__SecondaryAttr__c=attr31.id;
        orderItem[1].ccrz__TertiaryAttr__c=attr1.id;
        orderItem[1].Machines__c=mcCode2.id;
        orderItem[1].Machine_Type__c='Base';
        orderItem[1].Drug_Code_Exists_in_SAP__c=FALSE;
        orderItem[1].DrugCodes__c=drCode.id;
        orderItem[1].ccrz__SubAmount__c=0;
        insert orderItem;
        

        //ccrz__E_OrderItem__c orderitem1 = new ccrz__E_OrderItem__c(ccrz__Quantity__c=2.0, Discounted_Quantity__c=2,ccrz__Order__c=order.id,ccrz__Price__c=10.00,ccrz__Product__c =prd1[0].id,ccrz__Coupon__c =coup.id,ccrz__PricingType__c='auto',ccrz__PrimaryAttr__c=attr2.id,ccrz__SecondaryAttr__c=attr30.id,ccrz__TertiaryAttr__c=attr1.id,Machine__c=mcCode1.id,Machine_Type__c='Canister', DrugCodes__c=drCode.id,ccrz__SubAmount__c=0);
        //insert orderitem1;        
        //ccrz__E_OrderItem__c orderitem2 = new ccrz__E_OrderItem__c(ccrz__Quantity__c=2.0, Discounted_Quantity__c=2,ccrz__Order__c=order.id,ccrz__Price__c=10.00,ccrz__Product__c =prd1[1].id,ccrz__PricingType__c='auto',ccrz__PrimaryAttr__c=attr2.id,ccrz__SecondaryAttr__c=attr31.id,ccrz__TertiaryAttr__c=attr1.id,Machine__c=mcCode.id,Machine_Type__c='Base', DrugCodes__c=drCode.id,ccrz__SubAmount__c=0);
        //insert orderitem2;        
        
        ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c(ccrz__Storefront__c='ABC',ccrz__TransactionCode__c='ACCEPT',ccrz__TransactionType__c='authorization,create_payment_token',ccrz__CCOrder__c=order.Id,ccrz__AccountType__c='sopcc');
        insert transactionPayment;
        
        ccrz__E_Invoice__c invoice = SCP_TestDataFactory.createInvoices(1,acc,con,contAdd)[0];
        invoice.ccrz__Type__c='Debit';
        invoice.ccrz__CCOrder__c=order.Id;
        insert invoice;
        
        ccrz__E_OrderShipment__c orderShip = new ccrz__E_OrderShipment__c(ccrz__Carrier__c='test',ccrz__DeliveryDate__c=System.TODAY(),ccrz__Order__c=order.Id,ccrz__ShipmentDate__c=System.TODAY(),Tracking_URL__c='google.com');
        insert orderShip; 
        
        ccrz__E_OrderShipmentItem__c shipItem = new ccrz__E_OrderShipmentItem__c(ccrz__Quantity__c=1,ccrz__SKU__c='test',ccrz__OrderShipment__c=orderShip.Id);
        insert shipItem;
    }
    
     @istest
    private Static Void SCP_OrderTriggerHandler_TestMethod(){
        accounttriggerhandler.triggerdisabled = true;
        List<ccrz__E_Order__c> OrderList = [SELECT id,Name,ccrz__OriginatedCart__c,Integration_Status__c,ccrz__BillTo__c,ccrz__ShipTo__c FROM ccrz__E_Order__c LIMIT 1];
        List<ccrz__E_Order__c> OrderList2 = [SELECT id,Name,ccrz__OriginatedCart__c,Integration_Status__c FROM ccrz__E_Order__c LIMIT 1];
        OrderList2[0].Integration_Status__c = 'Error';
        update OrderList2;
        
        Map<id,ccrz__E_Order__c> oldMap = new Map<id,ccrz__E_Order__c>();
        for(ccrz__E_Order__c co: OrderList){
            co.SAP_Order_Number__c = '1800898787';
            oldMap.put(co.id,co);
        }
        
        Map<id,ccrz__E_Order__c> newMap = new Map<id,ccrz__E_Order__c>();
        for(ccrz__E_Order__c co: OrderList2){
            co.SAP_Order_Number__c = '1800998787';
            newMap.put(co.id,co);
        }
        
        Test.StartTest();
        SCP_OrderTriggerHandler.beforeInsertEvent(OrderList);
        SCP_OrderTriggerHandler.NotificationOnOrderFail(newMap,oldMap);
        SCP_OrderTriggerHandler.sendMailForMissingDrugCode(newMap, oldMap);
        Test.StopTest();
    }  
   
     @istest
   private Static Void CloneTPtoChildOrder_TestMethod(){
       accounttriggerhandler.triggerdisabled = true;
        List<ccrz__E_Order__c> OrderList = [SELECT id,Name,ccrz__OriginatedCart__c,Integration_Status__c,
                                            ccrz__Account__c,ccrz__Name__c,ccrz__OrderNumber__c,ccrz__OrderStatus__c,
                                            SHIP_COND__c,ccrz__ShipAmount__c,ccrz__Storefront__c,ccrz__BillTo__c,ccrz__ShipTo__c,
                                            ccrz__OrderDate__c,ccrz__EncryptedId__c,ccrz__Note__c,ccrz__ShipComplete__c,ccrz__ShipMethod__c,
                                            ccrz__RequestDate__c,ccrz__Order__c
                                            FROM ccrz__E_Order__c where ccrz__Name__c = 'TestOrdertest1' LIMIT 1];

           
           
        system.debug('## OrderList--'+OrderList); 
       Test.StartTest();
        SCP_OrderTriggerHandler.CloneTPtoChildOrder(orderList);
         Test.StopTest(); 
    }
    
    @istest
    private Static Void TestMethod3(){
        accounttriggerhandler.triggerdisabled = true;
        List<ccrz__E_Order__c> OrderList = [SELECT Name,ccrz__OriginatedCart__c,Integration_Status__c,
                                            ccrz__Account__c,ccrz__Name__c,ccrz__OrderNumber__c,ccrz__OrderStatus__c,
                                            SHIP_COND__c,ccrz__ShipAmount__c,ccrz__Storefront__c,ccrz__BillTo__c,ccrz__ShipTo__c,
                                            ccrz__OrderDate__c,ccrz__EncryptedId__c,ccrz__Note__c,ccrz__ShipComplete__c,ccrz__ShipMethod__c,
                                            ccrz__RequestDate__c,ccrz__Order__c
                                            FROM ccrz__E_Order__c where ccrz__Name__c = 'TestOrdertest1' LIMIT 1];
	   System.debug('***'+OrderList.size());
        ccrz__E_Order__c ord = new ccrz__E_Order__c();
        ord.ccrz__OriginatedCart__c = OrderList[0].ccrz__OriginatedCart__c;
       Attachment att = new Attachment();
       att.Name ='Unit Test Attachment';
       att.Body =Blob.valueOf('Unit Test Attachment Body');
	   att.ParentId = ord.ccrz__OriginatedCart__c;   
        insert att;
       system.debug('## OrderList--'+OrderList); 
       Test.StartTest();
        insert ord;
        SCP_OrderTriggerHandler.CloneTPtoChildOrder(orderList);
         Test.StopTest(); 
    }
}