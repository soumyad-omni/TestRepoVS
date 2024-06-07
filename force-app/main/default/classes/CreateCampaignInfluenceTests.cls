@isTest
public class CreateCampaignInfluenceTests {

    @testSetup static void setup() { 
        // Create common test accounts 
        AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        insert opp;

        // create Campaign 
        Campaign camp = new Campaign( 
            Name = 'TestCamp', StartDate = Date.today(),
            IsActive = TRUE); 
        insert camp; 
        System.debug('Inserted Campaign, ID: ' + camp.id); 

        Contact contactRec = TestDataFactory.createTestContact(true, acc.id, 'JaySinghTest',null);
        // create Campaign Member 
        CampaignMember member = new CampaignMember( 
            ContactId = contactRec.Id, 
            Status = 'Contact', 
            CampaignId = camp.Id); 
        insert member; 
        System.debug('Inserted Member, ID: ' + member.id); 
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = contactRec.Id,OpportunityId = opp.Id);
       //ocrList = [SELECT id, ContactId, Role, OpportunityId FROM OpportunityContactRole WHERE OpportunityID in: oppIds ];
        insert ocr;
    } 

    @isTest static void testInsert() { 

        // Get opportunty
        Opportunity opp = [
            SELECT Id,OppStatus__c 
            FROM Opportunity  
            LIMIT 1
        ]; 
       opp.OppStatus__c = 'Fully Booked';
       Test.startTest();
         update opp;
         CreateCampaignInfluence.addCampaignInfluences(opp.Id);
       Test.stopTest();
       List<CampaignInfluence> camInfluenceList = [Select Id,CampaignId,ModelId,ContactId from CampaignInfluence
                                                   WHERE ID =: opp.id ];          
       
    }

}