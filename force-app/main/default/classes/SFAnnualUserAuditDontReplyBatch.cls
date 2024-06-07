/*
 * 
 * 
*/
global class SFAnnualUserAuditDontReplyBatch  implements Database.Batchable<sObject>,Database.Stateful{
    
    public String changeInfo='';
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
        try{
            // change the stutus from Pending Review to Did not Reply
            changeInfo+='The following Salesforce User Audit records Status updated from Pending Review to Did not reply : ';         
            
            for(SalesforceUserAudit__c pndAuditRec:pendingAuditList){
                pndAuditRec.Status__c = 'Did not reply';
                changeInfo+=pndAuditRec.Id+' ';
            }
            
            update pendingAuditList;
            changeInfo+='\n';            
        }catch(Exception ex){
            System.debug(ex.getMessage()+ex.getStackTraceString());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        changeInfo+='\n\n- Thanks, SalesforceAnnualUserAuditDontReplyBatch';	
        String recipient=System.Label.SalesforceAuditEmailServiceCC;
        
        if(recipient!=null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = new String[] {recipient}; 
            mail.setToAddresses(toAddresses); 
            mail.setSubject('Salesforce Annual User Audit Status update to Do not reply'); 
            mail.setPlainTextBody(changeInfo);
            if(!Test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    }
    
}