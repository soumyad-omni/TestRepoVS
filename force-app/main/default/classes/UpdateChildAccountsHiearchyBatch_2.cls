/*
*Name       : UpdateChildAccountsHierarchyBatch_2
*Author     : Swapnil R
*Description: Apex class to update all the accounts in a account hiearchy where the parent account is in Top200 via batch. 
Mark all Child accounts as FALSE.
*CreatedDate: 01-May-2018
*Verion     : 1.0
*/

global class UpdateChildAccountsHiearchyBatch_2 implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String Id = '\'001E000000ddwjq\'';
        //String query = 'SELECT Id, ParentId FROM Account WHERE ParentId = '+Id;
        ////Query Updated By Venu Kukkapalli as part of redesign
        Boolean isTop;
        if(Label.Account_IsTop200 == 'False')
            isTop = false;
        else
            isTop = true;
        System.debug('isTop : '+isTop);
        String query = 'SELECT Id, ParentId FROM Account WHERE ParentId != NULL';   //IBA-4149
        System.debug('query result : '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountListForHiearchy){
        Set<Id> parnetIds = new Set<Id>();
        
        for (Account acc : accountListForHiearchy) {
            //if(acc.Is_Top_200__c = TRUE)
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
                
                parentAccountIds.addAll(parnetIds);
                System.debug('UpdateChildAccountsHiearchyBatch_2::execute::parnetIds ' + parnetIds.size());
                
                System.debug('UpdateChildAccountsHiearchyBatch_2::execute::parentAccountIds '+parentAccountIds);
                
                if (parnetIds != NULL && !parnetIds.isEmpty()) {
                    targetInitiaviteAccount = [SELECT Id, Account__c 
                                               FROM Target_Initiative_Account__c 
                                               WHERE Target_Initiative__r.Name = 'Top Accounts'
                                              AND Account__c IN: parentAccountIds];
                    System.debug('UpdateChildAccountsHiearchyBatch_2::execute::targetInitiaviteAccount ' + targetInitiaviteAccount.size());
                    
                    if (targetInitiaviteAccount != NULL && !targetInitiaviteAccount.isEmpty()) {
                        for (Target_Initiative_Account__c tg : targetInitiaviteAccount) {
                            parentAccountIds_ti.add(tg.Account__c);
                        }
                    }
                    parentAccountIds.removeAll(parentAccountIds_ti);
                    System.debug('UpdateChildAccountsHiearchyBatch_2::execute::parentAccountIds ' + parentAccountIds.size());
                }
                
                /*Map<Id, List<Account>> accParentMap = new Map<Id, List<Account>>();
                for(Account acc1: accountListForHiearchy){
                    if(!accParentMap.containsKey(acc1.ParentId ))
                        accParentMap.put(acc1.ParentId , new List<Account>());
                    accParentMap.get(acc1.ParentId).add(acc1);
                }*/
                
                if (parentAccountIds != NULL && !parentAccountIds.isEmpty()) {
                    System.debug('UpdateChildAccountsHiearchyBatch_2::execute::InsideDoWhileLoop');
                    do {
                        childAccount =  [SELECT Id, Name                //IBA-4149 
                                         FROM Account 
                                         WHERE ParentId IN :parentAccountIds];
                        /*for(Account acc1: accountListForHiearchy){
                            if(parentAccountIds.contains(acc1.ParentId) && !childAccount.contains(acc1))
                                childAccount.add(acc1);
                        }*/
                        /*for(Id pId: parentAccountIds){
                            childAccount.addAll(accParentMap.get(pid));
                        }*/
                        System.debug('UpdateChildAccountsHiearchyBatch_2::execute::childAccount ' + childAccount.size());
                        
                        allAccountsInHiearchy.addAll(childAccount);
                        System.debug('UpdateChildAccountsHiearchyBatch_2::execute::parentAccountIds ' + parentAccountIds);
                        parentAccountIds.clear();
                        
                        for (Account ac : childAccount) parentAccountIds.add(ac.Id);
                    } while (childAccount.size() > 0);
                    System.debug('UpdateChildAccountsHiearchyBatch_2::execute::allAccountsInHiearchy ' + allAccountsInHiearchy.size());
                    
                    if (allAccountsInHiearchy != NUll && !allAccountsInHiearchy.isEmpty()) {
                        for (Account acc : allAccountsInHiearchy) {
                            Account ac = new Account(Id = acc.Id);
                     //IBA-4149       ac.Is_Top_200__c = FALSE;
                            if(!allAccountsInHiearchy2.contains(ac))
                                allAccountsInHiearchy2.add(ac);
                            System.debug('UpdateChildAccountsHiearchyBatch_2::execute::allAccountsInHiearchy ' + allAccountsInHiearchy2.size());
                        }
                    }
                }
                
                if (!allAccountsInHiearchy2.isEmpty()) {
                    Database.update(allAccountsInHiearchy2,false);
                    System.debug('UpdateChildAccountsHiearchyBatch_2::execute::allAccountsInHiearchy2 - Updated ');
                }           
            } catch (Exception e) {
                
            } catch (LimitException le) {
                System.debug('UpdateChildAccountsHiearchyBatch_2::execute::ErrorMessage ' + le.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()]; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        String[] toAddresses = new String[] {a.CreatedBy.Email}; 
            mail.setToAddresses(toAddresses); 
        mail.setSubject('Batch Job Status for updating the Accounts : ' + a.Status); 
        mail.setPlainTextBody('The batch job for updating the IsTop200 as FALSE on child accounts is completed.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        UpdateChildAccountsHierarchyBatch schedule = new UpdateChildAccountsHierarchyBatch();
        database.executeBatch(schedule, 5);
    }
}