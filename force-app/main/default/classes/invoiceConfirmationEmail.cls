public class invoiceConfirmationEmail implements Schedulable {
    Map<id,ccrz__E_Invoice__c> iMap = new Map<id,ccrz__E_Invoice__c>();
    list<ccrz__E_Invoice__c> TriggerNewList = new list<ccrz__E_Invoice__c>();
    map<id,contact> contactM = new map<id,contact>();
    
    public invoiceConfirmationEmail(Map<id,ccrz__E_Invoice__c> invMap, map<id,contact> cont){
        
        
        iMap = invMap;
        TriggerNewList.add(iMap.values());
        contactM = cont;
        
        
    }
    
    public void execute(System.SchedulableContext sc){
        
        list<id> invId = new list<id>();
        invId.addall(iMap.keyset());
        
        /*map<id,id> contMap = new map<id,id>();
        for(ContentDocumentLink c:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =:invId]){
            contMap.put(c.ContentDocumentId,c.LinkedEntityId);
        }*/
        
        map<id,ContentVersion> contVerMap = new map<id,ContentVersion>();
        for(ContentVersion cv:[select VersionData, PathOnClient,Title ,FileType,ContentDocumentId from ContentVersion where Title =:invId]){
            //if(contMap.containskey(cv.ContentDocumentId)){
                //id invI = contMap.get(cv.ContentDocumentId);
                contVerMap.put(cv.Title,cv);
            //}
        }
        
        
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(ccrz__E_Invoice__c inv:TriggerNewList){
            ContentVersion cv = contVerMap.get(inv.id);
            contact c = contactM.get(inv.ccrz__Contact__c);
            messages.add(sendInvNotification(inv,c,cv));
            
        }      
        
        
        if(messages.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);       
        }  
        System.AbortJob(sc.getTriggerId());
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