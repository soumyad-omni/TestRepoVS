/*********************************************************************
Name:      DrugCodeTriggerHandler
Purpose:   Customize the transaction on Drug Codes records
Copyright © 2023
=======================================================================
History :
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Sourav  Das              5/16/2023         Initial Creation
************************************************************************/
public class DrugCodeTriggerHandler implements ITriggerHandler{
    
    public static boolean TriggerDisabled= false;
	public boolean isDisabled;
    
    public boolean IsDisabled(){        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('DrugCodeTriggerDisabled');
        if(tc != null) isDisabled = tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){}
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newItems){}
    
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        List<DrugCode__c> newDrugCodes = newItems.values();
        List<ccrz__E_Attribute__c> cAttributeToInsert = new List<ccrz__E_Attribute__c>();
        //get Parent attribute for NDC
        ccrz__E_Attribute__c parenAttr = [Select Id From  ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC' Limit 1];
        //get the last sequence number
        Decimal lastSeq = [Select Id,ccrz__Sequence__c  From ccrz__E_Attribute__c Where ccrz__ParentAttribute__c =:parenAttr.Id Order By 
                           ccrz__Sequence__c Desc Limit 1].ccrz__Sequence__c;
              
        Integer seq = (Integer)lastSeq;
        for(DrugCode__c drg:newDrugCodes){
            cAttributeToInsert.add(createNewAttribute(drg.DrugCodes__c,parenAttr.Id,seq));  
            seq += 1;
        }
        insert cAttributeToInsert;
    }
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<DrugCode__c> newDrugCodes = newItems.values();
        Map<Id,DrugCode__c> oldDrugMap = (Map<Id,DrugCode__c>)oldItems;
        List<ccrz__E_Attribute__c> ccAttributeToUpsertInsert = new List<ccrz__E_Attribute__c>();
        Set<String> allChangedDrugCodes = new Set<String>();
        Set<String> allOldDrugCodes = new Set<String>();
        Map<String,String> oldNewMap = new Map<String,String>();
        
        for(DrugCode__c drg:newDrugCodes){
            if(drg.DrugCodes__c != oldDrugMap.get(drg.Id).DrugCodes__c){
                allChangedDrugCodes.add(drg.DrugCodes__c);
                allOldDrugCodes.add(oldDrugMap.get(drg.Id).DrugCodes__c);
                oldNewMap.put(oldDrugMap.get(drg.Id).DrugCodes__c, drg.DrugCodes__c);
            }
        }
        
        List<ccrz__E_Attribute__c> allOldccAttributes = [Select Id,ccrz__AttributeID__c,Name,ccrz__DisplayName__c From ccrz__E_Attribute__c Where ccrz__AttributeID__c IN :allOldDrugCodes];
        for(ccrz__E_Attribute__c ccAttr:allOldccAttributes){
            updateCCAttribute(ccAttr,oldNewMap.get(ccAttr.ccrz__AttributeID__c));
        }
        update allOldccAttributes;
    }
        
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){}
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){}
    
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){}    
    
    public static ccrz__E_Attribute__c createNewAttribute(String drugCode, String paretAttrId, Integer seq){
        ccrz__E_Attribute__c ccAttr = new ccrz__E_Attribute__c();
        ccAttr.Name = drugCode;
        ccAttr.ccrz__AttributeID__c = drugCode;
        ccAttr.ccrz__DisplayName__c = drugCode;
        ccAttr.ccrz__ParentAttribute__c = paretAttrId;
        ccAttr.ccrz__EffectiveStart__c = System.today();
        ccAttr.ccrz__EffectiveEnd__c = System.today()+10000;
        ccAttr.ccrz__Sequence__c = seq;
        return ccAttr;
    }
    
    public static void updateCCAttribute(ccrz__E_Attribute__c ccAtrToUpdtae, String newValue){
        ccAtrToUpdtae.Name = newValue;
        ccAtrToUpdtae.ccrz__AttributeID__c = newValue;
        ccAtrToUpdtae.ccrz__DisplayName__c = newValue;
    }
}