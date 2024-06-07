/***********************************************************************************************************
Name:  AccountQuoteLineItemType_Batch_NEW
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at 1:00 AM, this Batch will go through all records of Quote_Line_Type__c object, deletes exisitng records
of Account_Quote_Line_Item_Type__c and roll up the values from Quote_Line_Type__c and create new records in Account_Quote_Line_Item_Type__c 
for an Account.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Sravan          17/09/2019                             INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountQuoteLineItemType_Batch_NEW implements DataBase.Batchable<sObject>{
    global Date lastProductSoldDate;
    private String jobStatus = 'Successful';
	private Job_execution__c jobExec;
    
    global AccountQuoteLineItemType_Batch_NEW(){        
    }
    
    global AccountQuoteLineItemType_Batch_NEW(Job_execution__c j) {
        jobExec = j;
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Amount__c,Cost__c,Date_Booked__c,Estimate__c,Opportunity__c,Opportunity__r.AccountId,Quote_Line_Item_Type__c,Quantity__c,Quote__c FROM Quote_Line_Type__c where Opportunity__r.AccountId !=null';
        List<Quote_Line_Type__c> quoteLineType = [select id, Date_Booked__c from Quote_Line_Type__c ORDER BY Date_Booked__c DESC limit 1];
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Quote_Line_Type__c> quoteLineTypeList){
        try{
            //Delete all existing records in Account_Quote_Line_Item_Type__c
            System.Debug('quoteLineTypeList Size:  '+quoteLineTypeList.size());
            System.Debug('quoteLineTypeList :  '+quoteLineTypeList);
            //Set<String> qLineTypeSet = new Set<String>();
            Map<Id,Set<String>> acctQLTypeSetMap = new Map<Id,Set<String>>();
            Map<Id,String> qltQLTypeMap = new Map<Id,String>();
            List<Account_Quote_Line_Item_Type__c> actQuoteLineItemTypeList = new List<Account_Quote_Line_Item_Type__c>();
            Set<ID> accountIds = new Set<ID>();
            Map<Id,List<Quote_Line_Type__c>> accountQtLineTypeMap = new Map<Id,List<Quote_Line_Type__c>>();
            
            Map<String,List<Quote_Line_Type__c>> qltQlineTypesMap = new Map<String,List<Quote_Line_Type__c>>();
            
            try{
                if(quoteLineTypeList.size()>0){
                    for(Quote_Line_Type__c qlt : quoteLineTypeList){
                        lastProductSoldDate = qlt.Date_Booked__c;
                            //qLineTypeSet.add(qlt.Quote_Line_Item_Type__c);
                        
                        accountIds.add(qlt.Opportunity__r.AccountId);
                        
                        if(accountQtLineTypeMap.containsKey(qlt.Opportunity__r.AccountId)){
                            accountQtLineTypeMap.get(qlt.Opportunity__r.AccountId).add(qlt);
                        }else{
                            accountQtLineTypeMap.put(qlt.Opportunity__r.AccountId, new  List <Quote_Line_Type__c> { qlt });
                        }
                        
                        if(qltQlineTypesMap.containsKey(qlt.Quote_Line_Item_Type__c)){
                            qltQlineTypesMap.get(qlt.Quote_Line_Item_Type__c).add(qlt);
                        }else{
                            qltQlineTypesMap.put(qlt.Quote_Line_Item_Type__c, new List<Quote_Line_Type__c> {qlt});                                
                        }
                        
                        qltQLTypeMap.put(qlt.id,qlt.Quote_Line_Item_Type__c);
                        
                    }
                }
                
                System.Debug('qltQlineTypesMap :- '+qltQlineTypesMap);
            } catch(Exception e){
            	JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : qltQLTypeMap create Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e');    
            }
        
            try{
                if(accountIds.size()>0){
                    for(Id acct : accountIds){
                        for(Quote_Line_Type__c qlt : accountQtLineTypeMap.get(acct)){
                            if(acctQLTypeSetMap.containsKey(acct)){
                                acctQLTypeSetMap.get(acct).add(qlt.Quote_Line_Item_Type__c);
                            }else{
                                acctQLTypeSetMap.put(acct, new Set<String> {qlt.Quote_Line_Item_Type__c});
                            }
                        }
                    }
                }
            } catch(Exception e){
                JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : acctQLTypeSetMap create Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e');                
            }
            
            try{
                if(accountIds.size()>0){
                    for(Id acctId : accountIds){
                            for(String qLineTy : acctQLTypeSetMap.get(acctId)){
                                ID account;
                                double amountBooked = 0;
                                double amountEstimated = 0;
                                String quoteLineType;
                                Date recentSoldDate; 
                                for(Quote_Line_Type__c qlt : accountQtLineTypeMap.get(acctId)){
                                    System.Debug('Actual list === '+accountQtLineTypeMap.get(qlt.Opportunity__r.AccountId));
                                    if(qltQlineTypesMap.containsKey(qlt.Quote_Line_Item_Type__c) && qlt.Quote_Line_Item_Type__c == qLineTy){
                                        System.Debug('qLineTy : '+qLineTy);
                                        if(qlt.Amount__c != null){
                                            System.Debug('ps.Amount__c : '+qlt.Amount__c);
                                            amountBooked = amountBooked + qlt.Amount__c;
                                        }
                                        
                                        if(qlt.Estimate__c && qlt.Amount__c != null){
                                            amountEstimated = amountEstimated + qlt.Amount__c;
                                        }
                                        quoteLineType = qltQLTypeMap.get(qlt.Id);//qLineTy;
                                        account = qlt.Opportunity__r.AccountId;
                                        System.Debug('account : '+account);
                                        
                                    }
                                    System.Debug('Rollup amount : '+amountBooked);                                
                                }
                                Account_Quote_Line_Item_Type__c actQuoteLineItemType = new Account_Quote_Line_Item_Type__c();
                                actQuoteLineItemType.Account__c = account;
                                actQuoteLineItemType.Amount_Booked__c = amountBooked;
                                actQuoteLineItemType.Amount_Estimated__c = amountEstimated;
                                System.Debug('lastProductSoldDate : '+lastProductSoldDate);
                                actQuoteLineItemType.Last_Product_Sold_Date__c = lastProductSoldDate;
                                actQuoteLineItemType.Quote_Line_Type__c = quoteLineType;
                                
                                actQuoteLineItemTypeList.add(actQuoteLineItemType);                                           
                            }
                    }
                }
                System.debug('actQuoteLineItemTypeList size : '+actQuoteLineItemTypeList.size());
                System.debug('actQuoteLineItemTypeList : '+actQuoteLineItemTypeList);
            } catch(Exception e) {
            	JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
							+ ' : actQuoteLineItemTypeList create Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e');    
            }
        
            try{
                if(actQuoteLineItemTypeList.size()>0){
                    insert actQuoteLineItemTypeList;
                }
            } catch(Exception e){
            	JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
					+ ' : insert Exception: ' + e.getMessage() + ' Line : ' + e.getLineNumber(), 'e');     
            }
        }catch(Exception exAll){
            System.debug('Exception : '+ exAll.getMessage()+' Line no. : '+ exAll.getLineNumber());
            JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW.execute : jobExecid = ' + jobExec.Id 
				+ ' : EXCEPTION : ' + exAll.getMessage() + ' Line : ' + exAll.getLineNumber(), 'e');
            
            ErrorLogging.Log(exAll, 'AccountQuoteLineItemType_Batch_NEW','App');
        }
    }
    global void finish(DataBase.BatchableContext BC){
        //TO DO
				Id BatchId = bc.getJobId();
        system.debug('BatchId::'+ BatchId);
        system.debug('LeadSourceUpdate_batch :: Finish batch job');
        
        JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW :: Finish < AccountProductLine_Batch > batch job. ', 'w');
        
        JobMonitor.logJobFinish(jobExec, Datetime.now(), jobStatus);
        
        // Get next run time
        List<CronTrigger> jobs = [SELECT ID, CronExpression, CronJobDetail.Name, CronJobDetailId, EndTime, 
			NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered FROM CronTrigger
			WHERE CronJobDetail.Name ='AccountProductLine_Batch'];
            
        Datetime nextSchedule = null;
        
        for(CronTrigger job : jobs) {
            if(job.NextFireTime != null){
                nextSchedule = job.NextFireTime;    
            }
            System.debug('Finish :: JOB NAME :: ' + job.CronJobDetail.Name 
                         + ' Next run time :: ' + nextSchedule);
        }
        
        JobMonitor.logJobNextRunTime(jobExec, nextSchedule);
            
        if(nextSchedule == null || nextSchedule.format().length() <= 0){
            
            // log the schedule error
			JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW.finish() : jobExecid = ' + jobExec.Id 
				+ ' : Next run error : Could not schedule next run!', 'n');        
        }   
         
        // Check batch status - IF COMPLETED then 
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :BatchId]; 
       System.debug('AccountQuoteLineItemType_Batch_NEW.finish() : Job Status :: ' + a.Status);
        // log the schedule error
			JobMonitor.logMessage(jobExec, 'AccountQuoteLineItemType_Batch_NEW.finish() : jobExecid = ' + jobExec.Id 
				+ ' :  Job Status : ' +  a.Status, 'l');
        
     //  if(a.Status.equalsIgnoreCase('Aborted') || a.Status.equalsIgnoreCase('Completed')
     //          || a.Status.equalsIgnoreCase('Failed')){
            
                //    System.debug('AccountQuoteLineItemType_Batch_NEW.finish() : Calling SendJobNotification.checkTimeAndSendMail(true)');
			// Send email to notify
			SendJobNotification s = new SendJobNotification('AccountProductLine', 1440);
			s.checkTimeAndSendMail(true);  
	//	} 	// if(a.Status.equalsIgnoreCase('Aborted') || a.Status.equalsIgnoreCase('Completed')   

    }
}