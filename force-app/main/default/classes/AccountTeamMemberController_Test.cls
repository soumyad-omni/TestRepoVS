@isTest
public class AccountTeamMemberController_Test {
    
    public static testmethod void AccountTeamMemberController(){
        AccountCreateController.isFirstRun= false;
		accountTriggerHandler.TriggerDisabled = true;
        userTriggerHandler.TriggerDisabled = true;
        Account acc= TestDataFactory.createTestAccountQuotePrint();
        Opportunity opp=TestDataFactory.createOppWitOptyTypeAndAccount_Integration();
        AccountTeamMember atm = TestDataFactory.createTestAccountTeamMemberWithAccId(opp.accountId);
        OpportunityTeamMember newOTM = new OpportunityTeamMember();
        newOTM.OpportunityId = opp.Id;
        newOTM.TeamMemberRole = atm.TeamMemberRole ;
        newOTM.UserId = atm.userId;
        insert newOTM;
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            AccountTeamMemberController atmc = new AccountTeamMemberController(sc);
            atmc.selectedId = atm.Id;
            atmc.deleteMember();
        	atmc.deleteOptyTeam(atm);
        Test.stopTest();
    }
}