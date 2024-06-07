@isTest
public class NewAccountTeamMemberController_Test {
    public static testmethod void NewAccountTeamMemberCreateController(){
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = True;
        UserTriggerHandler.TriggerDisabled=True;
        Account acc = TestDataFactory.createTestAccount();
        AccountTeamMember atm= TestDataFactory.createTestAccountTeamMember();
       	PageReference myVfPage = Page.NewAccountTeamMember;
		Test.setCurrentPage(myVfPage);
		ApexPages.currentPage().getParameters().put('accid',acc.Id);
    	Test.startTest();
        	Opportunity opp = TestDataFactory.createOppWithAccount(); //createOpportunityforAccount(atm.AccountId)
        	opp.name = 'Test Opportunity';
        	opp.StageName = '1 Solution Design';
        	opp.CloseDate = System.today()+30;
        	opp.AccountId = atm.AccountId;
        	update opp;
        	ApexPages.StandardController sc = new ApexPages.StandardController(atm);
        	NewAccountTeamMemberCreateController natmc = new NewAccountTeamMemberCreateController(sc);
        	natmc.save();
        	natmc.cancel();
        	natmc.getaccountName();
        	natmc.populateOpportunityTeam(atm);
        Test.stopTest();
    }
}