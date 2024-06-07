global class BatchKlarityDataUploadSchedulerApex implements Schedulable {
    global void execute(SchedulableContext ctx) {
        BatchKlarityDataUpload batch = new BatchKlarityDataUpload();
        database.executebatch(batch,Integer.ValueOf(Label.KlarityUploadBatchSize)); //IBA-5326 SH added batch size using a Custom label 
    }
}