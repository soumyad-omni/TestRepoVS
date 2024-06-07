/**********************************************************************
Name: ITriggerHandler
Copyright © 2017
======================================================
======================================================
Purpose: Interface which contains various event methods related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR           DATE             DETAIL               Description
 
 0.1        	?        		?           Created by CG Team      Interface for trigger events as part of Trigger frammework
***********************************************************************/
public interface ITriggerHandler {
    void beforeInsert(List<SObject> newItems);
    void beforeDelete(Map<Id, SObject> oldItems);
    void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems);
	void afterInsert(Map<Id, SObject> newItems);
    void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems);
    void afterDelete(Map<Id, SObject> oldItems);
    void afterUndelete(Map<Id, SObject> oldItems);
    boolean IsDisabled();
}