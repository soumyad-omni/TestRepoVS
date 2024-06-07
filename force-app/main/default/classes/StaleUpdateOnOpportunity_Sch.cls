//This is to schedule StaleUpdateatOpportunity_Batch for 1 day time interval.. morning 12:00 AM PST
global class StaleUpdateOnOpportunity_Sch implements Schedulable {
    global void execute(SchedulableContext sc) {
        StaleUpdateatOpportunity_Batch staleBatch = new StaleUpdateatOpportunity_Batch(); 
        DataBase.executeBatch(staleBatch, 1);
    }
}