/**********************************************************************

Name:  ProductLineTrigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Product Line Object for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Supriya Ambre          10/17/2018       INITIAL DEVELOPMENT
**********************************************************************/


trigger ProductLineTrigger on Product_Line__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {


    TriggerDispatcher.run(new ProductLineTriggerHandler());

}