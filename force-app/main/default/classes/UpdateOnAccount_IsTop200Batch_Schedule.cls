global class UpdateOnAccount_IsTop200Batch_Schedule implements Schedulable {
    global void execute (SchedulableContext SC) {
        //UpdateOnAccount_IsTop200Batch schedule = new UpdateOnAccount_IsTop200Batch();
        //database.executeBatch(schedule, 2000);
        
        //UpdateOnAccount_IsTop200Batch2 schdeule2 = new UpdateOnAccount_IsTop200Batch2();
        //database.executeBatch(schdeule2, 2000);
        
        //UpdateOnAccount_IsTop200Batch3 schedule3 = new UpdateOnAccount_IsTop200Batch3();
        //database.executeBatch(schedule3, 2000);
        
        UpdateChildAccountsHiearchyBatch_2 schedule2 = new UpdateChildAccountsHiearchyBatch_2();
        database.executeBatch(schedule2, 1);
    }
}