/***********************************************************************************************************
Name:  ScheduleAcctSegmentUpdate 
Copyright © 2021
============================================================================================================
============================================================================================================
Purpose: 
IBA-1911: The Scheduler calls ScheduleAcctSegmentUpdate batch to update Account Segment field on Accout create/update

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Pabitra Tripathy          08/25/2021        
*************************************************************************************************************/
global class ScheduleAcctSegmentUpdate implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        List<Target_Initiative__c> trgtIniList = [Select Id, Name,Use_for_segmentation__c from Target_Initiative__c 
                                                     where Use_for_segmentation__c = true and 
                                                     Type_of_account_propagation__c = 'Apply to account and all child accounts'];
        
        BCH_UpdateIsDeletedFromTopAccounts segmentUptBatch=new BCH_UpdateIsDeletedFromTopAccounts();
        segmentUptBatch.targetList = trgtIniList;
        Database.executeBatch(segmentUptBatch,30);
    }
}