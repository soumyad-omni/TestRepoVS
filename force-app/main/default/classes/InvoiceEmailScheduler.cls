global class InvoiceEmailScheduler implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        InvoiceEmailScheduler_batch b = new InvoiceEmailScheduler_batch();
        database.executeBatch(b,integer.valueof(label.InvoiceEmailBatchSize));
    }
    
}