/**********************************************************************
Name:  ContractApprovalProcessFields_Class
Copyright © 2018
======================================================
======================================================
Purpose: To update Assigned To and Status fields from current approval process steps
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL                 Description
0.1       Haripriya Maturi            7/26/2018       INITIAL DEVELOPMENT
***********************************************************************/
public with sharing class ContractApprovalProcessFields_Class{
    public Set<Id> contractIdSet = new Set<Id>();
    public Set<Id> processInstanceIds = new Set<Id>();
    public Contracts__c cRec = new Contracts__c();
    public List<Contracts__c> cRecList = new List<Contracts__c>();
    public String assignedTo;
    public String status;

    public void updateContractsFields(List<Contracts__c> contractList){    
        System.Debug('Inside updateContractsFields...'+contractList);    
        for(Contracts__c c : contractList){
            contractIdSet.add(c.Id);
        }
        for(Contracts__c c : [SELECT Id,(SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC) FROM Contracts__c WHERE ID  =: contractIdSet]){
            for(ProcessInstance pi :c.ProcessInstances)
                processInstanceIds.add(pi.Id);
        }
        
// Now we have most recent process instances and the most recent process steps.  
        
        for (ProcessInstance pi : [SELECT ProcessInstance.Id,status, 
                          ProcessInstance.ProcessDefinition.name, (Select actorid ,OriginalActorId,ProcessInstanceHistory.StepStatus
                          ,ProcessInstanceHistory.IsPending,OriginalActor.name  FROM StepsAndWorkitems order by ProcessInstanceHistory.IsPending asc, createddate asc) 
                          FROM ProcessInstance WHERE ProcessInstance.TargetObjectId = :contractIdSet  order by createddate asc nulls last] )
        {
            //soumyad sf-bug-704 start
            status = pi.Status;
            
            if (status == 'Pending'){
                system.debug('status:  '+status);
                
                for(ProcessInstanceHistory pih :pi.StepsAndWorkitems){
                    //status = pih.StepStatus;
                    assignedTo = pih.OriginalActor.name;
                    System.Debug('assignedTo00000000000000 : '+assignedTo);
                }
            }else{
                assignedTo = '';
                    System.Debug('assignedTo00000000000000 : '+assignedTo);
            } 
            //soumyad sf-bug-704 end   
        }
        System.Debug('assignedTo : '+assignedTo+'status : '+status);
        
        for(Contracts__c c : contractList){
            c.Assigned_To__c = assignedTo ;
            c.Status__c= status;
            cRecList.add(c);
        }
        System.Debug('assignedTo--- : '+assignedTo);

    }
    

}