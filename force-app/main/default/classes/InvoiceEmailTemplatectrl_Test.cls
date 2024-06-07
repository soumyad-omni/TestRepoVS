@istest
public class InvoiceEmailTemplatectrl_Test {

    
    @testsetup
    public static void InvoiceEmailTemplateCtrl_Test_Setup(){
    	accounttriggerhandler.triggerdisabled = true;
        SCP_TestDataFactory.createCastIron();
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c(Name = 'SCP_Mulesoft_Authorization', SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token',SCP_Key_Client_Id__c='ooooiiii',SCP_Method_Type__c='POST',SCP_Password_Client_Secret__c='xxxxxxxbbbbbbbbbxx',SCP_Grant_Type__c='CLIENT_CREDENTIALS');
		insert obj2;
        
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
        update eod;
        
        ccrz__E_OrderShipment__c ship = new ccrz__E_OrderShipment__c();
        ship.ccrz__ShipmentDate__c = system.today() ;
        ship.ccrz__Order__c = eod[0].id ;
        insert ship;
        
        ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
        tp.ccrz__AccountNumber__c = 'TESTING PO NUMBER';
        insert tp;
                
        ccrz__E_Invoice__c invoice = SCP_TestDataFactory.createInvoices(1,acc,con,contAdd)[0];
           invoice.ccrz__CCOrder__c=eod[0].Id; 
            invoice.ccrz__Type__c='Debit';
        insert invoice; 
        
        ccrz__E_InvoiceItem__c invitem = new ccrz__E_InvoiceItem__c();
        invitem.Invoice_Item_Quantity__c = 1;
        invitem.ccrz__Type__c = 'Item';
        invitem.ccrz__Invoice__c = invoice.id;
          
        insert invitem;
    }
    
    @istest
    public static void getOrderList_test(){
        ccrz__E_Invoice__c Inv = [Select Id from ccrz__E_Invoice__c Limit 1];
        InvoiceEmailTemplateCtrl ctrl = new InvoiceEmailTemplateCtrl();
        Test.startTest();
            ctrl.Invoice =  Inv.Id;
        Try{
            ctrl.getOrderList();
        }
        catch(exception e){}
        try{
            ctrl.getInvoiceItem();
        }
        catch(exception e){}
        ctrl.getCCOrdItem();
        Test.stopTest();
    }

}