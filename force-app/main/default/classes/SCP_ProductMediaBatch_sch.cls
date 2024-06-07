global with sharing class SCP_ProductMediaBatch_sch Implements Schedulable
{
    global void execute(SchedulableContext dc)
    {
        SCP_ProductMediaBatch btchcls =new SCP_ProductMediaBatch();
        Database.executeBatch(btchcls);
    }
}