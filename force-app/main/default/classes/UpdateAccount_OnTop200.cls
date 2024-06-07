public class UpdateAccount_OnTop200 {
  
   public static void updateAccount_OnAfterInsert (Map<Id, Target_Initiative_Account__c> map_Tag_Initiave_Account) {
      
       if (map_Tag_Initiave_Account != NULL && !map_Tag_Initiave_Account.isEmpty()) {
          
           Set <Id> accountIds                    = new Set <Id> ();
           List <Account> listOfAccount          = new List <Account> ();
           List <Account> listOfAccountForUpdate = new List <Account> ();
          
           if (!map_Tag_Initiave_Account.keySet().isEmpty()) {
               for (Target_Initiative_Account__c tag : map_Tag_Initiave_Account.values()) {
                    if(tag.Target_Initiative_Name__c == 'Top Accounts')
                   		accountIds.add(tag.Account__c);
               }
           }
          
           if (accountIds != NULL && !accountIds.isEmpty()) {
               listOfAccount = [SELECT Id FROM     //IBA-4149
                                Account
                                WHERE Id IN : accountIds];   //IBA-4149
           }
           System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterInsert::listOfAccount.Size ' + listOfAccount.size());
           if (listOfAccount != NULL && !listOfAccount.isEmpty()) {
               for (Account acc : listOfAccount) {
                   Account ac = new Account(Id = acc.Id);
                   //IBA-4149    ac.Is_Deleted_From_Top_Accounts__c = false;
                   listOfAccountForUpdate.add(ac);
               }
               System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterInsert::listOfAccountForUpdate ' + listOfAccountForUpdate);
           }
          
           try {
               if (listOfAccountForUpdate != NULL && !listOfAccountForUpdate.isEmpty()) {
                   update listOfAccountForUpdate;
                  /* BCH_UpdateIsDeletedFromTopAccounts accountBatch = new BCH_UpdateIsDeletedFromTopAccounts();
                   accountBatch.accountIds = accountIds;
                   accountBatch.parentStatus = false;
                   accountBatch.status = true;
                   Database.executebatch(accountBatch,10);*/
               }
           }catch (Exception e) {
               System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterInsert::Cause for Exception ' + e.getCause());
           }
       }
   }
  
   public static void updateAccount_OnAfterDelete (Map<Id, Target_Initiative_Account__c> map_Tag_Initiave_Account) {
      
       if (map_Tag_Initiave_Account != NULL && !map_Tag_Initiave_Account.isEmpty()) {
          
           Set<Id> accountIds                    = new Set <Id> ();
           List <Account> listOfAccount          = new List <Account> ();
           List <Account> listOfAccountForUpdate = new List <Account> ();
          
           if (!map_Tag_Initiave_Account.keySet().isEmpty()) {
               for (Target_Initiative_Account__c tag : map_Tag_Initiave_Account.values()) {
                   accountIds.add(tag.Account__c);
               }
           }
          
           if (accountIds != NULL && !accountIds.isEmpty()) {
               listOfAccount = [SELECT Id FROM         //IBA-4149
                                Account
                                WHERE Id IN : accountIds];
           }
          
           if (listOfAccount != NULL && !listOfAccount.isEmpty()) {
               for (Account acc : listOfAccount) {
                   Account ac = new Account(Id = acc.Id);
                //IBA-4149   ac.Is_Top_200__c = TRUE;
                   listOfAccountForUpdate.add(ac);
               }
               System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterDelete::listOfAccountForUpdate ' + listOfAccountForUpdate);
           }
          
           try {
               if (listOfAccountForUpdate != NULL && !listOfAccountForUpdate.isEmpty()) {
                   update listOfAccountForUpdate;
                   System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterInsert::ListUpdated');
               }
           }catch (Exception e) {
               System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterDelete' + e.getCause());
           }
       }
   }
  
   public static void updateAccount_OnAfterUnDelete (Map<Id, Target_Initiative_Account__c> map_Tag_Initiave_Account) {
      
       if (map_Tag_Initiave_Account != NULL && !map_Tag_Initiave_Account.isEmpty()) {
          
           Set<Id> accountIds                    = new Set <Id> ();
           List <Account> listOfAccount          = new List <Account> ();
           List <Account> listOfAccountForUpdate = new List <Account> ();
           Set <String> tagSet = new Set <String> ();
          
           if (!map_Tag_Initiave_Account.keySet().isEmpty()) {
               for (Target_Initiative_Account__c tag : map_Tag_Initiave_Account.values()) {
                    accountIds.add(tag.Account__c);
                    tagSet.add(tag.Target_Initiative_Name__c);
               }
           }
          
         if (accountIds != NULL && !accountIds.isEmpty()) {
                 listOfAccount = [SELECT Id, Segment__c FROM Account  //IBA-4149
                                  WHERE Id IN : accountIds];
           }
          
        /*   if (listOfAccount != NULL && !listOfAccount.isEmpty()) {
               for (Account acc : listOfAccount) {
                   for (String tagName : tagSet) {
                        if(acc.Segment__c!=null && acc.Segment__c.contains(tagName))
                        {
                            if(acc.Delete_Segments__c!=null && !acc.Delete_Segments__c.contains(tagName))
                            {
                                acc.Delete_Segments__c = acc.Delete_Segments__c + ';' + tagName; 
                                listOfAccountForUpdate.add(acc);
                            } 
                            else
                            {
                                acc.Delete_Segments__c = tagName; 
                                listOfAccountForUpdate.add(acc);
                            }
                        }        
                   }                   
                  
               }
           }       IBA-4149 */
           try {
               if (listOfAccountForUpdate != NULL && !listOfAccountForUpdate.isEmpty()) {
                   AccountTriggerHandler.TriggerDisabled = true;
                   update listOfAccountForUpdate;
                  /* BCH_UpdateIsDeletedFromTopAccounts accountBatch = new BCH_UpdateIsDeletedFromTopAccounts();
                   accountBatch.accountIds = accountIds;
                   Database.executebatch(accountBatch,10);*/
                   System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterInsert::ListUpdated');
               }
           }catch (Exception e) {
               System.debug('UpdateAccount_OnTop200::updateAccount_OnAfterUndelete:: ' + e.getCause());
           }
       }
   }
}