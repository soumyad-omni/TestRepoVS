@istest
public class OrderConfirmEmailTemplatectrl_Test {
    
    @testsetup
    public static void OrderConfirmEmailTemplatectrl_Test_Setup(){
    
        SCP_TestDataFactory.createCastIron();
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c(Name = 'SCP_Mulesoft_Authorization', SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token',SCP_Key_Client_Id__c='ooooiiii',SCP_Method_Type__c='POST',SCP_Password_Client_Secret__c='xxxxxxxbbbbbbbbbxx',SCP_Grant_Type__c='CLIENT_CREDENTIALS');
		insert obj2;
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
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


    }
    
    @istest
    public static void getOrderList_test(){
        ccrz__E_Order__c orderObj = [Select Id from ccrz__E_Order__c Limit 1];
        OrderConfirmEmailTemplatectrl ctrl = new OrderConfirmEmailTemplatectrl();
        Test.startTest();
        	ctrl.OrderId = 	orderObj.Id;
        	ctrl.getOrderList();
        	ctrl.getOrderShipList();
        	ctrl.getOrderItemsList();
        	ctrl.getOrderCassetteitem();
        	ctrl.getOrderCanisteritem();
        	ctrl.getTranscList();
        Test.stopTest();
    }

}