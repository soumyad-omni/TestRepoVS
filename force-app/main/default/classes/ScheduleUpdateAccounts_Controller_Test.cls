/**********************************************************************
Name:  ScheduleUpdateAccounts_Controller_Test
Copyright © 2018
======================================================
======================================================
Purpose: 
Test class for the Controller ScheduleUpdateAccounts_Controller

======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          6/13/2018	  Developed by CG team	    INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class ScheduleUpdateAccounts_Controller_Test {
    public static testmethod void testScheduleBatch(){
        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        tarIni.Use_for_segmentation__c = true;
        insert tarIni;
         // create account for testing
            AccountCreateController.isFirstRun= false; 
            Accounttriggerhandler.TriggerDisabled = true;
            Account acc01 = TestDataFactory.createTestAccountQuotePrint();
         // IBA-4149   acc01.Delete_Segments__c = 'Top Accounts';
            update acc01;          
            
            // add an account to target initiative
            Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
            tia1.Target_Initiative__c = tarIni.id;
            tia1.Account__c = acc01.id;
            insert tia1;
        test.startTest();
        
        String second = string.valueOf(system.now().second());
        String minute = string.valueOf(system.now().minute()+5);
        String hour = string.valueOf(system.now().hour());
        String day = string.valueOf(system.now().day());
        String month = string.valueOf(system.now().month());
        String year = string.valueOf(system.now().year());
        
        ScheduleUpdateAccounts_Controller.scheduleBatch(second,minute,hour,day,month,year,tarIni.id);
        
        second = string.valueOf(system.now().second());
        minute = string.valueOf(system.now().minute());
        hour = string.valueOf(system.now().hour());
        day = string.valueOf(system.now().day());
        month = string.valueOf(system.now().month());
        year = string.valueOf(system.now().year());
        
        ScheduleUpdateAccounts_Controller.scheduleBatch(second,minute,hour,day,month,year,tarIni.id);
        
        test.stopTest();
    }
}