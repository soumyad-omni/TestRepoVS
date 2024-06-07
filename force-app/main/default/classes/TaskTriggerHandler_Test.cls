/**********************************************************************
Name:  TaskTriggerHandlerTestClass
Copyright © 2018
======================================================
======================================================
Purpose: Test class for TaskTriggerHandler class
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Venu Kukkapalli          13/06/2018       INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class TaskTriggerHandler_Test {
    //Test method for assignTasktoCampaignMember method
    @isTest
    public static void assignTasktoCampaignMemberTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');  
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        insert camp;
        Lead ld=TestDataFactory.createLead(1)[0];
        insert ld;
        Account a  = TestDataFactory.createUSTestAccount();
        Contact c = TestDataFactory.createTestContact(true,a.id,'TestContact',u.id);
        CampaignMember member=new CampaignMember(leadId=ld.Id,campaignid=camp.Id,status='Sent');
        insert member;
        Task tc=new Task(Campaign__c=camp.id, whoId=c.id);
        insert tc;
        tc.Subject = 'test task';
        tc.Status = 'Completed';
        update tc;
    }
    //IBA-1919 Test Method Start Abhrajitc
    @isTest
    public static void staleTestScenario(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Representative' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');  
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        insert camp;
        //Lead ld=TestDataFactory.createLead(1)[0];
        //insert ld;
        Opportunity o  = TestDataFactory.createOpportunity();
        //Contact c = TestDataFactory.createTestContact(true,a.id,'TestContact',u.id);
        //CampaignMember member=new CampaignMember(leadId=ld.Id,campaignid=camp.Id,status='Sent');
        //insert member;
        Task tc=new Task(Campaign__c=camp.id, whatId=o.id);
        insert tc;
        test.startTest();
        tc.Subject = 'test task';
        tc.Status = 'Completed';
        update tc;
        test.stopTest();
    }
    //IBA-1919 Test Method End Abhrajitc
    @isTest
    public static void testmethod1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Representative' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles'); 
        UserTriggerHandler.TriggerDisabled = True;
        insert u;
        System.RunAs(u)
        {
            Campaign camp=TestDataFactory.createCampaign(1)[0];
            insert camp;
            //Lead ld=TestDataFactory.createLead(1)[0];
            //insert ld;
            Opportunity o  = TestDataFactory.createOpportunity();
            //Contact c = TestDataFactory.createTestContact(true,a.id,'TestContact',u.id);
            //CampaignMember member=new CampaignMember(leadId=ld.Id,campaignid=camp.Id,status='Sent');
            //insert member;
            Task tc=new Task(Campaign__c=camp.id, whatId=o.id);
            insert tc;
            test.startTest();
            tc.Subject = 'test task';
            tc.Status = 'Completed';
            update tc;
            test.stopTest();
        }
    }
    
    @isTest
    public static void createTaskHistory()
    {
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        insert camp;
        
        Opportunity o  = TestDataFactory.createOpportunity();
        
        Task tc=new Task(Campaign__c=camp.id, whatId=o.id);
        insert tc;
        
        tc.Account_Name__c = '123';
        tc.Activity_Type__c = 'Call';
        tc.Approved__c = true;
        tc.Approved_Date__c = date.today();
        tc.Campaign__c = null;
   // IBA-4524     tc.Campaign_Task_Type__c = 'Call';
        tc.Cancelled_Date2__c = date.today();
        tc.Completed_Date__c = datetime.now();
        tc.ActivityDate = date.today();
      //  IBA-4524  tc.EndDateTime__c = datetime.now();
        tc.End_Date_Time__c = datetime.now();
        tc.Follow_up_Tasks_Notes__c = '123';
        tc.Omnicell_Involvement__c = 'Not Engaged';
        tc.Original_Due_Date__c =  date.today();
        tc.Campaign_Name__c = '123';
     /*   tc.Reminder_Date_Time__c = datetime.now();
        tc.IsReminderSet__c = true;      IBA-4524 */
   //  IBA-4524       tc.StartDateTime__c = datetime.now();
        tc.Start_Date_Time__c = datetime.now();
        tc.Description = '123';
        tc.Status = 'Completed';
        tc.ActivityDate = date.today();
        tc.Priority = 'Normal';
        tc.Subject = 'test';
        update tc;
    }
}