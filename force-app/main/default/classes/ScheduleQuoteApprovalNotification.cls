global class ScheduleQuoteApprovalNotification implements Schedulable {
   global void execute(SchedulableContext SC) {
       QuoteApprovalProcessTriggerNotification qapt = new QuoteApprovalProcessTriggerNotification();
       database.executeBatch(qapt);
       system.schedule('Quote Approval Notification', '0 0 23 * * ?', new ScheduleQuoteApprovalNotification());
   }
}