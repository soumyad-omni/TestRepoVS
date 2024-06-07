/*********************************************************************
Name:      MachineTriggerHandler
Purpose:   Customize the transaction on Machines records
Copyright © 2023
=======================================================================
History :
-----------------------------------------------------------------------
Developer                  Date                Description
-------------------------------------------------------------- --------
Sourav  Das              5/16/2023         Initial Creation
************************************************************************/

public class MachineTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
	public boolean isDisabled;
    
    public boolean IsDisabled(){        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('MachineTriggerDisabled');
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
        List<Machine__c> newmachines = newItems.values();
        List<ccrz__E_Attribute__c> ccAttributeToInsert = new List<ccrz__E_Attribute__c>();
        //get Parent attribute for machine
        ccrz__E_Attribute__c parenAttr = [Select Id From  ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE' Limit 1];
        //get the last sequence number
        Decimal lastSeq = [Select Id,ccrz__Sequence__c  From ccrz__E_Attribute__c Where ccrz__ParentAttribute__c =:parenAttr.Id Order By 
                           ccrz__Sequence__c Desc Limit 1].ccrz__Sequence__c;
        
        Integer seq = (Integer)lastSeq;
        for(Machine__c machine:newmachines){
            ccAttributeToInsert.add(createNewAttribute(machine.Machine_Name__c ,parenAttr.Id,seq));  
            seq += 1;
        }
        insert ccAttributeToInsert;
    }
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Machine__c> newmachines = newItems.values();
        Map<Id,Machine__c> oldMachineMap = (Map<Id,Machine__c>)oldItems;
        List<ccrz__E_Attribute__c> ccAttributeToUpsertInsert = new List<ccrz__E_Attribute__c>();
        Set<String> allChangedmachines = new Set<String>();
        Set<String> allOldMachines = new Set<String>();
        Map<String,String> oldNewMap = new Map<String,String>();
        
        for(Machine__c machine:newmachines){
            if(machine.Machine_Name__c != oldMachineMap.get(machine.Id).Machine_Name__c){
                allChangedmachines.add(machine.Machine_Name__c);
                allOldMachines.add(oldMachineMap.get(machine.Id).Machine_Name__c);
                oldNewMap.put(oldMachineMap.get(machine.Id).Machine_Name__c, machine.Machine_Name__c);
            }
        }
        
        List<ccrz__E_Attribute__c> allOldccAttributes = [Select Id,ccrz__AttributeID__c,Name,ccrz__DisplayName__c From ccrz__E_Attribute__c Where ccrz__AttributeID__c IN :allOldMachines];
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
	
    public static ccrz__E_Attribute__c createNewAttribute(String machineName, String paretAttrId, Integer seq){
        ccrz__E_Attribute__c ccAttr = new ccrz__E_Attribute__c();
        ccAttr.Name = machineName;
        ccAttr.ccrz__AttributeID__c = machineName;
        ccAttr.ccrz__DisplayName__c = machineName;
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