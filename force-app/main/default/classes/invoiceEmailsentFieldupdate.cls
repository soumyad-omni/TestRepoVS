global class invoiceEmailsentFieldupdate implements Database.Batchable<SObject>{
    
    global Database.queryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('Select id,ccrz__Contact__c,EmailSent__c from ccrz__E_Invoice__c where EmailSent__c=false');
    }
    
    global void execute (Database.BatchableContext BC, List<ccrz__E_Invoice__c> invList){
       
        for( ccrz__E_Invoice__c inv  :invList){
               inv.EmailSent__c = true;
        }
        
        update invList;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    
}