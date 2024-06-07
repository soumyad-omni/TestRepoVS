/*
 * 
*/
global class SalesforceAnnualUserAuditBatch implements Database.Batchable<sObject>,Database.Stateful{ //IBA-4716
    String query;
    String licenseKey = 'SFDC';
    String suaErrorMsg = '';//IBA-4716
    String empErrorMsg = '';//IBA-4716
    global Map<Integer,String> monthToQuarterMap = new Map<Integer,String>{1 => 'Q1',2 => 'Q1',3 => 'Q1',4 => 'Q2',5 => 'Q2',6 => 'Q2',7 => 'Q3',8 => 'Q3',9 => 'Q3',10 => 'Q4',11 => 'Q4',12 => 'Q4'};//IBA-4716
        global Database.QueryLocator start(Database.BatchableContext BC) {
            Set<String> managerNames = new Set<String>(); //IBA-4716 - Start
            List<SFDC_Annual_Audit_Managers__c> managers = SFDC_Annual_Audit_Managers__c.getall().values();
            for(SFDC_Annual_Audit_Managers__c manager :managers ){
                managerNames.add(manager.Name);
            }
            if(managerNames.size()>0){
                query = 'Select Id,Name,FirstName,LastName,Department,Title,Profile.Name,Cost_Center__c,IsActive,Email,Omnicell_Employee_Number__c,'+
                    'PreviousProfileName__c,PreviousCostCenter__c,PreviousDepartment__c,ManagerId,Manager.Name,Manager.Profile.Name,Manager.Email,'+
                    'PreviousTitle__c From User Where ManagerId <> null AND Manager.IsActive = true AND IsActive = true '+
                    'AND Profile.UserLicense.LicenseDefinitionKey = :licenseKey'+
                    ' AND Id IN(select userId from UserLogin Where IsFrozen=false) AND Manager.Name IN :managerNames Order By Manager.Name';
            }
            else{
                query = 'Select Id,Name,FirstName,LastName,Department,Title,Profile.Name,Cost_Center__c,IsActive,Email,Omnicell_Employee_Number__c,'+
                    'PreviousProfileName__c,PreviousCostCenter__c,PreviousDepartment__c,ManagerId,Manager.Name,Manager.Profile.Name,Manager.Email,'+
                    'PreviousTitle__c From User Where ManagerId <> null AND Manager.IsActive = true AND IsActive = true '+
                    'AND Profile.UserLicense.LicenseDefinitionKey = :licenseKey'+
                    ' AND Id IN(select userId from UserLogin Where IsFrozen=false) Order By Manager.Name';
            }																					//IBA-4716 - End
            
            if(Test.isRunningTest()){
                query = 'Select Id,Name,FirstName,LastName,Department,Title,Profile.Name,Cost_Center__c,IsActive,Email,Omnicell_Employee_Number__c,'+
                'PreviousProfileName__c,PreviousCostCenter__c,PreviousDepartment__c,ManagerId,Manager.Name,Manager.Profile.Name,Manager.Email,'+
                'PreviousTitle__c From User Where ManagerId <> null AND Manager.IsActive = true AND IsActive = true '+
                'AND Profile.UserLicense.LicenseDefinitionKey = :licenseKey'+
                ' AND Id IN(select userId from UserLogin Where IsFrozen=false) Order By Manager.Name LIMIT 5';//IBA-4716
            }
            
            return Database.getQueryLocator(query);
        }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {
        
        Map<Id,List<User>> managerToRelatedEmployeesMap = new Map<Id,List<User>>();  
        
        for(User usr : scope) { 
                if(managerToRelatedEmployeesMap.containsKey(usr.ManagerId))
                    managerToRelatedEmployeesMap.get(usr.ManagerId).add(usr);
                else{
                    managerToRelatedEmployeesMap.put(usr.ManagerId,new List<User>{usr});
                }            
        }
        
        List<SalesforceUserAudit__c> salesforceUserAudits = new List<SalesforceUserAudit__c>();
        Integer currentMonth = Date.Today().Month();//IBA-4716
        for(Id mgrId : managerToRelatedEmployeesMap.keySet()){
            // add salesforce user audit request
            salesforceUserAudits.add(new SalesforceUserAudit__c(Manager__c = mgrId,
                                                                Quarter__c = monthToQuarterMap.get(currentMonth),//IBA-4716
                                                                LastDatetoCompleteAudit__c = Date.today().addMonths(1).toStartOfMonth().addDays(-5),
                                                                FiscalYear__c = String.valueOf(Date.today().Year()),
                                                                Status__c = 'Pending Review',
                                                               	Audit_Purpose__c = 'Annual'));
        }
        
        
        Savepoint sp = Database.setSavepoint();
        
        try {            
            
            // creates user audit records in bulk
			//Database.insert(salesforceUserAudits,false);
            List<Database.SaveResult> resultSFUA = Database.insert(salesforceUserAudits,false); //IBA-4716 - Start
            for (Database.SaveResult sr : resultSFUA) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. SFU ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        suaErrorMsg = suaErrorMsg + err.getStatusCode() + ': ' + err.getMessage()+'\n';
                    }
                }
            }																					//IBA-4716 - End
            
            Map<Id,Id> managerToSuaMap = new Map<Id,Id>();
            
            for(SalesforceUserAudit__c sua : [Select Id,Manager__c,Manager__r.Email,EmailNotificationSent__c From SalesforceUserAudit__c Where Id IN :salesforceUserAudits]){
                managerToSuaMap.put(sua.Manager__c,sua.Id);
            }
            
            List<Employee__c> employeesToCreateList = new List<Employee__c>();
            
            for(Id mgr : managerToSuaMap.keySet()){
                for(User employee : managerToRelatedEmployeesMap.get(mgr)){                    
                    employeesToCreateList.add(new Employee__c(Name = employee.Name,
                                                              Manager__c = mgr,
                                                              Completed__c = false,
                                                              Employee__c = employee.Id,
                                                              Title__c = employee.Title,
                                                              RequestType__c = 'No Change',
                                                              Profile__c = employee.Profile.Name,
                                                              Department__c = employee.Department,
                                                              CostCenter__c = employee.Cost_Center__c,
                                                              PreviousCostCenter__c =  employee.PreviousCostCenter__c,
                                                              PreviousDepartment__c = employee.PreviousDepartment__c,
                                                              PreviousTitle__c = employee.PreviousTitle__c,
                                                              CurrentProfile__c = employee.Profile.Name,
                                                              NewProfile__c = employee.Profile.Name,
                                                              SalesforceUserAudit__c = managerToSuaMap.get(mgr),
                                                              Email__c = employee.Email.substringBefore('.invalid'),
                                                              OmnicellEmployeeNumber__c = employee.Omnicell_Employee_Number__c,
                                                              CurrentUserStatus__c = employee.IsActive == true ? 'Active' : 'Inactive', 
                                                              NewUserStatus__c = employee.IsActive == true ? 'Active' : 'Inactive',
                                                              Contractor__c = employee.Omnicell_Employee_Number__c == null ? true : false));
                    
                }
            }    
			//Database.insert(employeesToCreateList,false); 
            List<Database.SaveResult> resultEMP = Database.insert(employeesToCreateList,false); //IBA-4716 - Start
            for (Database.SaveResult sr : resultEMP) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. SFU ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        empErrorMsg = empErrorMsg + err.getStatusCode() + ': ' + err.getMessage()+'\n';
                    }
                }
            }																					//IBA-4716 - End
            System.debug('employeesToCreateList'+employeesToCreateList);
            Approval.ProcessSubmitRequest req;
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            
            for(SalesforceUserAudit__c sua : salesforceUserAudits){
                req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(sua.Id);
                req.setProcessDefinitionNameOrId('SFDC_Access_Annual_Approval_Process');
                req.setSkipEntryCriteria(true);
                requests.add(req);
            }        
            
            // submit the approval request for the Salesforce Audit Request
            Approval.ProcessResult[] result = Approval.process(requests,true);
            
        } catch(Exception e) {            
            Database.rollback(sp);
        }        
    }   
    
    global void finish(Database.BatchableContext BC) {
        System.debug(suaErrorMsg+''+empErrorMsg); //IBA-4716 - Start
        if(suaErrorMsg!='' || empErrorMsg!=''){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setReplyTo('no-reply@omnicell.com');
            email.setSubject('Salesforce Annual Audit Batch Error Messages');
            email.setUseSignature(false); 
            email.setBccSender(false); 
            email.setSaveAsActivity(false);
            email.setPlainTextBody('Error Messages are:\n'+suaErrorMsg+'\n'+empErrorMsg);
            email.setToAddresses(System.Label.SFDC_Annual_Audit_Emails.split('[,;]'));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }										//IBA-4716 - End
    }
    
}