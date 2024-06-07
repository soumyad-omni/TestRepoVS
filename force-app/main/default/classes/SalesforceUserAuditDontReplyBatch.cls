/*IBA-2471
*@author : Pabitra Tripathy 
*If Status is Pending Review, change status to Did not reply
*Set NULL to previous cost center for current fiscal quarter
*Author : Pabitra Tripathy
*/
global class SalesforceUserAuditDontReplyBatch  implements Database.Batchable<sObject>,Database.Stateful{
   	public Map<Integer,String> monthToQuarterMap = new Map<Integer,String>{1 => 'Q1',2 => 'Q1',3 => 'Q1',
        	4 => 'Q2',5 => 'Q2',6 => 'Q2',7 => 'Q3',8 => 'Q3',9 => 'Q3',10 => 'Q4',11 => 'Q4',12 => 'Q4'};
    public String changeInfo='';
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
        try{
        	// change the stutus from Pending Review to Did not Reply
			changeInfo+='The following sf User Audit records Status updated from Pending Review to Did not reply : ';         
            
            for(SalesforceUserAudit__c pndAuditRec:pendingAuditList){
        		pndAuditRec.Status__c = 'Did not reply';
             	changeInfo+=pndAuditRec.Id+' ';
	       		}
		
        	update pendingAuditList;
           	changeInfo+='\n';
            
        //update previous cost center to NULL for audit records status - Did not reply,current fiscal,quarter
        List<SalesforceUserAudit__c> compUserAudit = [SELECT Id,Status__c FROM SalesforceUserAudit__c WHERE 
                                                      Status__c='Did not reply' 
                                                      AND Quarter__c=:quarter AND FiscalYear__c= :fiscalYr];
		
        List<Employee__c> emplList = [SELECT Id,Employee__c FROM Employee__c where SalesforceUserAudit__c in:compUserAudit ];
        Set<Id> userSet=new Set<Id>();	
        for(Employee__c e:emplList) {
            	userSet.add(e.Employee__c);                                              
            }  
            
            changeInfo+='The following users previous cost center and previous title set to blank : ';//IBA-4410
            List<User> usrToUpdateList=[Select Id,Cost_Center__c,PreviousCostCenter__c,PreviousDepartment__c,ManagerId,Name,PreviousTitle__c 
                                        From User 
                                        Where (PreviousCostCenter__c <> null OR PreviousTitle__c <> null) AND Id in :userSet]; //IBA-4410
            for(User usr:usrToUpdateList){
                if(usr.PreviousCostCenter__c != NULL && usr.PreviousTitle__c != NULL){//IBA-4410-Start
                    usr.PreviousCostCenter__c = NULL;
                    usr.PreviousTitle__c = NULL;
                    changeInfo+=usr.Name+' ';
                }
                if(usr.PreviousCostCenter__c == NULL && usr.PreviousTitle__c != NULL){
                    usr.PreviousTitle__c = NULL;
                    changeInfo+=usr.Name+' ';
                }
                if(usr.PreviousCostCenter__c != NULL && usr.PreviousTitle__c == NULL){
                    usr.PreviousCostCenter__c=NULL;
                    changeInfo+=usr.Name+' ';
                }                													 //IBA-4410-End
            }
            
            update usrToUpdateList;
            
        }catch(Exception ex){
            System.debug(ex.getMessage()+ex.getStackTraceString());
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        	changeInfo+='\n\n- Thanks, SalesforceUserAuditDontReplyBatch';	
        	String recipient=System.Label.SalesforceAuditEmailServiceCC;
            
        	if(recipient!=null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                String[] toAddresses = new String[] {recipient}; 
                mail.setToAddresses(toAddresses); 
                mail.setSubject('Salesforce User Audit Status update to Do not reply'); 
                mail.setPlainTextBody(changeInfo);
                if(!Test.isRunningTest())
                  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }
    }
 
}