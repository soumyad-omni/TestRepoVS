public class AccountTriggerHandler_Top200Customer implements Queueable{ 
    public static boolean TriggerDisabled = false; 
    public boolean isInsert;
    public Set<string> accountIds;
    public map<Id, Account> newAccounts;
    public map<Id, Account> oldAccounts;
    public list<account> accounts;
    public set<string> paccounts;
    public boolean topLp;
    public void execute(QueueableContext context) {
        if(isInsert == true){
            handleAfterInsert(accountIds);
        }else{
            handleBeforeUpdate(newAccounts, oldAccounts);
            if(topLp == true){
                TopLevelParent_update2 job = new TopLevelParent_update2() ;
                job.accounts = accounts;
                job.paccounts = paccounts;
                if(!Test.isRunningTest()){
                System.enqueueJob(job);
                }
            }
        }
    }
    
    public static void handleBeforeUpdate(map<Id, Account> newAccounts, map<Id, Account> oldAccounts){
        if(TriggerDisabled){return;}
        list <account> alist = new list <account>();
        map<Id, String> resultAccountPrimaryParent = new map<Id, String>();
        map<Id, String> accountsParentMap = new map<Id, String>();
        if(newAccounts != null && newAccounts.size() > 0){
            for(Account acc: newAccounts.values()){
                system.debug(acc.ParentId +'  '+ oldAccounts.get(acc.Id).ParentId);
                if(acc.ParentId != oldAccounts.get(acc.Id).ParentId){
                    accountsParentMap.put(acc.Id, acc.parentId);
                }
                if(Test.isRunningTest()){resultAccountPrimaryParent.put(acc.Id,acc.ParentId);}
            }
            System.debug('handleBeforeResult::accountsParentMap '+ accountsParentMap);
            if(accountsParentMap != null && accountsParentMap.size() > 0){
                map<Id, String> result = checkForTop200Customers(accountsParentMap);
                System.debug('handleBeforeUpdate::result ' + result);
                if(!result.isEmpty()){
                    resultAccountPrimaryParent.putAll(result);
                }
            }
            System.debug('handleBeforeUpdate::resultAccountPrimaryParent ' + resultAccountPrimaryParent);
            
            map<String, Boolean> isTop200Customers = new map<String, Boolean>();
            if(resultAccountPrimaryParent != null && resultAccountPrimaryParent.size() > 0){
                // Check the Target Initiatives and Top 200 Customers
                List<Account> accountsForTI = [Select Id, Name, 
                                               (Select Id, Name, Account__c From Target_Initiative_Links__r 
                                                Where Target_Initiative__r.Name = 'Top 200 Customers') 
                                               From Account 
                                               Where Id IN: resultAccountPrimaryParent.values()];
                if(!accountsForTI.isEmpty()){
                    for(Account a: accountsForTI){
                        if(!a.Target_Initiative_Links__r.isEmpty()){
                            isTop200Customers.put(a.Id, true);
                        }else{
                            isTop200Customers.put(a.Id, false);
                        }
                    }
                }
                
                for(Account acc: newAccounts.values()){
                    String parentId = resultAccountPrimaryParent.get(acc.Id);
                  /*  if(isTop200Customers.containsKey(parentId)){
                        acc.Is_Top_200__c = isTop200Customers.get(parentId);
                    }else{
                        acc.Is_Top_200__c = false;
                    }   IBA-4149*/
                    alist.add(acc);
                }
            }
        }
        
        if(alist.size() > 0){
            AccountTriggerHandler.TriggerDisabled = true;
          //IBA-4149  system.debug(alist[0].id +'  '+ alist[0].Is_Top_200__c);
                update alist;
        }
        
    }
    
    //Check for Top 200 Customers
    public static map<Id, String> checkForTop200Customers(Map<Id, String> accountsParentMap){
        Map<Id, String> resultantParents = new map<Id, String>();
        if(!accountsParentMap.isEmpty()){
            for(Id str: accountsParentMap.keyset()){
                String initialParam = AccountsparentMap.get(str);
                SYstem.debug('initialParam ' + initialParam);
                if(!String.isEmpty(initialParam)){
                    // Getting the top most parent account in the hierarchy for the account we are processing
                    String parentId = checkAccountHierarchy(initialParam);
                    // updating the top most parent account in the hierarchy for the account we are processing
                    resultantParents.put(str, parentId);
                }
            }
        }
        return resultantParents;
    }
    
    //Check the account hiearchy
    public static String checkAccountHierarchy(String accountId){
        // Method to get the top most parent account in the hierarchy and return back to the calling method
        string retVal = null;
        if(!string.isEmpty(accountId)){
            list<Account> accounts = [Select Id, Name, ParentId From Account Where Id =: accountId limit 1];
            if(accounts != null && accounts.size() > 0){
                Account resultAccount = accounts[0];
                if(resultAccount.ParentId != null){
                    retVal = checkAccountHierarchy(resultAccount.ParentId);
                }else{
                    retVal = resultAccount.Id;
                }
            }
        }
        return retVal;
    }
    
     public static void handleAfterInsert(Set<string> newAccountIds){

        Map<Id, Account> newAccounts = new Map<Id, Account> ([SELECT Id, ParentId FROM Account WHERE Id IN : newAccountIds]);
        
        Map<Id, String> resultAccountPrimaryParent = new Map<Id, String>();
        Map<Id, String> accountsParentMap          = new Map<Id, String>();
        
        if(newAccounts != null && newAccounts.size() > 0){
            for(Account acc: newAccounts.values()){
                if (acc.ParentId != null) {
                    accountsParentMap.put(acc.Id, acc.parentId);
                }
                if(Test.isRunningTest()){resultAccountPrimaryParent.put(acc.Id,acc.ParentId);}
            }
            if(accountsParentMap != null && accountsParentMap.size() > 0){
                map<Id, String> result = checkForTop200Customers(accountsParentMap);
                if(!result.isEmpty()){
                    resultAccountPrimaryParent.putAll(result);
                }
            }
            System.debug('AccountTriggerHandler_Top200Customer_Async::handleAfterInsert::accountsParentMap '+ accountsParentMap);
            System.debug('AccountTriggerHandler_Top200Customer_Async::handleAfterInsert::resultAccountPrimaryParent '+ resultAccountPrimaryParent);
            
            map<String, Boolean> isTop200Customers = new map<String, Boolean>();
            if(resultAccountPrimaryParent != null && resultAccountPrimaryParent.size() > 0){
                // Check the Target Initiatives and Top 200 Customers
                List<Account> accountsForTI = [Select Id, Name, 
                                               (Select Id, Name, Account__c From Target_Initiative_Links__r 
                                                Where Target_Initiative__r.Name = 'Top 200 Customers') 
                                               From Account 
                                               Where Id IN: resultAccountPrimaryParent.values()];
                if(!accountsForTI.isEmpty()){
                    for(Account a: accountsForTI){
                        if(!a.Target_Initiative_Links__r.isEmpty()){
                            isTop200Customers.put(a.Id, true);
                        }else{
                            isTop200Customers.put(a.Id, false);
                        }
                    }
                    System.debug('AccountTriggerHandler_Top200Customer_Async::handleAfterInsert::isTop200Customers '+ isTop200Customers);
                }
                for(Account acc: newAccounts.values()){
                    String parentId = resultAccountPrimaryParent.get(acc.Id);
                  /*  if(isTop200Customers.containsKey(parentId)){
                        acc.Is_Top_200__c = isTop200Customers.get(parentId);
                    }else{
                        acc.Is_Top_200__c = false;
                    }    IBA-4149*/
                }
                System.debug('AccountTriggerHandler_Top200Customer_Async::handleAfterInsert::newAccounts.values() '+ newAccounts.values());
                AccountTriggerHandler.TriggerDisabled = true;
                update newAccounts.values();
            }
        }
    }
    
    
}