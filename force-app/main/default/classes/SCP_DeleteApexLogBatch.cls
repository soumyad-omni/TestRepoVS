global class SCP_DeleteApexLogBatch implements Database.Batchable<sObject>{

    
    // Start Method to fetch the Apex Debug Log records
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'select id,name,CreatedDate from SCP_Apex_Debug_Logs__c where CreatedDate <= LAST_N_MONTHS:6';//keep it TODAY for testing purpose
        return Database.getQueryLocator(query);
    }  
  
    global void execute(Database.BatchableContext BC, List<SCP_Apex_Debug_Logs__c> scope){
          if(scope.size()>0)
            delete scope; 
    }
 
    global void finish(Database.BatchableContext BC){
        
    }
}