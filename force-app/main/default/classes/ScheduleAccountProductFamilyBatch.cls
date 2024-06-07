global class ScheduleAccountProductFamilyBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
       AccountProductLine_Batch b = new AccountProductLine_Batch();
       database.executeBatch(b, 1);
   }
}