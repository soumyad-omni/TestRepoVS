/**********************************************************************
Name:  QuoteLineAssetTriggerHandler
======================================================
======================================================                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sahid Hussain            4/25/2022       INITIAL DEVELOPMENT
***********************************************************************/
public class QuoteLineAssetTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('QuoteLineAssetTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
        
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems) {
        List<Quote_Line_Assests__c> newQLAdata = newItems;
        List<C4C_Assets__c> listAssets = new List<C4C_Assets__c>();
        List<Quote_Line_Assests__c> existingrecrods = new List<Quote_Line_Assests__c>();
        Set<String> uniqId = new Set<String>();
        set<String> uniqueIdSet2 = new set<String>();
        String accid;
        String qlid;
        for(Quote_Line_Assests__c qla: newQLAdata) {
            uniqId.add(qla.Unique_ID2__c);
            accid = qla.AccountID__c;
            qlid = qla.Quote_Line__c;
        }
        //system.debug('test...qlid: ' +qlid);
        //system.debug('Acc...' +accId);
        listAssets = [Select id,Name,Unique_ID__c from C4C_Assets__c where Account__c =:accId AND Unique_ID__c IN:uniqId];
        existingrecrods = [Select id,Quote_Line__c,Unique_ID2__c,Assets__c from Quote_Line_Assests__c where Quote_Line__c =: qlid];
        //System.debug('size..' +listAssets.size());
        //System.debug('existingrecrods..size..' +existingrecrods.size());
        
        if(existingrecrods != Null) {
            for(Quote_Line_Assests__c qla: existingrecrods) {
                uniqueIdSet2.add(qla.Unique_ID2__c);
            }                
        }
        
        for(Quote_Line_Assests__c qla2: newQLAdata) {
            if(uniqueIdSet2.contains(qla2.Unique_ID2__c)){
                qla2.Assets__c.addError('Relationship already Exist');
            }else if(listAssets.size() == 0){
                qla2.Assets__c.addError('Unique ID does not Exist');
            }
        }
    }
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){}
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){}
    
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){}
    
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
    
}