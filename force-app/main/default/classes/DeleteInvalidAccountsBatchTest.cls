@isTest
public class DeleteInvalidAccountsBatchTest {
    public testMethod static void testBatchClass() {
        AccountTriggerHandler.TriggerDisabled = true;
        Account a = TestDataFactory.createTestAccount();
        a.Validation_Status__c = 'Invalid';
        a.Recordtypeid = TestDataFactory.recTypeAccountUS;
        update a;
        
        Datetime thirtydayback = Datetime.now().addDays(-31);
        Test.setCreatedDate(a.Id, thirtydayback); 
        
        Test.startTest();
        DeleteInvalidAccountsBatch c = new DeleteInvalidAccountsBatch();
        Database.executeBatch(c);
        Test.stopTest();
    }
    public testMethod static void testSchedulerClass() {
        Test.StartTest();
        ScheduledBatchToDeleteInvalidAccounts sh1 = new ScheduledBatchToDeleteInvalidAccounts();
        String sch = '0 5 * * * ?'; 
        system.schedule('Account Status Update Job', sch, sh1); 
        Test.stopTest(); 
    }
}