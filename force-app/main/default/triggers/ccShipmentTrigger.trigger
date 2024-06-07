trigger ccShipmentTrigger on ccrz__E_OrderShipment__c (after insert) {
    
    if(Trigger.isAfter&&Trigger.isInsert){
       ccShipmentTriggerHandler.beforeInsertEve(Trigger.New);
       
   }

}