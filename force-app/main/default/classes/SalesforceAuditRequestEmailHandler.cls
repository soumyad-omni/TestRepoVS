/**
* Email services are automated processes that use Apex classes
* to process the contents, headers, and attachments of inbound
* email.
*/
global class SalesforceAuditRequestEmailHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
     	try{
 	    String APPROVED = 'APPROVED';
        String REJECTED = 'REJECTED';
        
        String bodyText;
        
        if(string.isEmpty(email.plainTextBody))
            bodyText = HtmlToText(email.htmlBody);
        else
            bodyText = email.plainTextBody;
        
        String comments;
        if(email.subject.containsIgnoreCase(APPROVED)){
            comments = bodyText;
        }else if(email.subject.containsIgnoreCase(REJECTED)){
            comments = bodyText;
        }
        
        String sauRefId;
        if(bodyText.contains('ref:')){
            sauRefId = bodyText.subStringBetween('ref:_',':ref');
        }
        
            SalesforceUserAudit__c sau = [Select Id,ThreadID__c,Audit_Purpose__c From SalesforceUserAudit__c Where Id = :sauRefId];//IBA-4410
        
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :sau.Id];
        
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            if(email.subject.containsIgnoreCase(APPROVED))
                req.setAction('Approve');
            else if(email.subject.containsIgnoreCase(REJECTED)){
                req.setAction('Reject');
            }
            req.setComments(comments);
            requests.add(req);
        }
        
        // submit approval request
        Approval.ProcessResult[] processResults = Approval.process(requests);        
        
        // update salesforce user audit record
        update new SalesforceUserAudit__c(Id = sau.Id,Status__c = 'Completed',CompletedOn__c = Date.today(),ReviewComments__c = comments);
            if(sau.Audit_Purpose__c == 'Quarterly'){ //IBA-4410
        List<Employee__c> emplList = [SELECT Id,Employee__c FROM Employee__c where SalesforceUserAudit__c= :sau.Id ];
        Set<Id> userSet=new Set<Id>();	
        for(Employee__c e:emplList) {
            	userSet.add(e.Employee__c);                                              
            }  

                List<User> usrToUpdateList=[Select Id,Cost_Center__c,PreviousCostCenter__c,PreviousDepartment__c,ManagerId,PreviousTitle__c From User 
                                            Where (PreviousCostCenter__c <> null OR PreviousTitle__c <> null) AND Id in :userSet]; //IBA-4410
                for(User usr:usrToUpdateList){
                    if(usr.PreviousCostCenter__c != NULL && usr.PreviousTitle__c != NULL){//IBA-4410-Start
                        usr.PreviousCostCenter__c = NULL;
                        usr.PreviousTitle__c = NULL;
                    }
                    if(usr.PreviousCostCenter__c == NULL && usr.PreviousTitle__c != NULL){
                        usr.PreviousTitle__c = NULL;
                    }
                    if(usr.PreviousCostCenter__c != NULL && usr.PreviousTitle__c == NULL){
                        usr.PreviousCostCenter__c=NULL;
                    } 	
                }
                
                update usrToUpdateList;
            }
            //Attach the email   	
        Attachment attachment = new Attachment();
        attachment.Name =email.subject ;
        attachment.Body =  Blob.valueOf(bodyText);
        attachment.ParentId = sau.Id;
        insert attachment;
        
        result.success = true;        
        return result;
        
        }catch(Exception e){
        
            result.success = true;
        	result.message = e.getMessage()+e.getStackTraceString();
        	return result;
        }
        
    }    
    
    public static string HtmlToText(string html){
        //replace all <BR> tags with \n to support new lines
        string result = html.replaceAll('<br/>', '\n');
        result = result.replaceAll('<br />', '\n');
        
        //all HTML/XML tags
        string HtmlPattern = '<.*?>';
        
        Matcher match =  Pattern.compile(HtmlPattern).matcher(result);
        
        //remove the tags and return string     
        return match.replaceAll('');
    }
}