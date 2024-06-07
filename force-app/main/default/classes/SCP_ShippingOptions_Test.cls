@istest
public class SCP_ShippingOptions_Test {
    
    @testsetup
    public static void SCP_ShippingOptions_TestSetup(){
        AccountTriggerHandler.triggerdisabled = true;
        contacttriggerhandler.triggerdisabled = true;
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
        cart.ccrz__EffectiveAccountID__c=acc.Id;
        cart.SAP_Shipping_Customer_Number__c='12345';
        update cart;
        
        SCP_TestDataFactory.createIntDetails_order_simulate();

        ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123',ccrz__ShippingWeight__c=151);
        insert productObj;
        
        ccrz__E_CartItem__c oitem = new ccrz__E_CartItem__c(ccrz__Cart__c=cart.Id,ccrz__Price__c=123,ccrz__Product__c=productObj.Id);
        insert oitem;    
    }
    
    @istest
    public static void getShippingOptions_test(){
        AccountTriggerHandler.triggerdisabled = true;
        SCP_ShippingOptions shippingOptions = new SCP_ShippingOptions();
        SCP_ShippingOptions shippingOptions1 = new SCP_ShippingOptions();
        SCP_ShippingOptions shippingOptions2 = new SCP_ShippingOptions();
        ccrz__E_Cart__c cart = [Select Id,Name from ccrz__E_Cart__c Limit 1];
        ccrz__E_CartItem__c cartItem = [Select Id,Name from ccrz__E_CartItem__c Where ccrz__Cart__c =: cart.Id Limit 1];
        List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST> etItemList = new List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST>();
        SCP_OrderSimulate_Res_Parser.ET_ITEMLIST etList = new SCP_OrderSimulate_Res_Parser.ET_ITEMLIST();
        etList.ITM_NUMBER=cartItem.Name;
        etList.MATERIAL='1120';
        etList.REQ_QTY='1';
        etList.AVL_QTY='2';
        etList.ABS_DISCOUNT='5';
        etList.PERC_DISCOUNT='1';
        etItemList.add(etList);
        
        SCP_OrderSimulate_Res_Parser.ET_ITEMLIST etList1 = new SCP_OrderSimulate_Res_Parser.ET_ITEMLIST();
        etList1.ITM_NUMBER=cartItem.Name;
        etList1.MATERIAL='1120';
        etList1.REQ_QTY='1';
        etList1.AVL_QTY='0';
        etList1.ABS_DISCOUNT='5';
        etList1.PERC_DISCOUNT='1';
        etItemList.add(etList1);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(0));
        shippingOptions.getShippingOptions('12345', 'KA', 'IND',cart.Id,'ABC');
        shippingOptions.processETItemList(etItemList,cart.Id);
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(1));
        shippingOptions1.getShippingOptions('12345', 'KA', 'IND',cart.Id,'ABC');
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(2));
        //shippingOptions2.getShippingOptions('12345', 'KA', 'IND',cart.Id,'ABC');
        Test.stopTest();
    }
    
    @istest
    public static void getShippingOptions_test1(){
        AccountTriggerHandler.triggerdisabled = true;
        SCP_ShippingOptions shippingOptions2 = new SCP_ShippingOptions();
        ccrz__E_Cart__c cart = [Select Id,Name from ccrz__E_Cart__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(3));
        shippingOptions2.getShippingOptions('12345', 'KA', 'IND',cart.Id,'ABC');
        Test.stopTest();
    }

}