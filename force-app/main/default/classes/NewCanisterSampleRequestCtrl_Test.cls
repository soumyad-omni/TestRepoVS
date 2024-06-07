@istest
public class NewCanisterSampleRequestCtrl_Test {
    
    @testsetup
    public static void newCanisterSampleRequestCtrl_Test_Setup(){
    
        SCP_TestDataFactory.createCastIron();
        
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        //insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        //insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        //insert contAdd;

        ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc, con, contAdd)[0];
        //insert ec;

        List <ccrz__E_Order__c> eod = SCP_TestDataFactory.createOrders(1,ec, acc, con,contAdd);

        insert  eod;
        eod[0].SAP_Order_Number__c='tst5959';
        update eod;


    }
    
    @istest
    public static void getOrderList_test(){
        ccrz__E_Order__c orderObj = [Select Id from ccrz__E_Order__c Limit 1];
        NewCanisterSampleRequestCtrl ctrl = new NewCanisterSampleRequestCtrl();
        Test.startTest();
        	ctrl.OrderId = 	orderObj.Id;
        	ctrl.getOrderList();
        	ctrl.getOrderItemsList();
        Test.stopTest();
    }

}