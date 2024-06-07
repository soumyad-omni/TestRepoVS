public class AccountApprovalTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('AccountApprovalTriggerDisabled');
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
        
    }
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
        //IBA-1148 START
        List<Account_Approval__c> aapList = newItems.values();
        Set<id> aapIds = new Set<id>(); 
        if(aapList != null && aapList.size() > 0){
            for(Account_Approval__c aap : aapList) {
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
        //IBA-1148 END
        
    }
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Account_Approval__c> aapList = newItems.values();
        //IBA-1148 START
        Set<id> aapIds = new Set<id>();
        if(aapList != null && aapList.size() > 0){
            for(Account_Approval__c aap : aapList) {
                aapIds.add(aap.id); 
            }
            updateAssignedTo(aapIds);
        }
        //IBA-1148 END
    }
    
    //IBA-1148 START
    @future
    public static void updateAssignedTo(Set<ID> ids) {
        List<ProcessInstance> pi = [SELECT Id,TargetObjectid, Status,(select id,actor.name,originalActor.name from Workitems) FROM ProcessInstance WHERE TargetObjectId =: ids and Status = 'pending'];
        List<Account_Approval__c> aapList = [Select id,Assigned_To__c from Account_Approval__c where id =: ids];
        Map<Id, String> map1 = new Map<Id, String>();
        if(pi.size() > 0) {
            for(ProcessInstance p: pi) {
                map1.put(p.TargetObjectid,p.Workitems[0].originalActor.name);
            }
        }
        for(Account_Approval__c aap: aapList) {
            String assignToName = map1.get(aap.id);
            if(assignToName != null && assignToName != '') {
                aap.Assigned_To__c = assignToName;  
                aap.isApproved__c = false;
            }
        }
        AccountApprovalTriggerHandler.TriggerDisabled = true;
        try {
            update aapList;
        }catch(Exception e) {
            System.debug('Exception:' +e);
        }
    }
    //IBA-1148 END
    
}