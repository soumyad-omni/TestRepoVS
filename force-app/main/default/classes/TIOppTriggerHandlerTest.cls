/**********************************************************************
Name:  TIOppTriggerHandlerTest
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for QuoteLineTriggerHandler                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Haripriya Maturi           1/31/2019      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class TIOppTriggerHandlerTest {
	public static testmethod void quoteLineTriggerHandlerTest(){        
        AccountCreateController.isFirstRun= false;   
        Target_Initiative_Opportunity__c quoteline = TestDataFactory.createTestTIOpp(); 
        TestDataFactory.update_delete_TestTIOpp();
    }
}