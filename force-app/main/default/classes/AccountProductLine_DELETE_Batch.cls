/***********************************************************************************************************
Name:  AccountProductLine_DELETE_Bacth
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at 1:00 AM, this Batch will delete all the account product lines

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Sravan          17/09/2019                             INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountProductLine_DELETE_Batch implements DataBase.Batchable<sObject>{
    global AccountProductLine_DELETE_Batch(){        
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,name from Account_Product_Line__c where CreatedDate != TODAY';
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Account_Product_Line__c> prodLineList){
        if(prodLineList.size()>0){
            delete prodLineList;
        }
    }
    
    global void finish(DataBase.BatchableContext BC){
        if(!Test.isRunningTest()){ 
            AccountProductLine_Batch_NEW schedule = new AccountProductLine_Batch_NEW();
            database.executeBatch(schedule,200);
        }else{
            Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        	AccountProductLine_Batch_NEW   schedule = new AccountProductLine_Batch_NEW (je);
            database.executeBatch(schedule,200);
        }
    }

}