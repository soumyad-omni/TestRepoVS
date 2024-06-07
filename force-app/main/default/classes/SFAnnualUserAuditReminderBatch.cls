/*
 * 
 * 
*/
global class SFAnnualUserAuditReminderBatch  implements Database.Batchable<sObject>{
        
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        query = 'SELECT Id,Status__c,Manager__c,Manager__r.Email FROM SalesforceUserAudit__c WHERE '+
            'Status__c=\'Pending Review\' AND Audit_Purpose__c = \'Annual\'';
        
        if(Test.isRunningTest()){
            query = 'SELECT Id,Status__c,Manager__c,Manager__r.Email FROM SalesforceUserAudit__c WHERE '+
                'Status__c=\'Pending Review\' AND Audit_Purpose__c = \'Annual\' LIMIT 5'; 
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SalesforceUserAudit__c> pendingAuditList) {
                
        //Send email to pending audit records
        List<Messaging.SingleEmailMessage> emailsToSend=new List<Messaging.SingleEmailMessage>();
        String recipient=System.Label.SalesforceAuditEmailServiceCC;
        for(SalesforceUserAudit__c pndAuditRec:pendingAuditList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String templateName='Salesforce_Annual_User_Audit_Request';
            EmailTemplate emailTemplate = [Select Id from EmailTemplate where DeveloperName= :templateName];
            email.setTemplateID(emailTemplate.Id);        
            email.setTargetObjectId(pndAuditRec.Manager__c);
            email.setWhatId(pndAuditRec.Id);
            email.setReplyTo('no-reply@omnicell.com');
            email.setUseSignature(false); 
            email.setBccSender(false); 
            email.setSaveAsActivity(false);
            String[] ccAddresses = new String[] {recipient}; 
            email.setCcAddresses(ccAddresses); 
            emailsToSend.add(email);
        }
        try{
            if(emailsToSend.size()>0)  {
                Messaging.sendEmail(emailsToSend);
            }
        }catch(Exception e){
            system.debug(e);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}