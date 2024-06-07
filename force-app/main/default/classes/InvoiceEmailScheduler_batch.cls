global class InvoiceEmailScheduler_batch implements Database.Batchable<SObject>{
    
    global Database.queryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('Select id,ccrz__Contact__c,EmailSent__c from ccrz__E_Invoice__c where EmailSent__c=false');
    }
    
    global void execute (Database.BatchableContext BC, List<ccrz__E_Invoice__c> invList){
        Map<id,ccrz__E_Invoice__c> iMap = new Map<id,ccrz__E_Invoice__c>();
        list<id> contId= new list<id>();
        List<ccrz__E_Invoice__c> inv2update = new List<ccrz__E_Invoice__c>();
        for( ccrz__E_Invoice__c inv  :invList){
               contId.add(inv.ccrz__Contact__c);
               iMap.put(  inv.id ,inv);
            inv.EmailSent__c = true;
            	inv2update.add(inv);
        }
        
        Map<Id,contact> contMap = new Map<Id,contact>([select id,email from contact where id =:contId]);
        
        ConfirmationEmail(iMap,contMap,inv2update);
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    public static void ConfirmationEmail(Map<id,ccrz__E_Invoice__c> iMap, map<id,contact> contMap, List<ccrz__E_Invoice__c> inv2update){
        
        list<ccrz__E_Invoice__c> invList = new list<ccrz__E_Invoice__c>();
        invList.addall(iMap.values());
        list<id> invId = new list<id>();
        invId.addall(iMap.keyset());
        
        map<id,ContentDocumentLink > ContentDocumentMap = new map<id,ContentDocumentLink >();
        for(ContentDocumentLink  cv:[select ContentDocumentId from ContentDocumentLink where LinkedEntityId =:invId]){            
            ContentDocumentMap.put(cv.ContentDocumentId,cv);            
        }
        
        map<id,ContentVersion> contVerMap = new map<id,ContentVersion>();
        for(ContentVersion cv:[select VersionData, PathOnClient,Title ,FileType,ContentDocumentId from ContentVersion where ContentDocumentId =:ContentDocumentMap.keyset()]){            
            contVerMap.put(cv.Title,cv);            
        }
        
        
        
        list <Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for(ccrz__E_Invoice__c inv:invList){
            ContentVersion cv = contVerMap.get(inv.id);
            contact c = contMap.get(inv.ccrz__Contact__c);
            messages.add(sendInvNotification(inv,c,cv));
            
        }      
        
        try{
            if(messages.size()>0 && !Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
                update inv2update;
            }
            
        }  
        catch(Exception e){
            list<SCP_Apex_Debug_Logs__c> loglist= new list<SCP_Apex_Debug_Logs__c>();
            for(ccrz__E_Invoice__c inv:invList){
                SCP_Apex_Debug_Logs__c log= new SCP_Apex_Debug_Logs__c();
                log.SCP_Apex_Class__c='InvoiceEmailScheduler_batch';
                log.SCP_Method__c='OrderSubmitUpdateCall';
                log.SCP_Record_Id__c=inv.id;
                log.SCP_Message__c='Exception message : '+e;
                loglist.add(log);
            }
            if(loglist.size()> 0){
                insert loglist;
            }
            
        }
        
    }
    
    
    
    Public static Messaging.SingleEmailMessage sendInvNotification(ccrz__E_Invoice__c OrdId,contact cont,ContentVersion cv){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(cont.id);
        message.setSenderDisplayName('Order Invoice');
        message.setReplyTo('no-reply@omnicell.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Invoice Template'];
        system.debug('mail inv conf');        
        message.setTemplateID(emailTemplate.Id);
        message.setWhatId(OrdId.Id); 
        message.toAddresses = new String[] { cont.email};
            
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
        efa.setFileName(cv.Title + '.' + cv.FileType); 
        efa.setBody(cv.VersionData); 
        emailFileAttachments.add(efa);
        message.setFileAttachments(emailFileAttachments);
        
        return message;
        
    }
}