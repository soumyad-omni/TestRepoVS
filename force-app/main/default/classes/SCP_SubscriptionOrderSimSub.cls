/*** 
Class to scheduler the Batch class - SCP_SubsOrderSimulateBatch and SCP_SubscriptionOrderSubmitBatch 
Developer - Subramanyam Gopinath  
***/

global class SCP_SubscriptionOrderSimSub implements Schedulable
{
    global void execute(SchedulableContext sc){
        SCP_SubsOrderSimulateBatch  s = new SCP_SubsOrderSimulateBatch();
        DataBase.executeBatch(s,1);      
    }
}