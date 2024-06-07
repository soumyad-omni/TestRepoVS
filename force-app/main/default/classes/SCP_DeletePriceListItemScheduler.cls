/*** 
Class to scheduler the Batch class - SCP_DeletePriceListItemBatch
Developer - Subramanyam Gopinath  
***/

global class SCP_DeletePriceListItemScheduler implements Schedulable
{
    global void execute(SchedulableContext sc){
        SCP_DeletePriceListItemBatch b = new SCP_DeletePriceListItemBatch(); 
        database.executebatch(b);
    }
}