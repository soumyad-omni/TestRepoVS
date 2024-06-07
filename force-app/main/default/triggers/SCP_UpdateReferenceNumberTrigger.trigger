trigger SCP_UpdateReferenceNumberTrigger on ccrz__E_Order__c (Before Insert,After Insert,after update) {
    if(Trigger.isInsert&&Trigger.isBefore){
        
        set<id> cids = new set<id>();
        for(ccrz__E_Order__c ord: trigger.new){
            
              cids.add(ord.ccrz__OriginatedCart__c);                           
        }
        
        if(cids.size()>0){
         
        list<ccrz__E_Cart__c> carts = [select Id,Reference_Number__c from ccrz__E_Cart__c where Id IN:cids  
                                        AND  Reference_Number__c != null ]; 
        
        if(carts.size()>0){
        
        for(ccrz__E_Order__c orderObj : Trigger.new){
           
            orderObj.Reference_Number__c  = [select Id,Reference_Number__c from ccrz__E_Cart__c where Id= :orderObj.ccrz__OriginatedCart__c LIMIT 1].Reference_Number__c ;
        }
        }
        SCP_OrderTriggerHandler.beforeInsertEvent(Trigger.New);         
        } 
        SCP_OrderTriggerHandler.mapFieldsToChildOrder(Trigger.New); 
    }
    if(Trigger.isInsert &&Trigger.isAfter){ 
        SCP_OrderTriggerHandler.CloneTPtoChildOrder(Trigger.New);
        //SCP_OrderTriggerHandler.updateMachinePurchasedCount(Trigger.newMap); 
     }
     
    if(Trigger.isUpdate&&Trigger.isAfter){ 
        SCP_OrderTriggerHandler.NotificationOnOrderFail(Trigger.newMap, Trigger.oldMap);
        SCP_OrderTriggerHandler.updateTransactionAmount(Trigger.newMap, Trigger.oldMap);
        
        SCP_OrderTriggerHandler.sendMailForMissingDrugCode(Trigger.newMap, Trigger.oldMap);
    } 
    if(Trigger.isUpdate&&Trigger.isBefore){
        
    }
    //Commenting code logic for Updating Bill to and Ship to on Order from Cart.
    /*if(Trigger.isAfter&&Trigger.isInsert){
       SCP_OrderTriggerHandler.AfterInsertEvent(Trigger.New,Trigger.NewMap);
    }*/
}