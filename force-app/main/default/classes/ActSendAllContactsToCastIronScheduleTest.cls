/***********************************************************************************************************
Name:  ActSendAllContactsToCastIronScheduleTest 
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Test class for AcctSendAllContactsToCastIron_Schedule
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1        Capgemini Dev Team         12/13/2018                             INITIAL DEVELOPMENT
*************************************************************************************************************/
@isTest
public class ActSendAllContactsToCastIronScheduleTest {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        AcctSendAllContactsToCastIron_Schedule sch1 = new AcctSendAllContactsToCastIron_Schedule();
        
        String sch = '0 0 * * * ?'; 
        system.schedule('Test Batch', sch, sch1);
        Test.stopTest(); 
    }
}