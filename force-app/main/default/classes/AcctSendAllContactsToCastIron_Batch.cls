/***********************************************************************************************************
Name:  AcctSendAllContactsToCastIron_Batch
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at hourly basis, 
If Account.Validation_Status__c=Validated && Account. SAP_Account_ID__c!=null and contacts which have SAP_Contact_ID__c='' then sending all those contacts to Castiron,which are currently associated to this account.

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Capgemin Dev Team          12/13/2018                           INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AcctSendAllContactsToCastIron_Batch implements DataBase.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    
    Datetime minBack = Datetime.now().addMinutes(-15);
    
    private String jobStatus = 'Successful';
    private Job_execution__c jobExec;
    private List<String> msgLogMsgList; 
    
    public AcctSendAllContactsToCastIron_Batch(Job_execution__c j) {
        jobExec = j;
        msgLogMsgList = new List<String>();
    }
    
    global AcctSendAllContactsToCastIron_Batch(){
        msgLogMsgList = new List<String>();
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        msgLogMsgList.add('AcctSendAllContactsToCastIron_Batch.execute : start.  jobExecid = ' 
                          + jobExec.Id + '#l');
        
        return Database.getQueryLocator('select Id,Validation_Status__c,SAP_Account_ID__c FROM Account where IsValidated__c=true and LastModifiedDate=today and SystemModstamp > =:minBack');
        
    } 

    
    global void execute(DataBase.BatchableContext BC,List<Account> act){
        msgLogMsgList.add('AcctSendAllContactsToCastIron_Batch.execute : execute start.  jobExecid = ' 
                          + jobExec.Id + '#l');
        
        Set<Id> actIds = new Set<Id>();
        Set<Id> newconIds= new Set<Id>();
        
        try{
            if(act.size()>0)
            {
                for(Account a : act)
                {
                    actIds.add(a.Id);
                }
            }
            
            List<Contact> conList = [select id,AccountId,sent_to_SAP__c from contact where AccountId IN: actIds and SAP_Contact_ID__c=null and sent_to_SAP__c = false];//Added sent_to_SAP__c by sravan for SF-BUG-847
            
            if(act.size()>0)
            {
                for(Account a : act)
                {
                    if(a.Validation_Status__c=='Validated' && a.SAP_Account_ID__c!=null){
                        
                        if(conlist.size()>0)
                        {
                            for(contact con : conlist)
                            {
                                con.sent_to_SAP__c = true;//Added by sravan for SF-BUG-847
                                
                                if(con.AccountId == a.Id)
                                { 
                                    newconIds.add(con.Id);
                                }
                            }
                        }       
                    }
                }
            }         
            //if(System.IsBatch() == false && System.isFuture() == false && conid.size()>0)
            if(newconIds.size()>0){ 
                system.debug('AcctSendAllContactsToCastIron_Batch.execute :: Check list size..' + newconIds.size());
                //OmnicellContactToCastIron_Class.callOutMethodInsert(newconIds); 
                OmnicellSendAllContactToCastIron_Class.callOutMethodInsert(newconIds);
                contacttriggerhandler.updatefromallcontbatch = true;//Added by sravan for SF-BUG-847
                update conlist;//Added by sravan for SF-BUG-847  
            } 
            if(newconIds.size()>0){
                msgLogMsgList.add('AcctSendAllContactsToCastIron_Batch.execute.execute :  jobExecid = ' 
                                  + jobExec.Id + ' : ' + newconIds.size() + ' Contacts updated.#u');
            }else{
                msgLogMsgList.add('AcctSendAllContactsToCastIron_Batch.execute.execute :  jobExecid = ' 
                                  + jobExec.Id + ' : ' + ' No Contact updated.#l');
            }
        } catch(Exception e) {
            system.debug('AcctSendAllContactsToCastIron_Batch.execute : ERROR :: ' + ' :: ' 
                         + e.getLineNumber() + ' :: '  + e.getMessage() );
            
            msgLogMsgList.add('AcctSendAllContactsToCastIron_Batch.execute.execute :  jobExecid = ' 
                              + jobExec.Id + ' : ' + ' ERROR :: ' + e.getLineNumber() + ' : ' + + e.getMessage()  + '#e');
            
        } 
    }
    
    global void finish(DataBase.BatchableContext BC){
        Id BatchId = bc.getJobId();
        msgLogMsgList.add('AcctSendAllContactsToCastIron_Batch.finish :  jobExecid = ' 
                          + jobExec.Id + ' : ' + ' Finish batch job. ' + ' BatchId = ' + BatchId + '#l');
        
        JobMonitor.logJobFinish(jobExec, Datetime.now(), jobStatus);
        
        // Get next run time
        List<CronTrigger> jobs = [SELECT ID, CronExpression, CronJobDetail.Name, CronJobDetailId, EndTime, 
                                  NextFireTime, PreviousFireTime, StartTime, State, TimesTriggered FROM CronTrigger
                                  WHERE CronJobDetail.Name Like 'AcctSendAllContactsToCastIron_Batch_Job%'];
        // This part is just for reference purposes, clearly, and I am getting results back
        Datetime nextSchedule = null;
        Datetime timeNow = DateTime.now();
        for(CronTrigger job : jobs) {
            if(job.NextFireTime != null){
                if(nextSchedule == null){
                    nextSchedule = job.NextFireTime;    
                }
                else if (job.NextFireTime < nextSchedule){
                    nextSchedule = job.NextFireTime;    
                }     
            }
            
        }
        JobMonitor.logJobNextRunTime(jobExec, nextSchedule);
        
        if(nextSchedule == null || nextSchedule.format().length() <= 0){
            
            // log the schedule error
            msgLogMsgList.add('AccountQuoteLineItemType_Batch_NEW.finish() : jobExecid = ' + jobExec.Id 
                              + ' : Next run error : Could not schedule next run!#n');
        }
        
        if((msgLogMsgList != null) && (!msgLogMsgList.isEmpty())){
            for(String msg : msgLogMsgList){
                List<String> parts = msg.split('#');
                JobMonitor.logMessage(jobExec, parts[0], parts[1]);  
            } 
        }
        
        SendJobNotification s = new SendJobNotification('AcctSendAllContactsToCastIron',  240);
        s.checkTimeAndSendMail(true);  
    }
}