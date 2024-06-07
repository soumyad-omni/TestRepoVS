/**********************************************************************
Name:  Task_Trigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Task to check Task_Assigned checkbox true on CampaignMember Record
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Supriya  Ambre           11/06/2018       INITIAL DEVELOPMENT
***********************************************************************/


trigger TaskTrigger on Task (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     TriggerDispatcher.run(new TaskTriggerHandler());
}