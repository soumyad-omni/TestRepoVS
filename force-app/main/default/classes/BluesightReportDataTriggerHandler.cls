public class BluesightReportDataTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public BluesightReportDataTriggerHandler(){
        
    }
    public boolean IsDisabled(){
        boolean isDisabled;
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('BluesightReportDataTriggerDisable');
        if(tc != null) 
            isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled; 
    }
    
    public void afterInsert(Map<Id, SObject> newItems){}
    public void beforeDelete(Map<Id, SObject> oldItems){}
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){}
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){}
    public void afterDelete(Map<Id, SObject> oldItems){}
    public void afterUndelete(Map<Id, SObject> oldItems){}
    
    public void beforeInsert(List<SObject> newItems){
        Set<String> acctNumbers=new Set<String>();  
        Map<String,Id> acctIdNoMap=new Map<String,Id>();
        List<Bluesight_Report_Data__c> ExNewData = newItems;
        for(Bluesight_Report_Data__c ex : ExNewData){
            if(ex.Account_Number__c != null){
                acctNumbers.add(ex.Account_Number__c);
            }
        }
        System.debug('acctNumbers '+acctNumbers);
        List<Account> acctList = [Select Id,SAP_Account_Id__c from Account where SAP_Account_Id__c IN: acctNumbers];     
        for(Account acct:acctList){ 
            acctIdNoMap.put(acct.SAP_Account_Id__c,acct.Id);
        }
        
        System.debug('acctIdNoMap'+acctIdNoMap);
        
        for(Bluesight_Report_Data__c ex : ExNewData){
            if(ex.Account_Number__c != null){
                Id acctId=acctIdNoMap.get(ex.Account_Number__c);
                ex.AccountId__c=acctId;
            }  
        } 
    }//
}