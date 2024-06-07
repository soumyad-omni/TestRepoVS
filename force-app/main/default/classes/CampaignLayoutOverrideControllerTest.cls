@isTest
public class CampaignLayoutOverrideControllerTest {

    public static testmethod void campaignlayoutcontrollertest(){
        usertriggerhandler.triggerdisabled = true;
        List<Campaign> campList = TestDataFactory.createCampaign(1);
        Campaign c = campList[0];
        insert c;
        Group g = new Group(Name = 'Test Group');
        insert g;
        User u = TestDataFactory.createUser(true,'TestUser','CampShare');
        CampaignShare cs = new CampaignShare();
        cs.UserOrGroupId = u.id;
        cs.CampaignId = c.id;
        cs.CampaignAccessLevel = 'Edit';
        insert cs;
        CampaignShare cs1 = new CampaignShare();
        cs1.UserOrGroupId = g.id;
        cs1.CampaignId = c.id;
        cs1.CampaignAccessLevel = 'Edit';
        insert cs1;
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        camp.Status='Planned';
        camp.ParentId = c.Id;
        insert camp;
        Campaign camp2=TestDataFactory.createCampaign(1)[0];
        camp2.Status='Planned';
        camp2.ParentId = c.Id;
        insert camp2;
        view_all_campaign_mem_report__c vcmr = new view_all_campaign_mem_report__c();
        vcmr.Name ='view_all_campaign_mem_report_url';
        vcmr.report_url__c = 'https://omnicell--fulldev.lightning.force.com/lightning/r/Report/00O2g000000JuSIEA0/view?fv0=';
        insert vcmr;
        //CampaignLayoutOverrideController cloc = new CampaignLayoutOverrideController();
        Test.startTest();
        	CampaignLayoutOverrideController.getCurrentUser();
        	CampaignLayoutOverrideController.getIds(c.id);
        	CampaignLayoutOverrideController.getStatus(c.id);
        	CampaignLayoutOverrideController.getReportUrl(c.id);
    	Test.stopTest();
    }
}