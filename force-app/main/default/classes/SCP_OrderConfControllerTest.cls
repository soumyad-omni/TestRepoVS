/*** 
Test Class For - SCP_OrderConfirmationController
Developer - Sanjana K.R 
***/
@isTest
public class SCP_OrderConfControllerTest{
    
    @testSetup 
    public static void dataSetup(){
        
        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createIntDetails_Auth();
        SCP_TestDataFactory.createCastIron();
		Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
        
        ccrz__E_TransactionPayment__c tPay = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c = 'Test PO',ccrz__AccountType__c = 'po',ccrz__CCOrder__c = order.id);
        insert tPay;
        System.assert(tPay.id != null);
    }
    
    private static final string SAP_ORDER_RESPONSE_BODY = '{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "","": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMSLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}}';
    @isTest
    public static void testOrderConfirmation(){
    
        
        ccrz__E_Order__c order = [select id,Name,SAP_Order_Number__c,PO_Number__c FROM ccrz__E_Order__c where ccrz__Name__c = 'Test Order' LIMIT 1];
        SCP_OrderConfirmationController.getOrderItemsInformation(order.id);
        ccrz__E_TransactionPayment__c tPay = [select id,ccrz__AccountType__c,ccrz__AccountNumber__c FROM ccrz__E_TransactionPayment__c where ccrz__CCOrder__c =: order.id LIMIT 1];
        System.assert(tPay.id != null);
        mockCalloutsTest(order.id);
        
    }
    static void mockCalloutsTest(ID orderID){   

        String str = '[{"IV_SOLD_TO":"0000036773","EV_SALES_ORDER":"sales","IV_SHIP_TO":"0000036773","IV_SHIP_COND":"5","IV_SHIP_AMOUNT":null,"IV_SALES_ORG":"OM01","IV_PURCH_NO_C":"TESTING PO NUMBER","IV_ORDER_TYPE":"ZORB","IV_NOTE":null,"IV_NAME":"O-0000000119","IV_DIVISION":"00","IV_DISTR_CHAN":"01","IV_CURRENCY":"USD","IV_CREDIT_CARD":null,"IV_COUPON":null,"IV_CONTACT":null,"IV_COMMIT":"X","IV_BILL_TO":"0000036773","ITEMS":{"ITEM":[{"ITEM_TARGET_QU":"EA","ITEM_TARGET_QTY":10,"ITEM_NUMBER":"000160","ITEM_MATERIAL":"155802"}]}}]';
        
        final Map<String,String> resHeaders = new Map<String,String>();
        resHeaders.put('Content-Type','application/json');
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'http://sfdc-sap-prc-api.us-w1.cloudhub.io/api/orders/submit';    //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new SCP_MockHttpResponse(200,'OK', SAP_ORDER_RESPONSE_BODY, resHeaders));
            Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(0));
        Test.stopTest();    
        
        Approval.LockResult lock = Approval.lock(orderID);           
        SCP_OrderConfirmationController.getSapInformation((String)orderID);
    }
}