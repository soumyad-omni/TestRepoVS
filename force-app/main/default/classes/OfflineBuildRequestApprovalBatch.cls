/* *******************************************************
 * Author : Pavan Kumar
 * Dated:October 13, 2020
 * Description: 
 * a) Batch is used to send automatic approval request if the offline build ship before approval entry criterias are met
 * b) Batch is suppose to run everyday so that ship before notification can be sent on daily basis for the records meeting the criterias.
 * Test Class: OffineBuildRequestControllerTest
 * *******************************************************/
global class OfflineBuildRequestApprovalBatch implements Database.Batchable<sObject>,Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Date todayDate = Date.Today();
        
        String query = 'SELECT Id, Opportunity__c,Quote__c,RequestedLandDate__c,Status__c,OpportunityCloseDate__c FROM OfflineBuildRequest__c WHERE ShipBeforeBookingApprovalDate__c = null AND Status__c != \'Submitted for Approval\''+' AND RequestedLandDate__c > :todayDate';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OfflineBuildRequest__c> scope) {
        
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        
        Approval.ProcessSubmitRequest req;
        
        // process each batch of records
        for(OfflineBuildRequest__c obr : scope) { 
            
            if(obr.OpportunityCloseDate__c.addDays(Integer.valueOf(Label.Offline_Build_Ship_Before_Approval_Email_Deadline)) >= obr.RequestedLandDate__c){
                
                // instantiate new approval request
                req = new Approval.ProcessSubmitRequest();
                
                // Set the comment you want to add
                req.setComments('Submitting request for Ship Before approval');
                
                // Set the object-id in the Approval.ProcessSubmitRequest instance
                req.setObjectId(obr.Id);
                
                //Add the instance to the list initialized above, before the for loop
                requests.add(req);
                
                obr.SendBeforeShippingApproval__c = true;
            }
        }
        
        try {
            // update offline build requests
            update scope;
            
            // the command Approval.process will submit all your record for Approval
            Approval.ProcessResult[] processResults = Approval.process(requests);            
        } catch(Exception e) {
            System.debug(e);
        }        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    global void execute(SchedulableContext sc) {
        OfflineBuildRequestApprovalBatch obra = new OfflineBuildRequestApprovalBatch(); 
        Database.executeBatch(obra);
    }
}