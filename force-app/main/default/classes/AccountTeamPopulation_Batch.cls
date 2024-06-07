global class AccountTeamPopulation_Batch implements Database.Batchable<SObject> {
	global Integer recordsProcessed = 0;
    global Database.queryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select id, Name,Account_Territory__c from Account');
    }
    
    global void execute (Database.BatchableContext BC, List<Account> accList){
    /*	System.debug('accList : '+accList);
        List<Roles2__mdt> roles = [select list_of_roles__c from roles2__mdt where MasterLabel = :Label.Goegraphy_Territory_Roles];
        List<String> roles1 = roles[0].list_of_roles__c.split(',');
        System.debug('roles : '+roles1);
        List<String> territoryList= new List<String>();
        for(Account a : accList){
            territoryList.add(a.account_territory__c);
        }
        List<AccountTeamMember> act = new List<AccountTeamMember>();
        List<User> users = [select id,Territory__c,Position_Name__c from User where Territory__c=:territoryList and Position_Name__c=:roles1];
        System.debug('Users : '+users);
        for(User u : users){
            for(Account acc : accList){
                if(u.Territory__c == acc.Account_Territory__c){
                    AccountTeamMember at = new AccountTeamMember();
                    at.userid = u.Id;
                    at.teammemberrole = u.Position_Name__c;
                    at.AccountId = acc.id;
                    act.add(at);
                    recordsProcessed = recordsProcessed + 1;
                }
            }
        }
        insert act;*/
    }
    global void finish(Database.BatchableContext BC){   
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
    }

}