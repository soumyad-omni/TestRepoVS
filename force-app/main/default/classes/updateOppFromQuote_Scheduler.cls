global class updateOppFromQuote_Scheduler implements schedulable{
    
    global void execute(schedulablecontext sc){
        updateOppFromQuote b= new updateOppFromQuote();
		database.executeBatch(b);
    }

}