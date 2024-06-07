/* 
  Description: Schedule class for OmnicellOrderInfoBatch
  Author: Aravind 
*/
global class OmnicellOrderInfoBatch_Sch implements Schedulable {
        global void execute(SchedulableContext sc) {
         OmnicellOrderInfoBatch orderBatch = new OmnicellOrderInfoBatch(); 
         DataBase.executeBatch(orderBatch, 200);
        }
        
}