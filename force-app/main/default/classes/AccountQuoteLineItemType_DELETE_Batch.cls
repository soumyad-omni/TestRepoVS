/***********************************************************************************************************
Name:  AccountQuoteLineItemType_DELETE_Batch
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at 1:00 AM, this Batch will delete all the Account_Quote_Line_Item_Type__c

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Sravan          17/09/2019                             INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountQuoteLineItemType_DELETE_Batch implements DataBase.Batchable<sObject>{
    private String jobStatus = 'Successful';
	private Job_execution__c jobExec;
    
    global AccountQuoteLineItemType_DELETE_Batch(){        
    }
    
    global AccountQuoteLineItemType_DELETE_Batch(Job_execution__c j){ 
        jobExec = j;
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,name from Account_Quote_Line_Item_Type__c where CreatedDate != TODAY';
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Account_Quote_Line_Item_Type__c> prodLineList){
        try{
            if(prodLineList.size()>0){
                delete prodLineList;
            }
        } catch(Exception e){
            JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_DELETE_Batch.execute : jobExecid = ' + jobExec.Id
				+ ' : Delete EXCEPTION :: ' + e.getMessage(), 'e');     
        }
    }
    
    global void finish(DataBase.BatchableContext BC){
        AccountQuoteLineItemType_Batch_NEW schedule = new AccountQuoteLineItemType_Batch_NEW(jobExec);
        database.executeBatch(schedule,200);
    }

}