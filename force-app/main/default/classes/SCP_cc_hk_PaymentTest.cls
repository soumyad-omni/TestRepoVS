@istest
public class SCP_cc_hk_PaymentTest {
    @istest
    Public static void  SCP_cc_hk_PaymentTestMethod(){
        SCP_TestDataFactory.createCastIron();
      
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
           
        ccrz__E_Subscription__c subscription= new ccrz__E_Subscription__c();
        subscription.ccrz__Sequence__c= 100;
        subscription.ccrz__Storefront__c= 'OmnicellB2BStore';
        subscription.ccrz__SubscriptionStartDate__c= Date.parse('04/26/21');
        subscription.ccrz__SubscriptionStatus__c= 'Active';
        insert subscription;
            
        ccrz__E_Order__c Parentorder = new ccrz__E_Order__c();
        Parentorder.SAP_Order_Number__c = '12345';
        insert Parentorder;
            
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        order.Process_OrderSubmit__c = True;
        order.ccrz__CCSubscription__c = subscription.id;
        order.SAP_Order_Number__c = '123457'; 
        order.ccrz__Order__c=Parentorder.id;
        insert order;              
        
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c();
        invoice.ccrz__CCOrder__c=order.Id;
        invoice.ccrz__OriginalAmount__c=1000;
        invoice.ccrz__RemainingAmount__c=1000;
        invoice.ccrz__Type__c='Debt';
        invoice.ccrz__Status__c='Open';
        invoice.ccrz__Storefront__c='OmnicellB2BStore';
        invoice.CurrencyIsoCode='USD';
        invoice.ccrz__InvoiceId__c = 'testclass';
        insert invoice;
        
        ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c();
        transactionPayment.ccrz__Storefront__c='OmnicellB2BStore';
        transactionPayment.ccrz__CCSubscription__c = subscription.id;
        transactionPayment.ccrz__CCOrder__c = order.id;
        transactionPayment.ccrz__InvoiceAppliedFor__c = invoice.id;
        insert transactionPayment;
              
        Map<String,Object> dummyMap = new Map<String,Object>();        
        Map<String,Object> orderHisMap = new Map<String,Object>();
        dummyMap.put('sfid',order.id);
        dummyMap.put('SAP_Order_Number__c',order.id);
        orderHisMap.put('ccOrder',dummyMap );
        
        Map<String,Object> dummyInvoice = new Map<String,Object>(); 
        dummyInvoice.put('sfid',invoice.id);
        orderHisMap.put('invoiceAppliedFor',dummyInvoice);
        orderHisMap.put('invoiceAppliedTo',dummyInvoice);
        
        Map<String,Object> inputData= new Map<String,Object>();
        inputData.put('payment', orderHisMap);
                
        system.debug('test class inputdata--->'+inputData);
          
        SCP_cc_hk_Payment hk =  new SCP_cc_hk_Payment();
        hk.fetchTransactionPayment(inputData);
    }
   }