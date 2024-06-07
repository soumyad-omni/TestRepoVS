trigger SCP_OrderItemTrig on ccrz__E_OrderItem__c (before insert,before update,after insert) {
    
    SCP_OrderItemTriggerHandler orderItemHandler = new SCP_OrderItemTriggerHandler();

	if ((Trigger.isInsert) && (Trigger.isBefore))
		orderItemHandler.beforeInsertMethod(Trigger.New);

    if ((Trigger.isUpdate) && (Trigger.isBefore))
		orderItemHandler.beforeUpdateMethod(Trigger.New);
    
    if((Trigger.isInsert) && (Trigger.isAfter)){
        System.debug('****+AfterInsert');
        orderItemHandler.afterInsertMethod(Trigger.newMap);
    }
}