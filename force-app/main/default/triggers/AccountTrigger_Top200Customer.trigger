trigger AccountTrigger_Top200Customer on Account (after insert, before update) {
   // Trigger_Configuration__c tc = Trigger_Configuration__c.getValues('AccountTriggerDisabled');    
    
    /*public boolean isDisabled;
    Trigger_Configuration__c tc = Trigger_Configuration__c.getValues('AccountTrigger_Top200CustomerDisabled');    
    if(tc!= null) 
    isDisabled = tc.isDisabled__c;
    
    if(isDisabled ==FALSE){
        if(Trigger.IsAfter && Trigger.isInsert){
            // AccountTriggerHandler_Top200CustomerAsyn.handleAfterInsert(Trigger.NewMap.keySet());
            
            AccountTriggerHandler_Top200Customer.handleAfterInsert(Trigger.NewMap.keySet());
        }
        if(Trigger.IsBefore && (trigger.IsInsert)){
            AccountTriggerHandler_Top200Customer.handleBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
        } else if (Trigger.IsBefore && (Trigger.isUpdate)) {
            AccountTriggerHandler_Top200Customer.handleBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
            //UpdateOnAdditionOfParnetAccount.handleUpdateBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }*/
}