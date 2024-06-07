public class UpdateContactOwnerFromAcc implements Queueable{
    //Public List<Account> delAccList;
    Public Map<id,Contact> conMap;
    Public UpdateContactOwnerFromAcc(Map<id,Contact> conMap){
        this.conMap = conMap;
    }
    
    public void execute(QueueableContext context) {
        Map<id,Contact> updateConMap = new Map<id,Contact>();
        //List<Contact> conList = [SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId In: delAccList];
        Id ownerId = (Id)Label.Admin_Integration_User_Id;
        //System.debug(conList);
        
        
        if(conMap.size()>200){            
        	Map<id,Contact> revisedConMap = new Map<id,Contact>();
            revisedConMap.putall(conMap);
            for(Contact con : conMap.values()){
                
                if(ownerId!=NULL){
                    con.OwnerId = ownerId; 
                    con.Is_Active__c= 'N';
                    con.Inactive_Reason__c=Label.ContactInactiveReason;
                    //System.debug('con' +con);
                    if(updateConMap.size() <= 199){
                        updateConMap.put(con.id,con);
                        revisedConMap.remove(con.id);
                    }
                    else{
                        break;
                    }                        
                } 
            }
            if(updateConMap.size()>0){
                ContactTriggerHandler.isUpdateFromAccount = True;
                Database.SaveResult[] results = Database.update(updateConMap.values(),false);
                if(results.size()>0){
                    sendErrorEmail(results);
                }
            }
            if(revisedConMap.size()>0){
                system.debug('@#$revisedConList more than 200: '+ revisedConMap.size());
                if(!Test.isRunningTest()) {
                    system.enqueueJob(new UpdateContactOwnerFromAcc(revisedConMap), Integer.ValueOf(Label.UpdateContactOwnerFromAccQueueDelay)); 
                } 
            }
        }else{
            for(Contact con : conMap.values()){
                if(ownerId!=NULL){
                    con.OwnerId = ownerId; 
                    con.Is_Active__c= 'N';
                    con.Inactive_Reason__c=Label.ContactInactiveReason;
                    //System.debug('con' +con);
                    updateConMap.put(con.id,con);
                } 
            }
            if(updateConMap.size()>0){
                system.debug('@#$updateConList less then 200: '+ updateConMap.size());
                ContactTriggerHandler.isUpdateFromAccount = True;
                Database.SaveResult[] results = Database.update(updateConMap.values(),false);
                if(results.size()>0){
                    sendErrorEmail(results);
                }
            }
        }
    }
    
    public void sendErrorEmail(Database.SaveResult[] results){
        String ErrorMessage = '';                
        String[] toAddresses = new String[]{Label.AlohaIntegrationErrorsEmail};
        String subject = 'Contact Owner Updation Failed(UpdateContactOwnerFromAcc)';
        for(Database.SaveResult result : results){
            if(!result.isSuccess()){                
                for(Database.Error err : result.getErrors()) {
                    ErrorMessage += 'Exception: '+ err.getMessage() + ' for Record Id: '+ result.getId()+' \n';
                    system.debug('Exception: '+ err.getMessage());
                }
            }
        }
        
        if(!String.isEmpty(ErrorMessage)){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody(ErrorMessage);
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }
}