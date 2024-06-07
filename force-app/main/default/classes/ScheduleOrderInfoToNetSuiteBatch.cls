global class ScheduleOrderInfoToNetSuiteBatch implements Schedulable{//IBA-4831
    global void execute(SchedulableContext ctx) {
        OrderInfoToNetSuiteBatchForQuote netsuiteQuote = new OrderInfoToNetSuiteBatchForQuote();
        Database.executeBatch(netsuiteQuote);
    }
}