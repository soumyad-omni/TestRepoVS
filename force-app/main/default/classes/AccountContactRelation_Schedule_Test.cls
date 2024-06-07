/***********************************************************************************************************
Name:  AccountContactRelation_Schedule_Test
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Test class for AccountContactRelation_Schedule
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1        Capgemini Dev Team         10/09/2018                             INITIAL DEVELOPMENT
*************************************************************************************************************/
@isTest
public class AccountContactRelation_Schedule_Test {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        AccountContactRelation_Schedule sch1 = new AccountContactRelation_Schedule();
        
        String sch = '0 0 * * * ?'; 
        system.schedule('Test Batch', sch, sch1);
        Test.stopTest(); 
    }
}