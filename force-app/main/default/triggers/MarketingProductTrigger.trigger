/**********************************************************************
Name:  MarketingProductTrigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Marketing Product Object for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sravan Kumar                     ?       INITIAL DEVELOPMENT
***********************************************************************/

trigger MarketingProductTrigger on Marketing_Product__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    TriggerDispatcher.run(new MarketingProductTriggerHandler()); 
}