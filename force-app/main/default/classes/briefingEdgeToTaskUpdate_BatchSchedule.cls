global class briefingEdgeToTaskUpdate_BatchSchedule implements Schedulable{
	global void execute(SchedulableContext SC) {
       briefingEdgeToTaskUpdate_Batch b = new briefingEdgeToTaskUpdate_Batch();
       database.executeBatch(b, 1);
   }
}