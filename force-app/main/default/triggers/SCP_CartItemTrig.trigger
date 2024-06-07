trigger SCP_CartItemTrig on ccrz__E_CartItem__c (before insert,before update) {
    
    SCP_CartItemTriggerHandler cartItemHandler = new SCP_CartItemTriggerHandler();

	if ((Trigger.isInsert) && (Trigger.isBefore))
		cartItemHandler.beforeInsertMethod(Trigger.New);

    if ((Trigger.isUpdate) && (Trigger.isBefore))
		cartItemHandler.beforeUpdateMethod(Trigger.New);

}