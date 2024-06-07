/***********************************************************************************************************
Name:  AccountProductLine_Batch_Test
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Test class for AccountProductLine_Batch and respective Batch Classes (AccountProductSegment_Batch,AccountBusinessSegment_Batch,
AccountQuoteLineItemType_Batch)
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Venu Kukkapalli          9/08/2018                             INITIAL DEVELOPMENT
*************************************************************************************************************/
@isTest
public class AccountTeamPopulation_BatchTest {
    public testmethod static void accountTeamUpdateBatchTest(){
        Default_Currency_by_Country_Code__c setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        test.startTest();
        
            AccountCreateController.isFirstRun= false;

            Account acc = TestDataFactory.createTestAccountQuotePrint();
        
            AccountTeamPopulation_Batch aplb = new AccountTeamPopulation_Batch();
            Id batchId = Database.executeBatch(aplb);
        test.stopTest();
    }
    public static testmethod void testSchedulerClassForAccountTeamPopulation(){
        Test.StartTest();
            ScheduleAccountTeamPopulation_Batch sh1 = new ScheduleAccountTeamPopulation_Batch();
            //ScheduleAccountTeamPopulation_Batch.scheduleMe();
            String sch = '0 0 00 * * ?'; 
            System.schedule('Account Teamp Population Check', sch, sh1);
        Test.stopTest();
    } 
    public static testmethod void testSchedulerClassForAccountTeamPopulation2(){
        Test.StartTest();
            ScheduleAccountTeamPopulation_Batch.scheduleMe();
            
        Test.stopTest();
    } 
}