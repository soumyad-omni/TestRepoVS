global class contactReportBatch implements Database.Batchable<sobject> {
   
   global Database.Querylocator start (Database.BatchableContext BC) {
      return Database.getQueryLocator('SELECT id FROM ContactWhereUsed__c');
   }
   
   
   global void execute (Database.BatchableContext BC, List<ContactWhereUsed__c> scope) {
      delete scope;
   }
   
   
   global void finish(Database.BatchableContext BC) {
      contactReportBatch_WS b = new contactReportBatch_WS();
      database.executeBatch(b);
   }
}