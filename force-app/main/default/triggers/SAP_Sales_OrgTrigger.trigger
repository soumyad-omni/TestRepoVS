/**********************************************************************
Name:  SAP_Sales_OrgTrigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on SAP_Sales_Org__c  for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1             ?                       ?       INITIAL DEVELOPMENT
***********************************************************************/
trigger SAP_Sales_OrgTrigger on SAP_Sales_Org__c  (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
    // Added to prevent trigger from firing when change is due to Overcast inbound data
    //if (!overcast.ObjectMapping.InboundMappingIsRunning) {//Commented by Sourav for Overcast uninstall
      TriggerDispatcher.run(new SAP_Sales_OrgTriggerHandler());
    //}//Commented by Sourav for Overcast uninstall
}