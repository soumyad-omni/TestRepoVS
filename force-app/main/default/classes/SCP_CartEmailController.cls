global without sharing class SCP_CartEmailController{

    @RemoteAction
    global static ccrz.cc_RemoteActionResult sendEmail(ccrz.cc_RemoteActionContext ctx,String emailData){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;  
         Map<String,object> outputMap= new Map<String,Object>();
         Map<String,object> emailDataMap = (Map<String, Object>)JSON.deserializeUntyped(emailData);
        try{
            system.debug('## emailData--'+emailData);
            system.debug('## ctx--'+ctx);
            
            String email_to = String.valueOf(emailDataMap.get('email_to'));
            String email_cc = String.valueOf(emailDataMap.get('email_cc'));
            String subject = String.valueOf(emailDataMap.get('subject'));
            String description  = String.valueOf(emailDataMap.get('description'));
            PageReference pdfPage = Page.SCP_EmailCartPDF;
            
            pdfPage.getParameters().put('recordId',ccrz.cc_CallContext.currCartId);
            Blob pagePdf;
            try {
                if(Test.isRunningTest()){
                    pagePdf = Blob.valueOf('Test');
                }else{
                    pagePdf = pdfPage.getContentAsPDF();
                }
            }catch(Exception e){
                
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('Cart.pdf');
            efa.setBody(pagePdf );
            List<String> sendTo = new List<String>();
            sendTo.add(email_to);
            
            // Sets the paramaters of the email
            email.setSubject(subject);
            email.setToAddresses(sendTo);
            email.setPlainTextBody(description);
            if(String.isNotBlank(email_cc)){
                email.setCcAddresses(new List<String>{email_cc});
            }

     
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
     
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            ccRemoteActionResult.success = true; 
            for(Messaging.SendEmailResult o : r){
                System.debug('result is---'+o);
            }
              ccrz.ccLog.log(System.LoggingLevel.DEBUG,'SendEmailResult','worked');
         }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }



}