Global class DefaultOpportunityTeamBatchClass implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){    
        return Database.getQueryLocator([SELECT Id, OwnerId, (SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMembers) FROM Account WHERE IsDeleted__c = FALSE]);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope){ 
        Map<Id,List<AccountTeamMember>> accAtmMap = new Map<Id,List<AccountTeamMember>>();
        Map<Id,Id> accountOwners = new Map<Id,Id>();
        for(Account acc: scope){
            if(!accAtmMap.containsKey(acc.id))
                accAtmMap.put(acc.id, acc.AccountTeamMembers);
            if(!accountOwners.containsKey(acc.id))
                accountOwners.put(acc.id,acc.ownerId);
        }
        Boolean isMember = False;
        List<AccountTeamMember> insertAtmList = new List<AccountTeamMember>();
        for(Account acc: scope){
            for(AccountTeamMember atm:accAtmMap.get(acc.Id)){
                if(acc.OwnerId == atm.UserId){
                    isMember = True;
                    break;
                }
            }
            if(isMember == False){
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = acc.OwnerId ;
                atm.AccountId = acc.Id;
                atm.TeamMemberRole = Label.OppTeamPopulate5;
                atm.AccountAccessLevel = 'Read';
                atm.OpportunityAccessLevel = 'Edit';
                atm.ContactAccessLevel = 'Edit';
                if(!insertAtmList.contains(atm))
                    insertAtmList.add(atm);
            }
        }
        try{
            if(insertAtmList.size()>0)
                insert insertAtmList;
        }
        Catch(Exception e){
            System.debug(e);
        }
        
        List<Opportunity> optyList = [SELECT Id, AccountId, CustomerType__c,IV_Product_Line__c,Performance_Center_Product_Line__c, (SELECT Id, OpportunityId, UserId, TeamMemberRole FROM OpportunityTeamMembers) FROM Opportunity WHERE stageName != '6 Closed Won' AND stageName !='7 Closed Lost' AND AccountId IN: scope];
        List<OpportunityTeamMember> otmDelList = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
        for(opportunity opp:optyList){
            for(OpportunityTeamMember otm:opp.OpportunityTeamMembers){
                if(!otmDelList.contains(otm))
                    otmDelList.add(otm);
            }
        }
        try{
            delete otmDelList;
        }
        catch(Exception e){
            System.debug(e);
        }
        
        //Getting Roles Based on Customer Type and Product Line
        List<Roles1__mdt> Roles=[SELECT Id, Label, QualifiedApiName, List_of_Roles__c, AllTypes__c FROM Roles1__mdt];
        String listofdefRoles;
        String listofExtRoles;
        String listofIVRoles;
        String listofPerfRoles;
        
        for(Roles1__mdt rl: Roles){
            if(rl.AllTypes__c == Label.OppTeamPopulate1){
                listofdefRoles = rl.List_of_Roles__c;
            }
            else if(rl.AllTypes__c == Label.OppTeamPopulate2){
                listofExtRoles = rl.List_of_Roles__c;
            }
            else if(rl.AllTypes__c == Label.OppTeamPopulate3){
                listofIVRoles = rl.List_of_Roles__c;
            }
            else if(rl.AllTypes__c == Label.OppTeamPopulate4){
                listofPerfRoles = rl.List_of_Roles__c;
            }
        }
        
        List<String> defaultList= listofdefRoles.split(',');
        List<String> extList= listofExtRoles.split(',');
        List<String> IVList= listofIVRoles.split(',');
        List<String> perfList= listofPerfRoles.split(',');
        for(Opportunity o : optyList) {
            Boolean checkAcctOwner = FALSE;
            if(accAtmMap.containsKey(o.accountId)){
                for ( AccountTeamMember accountTeamMember : accAtmMap.get(o.accountId) )  {            
                    OpportunityTeamMember opportunityTeamMember  = new OpportunityTeamMember();
                    opportunityTeamMember.UserId = accountTeamMember.UserId;
                    opportunityTeamMember.TeamMemberRole = accountTeamMember.TeamMemberRole;
                    opportunityTeamMember.OpportunityId = o.ID;
                    if(opportunityTeamMember.UserId!=NULL){
                        if(defaultList.contains(accountTeamMember.TeamMemberRole)){
                            oppTeamMembersList.add(opportunityTeamMember);
                        }
                        if(o.CustomerType__c == Label.OppTeamPopulate2 && extList.contains(accountTeamMember.TeamMemberRole)){
                            oppTeamMembersList.add(opportunityTeamMember);
                        }
                        if(o.IV_Product_Line__c==TRUE && IVList.contains(accountTeamMember.TeamMemberRole)){
                            oppTeamMembersList.add(opportunityTeamMember);
                        }
                        if(o.Performance_Center_Product_Line__c==TRUE && perfList.contains(accountTeamMember.TeamMemberRole)){
                            oppTeamMembersList.add(opportunityTeamMember);
                        }
                        if(accountOwners.get(o.accountId)==accountTeamMember.UserId){
                            oppTeamMembersList.add(opportunityTeamMember);
                            checkAcctOwner = TRUE;
                        }
                    }
                }        
            }
            if(checkAcctOwner == FALSE){
                OpportunityTeamMember opportunityTeamMember  = new OpportunityTeamMember();
                opportunityTeamMember.UserId = accountOwners.get(o.accountId);
                opportunityTeamMember.TeamMemberRole = Label.OppTeamPopulate5;
                opportunityTeamMember.OpportunityId = o.ID;
                if(opportunityTeamMember.UserId!=NULL)
                    oppTeamMembersList.add(opportunityTeamMember);
            }
        }
        try{
            if(oppTeamMembersList.size()>0){
                Set<OpportunityTeamMember> otmSet = new Set<OpportunityTeamMember>();
                otmSet.addAll(oppTeamMembersList);
                List<OpportunityTeamMember> uniqOtmList = new List<OpportunityTeamMember>();
                uniqOtmList.addAll(otmSet);
                insert uniqOtmList;
            }
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('Default Opportunity Team Process : ' + a.Status);
        Integer count = a.TotalJobItems * 2000;
        mail.setPlainTextBody
            ('The batch job processed ' + a.TotalJobItems +
             ' jobs and updated all the opportunities with default account team.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}