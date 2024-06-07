/*** 
Class to scheduler the Batch class - SCP_SubscriptionOrderSubmitBatch 
Developer - Subramanyam Gopinath  
***/

global class SCP_SubscriptionOrderSubmitScheduler implements Schedulable
{
    global void execute(SchedulableContext sc){
        SCP_SubscriptionOrderSubmitBatch b = new SCP_SubscriptionOrderSubmitBatch(); 
        database.executebatch(b);
    }
}