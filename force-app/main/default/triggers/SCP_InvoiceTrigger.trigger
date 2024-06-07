trigger SCP_InvoiceTrigger on ccrz__E_Invoice__c (After Insert) {

   if(Trigger.isAfter&&Trigger.isInsert){
       SCP_InvoiceTriggerHandler.processAfterInsertEvent(Trigger.New,Trigger.NewMap);
       
   }

}