global class BCH_CreateOpportunityTeamMembers implements Database.Batchable<sObject>{
    
    global List<Id> opportunityIds = new List<Id>();
    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                         WHERE Id IN :opportunityIds and Account.IsDeleted__c = false
                                         AND (OppStatus__c ='PO Received - Pending Paperwork' OR 
                                              OppStatus__c ='PO Received' OR OppStatus__c ='Open')]);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList)
    {
        CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
        job.oppList = oppList; 
        System.enqueueJob(job); 
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    

}