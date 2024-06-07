@istest
public class SCP_InvoiceReprocessBatch_Test {
    
    @testsetup
    public static void SCP_InvoiceReprocessBatch_Test_Setup(){
        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
       insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
        
                        ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c(ccrz__Storefront__c='ABC',ccrz__TransactionCode__c='ACCEPT',ccrz__TransactionType__c='authorization,create_payment_token',ccrz__CCOrder__c=order.Id,ccrz__AccountType__c='sopcc');
        insert transactionPayment;
        
        ccrz__E_Invoice__c invoice = new ccrz__E_Invoice__c(ccrz__CCOrder__c=order.Id,ccrz__OriginalAmount__c=1000,ccrz__RemainingAmount__c=1000,ccrz__Type__c='Debt',ccrz__Status__c='Open',ccrz__Storefront__c='DefaultStore',CurrencyIsoCode='USD');
        insert invoice;
    }
    
    @istest
    public static void SCP_InvoiceReprocessBatch_Test_Batch(){
        //SCP_InvoiceReprocessScheduler
		Test.starttest();
        	SCP_InvoiceReprocessScheduler sh1 = new SCP_InvoiceReprocessScheduler();
			String sch = '0 0 23 * * ?'; 
        	system.schedule('Test Indexing Scheduler', sch, sh1);
        Test.stopTest();
    }

}