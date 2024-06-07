global class SCP_DeleteApexLogScheduler implements Schedulable
{
    global void execute(SchedulableContext sc){
        SCP_DeleteApexLogBatch b = new SCP_DeleteApexLogBatch(); 
        database.executebatch(b);
    }
}