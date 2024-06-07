public class CompensationRequestTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('CompensationRequestTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        
    }
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        
    }
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        //IBA-1924
        List<Compensation_Request_Approval__c> oldvalues = oldItems.values();
        List<Compensation_Request_Approval__c> newValues =  newItems.values();
if(newValues.size() == 1) {
            if(oldValues[0].Status__c != newValues[0].Status__c && (newValues[0].Status__c == 'Approved' || newValues[0].Status__c == 'Rejected' )) {
                newValues[0].Final_Approval_Rejected_Team__c = oldValues[0].Assigned_To__c;
            }
        }
    }
        //IBA-1924
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        //IBA-1647 START
        List<Compensation_Request_Approval__c> aapList = newItems.values();
        Set<id> aapIds = new Set<id>(); 
        if(aapList != null && aapList.size() > 0){
            for(Compensation_Request_Approval__c aap : aapList) {
                try {
                    aapIds.add(aap.id);     	
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(aap.id);
                    Approval.ProcessResult result = Approval.process(req1);
                }catch(Exception e) {
                    System.debug('Exception:' +e);
                }  
            }          
            // updateAssignedTo(aapIds);
        }
        //IBA-1647 END        
    }
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Compensation_Request_Approval__c> aapList = newItems.values();
        //IBA-1647 START
        Set<id> aapIds = new Set<id>();
        if(aapList != null && aapList.size() > 0){
            for(Compensation_Request_Approval__c aap : aapList) {
                aapIds.add(aap.id); 
            }
            updateAssignedTo(aapIds);
            updateReassigned(aapIds);
        }
        //IBA-1647 END    
    }
    //IBA-1647 START
    @future
    public static void updateAssignedTo(Set<ID> ids) {
        List<ProcessInstance> pi = [SELECT Id,TargetObjectid, Status,(select id,actor.name,originalActor.name from Workitems) FROM ProcessInstance WHERE TargetObjectId =: ids and Status = 'pending'];
        List<Compensation_Request_Approval__c> aapList = [Select id,Assigned_To__c from Compensation_Request_Approval__c where id =: ids];
        Map<Id, String> map1 = new Map<Id, String>();
        if(pi.size() > 0) {
            for(ProcessInstance p: pi) {
                map1.put(p.TargetObjectid,p.Workitems[0].originalActor.name);
            }
        }
        for(Compensation_Request_Approval__c aap: aapList) {
            String assignToName = map1.get(aap.id);
            if(assignToName != null && assignToName != '') {
                aap.Assigned_To__c = assignToName;  
                aap.isApproved__c = false;
            }
        }
        CompensationRequestTriggerHandler.TriggerDisabled = true;
        try {
            update aapList;
        }catch(Exception e) {
            System.debug('Exception:' +e);
        }
    }
    //IBA-1647 END
    //IBA-1924 Start
    @future
    public static void updateReassigned(Set<ID> ids) {
        List<ProcessInstance> pi = [SELECT Id, TargetObjectid, Status, (SELECT Id, StepStatus,Actor.Name, Comments FROM StepsAndWorkitems WHERE StepStatus ='Reassigned') FROM ProcessInstance WHERE TargetObjectId =: ids];
        List<Compensation_Request_Approval__c> aapList = [Select id,Final_Approval_Rejected_Team__c from Compensation_Request_Approval__c where id =: ids];
        Map<Id, String> map1 = new Map<Id, String>();
        if(pi.size() > 0) {
            for(ProcessInstance p: pi) {
                if(p.StepsAndWorkitems.size() > 0) {
                map1.put(p.TargetObjectid,p.StepsAndWorkitems[0].Actor.name);
                }
            }
        }
        for(Compensation_Request_Approval__c aap: aapList) {
            String reassignedUser = map1.get(aap.id);
            if(reassignedUser != null && reassignedUser != '') {
                aap.Final_Approval_Rejected_Team__c = reassignedUser;
            }
        }
        CompensationRequestTriggerHandler.TriggerDisabled = true;
        try {
            update aapList;
        }catch(Exception e) {
            System.debug('Exception:' +e);
        }
    }
    //IBA-1924 End
}