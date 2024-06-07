global class BatchToDeleteDealModelPDF implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT ID FROM Deal_Modeling_PDF__c');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){ }
}