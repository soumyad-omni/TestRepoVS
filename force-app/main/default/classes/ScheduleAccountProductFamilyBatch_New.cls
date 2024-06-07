global class ScheduleAccountProductFamilyBatch_New implements Schedulable {
   global void execute(SchedulableContext SC) {
       AccountProductLine_DELETE_Batch b = new AccountProductLine_DELETE_Batch();
       database.executeBatch(b, 200);
   }
}