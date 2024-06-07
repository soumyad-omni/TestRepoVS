public class ReportingManagerTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('ReportingManagerTriggerDisabled');
        if(tc != null) isDisabled = tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        List<Reporting_Manager__c> newReportingManagers = newItems;
        validateUniqueUser(newReportingManagers);
    }
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newItems){
        List<Reporting_Manager__c> newReportingManagers = newItems.values();
        validateUniqueUser(newReportingManagers);
    }
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
    }
    
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
    }
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    
    public static void validateUniqueUser(List<Reporting_Manager__c> newRecords) {
        // Set to store User__c values that are being inserted or updated
        Set<Id> userIds = new Set<Id>();
        Map<Id,Integer> newUserCountMap = new Map<Id,Integer>();
        // Collect all User__c values from the incoming records
        for (Reporting_Manager__c rm : newRecords) {
            if (rm.User__c != null) {
                userIds.add(rm.User__c);
                if (newUserCountMap.containsKey(rm.User__c)) {
                    newUserCountMap.put(rm.User__c, newUserCountMap.get(rm.User__c) + 1);
                } else {
                    // Otherwise, initialize the count to 1
                    newUserCountMap.put(rm.User__c, 1);
                }
            }
        }
        
        // Check if there are any existing records with the same User__c
        if (!userIds.isEmpty()) {
            // SOQL query to get existing Reporting_Manager__c records with the same User__c
            List<Reporting_Manager__c> existingRecords = [SELECT Id, User__c 
                                                          FROM Reporting_Manager__c 
                                                          WHERE User__c IN :userIds 
                                                          AND Id NOT IN :newRecords];
            
            // Map to store existing User__c values
            Map<Id, Id> existingUserMap = new Map<Id, Id>();
            for (Reporting_Manager__c rm : existingRecords) {
                existingUserMap.put(rm.User__c, rm.Id);
            }
            
            // Iterate through newRecords and add an error if a duplicate is found
            for (Reporting_Manager__c rm : newRecords) {
                if ((rm.User__c != null && existingUserMap.containsKey(rm.User__c)) || newUserCountMap.get(rm.User__c) > 1) {
                    rm.addError('A Reporting Manager record already exists for this user.');
                }
            }
        }
    }
}