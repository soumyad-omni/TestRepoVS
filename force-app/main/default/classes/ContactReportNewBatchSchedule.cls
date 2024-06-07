global class ContactReportNewBatchSchedule implements Schedulable{

   global void execute(SchedulableContext sc){        
 
  	contactwhereusednewbatch b = new contactwhereusednewbatch();
    database.executeBatch(b);
   }    

}