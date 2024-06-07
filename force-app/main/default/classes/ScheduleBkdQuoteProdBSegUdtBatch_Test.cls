/**
 * @File Name          : ScheduleBkdQuoteProdBSegUdtBatch_Test.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : Pabitra Tripathy
 * @Last Modified On   : 12-01-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/01/2020   Pabitra Tripathy     
**/

@isTest
public class ScheduleBkdQuoteProdBSegUdtBatch_Test {
    public static testMethod void testSchedule() {
        
        Test.StartTest();
        ScheduleBkdQuoteProdBSegUdtBatch schBkdQtPrBSegUdtBchObj = new ScheduleBkdQuoteProdBSegUdtBatch();
        String sch = '0 0 3 * * ?'; 
        system.schedule('Test Booked Quote Empty Product Line Fix Batch', sch, schBkdQtPrBSegUdtBchObj);
        Test.stopTest(); 
    }
}