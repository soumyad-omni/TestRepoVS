/**********************************************************************
Name:  ScheduleUpdateAccounts_Controller
Copyright © 2018
======================================================
======================================================
Purpose: 
Controller for Lightning Component "ScheduleAccountUpdateComponent.cmp", 
on click of lightning button Batch Scheduler will be scheduled

======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          6/8/2018 	Developed by CG Team    INITIAL DEVELOPMENT
***********************************************************************/
public class ScheduleUpdateAccounts_Controller {
    @AuraEnabled
    public static String scheduleBatch(String sec, String min, String hr, String da, String mn, String yr, String recId){     
        String second = String.valueOf(sec);
        String minute = String.valueOf(min);
        String hour = String.valueOf(hr);
        String day = String.valueOf(da);
        String month = String.valueOf(mn);		
        String year = String.valueOf(yr);
        
        String nextFireTime = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.Debug('nextFireTime : '+nextFireTime);
        try{
            //system.schedule('IsTop200_BatchSchedule_ ' + System.Now(), nextFireTime , new UpdateOnAccount_IsTop200Batch_Schedule());
            //UpdateChildAccountsHiearchyBatch_2 schedule2 = new UpdateChildAccountsHiearchyBatch_2();
            List<Target_Initiative__c> targetList = [Select Id, Name,Use_for_segmentation__c from Target_Initiative__c 
                                                     where Use_for_segmentation__c = true and 
                                                     Type_of_account_propagation__c = 'Apply to account and all child accounts'];
            BCH_UpdateIsDeletedFromTopAccounts updateAccountBatchable = new BCH_UpdateIsDeletedFromTopAccounts();
            updateAccountBatchable.tarAccId = recId;
            updateAccountBatchable.targetList = targetList;
            Database.executeBatch(updateAccountBatchable, 30);  
            //BCH_UpdateTopFlagAsFalseInAccount updateAccountBatchable = new BCH_UpdateTopFlagAsFalseInAccount();
            //updateAccountBatchable.tarAccId = recId;
           // Database.executeBatch(updateAccountBatchable, 1);
            
           // UpdateParentAndChildHierarchy schedule2 = new UpdateParentAndChildHierarchy(recId);
           // database.executeBatch(schedule2, 1);
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'ScheduleUpdateAccounts_Controller','App');
            return null;
        }
        return nextFireTime;
    }
    
}