public class confrimationEmailECC implements Schedulable {
    
    list<ccrz__E_Order__c> TriggerNewList = new list<ccrz__E_Order__c>();
    map<id,contact> contactM = new map<id,contact>();
    
    public confrimationEmailECC(list<ccrz__E_Order__c> ord, map<id,contact> cont){

        if(ord.size()>0){
            TriggerNewList = ord;
            contactM = cont;
        }
            
    }
    
    public void execute(System.SchedulableContext sc){
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(ccrz__E_Order__c order:TriggerNewList){
                 
                 contact c = contactM.get(order.ccrz__Contact__c);
                 messages.add(sendECCorderNotification(order,c));
             
        }      
        
    
    	if(messages.size()>0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);       
        }  
        System.AbortJob(sc.getTriggerId());
    }
    
Public static Messaging.SingleEmailMessage sendECCorderNotification(ccrz__E_Order__c OrdId,contact cont){
        Messaging.SingleEmailMessage message = new        
        Messaging.SingleEmailMessage();
        message.setTargetObjectId(cont.id);
        message.setSenderDisplayName('Company Support');
        message.setReplyTo('no-reply@omnicell.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'OrderConfirmationTemplate'];
		system.debug('mail ord conf');        
        message.setTemplateID(emailTemplate.Id);
        message.setWhatId(OrdId.Id); 
        message.toAddresses = new String[] { cont.email};
        return message;
        
    }
    
}