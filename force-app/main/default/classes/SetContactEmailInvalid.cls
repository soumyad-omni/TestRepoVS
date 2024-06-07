/*
1. Run the batch from Anonymous window 
Id batchJobId = Database.executeBatch(new SetContactEmailInvalid(), 200);
2. After batch completion - run the query (result should be zero) to make sure no more email id left behind  
SELECT Id, email FROM Contact WHERE NOT email  LIKE '%invalid'
*/
//==========================================================================================
//This class appends .invalid for each email id from all Contact
//==========================================================================================
global class SetContactEmailInvalid implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, email FROM Contact WHERE NOT email LIKE \'%invalid\'');
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts){
        for(Contact c : contacts) {
            c.email = c.email + '.invalid';
        }
        ContactTriggerHandler.TriggerDisabled = true;
        Database.update(contacts,false);
    }
    
    global void finish(Database.BatchableContext BC){
    }
}