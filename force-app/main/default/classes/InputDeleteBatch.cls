global class InputDeleteBatch implements Database.Batchable<sObject> {
    private Integer keepDays = 5;
    private String queryString;
    private String objectName;
    
    global InputDeleteBatch(String objName) {
        this.objectName = objName;
        /*overcast__EpgwSettings__c settings = overcast__EpgwSettings__c.getInstance('LogKeepDays');
        if (settings != null) {
            String val = settings.overcast__Value__c;
            try {
                this.keepDays = Integer.valueOf(val);
            } catch(TypeException e) {
                System.debug('Type exception: ' + val);
            }
        }*///Commented by Sourav for Overcast uninstall
        System.debug('KeepDays: ' + this.keepDays);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime dt = DateTime.now().addDays(this.keepDays * -1);
        queryString = 'SELECT Id FROM ' + this.objectName + ' WHERE CreatedDate <= :dt';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<sObject> records) {
        Database.DeleteResult[] result = Database.delete(records, false);

        //Error logging to system.debug
        for(Database.DeleteResult dr : result) {
            if (!dr.isSuccess()) {
                for(Database.Error err : dr.getErrors()) {           
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}