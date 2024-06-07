public class SalesforceUserAuditEmailVFController {
    
    public Id suaId {get;set;} 
    
    public String completedDate {
        get{
        	SalesforceUserAudit__c aurec = [Select Id,LastDatetoCompleteAudit__c   
            							 	From SalesforceUserAudit__c Where Id =:suaId];
            return aurec.LastDatetoCompleteAudit__c.month()+'/'+aurec.LastDatetoCompleteAudit__c.day()+'/'+
                   aurec.LastDatetoCompleteAudit__c.year();
    		}
        						
        set;
    }  
    //default constructor
    public SalesforceUserAuditEmailVFController(){} 
        
    public SalesforceUserAudit__c sua{
        get{            
            return [Select Id,Name,Manager__c,Manager__r.Email,Manager__r.Profile.Name,
                    Manager__r.Name,Manager__r.Omnicell_Employee_Number__c,Manager__r.Title,
                    Manager__r.Department,Manager__r.Manager.Name,Manager__r.LastLoginDate,
                    Manager__r.PreviousCostCenter__c,Manager__r.PreviousDepartment__c,ThreadID__c,
                    Status__c,LastDatetoCompleteAudit__c   
                    From SalesforceUserAudit__c Where Id =:suaId];
            }
        set;
    }
        
    // get the employees.
    public List<Employee__c> employees{
        get{            
            return [Select Id,Name,Completed__c,Title__c,
                    RequestType__c,Profile__c,Department__c,CostCenter__c,
                    CurrentProfile__c,NewProfile__c,SalesforceUserAudit__c,
                    Email__c,Employee__c,Employee__r.Name,Manager__r.Name,
                    Employee__r.LastLoginDate,OmnicellEmployeeNumber__c,
                    CurrentUserStatus__c,NewUserStatus__c,Contractor__c,
                    SalesforceUserAudit__r.TotalEmployees__c,PreviousCostCenter__c,PreviousDepartment__c
                    From Employee__c
                    Where SalesforceUserAudit__c = :suaId Order By Name];            
        }
        set;
    }
}