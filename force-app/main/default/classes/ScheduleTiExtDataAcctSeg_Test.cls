/**
 * @File Name          : ScheduleTiExtDataAcctSeg_Test.cls
 * @Description        : Schedule every day 5AM,PM
 * @Author             : Pabitra Tripathy
**/

@isTest
global class ScheduleTiExtDataAcctSeg_Test {
    global static testMethod void testSchedule() {
        Test.StartTest();
        ScheduleTiExtDataAcctSeg tiExtDataSegBatch = new ScheduleTiExtDataAcctSeg();
        String sch = '0 0 5,17 * * ?';
        system.schedule('TiExtDataAcctSegmentUpdateBatch', sch, tiExtDataSegBatch);
        Test.stopTest(); 
    }
}