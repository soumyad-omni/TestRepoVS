@isTest
private class SCP_ProductMediaBatch_sch_Test
{
    static TestMethod void method()
    {
        Test.StartTest();
        SCP_ProductMediaBatch_sch reSch = new SCP_ProductMediaBatch_sch();
        String sch = '0 0 * * * ?';
        system.schedule('SCP_ProductMediaBatch_sch', sch, reSch);
        Test.StopTest();
    }
}