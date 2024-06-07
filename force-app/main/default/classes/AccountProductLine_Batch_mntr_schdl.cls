global class AccountProductLine_Batch_mntr_schdl implements Schedulable {
    global void execute(SchedulableContext ctx) {
        // test
		// SendJobNotification s = new SendJobNotification('AccountProductLine', 240);
        SendJobNotification s = new SendJobNotification('AccountProductLine', 1440);
        s.checkTimeAndSendMail();
		
		system.debug('AccountProductLine_Batch_mntr_schdl :: job done at :: ' + Datetime.now());
   }

}