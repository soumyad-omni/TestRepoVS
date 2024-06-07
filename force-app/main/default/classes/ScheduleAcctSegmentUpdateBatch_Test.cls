/**
 *  Schedule every day 8 PM
 * @File Name          : ScheduleAcctSegmentUpdateBatch_Test.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : Pabitra Tripathy
 * @Last Modified On   : 08-09-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    08/09/2021   Pabitra Tripathy     
**/

@isTest
public class ScheduleAcctSegmentUpdateBatch_Test {
   
    public static testMethod void testSchedule() {
        Test.StartTest();
        ScheduleAcctSegmentUpdate schAcctSegTIAssgt = new ScheduleAcctSegmentUpdate();
        //String sch = '0 0 20 * * ?'; 
        String sch = '0 0 * * * ?';
        system.schedule('SegmentUpdateAccountCreateUpdate', sch, schAcctSegTIAssgt);
        Test.stopTest(); 
    }
}