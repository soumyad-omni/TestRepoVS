Global class ScheduleQuoteStatusUpdateBatch implements Schedulable{//IBA-4438 [To Schedule QuoteStatusUpdateBatch_Opps batch class]
    global void execute(SchedulableContext SC) {
        QuoteStatusUpdateBatch_Opps qtupdate = new QuoteStatusUpdateBatch_Opps();
        database.executeBatch(qtupdate,200);
    }
}