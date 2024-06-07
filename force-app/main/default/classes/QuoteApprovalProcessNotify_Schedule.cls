/**********************************************************************
Name:  QuoteApprovalProcessNotify_Schedule 
Copyright © 2017
======================================================
======================================================
Purpose: Scheduler for QuoteApprovalProcessTriggerNotification
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL               Description
0.1          Supriya Ambre          8/20/2018         INITIAL DEVELOPMENT   Scheduler for QuoteApprovalProcessNotify_Schedule
***********************************************************************/

global class QuoteApprovalProcessNotify_Schedule implements Schedulable {
  
    global void execute(SchedulableContext sc) {
        QuoteApprovalProcessTriggerNotification b = new QuoteApprovalProcessTriggerNotification(); 
        database.executebatch(b);
   
    }
}