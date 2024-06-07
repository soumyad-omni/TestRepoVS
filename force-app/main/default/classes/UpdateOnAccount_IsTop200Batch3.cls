/*
Name        : UpdateOnAccount_IsTop200Batch3.apxc
Description : Batch class to update the child account records where the Primary Parent is not in Top200.
CreatedDate : 23-Apr-2018
Version     : 1.0
Author      : Swapnil Nalla
*/

global class UpdateOnAccount_IsTop200Batch3 implements Database.batchable<sObject>, Database.Stateful {
    
    global Database.queryLocator start (Database.BatchableContext BC) {
        String query = 'SELECT Id, Name FROM Account';
        System.debug('UpdateOnAccount_IsTop200Batch3::start::query ' + query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Account> accList) {
        
        if (accList != NULL && !accList.isEmpty()) {
            
            Set<Id> accIds        = new Set<Id>();
            Set<Id> accIdsInTop200= new Set<Id>();
            
            List<Account> accForQuery  = new List<Account>();
            List<Account> accForUpdate = new List<Account> ();
            List<Target_Initiative_Account__c>  top200Accounts = new List<Target_Initiative_Account__c> ();
            
            for (Account acc : accList) {
                accIds.add(acc.Id);
            }
            System.debug('UpdateOnAccount_IsTop200Batch3::execute::accIds ' + accIds);
            if (accIds != NULL && !accIds.isEmpty()) {
                top200Accounts = [SELECT Id, Account__c 
                                  FROM Target_Initiative_Account__c 
                                  WHERE Account__c IN :accIds 
                                  AND Target_Initiative__r.Name = 'Top Accounts'];
                System.debug('UpdateOnAccount_IsTop200Batch3::execute::top200Accounts ' + top200Accounts);
                if (top200Accounts != NULL && !top200Accounts.isEmpty()) {
                    for (Target_Initiative_Account__c tg : top200Accounts) {
                        accIdsInTop200.add(tg.Account__c);
                    }
                }
                
                if (accIdsInTop200 != NULL && !accIdsInTop200.isEmpty()) {
                    accForQuery = [SELECT Id       //IBA-4149
                                   FROM Account WHERE Id IN: accIdsInTop200];
                }
                System.debug('UpdateOnAccount_IsTop200Batch3::execute::accIdsInTop200 ' + accIdsInTop200);
            }
            
            if (accForQuery != NULL && !accForQuery.isEmpty()) {
                for (Account acc : accForQuery) {
                    Account ac = new Account(Id = acc.Id);
                   // IBA-4149  acc.Is_Top_200__c = TRUE;
                    if(!accForUpdate.contains(ac))
                    	accForUpdate.add(acc);
                }
                System.debug('UpdateOnAccount_IsTop200Batch3::execute::accForUpdate ' + accForUpdate);
            }
            
            try {
                if (accForUpdate != NULL && !accForUpdate.isEmpty()) {
                    Database.update(accForUpdate,false);
                    System.debug('UpdateOnAccount_IsTop200Batch3::execute::AccountsAreUpdated');
                }
            } catch (Exception e) {
                
            }
        }
    }
    
    global void finish (Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Is Top 200: Child Account Update ' + a.Status);
        mail.setPlainTextBody
            ('The batch job processed ' + a.TotalJobItems +
             ' and updated the Child accounts accordingly.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //added 12-04
        /*UpdateChildAccountsHiearchyBatch_2 schedule = new UpdateChildAccountsHiearchyBatch_2();
        database.executeBatch(schedule, 5);*/
    }
}