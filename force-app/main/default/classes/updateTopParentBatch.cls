Global class updateTopParentBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, ParentId,BillingCountry FROM Account where (Top_level_1__c = null OR Top_Level_Parent_CSN_Number__c = null)'; 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){ 
        List<Account> accList=new List<Account>();
        
        for(Account acc:scope){            
            accList.add(acc);
        }
        
        Database.update(accList,false);
    }  
    
    global void finish(Database.BatchableContext BC){}
}