global class ScheduleIdentifyOudatedProductsBatch implements Schedulable {
   global void execute(SchedulableContext SC) {
       IdentifyOutdatedProducts_Batch b = new IdentifyOutdatedProducts_Batch();
       database.executeBatch(b, 200);
   }
}