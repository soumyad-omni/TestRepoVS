/**********************************************************************
Name:  ContractContentDocumentLink
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on ContentDocument Object for various events related to trigger
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sravan Kumar                     ?       INITIAL DEVELOPMENT
***********************************************************************/
trigger ContractContentDocumentLink on ContentDocumentLink (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
   TriggerDispatcher.run(new ContentDocLinkTriggerHandler());

}