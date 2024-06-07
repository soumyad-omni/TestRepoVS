global class briefingEdgeToTaskCreate_BatchSchedule implements Schedulable {
   global void execute(SchedulableContext SC) {
       briefingEdgeToTaskCreate_Batch b = new briefingEdgeToTaskCreate_Batch();
       database.executeBatch(b, 1);
   }
}