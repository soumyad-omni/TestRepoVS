/**********************************************************************
Name:  CampaignMemberTriggerHandler_Test
Copyright © 2018
======================================================
======================================================
Purpose: Test class for CampaignMemberTriggerHandler class
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Venu Kukkapalli          13/06/2018       INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class CampaignMemberTriggerHandler_Test {
    
    
    @TestSetup
    public static void testDataSetup() {
        
        contactTriggerHandler.TriggerDisabled = true;
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        List<CampaignMember> CampaignMemberList= new List<CampaignMember>(); 
        
        camp.Status='Planned';
        insert camp;
        Lead ld=TestDataFactory.createLead(1)[0];
        insert ld;
        Account acc=TestDataFactory.createAccounts(1)[0];
        insert acc;
        Contact cont=new Contact(LastName='TestContact', AccountId=acc.id);
        insert cont;
        
        CampaignMember member=new CampaignMember(leadId=ld.Id,campaignid=camp.Id,status='Sent');
        
        CampaignMemberList.add(member);
        
        CampaignMember member1=new CampaignMember(contactId=cont.Id,campaignid=camp.Id,status='Sent');
        
        CampaignMemberList.add(member1);
        
        insert CampaignMemberList;
        
        
        
        CampaignMemberStatus newStatus = new CampaignMemberStatus(
            CampaignID=camp.id,
            Label='Remove',
            IsDefault=false,
            HasResponded=false,
            SortOrder=3
        );
        insert newStatus;
        
        
    }
    
    // Test method for both SendMail and createCampaignMemberAudit
    @isTest
    public static void createrecordTest(){
        test.startTest();
        contactTriggerHandler.TriggerDisabled = true;
        Lead lead= [select lead.firstname, lead.lastName, id from Lead where lead.firstname=:'TestClass'];
        
        CampaignMember member=[select campaignid, status, id from CampaignMember where lead.Id =: lead.id];       
        
        member.Status='Remove';
        
        
        update member;
        
        System.debug('Campaign Member status is' +member.status);
        
        delete member;
        test.stopTest();
    }
    // Test method for both SendMail and createCampaignMemberAudit
    @isTest
    public static void createRecordTest1(){
        /*Campaign camp=TestDataFactory.createCampaign(1)[0];
		camp.Status='Planned';
		insert camp;
		Account acc=TestDataFactory.createAccounts(1)[0];
		insert acc;
		Contact cont=new Contact(LastName='Contact', AccountId=acc.id);
		insert cont;
		CampaignMember member=new CampaignMember(contactId=cont.Id,campaignid=camp.Id,status='Sent');
		insert member;*/
        test.startTest();
        contactTriggerHandler.TriggerDisabled = true;
        Contact contact= [select lastName, id from Contact where LastName=:'TestContact'];
        
        CampaignMember member=[select campaignid, status, id from CampaignMember where contact.Id =: contact.id];       
        
        
        member.Status='Remove';
        update member;
        
        System.debug('Campaign Member status is' +member.status);
        try
        {
            delete member;
            
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Remove'));
        }         
        test.stopTest();
    }
    // Test method for before delete method
    @isTest
    public static void createRecordTest3(){
        test.startTest();
        contactTriggerHandler.TriggerDisabled = true;
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        camp.Status='Completed';
        insert camp;
        Account acc=TestDataFactory.createAccounts(1)[0];
        acc.Name='Test Acc1';
        insert acc;
        Contact cont=new Contact(LastName='Contact', AccountId=acc.id);
        insert cont;
        CampaignMember member=new CampaignMember(contactId=cont.Id,campaignid=camp.Id,status='Sent');
        insert member;
        try{
            delete member;
            //throw new Exception('An exception should have been thrown by the trigger but was not.');
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('closed/Completed'));
        } 
        test.stopTest();
    }
    
    // Test method to track field changes in CampaignMemberAudit
    @isTest
    public static void createRecordTest4(){
        contactTriggerHandler.TriggerDisabled = true;
        test.startTest();
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        insert camp;
        Account acc=TestDataFactory.createAccounts(1)[0];
        acc.Name='Test Acc4';
        insert acc;
        Contact cont=new Contact(LastName='Contact', AccountId=acc.id);
        insert cont;
        CampaignMember member=new CampaignMember(contactId=cont.Id,campaignid=camp.Id,status='Sent');
        insert member;
        member.Status = 'Responded';
        update member;
        test.stopTest();
    }

    //added as part of SF-BUG-1080 bulkify code test - Bharath 
    @isTest
    public static void Trackfieldchangestest(){
        contactTriggerHandler.TriggerDisabled = true;
        List<Campaign> camp=TestDataFactory.createCampaign(200);
        insert camp;
        Account acc=TestDataFactory.createAccounts(1)[0];
        acc.Name='Test Omni Account';
        insert acc;
        Contact cont=new Contact(LastName='Contact', AccountId=acc.id);
        insert cont;
        CampaignMember member=new CampaignMember(contactId=cont.Id,campaignid=camp[0].Id,status='Sent');
        insert member;
        
        List<Campaign_Member_History__c> cmhistory =TestDataFactory.createCampaignmemberhistory(200,  camp,  member.Id );
		
        insert cmhistory;
       
        member.Status = 'Responded';
        
        test.startTest();
        try{
           update member;
        }
        catch(Exception e)
        {
            system.debug('Exception Error '+e);
        }
        test.stopTest();
    }
}