/**
 * @File Name          : ScheduleTiExtDataAcctSeg_Test.cls
 * @Description        : Schedule every day 12AM
 * @Author             : Sahid Hussain
**/

@isTest
global class BatchKlarityDataUploadSchedulerApexTest {
    global static testMethod void testSchedule() {
        Test.StartTest();
        BatchKlarityDataUploadSchedulerApex BatchKlarityDataUpload = new BatchKlarityDataUploadSchedulerApex();
        String sch = '0 0 * * * ?';
        system.schedule('BatchKlarityDataUpload', sch, BatchKlarityDataUpload);
        Test.stopTest(); 
    }
}