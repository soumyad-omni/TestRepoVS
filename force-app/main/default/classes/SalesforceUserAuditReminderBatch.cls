/* IBA-2471
* @author : Pabitra Tripathy
*If Status is Completed set NULL to previous cost center for current fiscal quarter
*If Status is Pending Review send reminder email
*Author: Pabtra Tripathy
*
*Test class : SalesforceUserAuditReminderBatch_Test
*/
global class SalesforceUserAuditReminderBatch  implements Database.Batchable<sObject>{
   	public Map<Integer,String> monthToQuarterMap = new Map<Integer,String>{1 => 'Q1',2 => 'Q1',3 => 'Q1',4 => 'Q2',
        						5 => 'Q2',6 => 'Q2',7 => 'Q3',8 => 'Q3',9 => 'Q3',10 => 'Q4',11 => 'Q4',12 => 'Q4'};
    public Integer currentMonth = Date.Today().Month();
    public String quarter= monthToQuarterMap.get(currentMonth);
    public String fiscalYr= String.valueOf(Date.today().Year());
    String query;
    
        global Database.QueryLocator start(Database.BatchableContext BC) {
            
              query = 'SELECT Id,Status__c,Manager__c,Manager__r.Email FROM SalesforceUserAudit__c WHERE '+
                  	  'Status__c=\'Pending Review\' AND Quarter__c=:quarter AND FiscalYear__c= :fiscalYr AND Audit_Purpose__c =\'Quarterly\'';//IBA-4410
            
            if(Test.isRunningTest()){
               query = 'SELECT Id,Status__c,Manager__c,Manager__r.Email FROM SalesforceUserAudit__c WHERE '+
                   	   'Status__c=\'Pending Review\' AND Quarter__c=:quarter AND FiscalYear__c= :fiscalYr AND Audit_Purpose__c =\'Quarterly\' LIMIT 5'; 
            }
            
            return Database.getQueryLocator(query);
        }
    
    global void execute(Database.BatchableContext BC, List<SalesforceUserAudit__c> pendingAuditList) {
	     Integer currentMonth = Date.Today().Month();
    	 String quarter= monthToQuarterMap.get(currentMonth);
    	 String fiscalYr= String.valueOf(Date.today().Year());
        //update previous cost center to NULL for audit records status - completed,current fiscal,quarter
        List<SalesforceUserAudit__c> compUserAudit = [SELECT Id,Status__c FROM SalesforceUserAudit__c WHERE 
                                                      Status__c='Completed' 
                                                      AND Quarter__c=:quarter AND FiscalYear__c= :fiscalYr];

        List<Employee__c> emplList = [SELECT Id,Employee__c FROM Employee__c where SalesforceUserAudit__c in:compUserAudit ];
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
                } 																	  //IBA-4410-End
            }
        
    	update usrToUpdateList;
      
        //Send email to pending audit records
        List<Messaging.SingleEmailMessage> emailsToSend=new List<Messaging.SingleEmailMessage>();
        String recipient=System.Label.SalesforceAuditEmailServiceCC;
        for(SalesforceUserAudit__c pndAuditRec:pendingAuditList){
        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        	String templateName='Salesforce_Quarterly_User_Audit';
        	EmailTemplate emailTemplate = [Select Id from EmailTemplate where DeveloperName= :templateName];
        	email.setTemplateID(emailTemplate.Id);        
            email.setTargetObjectId(pndAuditRec.Manager__c);
            email.setWhatId(pndAuditRec.Id);
    	    email.setReplyTo('no-reply@omnicell.com');
        	email.setUseSignature(false); 
        	email.setBccSender(false); 
        	email.setSaveAsActivity(false);
            String[] ccAddresses = new String[] {recipient}; 
            email.setToAddresses(ccAddresses); 
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