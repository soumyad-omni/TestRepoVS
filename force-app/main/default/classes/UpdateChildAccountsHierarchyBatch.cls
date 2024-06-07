/*
*Name       : UpdateChildAccountsHierarchyBatch
*Author     : Swapnil R
*Description: Apex class to update all the accounts in a account hiearchy where the parent account is in Top200 via batch.
                Mark all Child accounts as TRUE.
*CreatedDate: 01-May-2018
*Verion     : 1.0
*/

global class UpdateChildAccountsHierarchyBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
       // String Id = '\'001E000000ddwSM\'';
        //String query = 'SELECT Id, ParentId FROM Account WHERE ParentId= '+Id;
        //Query Updated By Venu Kukkapalli as part of redesign
        String query = 'SELECT Id, ParentId FROM Account WHERE ParentId != NULL';   //IBA-4149
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountListForHiearchy){
        Set<Id> parnetIds = new Set<Id>();
        
        for (Account acc : accountListForHiearchy) {
            parnetIds.add(acc.ParentId);
            System.debug('UpdateChildAccountsHiearchyBatch_2::execute::parnetIds ' + parnetIds.size());
        }
        
        if (parnetIds != NULL && !parnetIds.isEmpty()) {
            try {
                
                Set<Id> parentAccountIds     = new Set<Id>();
                Set<Id> parentAccountIds_ti  = new Set<Id>();        
                List<Account> allAccountsInHiearchy = new List<Account>();
                List<Account> allAccountsInHiearchy2= new List<Account>();
                List<Account> childAccount          = new List<Account>();
                
                List<Target_Initiative_Account__c> targetInitiaviteAccount = new List<Target_Initiative_Account__c>();
                
                if (parnetIds != NULL && !parnetIds.isEmpty()) {
                    
                    System.debug('UpdateChildAccountsHiearchyBatch::execute::parnetIds ' + parnetIds.size());
                    if (parnetIds != NULL && !parnetIds.isEmpty()) {
                        targetInitiaviteAccount = [SELECT Id, Account__c 
                                                   FROM Target_Initiative_Account__c 
                                                   WHERE Account__c IN :parnetIds 
                                                   AND Target_Initiative__r.Name = 'Top Accounts'];
                        System.debug('UpdateChildAccountsHiearchyBatch::execute::targetInitiaviteAccount ' + targetInitiaviteAccount.size());
                        
                        if (targetInitiaviteAccount != NULL && !targetInitiaviteAccount.isEmpty()) {
                            for (Target_Initiative_Account__c tg : targetInitiaviteAccount) {
                                parentAccountIds_ti.add(tg.Account__c);
                            }
                        }
                        parentAccountIds.addAll(parentAccountIds_ti);
                        System.debug('UpdateChildAccountsHiearchyBatch::execute::childAccount ' + parentAccountIds_ti);
                    }
                }
                
                if (parentAccountIds_ti != NULL && !parentAccountIds_ti.isEmpty()) {
                    do {
                        childAccount =  [SELECT Id, Name              //IBA-4149
                                         FROM Account 
                                         WHERE ParentId IN :parentAccountIds];
                        System.debug('UpdateChildAccountsHiearchyBatch::execute::childAccount ' + childAccount.size());
                        
                        allAccountsInHiearchy.addAll(childAccount);
                        System.debug('UpdateChildAccountsHiearchyBatch::execute::parentAccountIds ' + parentAccountIds);
                        parentAccountIds.clear();
                        
                        for (Account ac : childAccount) parentAccountIds.add(ac.Id);
                    } while (childAccount.size() > 0);
                    System.debug('UpdateChildAccountsHiearchyBatch::execute::allAccountsInHiearchy ' + allAccountsInHiearchy.size());
                    
                    if (allAccountsInHiearchy != NUll && !allAccountsInHiearchy.isEmpty()) {
                        for (Account acc : allAccountsInHiearchy) {
                            Account ac = new Account(Id = acc.Id);
                         //IBA-4149   ac.Is_Top_200__c = TRUE;
                            if(!allAccountsInHiearchy2.contains(ac))
                                allAccountsInHiearchy2.add(ac);
                            System.debug('UpdateChildAccountsHiearchyBatch::execute::allAccountsInHiearchy ' + allAccountsInHiearchy2.size());
                        }
                    }
                }
                
                if (!allAccountsInHiearchy2.isEmpty()) {
                    ProcessControlForAccountHiearchy.inFutureContext200List = TRUE;
                    Database.update(allAccountsInHiearchy2,false);
                    System.debug('UpdateAccountsInTop200InHiearchy::execute::allAccountsInHiearchy2 - Updated ');
                }           
            } catch (Exception e) {
                
            } catch (LimitException le) {
                System.debug('UpdateAccountsInTop200InHiearchy::execute::ErrorMessage ' + le.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
            mail.setToAddresses(toAddresses); 
        mail.setSubject('Batch Job Status for updating the Accounts : ' + a.Status); 
        mail.setPlainTextBody('The batch job for updating the IsTop200 as TRUE on child accounts is completed.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        UpdateOnAccount_IsTop200Batch3_New schedule3 = new UpdateOnAccount_IsTop200Batch3_New();
        database.executeBatch(schedule3, 2000);
    }
}