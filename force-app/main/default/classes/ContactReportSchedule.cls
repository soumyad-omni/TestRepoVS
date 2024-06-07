global class ContactReportSchedule implements Schedulable{

   global void execute(SchedulableContext sc){        
 
  	contactReportBatch b = new contactReportBatch();
    database.executeBatch(b);
   }    

}