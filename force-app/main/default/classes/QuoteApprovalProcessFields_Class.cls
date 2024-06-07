/**********************************************************************
Name:  QuoteApprovalProcessFields_Class
Copyright © 2018
======================================================
======================================================
Purpose: To update Assigned To and Status(Approval Process Status) fields from current approval process steps
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL                 Description
0.1       Haripriya Maturi            7/09/2018       INITIAL DEVELOPMENT
***********************************************************************/
public class QuoteApprovalProcessFields_Class{
    public Set<Id> quoteAprovalRecIdSet = new Set<Id>();
    public Set<Id> processInstanceIds = new Set<Id>();
    public Quote_Approval__c qApprovalRec = new Quote_Approval__c();
    public List<Quote_Approval__c> qApprovalRecList = new List<Quote_Approval__c>();
    public String assignedTo;
    public String status;

    public void updateQuoteApprovalFields(List<Quote_Approval__c> quoteAppList){    
        System.Debug('Inside updateQuoteApprovalFields...'+quoteAppList);    
        for(Quote_Approval__c c : quoteAppList){
            quoteAprovalRecIdSet.add(c.Id);
        }
        for(Quote_Approval__c c : [SELECT Id,(SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC) FROM Quote_Approval__c WHERE ID  =: quoteAprovalRecIdSet]){
            for(ProcessInstance pi :c.ProcessInstances)
                processInstanceIds.add(pi.Id);
        }

// Now we have most recent process instances and the most recent process steps.  
        for (ProcessInstance pi : [SELECT ProcessInstance.Id,status, 
                          ProcessInstance.ProcessDefinition.name, (Select actorid ,OriginalActorId,ProcessInstanceHistory.StepStatus
                          ,ProcessInstanceHistory.IsPending,OriginalActor.name  FROM StepsAndWorkitems order by ProcessInstanceHistory.IsPending asc, createddate asc) 
                          FROM ProcessInstance WHERE ProcessInstance.TargetObjectId = :quoteAprovalRecIdSet  order by createddate asc nulls last])
        {
            status = pi.status;
            if (pi.StepsAndWorkitems.size() > 0){
                for(ProcessInstanceHistory pih :pi.StepsAndWorkitems){
                    //status = pih.StepStatus;
                    assignedTo = pih.OriginalActor.name;
                }
            } 
               
        }
        System.Debug('assignedTo : '+assignedTo+'status : '+status);
        
        for(Quote_Approval__c c : quoteAppList){
            c.Assigned_To__c = assignedTo ;
            c.Approval_Process_Status__c= status;
            qApprovalRecList.add(c);
        }

    }

}