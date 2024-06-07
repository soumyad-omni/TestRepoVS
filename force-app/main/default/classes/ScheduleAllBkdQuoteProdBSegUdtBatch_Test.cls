/**
 * @File Name          : ScheduleAllBkdQuoteProdBSegUdtBatch_Test.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : Pabitra Tripathy
 * @Last Modified On   : 12-12-2020
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * 1.0    11/12/2020   Pabitra Tripathy     
**/

@isTest
public class ScheduleAllBkdQuoteProdBSegUdtBatch_Test {
    public static testMethod void testSchedule() {
        
        Test.StartTest();
        ScheduleAllBkdQuoteProdBSegUdtBatch schAllBkdQtPrBSegUdtBchObj = new ScheduleAllBkdQuoteProdBSegUdtBatch();
        String sch = '0 0 3 * * ?'; 
        system.schedule('Test Booked Quote Empty Product Line Fix Batch', sch, schAllBkdQtPrBSegUdtBchObj);
        Test.stopTest(); 
    }
}