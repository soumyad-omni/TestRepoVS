@istest
public class SCP_cc_hk_InvoiceTest {
    @istest
    Public static void  SCP_cc_hk_InvoiceTestMethod(){
        SCP_TestDataFactory.createCastIron();
        
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;

        ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc, con, contAdd)[0];
        insert ec;

        List <ccrz__E_Order__c> eod = SCP_TestDataFactory.createOrders(1,ec, acc, con,contAdd);

        insert  eod;
        eod[0].SAP_Order_Number__c='test123';


        ccrz__E_Invoice__c invoice = SCP_TestDataFactory.createInvoices(1,acc,con,contAdd)[0];
        insert invoice;  

        SCP_cc_hk_Invoice hk =  new SCP_cc_hk_Invoice();
        Map<String,Object> inputData= new Map<String,Object>();
        inputData.put('invoiceId', invoice.id);
        inputData.put('invoice',invoice);
        test.starttest();
        	hk.fetchInvoice(inputData);
            Map<String,Object> inputdata1 = new Map<String,Object>();
            inputdata1.put('sfid',invoice.id);
            List<Map<String,Object>> inputdata1List = new List<Map<String,Object>>();
            inputdata1List.add(inputdata1);
            inputData.put('invoices',inputdata1List);
        	hk.fetchInvoices(inputData);
        test.stoptest();

    }
}