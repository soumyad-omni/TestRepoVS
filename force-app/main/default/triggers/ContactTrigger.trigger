/**********************************************************************
Name:  ContactTrigger
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Contact Object for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Supriya Ambre                     ?       INITIAL DEVELOPMENT
***********************************************************************/
trigger ContactTrigger on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{
    TriggerDispatcher.run(new ContactTriggerHandler());
}