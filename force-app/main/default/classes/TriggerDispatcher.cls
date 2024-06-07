/**********************************************************************
Name:  TriggerDispatcher
Copyright © 2018
======================================================
======================================================
Purpose: Trigger Dispatcher class for trigger Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Venu Kukkapalli       		?    	INITIAL DEVELOPMENT
***********************************************************************/
public class TriggerDispatcher {
    public static void run(ITriggerHandler handler){
        
        // Check to see if trigger had been disabled, if so return
       	if(handler.isDisabled())
        	return ;
        
        // Detect the current trigger context and fire the relevant methods
        // Before Trigger Logic
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                handler.beforeInsert(trigger.new);
            }
            if(Trigger.isUpdate){
                handler.beforeUpdate(trigger.oldMap,trigger.newMap);
            }
            if(Trigger.isDelete){
                handler.beforeDelete(trigger.oldMap);
            }
        }
        
        // After Trigger Logic
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                handler.afterInsert(trigger.newMap);
            }
            if(Trigger.isUpdate){
                handler.afterUpdate(trigger.oldMap,trigger.newMap);
            }
            if(Trigger.isDelete){
                handler.afterDelete(trigger.oldMap);
            }
            if(Trigger.isUndelete){
                handler.afterUndelete(trigger.oldMap);
            }
        }
    }
}