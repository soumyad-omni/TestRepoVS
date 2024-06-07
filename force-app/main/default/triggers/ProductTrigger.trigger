trigger ProductTrigger on Product2 (before update) {
	if(Trigger.isUpdate&&Trigger.isBefore){ 
        ProductTriggerHandler.beforeupdatemethod(Trigger.newMap, Trigger.oldMap);
        
    } 
}