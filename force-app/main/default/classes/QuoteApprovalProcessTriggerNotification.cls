global class QuoteApprovalProcessTriggerNotification implements Database.Batchable<SObject> {
    public String assignedTo;
    public String assignedToName;
    public String status;   
    public Set<Id> quoteApprovalIdSet = new Set<Id>();
    public List<String> queueIds = new List<String>();
    public List<String> queueNames = new List<String>();
    public String st = 'Waiting Approval';
   // public string testid = 'a2G1k0000005eFjEAI'; 
    Datetime createdDate;
    global QuoteApprovalProcessTriggerNotification(){
        
    }
    
    global DataBase.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,status__c,Quote__c FROM Quote_Approval__c where status__c =:st';
        return Database.getQueryLocator(query);
    }
    global void execute(DataBase.BatchableContext BC, List<Quote_Approval__c> quoteApprovalsList){
        System.debug('Quote Approvals : '+quoteApprovalsList);
        for(Quote_Approval__c qa : quoteApprovalsList){
            quoteApprovalIdSet.add(qa.Id);
        }
        for (ProcessInstance pi : [SELECT ProcessInstance.Id,status, 
                                   ProcessInstance.ProcessDefinition.name, (Select actorid ,OriginalActorId,createdDate,ProcessInstanceHistory.StepStatus
                                                                            ,ProcessInstanceHistory.IsPending,OriginalActor.name  FROM StepsAndWorkitems order by ProcessInstanceHistory.IsPending asc, createddate asc) 
                                   FROM ProcessInstance WHERE ProcessInstance.TargetObjectId = :quoteApprovalIdSet  order by createddate asc nulls last])
        {
            status = pi.status;
            if (pi.StepsAndWorkitems.size() > 0){
                for(ProcessInstanceHistory pih :pi.StepsAndWorkitems){
                    //status = pih.StepStatus;
                    assignedToName = pih.OriginalActor.name;
                    assignedTo = pih.OriginalActorId;
                    createdDate = pih.CreatedDate;
                }
            }
            System.debug('Status : '+status);
            System.debug('Created Date : '+createdDate);
            if((status != 'Approved' && status != 'Rejected') && (createdDate+2 <= System.today())){
                queueIds.add(assignedTo);
                queueNames.add(assignedToName);
            }
            
        }
        
        List<User> usersinQueue = [SELECT Id,Email,isActive FROM User WHERE isActive= true and Id IN (
            SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN: queueIds)]; 
        System.debug('Users in Queue : '+usersinQueue);
        List<String> toAddresses = new List<String>();
        if (usersinQueue.size()>0)
        {
        for(User u : usersinQueue){
            toAddresses.add(u.email);
        }
        System.debug('Emails : '+toAddresses);
        System.debug('Queues : '+queueNames);
        
        
         sendEmailNotification(toAddresses);

        
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(toAddresses);
mail.setSubject('Email from Batch Class');
mail.setPlainTextBody('Hello '+queueNames);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }

 }
    
    
    
    global void finish(DataBase.BatchableContext BC){

        String sch = '0 0 22 * * ? *';
        //THE CRON STATEMENT FORMED HERE IS IN FORMAT SEC/MIN/HH/DAY_OF_MONTH/MONTH/DAY_OF_WEEK/YEAR
        //0 0 0 XX XX ? XXXX
        QuoteApprovalProcessNotify_Schedule m = new QuoteApprovalProcessNotify_Schedule();
        // Retriving the current job information from "AsyncApexJob" Object. 
        AsyncApexJob Apexjob = [SELECT Id,Status,MethodName,NumberOfErrors,JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(Userinfo.getuserId());
        mail.setSubject('Quote Approval 48 hours notification ' + Apexjob.Status);
        mail.setPlainTextBody('"QuoteApprovalProcessTriggerNotification"  Apex job processed '+Apexjob.TotalJobItems+' batches with '+Apexjob.NumberOfErrors+' Errors.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        
        //if(!Test.isRunningTest())
         //   system.schedule('QuoteApprovalProcessNotify_Schedule'+System.NOW(), sch, m);         
        
           
    }
    
    
    
    public static void sendEmailNotification(List<string> toAddresses)
    
    {
    
      EmailConfiguration__c emc= EmailConfiguration__c.getInstance('ReminderEmailTemplate');
            EmailTemplate et = null;
            if(emc!= null && emc.EmailTemplateId__c != null && emc.EmailTemplateId__c!= '') {
                for(EmailTemplate temp : [SELECT Id FROM EmailTemplate WHERE id = :emc.EmailTemplateId__c]) {
                    et = temp;  
                }
            }
            if(et != null) {
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateID(et.Id);
                mail.setToAddresses(toAddresses); 
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(Userinfo.getuserId());
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
    }
    
    
    }
    
}