global class AcctSendAllContactsToCastIron_mntr_schdl implements Schedulable {
    global void execute(SchedulableContext ctx) {
		SendJobNotification s = new SendJobNotification('AcctSendAllContactsToCastIron', 240);
        s.checkTimeAndSendMail();
		
		system.debug('AcctSendAllContactsToCastIron_mntr_schdl :: job done at :: ' + Datetime.now());
   }

}