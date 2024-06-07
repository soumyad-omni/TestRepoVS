@istest
public class SCP_CybersourceCapture_Test {
    @testsetup
    public static void SCP_CybersourceCapture_TestSetup(){
        SCP_TestDataFactory.createTransactionPayment();
        SCP_TestDataFactory.createIntDetails_Auth();
    }
    @istest
    public static void SCP_CybersourceCapture_TestExecute(){
        SCP_CybersourceCapture cyberCapture = new SCP_CybersourceCapture('ABC','DEF');
        ccrz__E_TransactionPayment__c transactionPayment = [Select Id From ccrz__E_TransactionPayment__c Limit 1];
        Test.startTest();
            System.enqueueJob(cyberCapture);
            SCP_CybersourceCapture.buildSoapData('ABC','100','IND','DEF');
            SCP_CybersourceCapture.sendCreditCardSettlementCaptureAPI(transactionPayment.Id,'DEF');
            //Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(0));
            //SCP_CybersourceCapture.sendCreditSettlementToCybersource('DEF');
            testCallout();
        Test.stopTest();
    }
    @future(callout=true)
    public static void testCallout(){
        SCP_CybersourceCapture cyberCapture = new SCP_CybersourceCapture('ABC','DEF');
        Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new SCP_OrderSubmitAPIMock_Test(2));
        SCP_CybersourceCapture.sendCreditSettlementToCybersource('DEF');
    }
}