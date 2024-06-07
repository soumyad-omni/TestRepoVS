@isTest
public class verifyEmailBatchTest {
    @isTest
    static void test1(){        
        
        Test.startTest();
        
        verifyEmailBatch b = new verifyEmailBatch();
        database.executebatch(b,1);
        Test.stopTest();
    }
}