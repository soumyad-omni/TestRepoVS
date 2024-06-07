public class AccountTeamPopulationController {

    @AuraEnabled
    public static void updateAccountTeamMember(Id accountId){
        /*Account acc = [select Top_Level_Parent__c from Account where id=:accountId];
        System.debug('Top : '+acc.Top_Level_Parent__c);
        List<Roles2__mdt> roles = [select list_of_roles__c from roles2__mdt where MasterLabel = :Label.Hierarchy];
        List<String> roles1 = roles[0].list_of_roles__c.split(',');
        System.debug('roles : '+roles1);
        List<AccountTeamMember> updatedactm = new List<AccountTeamMember>();
        List<AccountTeamMember> actm = [select userid,TeamMemberRole from AccountTeamMember where accountid =:acc.Top_Level_Parent__c and TeamMemberRole =: roles1];
        System.debug('ACTM Parent: '+actm);
        for(AccountTeamMember act : actm){
            AccountTeamMember a = new AccountTeamMember();
            a.accountId = accountId;
            a.UserId = act.UserId;
            a.TeamMemberRole = act.TeamMemberRole;
            updatedactm.add(a);
        }
        System.debug('ACTM child : '+updatedactm); 
        insert updatedactm; */
    }
    @AuraEnabled
    public static String updateAccountTeamMember1(Id accountId){
        return '';
       /* Id topAcc;
        List<Account> childAccounts = [select id,Name from Account where Top_level_parent__c =:accountId];
        List<Id> childIds = new List<Id>();
        
        if(childAccounts.size()>0){
        Account acc = [select id,Top_Level_Parent__c from Account where id=:accountId];
            if(acc.Top_Level_Parent__c != null){
                topAcc = acc.Id;
            }
            else
                topAcc = accountId;
        List<Account> childAccounts1 = [select id,Name from Account where Top_level_parent__c =:topAcc];
        System.debug('Top : '+acc.Top_Level_Parent__c);
        List<Roles2__mdt> roles = [select list_of_roles__c from roles2__mdt where MasterLabel = :Label.Hierarchy];
        List<String> roles1 = roles[0].list_of_roles__c.split(',');
        System.debug('roles : '+roles1);
        List<AccountTeamMember> updatedactm = new List<AccountTeamMember>();
        //List<AccountTeamMember> actm = [select userid,TeamMemberRole from AccountTeamMember where accountid =:topAcc and TeamMemberRole =: roles1];
            List<AccountTeamMember> actm = [SELECT AccountAccessLevel,AccountId,CaseAccessLevel,ContactAccessLevel,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,OpportunityAccessLevel,PhotoUrl,SystemModstamp,TeamMemberRole,Title,UserId FROM AccountTeamMember 
                                        where accountid =:topAcc and TeamMemberRole =: roles1]; //Praneeth
        System.debug('ACTM Parent: '+actm);
        for(AccountTeamMember act : actm){
            for(Account a:childAccounts1){
                AccountTeamMember at = new AccountTeamMember();
                at.accountId = a.Id;
                at.UserId = act.UserId;
                at.TeamMemberRole = act.TeamMemberRole;
                
                at.AccountAccessLevel = act.AccountAccessLevel;             //Praneeth added this for SF bug 318
                at.CaseAccessLevel = act.CaseAccessLevel;                   //Praneeth added this for SF bug 318
                at.ContactAccessLevel = act.ContactAccessLevel;             //Praneeth added this for SF bug 318
                at.OpportunityAccessLevel = act.OpportunityAccessLevel;     //Praneeth added this for SF bug 318
                updatedactm.add(at);
            }
        }
        System.debug('ACTM child : '+updatedactm); 
        insert updatedactm;
        return 'Updated';    
        }
        else{
            return 'Not a Top Level Parent';
        }*/
    }
}