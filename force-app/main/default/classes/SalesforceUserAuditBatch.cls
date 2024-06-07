/* Author: Pavan Kumar
* Test Class: SalesforceAuditBatchTest */
global class SalesforceUserAuditBatch implements Database.Batchable<sObject>{
    String query;
    
    global Map<Integer,String> monthToQuarterMap = new Map<Integer,String>{1 => 'Q1',2 => 'Q1',3 => 'Q1',4 => 'Q2',5 => 'Q2',6 => 'Q2',7 => 'Q3',8 => 'Q3',9 => 'Q3',10 => 'Q4',11 => 'Q4',12 => 'Q4'};
        
        global Database.QueryLocator start(Database.BatchableContext BC) {
            
            query = 'Select Id,Name,FirstName,LastName,Department,Title,Profile.Name,Cost_Center__c,IsActive,Email,Omnicell_Employee_Number__c,'+
                'PreviousProfileName__c,PreviousCostCenter__c,PreviousDepartment__c,ManagerId,Manager.Name,Manager.Profile.Name,Manager.Email,'+
                'PreviousTitle__c From User Where ManagerId <> null AND Manager.IsActive = true AND IsActive = true AND (PreviousCostCenter__c <> null '+
                'OR PreviousTitle__c <> null) Order By Manager.Name'; //IBA-4410
            
            if(Test.isRunningTest()){
               query = 'Select Id,Name,FirstName,LastName,Department,Title,Profile.Name,Cost_Center__c,IsActive,Email,Omnicell_Employee_Number__c,'+
                   'PreviousProfileName__c,PreviousCostCenter__c,PreviousDepartment__c,ManagerId,Manager.Name,Manager.Profile.Name,Manager.Email,'+
                   'PreviousTitle__c From User Where ManagerId <> null AND Manager.IsActive = true AND IsActive = true AND (PreviousCostCenter__c <> '+
                   'null OR PreviousTitle__c <> null) Order By Manager.Name LIMIT 5'; 
            }
            
            return Database.getQueryLocator(query);
        }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {
      
        Map<Id,List<User>> managerToRelatedEmployeesMap = new Map<Id,List<User>>();  
        
        for(User usr : scope) { 
             // store the manager Id whenever the previous profile name or previous cost center is not blank.
            if(usr.PreviousCostCenter__c != null || usr.PreviousTitle__c != null){//IBA-4410  
                
                if(managerToRelatedEmployeesMap.containsKey(usr.ManagerId))
                    managerToRelatedEmployeesMap.get(usr.ManagerId).add(usr);
                else{
                    managerToRelatedEmployeesMap.put(usr.ManagerId,new List<User>{usr});
                }
            } 
            
        }
        
        List<SalesforceUserAudit__c> salesforceUserAudits = new List<SalesforceUserAudit__c>();
        
        // get current month
        Integer currentMonth = Date.Today().Month();
        
        for(Id mgrId : managerToRelatedEmployeesMap.keySet()){
            // add salesforce user audit request
            salesforceUserAudits.add(new SalesforceUserAudit__c(Manager__c = mgrId,
                                                                Quarter__c = monthToQuarterMap.get(currentMonth),
                                                                LastDatetoCompleteAudit__c = Date.today().addMonths(1).toStartOfMonth().addDays(-5),
                                                                FiscalYear__c = String.valueOf(Date.today().Year()),
                                                                Status__c = 'Pending Review',
                                                                Audit_Purpose__c = 'Quarterly'));//IBA-4410
        }
        
        
        Savepoint sp = Database.setSavepoint();
        
        try {            
            
            // creates user audit records in bulk
            Database.insert(salesforceUserAudits,false);
	    
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
                                                              PreviousTitle__c = employee.PreviousTitle__c,//IBA-4410
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
            
            Database.insert(employeesToCreateList,false); 
            
            Approval.ProcessSubmitRequest req;
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            
            for(SalesforceUserAudit__c sua : salesforceUserAudits){
                req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(sua.Id);
                req.setProcessDefinitionNameOrId('Default_Manager');
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
        
    }
      
}