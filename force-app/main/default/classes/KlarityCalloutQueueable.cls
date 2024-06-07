public class KlarityCalloutQueueable implements Queueable, Database.AllowsCallouts {

    Public String FinalJSON;
    //Public List<echosign_dev1__SIGN_Agreement__c> Processed_Docs; //IBA-5326 SH, Commented as part of IBA-5772 as mulesoft is updating this field now SH
    
    public void execute(QueueableContext context) {
        string errormsg ='';
        String[] toAddresses = new String[]{Label.KlarityIntegrationErrorMail}; // IBA-5772 SH
        String subject = '[SFDC]Klarity Integration Error'; // IBA-5772 SH
        try{
            SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('Klarity_DataUploadEndpoint');
            String endpoint =   connectionDetails.SCP_End_Point__c;
            String accessToken = Klarity_MuleAccessTokenBuilder.authenticateMuleSystem();
            String method = connectionDetails.SCP_Method_Type__c;
            Integer timeout = Integer.valueOf(connectionDetails.SCP_Timeout__c);
            system.debug('endpoint...'+endpoint);
            system.debug('method...'+method);
            system.debug('timeout...'+timeout);
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            req.setHeader('Authorization', 'Bearer '+accessToken);
            req.setHeader('Content-Type','application/json');
            req.setHeader('accept','application/json');
            req.setBody(FinalJSON);
            req.setMethod(method);
            req.setEndpoint(endpoint);
            req.setTimeout(timeout);
            HttpResponse res=h.send(req);
            system.debug('res.getstatusCode()..'+res.getstatusCode());
            if(res.getstatusCode() == 200 || res.getstatusCode() == 201){
                system.debug('res.getBody()..'+res.getBody());
                /*if(Processed_Docs.size()>0){ //IBA-5326 SH, Commented as part of IBA-5772 as mulesoft is updating this field now SH
                    update Processed_Docs; 
                }*/
            } 
            
            if(res.getstatusCode() != 200 && res.getstatusCode() != 201){
                //IBA-5772 added this Messaging part SH
                errormsg = 'Status Recieved: '+res.getStatus()+ ' \nStatus Code Recieved: '+res.getstatusCode();
                if(errormsg!=null){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject(subject);
                    email.setToAddresses(toAddresses);
                    email.setPlainTextBody(errormsg);
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                }    
                //IBA-5772 ends
            }
        }catch(exception e){
            //IBA-5772 added this Messaging part SH
            errormsg = 'Execption: '+e;
            if(errormsg!=null){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject(subject);
                email.setToAddresses(toAddresses);
                email.setPlainTextBody(errormsg);
                Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }    
            //IBA-5772 ends
        }
    }
}