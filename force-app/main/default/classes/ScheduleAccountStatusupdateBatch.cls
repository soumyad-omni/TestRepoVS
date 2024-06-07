global class ScheduleAccountStatusupdateBatch implements Schedulable {
	global void execute(SchedulableContext SC) {
       AccountStatusupdateBatch a = new AccountStatusupdateBatch();
       database.executeBatch(a,50);
   }
}