/*
ProjectProductMappingBatch_Scheduler obj = new ProjectProductMappingBatch_Scheduler();
String cron = '0 0 0,2,4,6,8,10,12,14,16,18,20,22  * * ?';
System.schedule('ProjectProductMappingBatch_Scheduler job', cron, obj);
*/
global class ProjectProductMappingBatch_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ProjectProductMappingBatch b = new ProjectProductMappingBatch();
        Database.executeBatch(b,100);
    }
}