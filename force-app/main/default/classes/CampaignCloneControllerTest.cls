@isTest
public class CampaignCloneControllerTest {

    public static testmethod void campaignCloneTest(){
        Campaign c = new Campaign(Name = 'test campaign');
        c.Campaign_Region__c = 'NA - North America';
        c.Market_Portfolio_Segment__c = 'Other';
        insert c;
        CampaignMemberStatus cms = new CampaignMemberStatus(Label='Test Status',campaignId = c.Id);
        insert cms;
        Test.startTest();
        	PageReference pageRef = Page.CampaignClonePage;
        	Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',c.Id);
        	ApexPages.StandardController sc = new ApexPages.StandardController(c);
           	CampaignCloneController nq =new CampaignCloneController(sc);
        	nq.save();
        nq.updatetoplevelparent();
        Test.stopTest();
    }   
}