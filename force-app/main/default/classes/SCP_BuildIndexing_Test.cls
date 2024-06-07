@istest
public class SCP_BuildIndexing_Test {

    @istest
    public static void buildIndex_test(){
        Test.startTest();
            SCP_CategoryIndexingScheduler sh1 = new SCP_CategoryIndexingScheduler();
            SCP_ProdSpecIndexingScheduler sh2 = new SCP_ProdSpecIndexingScheduler();
            SCP_ProductIndexingScheduler sh3 = new SCP_ProductIndexingScheduler();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Cat Indexing Scheduler', sch, sh1);
            system.schedule('Test Prodspec Indexing Scheduler', sch, sh2);
            system.schedule('Test Prod Indexing Scheduler', sch, sh3);
        Test.stopTest();
    }
}