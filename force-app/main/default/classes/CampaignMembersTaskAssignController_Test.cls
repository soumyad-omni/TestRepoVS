/**********************************************************************
Name: CampaignMembersTaskAssignController_Test
Copyright © 2017
======================================================
======================================================
Purpose: Test Class for CampaignMembersTaskAssignController
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR           DATE             DETAIL               Description

0.1        Supriya A        06/19/2017           Updates by CG Team       Updated as part of Campaign Assign task functionality
***********************************************************************/

@isTest
public class CampaignMembersTaskAssignController_Test{
    
    
    @TestSetup
    public static void testDataSetup() {
        //Test.StartTest(); 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        UserTriggerHandler.TriggerDisabled = true;
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');   
        
        // Create a new account
        
        AccountCreateController.isFirstRun= false;
        ContactTriggerHandler.TriggerDisabled = true;
        SCP_TestDataFactory.createContact_Customsetting();
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
         insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                          BillingPostalCode='95128', SAP_Account_ID__c='13903',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        insert acc;
        Account newAccount = TestDataFactory.createtestaccountquoteprint();
        
        // Create new contacts for the campaign members
        
        Contact newContact= TestDataFactory.createTestContact(true,newAccount.id,'Doe',u.id);
        
        
        //Create State Data
        
        StateData__c stateData= new StateData__c();
        stateData.Name='CA';
        stateData.Inside_Sales_Rep_Owner__c=u.id;
        stateData.Lead_Qualification_Team_Owner__c=u.Id;
        
        insert stateData;
        
        // Create new Lead for the campaign members
        
        Lead newLead= TestDataFactory.createTestLead(true,newAccount.id,'ABC hospital','Doe',u.id);
        
        System.debug('newLead in test exceution: '+newLead);
        // Create a new campaign
        Campaign newCampaign = TestDataFactory.createTestCampaign(true,'Test Campaign');
        
        Acct_Team_Roles_for_Followup_Task__c aTRoles = new Acct_Team_Roles_for_Followup_Task__c();
        aTRoles.Name= 'Inside Sales Rep';
        aTRoles.Account_Team_Role__c = 'Inside Sales Rep';
        insert aTRoles;
        
        //Test.StopTest();
        
    }
    
    static testMethod void maiTestOfCampaignMembersTaskAssign() {
        System.debug('inside function...');
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.Campaign_Members_Task_Assign;
        
        // Start the test, this changes governor limit context to
        // that of trigger rather than test.
        test.startTest();
        
        // Set the Page
        test.setCurrentPage(pageRef);
        
        System.debug('1..............');
        Contact conct = [SELECT Id, LastName FROM Contact WHERE LastName='Doe' LIMIT 1];
        System.debug('2..............');
        Campaign newCampaign = [SELECT Id, Name FROM Campaign WHERE Name='Test Campaign' LIMIT 1];
        System.debug('3..............');
        
        // Assign campaign members for Contacts and Leads
        System.debug('4..............');
        CampaignMember newContactCM = TestDataFactory.createCampaignMemberFromContact(true,newCampaign.Id,conct.Id,'sent');
        System.debug('5..............');
        //CampaignMember newLeadCM = TestDataFactory.createCampaignMemberFromLead(true,newCampaign.Id,newLead.Id,'Responded');
        
        System.debug('6..............');
        ApexPages.StandardController sc = new ApexPages.standardController(newCampaign);
        System.debug('7..............');
        //
        System.currentPageReference().getParameters().put('CampaignId', newCampaign.id);
        System.currentPageReference().getParameters().put('CampaignName', newCampaign.name);
        
        //Instantiate and construct the controller class.  
        CampaignMembersTaskAssignController controller = new CampaignMembersTaskAssignController();
        
        
        CampaignMembersWrapper cmw = new CampaignMembersWrapper();
        cmw.cm = newContactCM ;
        cmw.checked = true;    
        
        controller.selectedCampaignMembers.add(cmw);
		System.debug('8..............');
        controller.selAssignedTo= 'Account Owner'; 
        System.debug('9..............');
        
        // add all
        controller.addAll();
        
        //  Test to see what happens if we don't fill out Task fields
        //controller.assignTaskToCampaignMembers();
        
        // Set up task
        controller.t.Subject='Test';
        controller.t.Description='Test Me';
        controller.t.ActivityDate=Date.today();
        controller.t.Priority='Normal';
        controller.t.Status='Not Started';
        controller.getProxyObject();
        
        //
        controller.assignTaskToCampaignMembers();
        
        //
        controller.returnToCampaign();
        
        controller.clearFilter();
        controller.checkBoxSelected();
        controller.getResponseStatus();
        
        controller.addSelectedMemberToList();
        controller.getAssignToValues();
        controller.getMemberStatusValues();
        controller.getMemberTypeValues();
        controller.getOmnicellJobTitleValues();
        controller.getLeadClassificationValues();
        controller.getProductOpportunityValues();
        controller.next();
        controller.previous();
        controller.getPageIndexes();
        controller.getPageNumber();
        controller.doNothing();
        controller.removeAll();
        
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();
    }
    
    
    public static testMethod void maiTestOfCampaignMembersTaskAssign1() {
        
        
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.Campaign_Members_Task_Assign;
        
        // Start the test, this changes governor limit context to
        // that of trigger rather than test.
        test.startTest();
        
        // Set the Page
        test.setCurrentPage(pageRef);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');   
        
        
         System.runAs(u){
       AccountCreateController.isFirstRun= false;
       SCP_TestDataFactory.createContact_Customsetting(); 
       Account newAccount = TestDataFactory.createtestaccountquoteprint();
        
        // Create new contacts for the campaign members
        
        Contact newContact= TestDataFactory.createTestContact(true,newAccount.id,'Doe',u.id);
        
        
        
        // Create new Lead for the campaign members
        
       Lead newLead= TestDataFactory.createTestLead(true,newAccount.id,'ABC hospital','Doe',u.id);
        
        //Lead newLead = [SELECT Id, LastName, Company FROM Lead WHERE LastName='Doe' and Company='ABC hospital' LIMIT 1];
        
        Campaign newCampaign = [SELECT Id, Name FROM Campaign WHERE Name='Test Campaign' LIMIT 1];
        
        // Assign campaign members
        CampaignMember newCM = new CampaignMember (campaignid=newCampaign.Id,leadid=newLead.Id);
        insert newCM;
        
        ApexPages.StandardController sc = new ApexPages.standardController(newCampaign);
        
        //
        System.currentPageReference().getParameters().put('CampaignId', newCampaign.id);
        System.currentPageReference().getParameters().put('CampaignName', newCampaign.name);
        
        //Instantiate and construct the controller class.  
        CampaignMembersTaskAssignController controller = new CampaignMembersTaskAssignController();
        
        
        CampaignMembersWrapper cmw = new CampaignMembersWrapper();
        cmw.cm = newCM;
        cmw.checked = true;    
        
        controller.selectedCampaignMembers.add(cmw);
        controller.selAssignedTo='Lead Owner'; 
        
        
        // add all
        controller.addAll();
        
        
        // Set up task
        controller.t.Subject='Test';
        controller.t.Description='Test Me';
        controller.t.ActivityDate=Date.today();
        controller.t.Priority='Normal';
        controller.t.Status='Not Started';
        controller.getProxyObject();
        
        //
        controller.assignTaskToCampaignMembers();
        
        
        controller.selMemberstat='Sent';
        controller.selMemberType='Contact';
        controller.selAcctOwnerName='Test user';
        controller.selectedJobTitle='';
        controller.selectedLeadClassification='A';
        controller.selectedProductOpportunity='Easyseal';
        
        
        controller.addFilter();
         }
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();
        
    }
    
    
    
    
    public static testMethod void maiTestOfCampaignMembersTaskAssign2() {
        
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.Campaign_Members_Task_Assign;
        
        // Start the test, this changes governor limit context to
        // that of trigger rather than test.
        test.startTest();
        
        // Set the Page
        test.setCurrentPage(pageRef);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');   
        
        //Lead newLead = [SELECT Id, LastName, Company FROM Lead WHERE LastName='Doe' and Company='ABC hospital' LIMIT 1];
        
        
       // Contact conct = [SELECT Id, LastName FROM Contact WHERE LastName='Doe' LIMIT 1];
       
       AccountCreateController.isFirstRun= false;
        
        Account newAccount = TestDataFactory.createtestaccountquoteprint();
        
        // Create new contacts for the campaign members
        
        Contact newContact= TestDataFactory.createTestContact(true,newAccount.id,'Doe',u.id);
        
        
        //Create State Data
        
        StateData__c stateData= new StateData__c();
        stateData.Name='CA';
        stateData.Inside_Sales_Rep_Owner__c=u.id;
        stateData.Lead_Qualification_Team_Owner__c=u.Id;
        
        insert stateData;
        
        // Create new Lead for the campaign members
        
        Lead newLead= TestDataFactory.createTestLead(true,newAccount.id,'ABC hospital','Doe',u.id);
        
        
        Campaign newCampaign = [SELECT Id, Name FROM Campaign WHERE Name='Test Campaign' LIMIT 1];
        
        // Assign campaign members
        
        CampaignMember newContactCM = TestDataFactory.createCampaignMemberFromContact(true,newCampaign.Id,newContact.Id,'sent');
        
        CampaignMember newLeadCM = TestDataFactory.createCampaignMemberFromLead(true,newCampaign.Id,newLead.Id,'Responded');
        
        ApexPages.StandardController sc = new ApexPages.standardController(newCampaign);
        
        //
        System.currentPageReference().getParameters().put('CampaignId', newCampaign.id);
        System.currentPageReference().getParameters().put('CampaignName', newCampaign.name);
        
        //Instantiate and construct the controller class.  
        CampaignMembersTaskAssignController controller = new CampaignMembersTaskAssignController();
        
        
        CampaignMembersWrapper cmw = new CampaignMembersWrapper();
        cmw.cm = newLeadCM ;
        cmw.checked = true;    
        
        controller.selectedCampaignMembers.add(cmw);
        controller.selAssignedTo='Lead Qualification Team'; 
        
        
        // add all
        controller.addAll();
        
        
        // Set up task
        controller.t.Subject='Test';
        controller.t.Description='Test Me';
        controller.t.ActivityDate=Date.today();
        controller.t.Priority='Normal';
        controller.t.Status='Not Started';
        controller.getProxyObject();
        
        //
        Controller.selAssignedTo=System.Label.Inside_Sales_Rep;
        controller.assignTaskToCampaignMembers();
        
        controller.selMemberstat='Responded';
        controller.selMemberType='Lead';
        controller.selAcctOwnerName='Test user';
        controller.selectedJobTitle='';
        controller.selectedLeadClassification='A';
        controller.selectedProductOpportunity='Easyseal';
        
        
        controller.addFilter();
        Integer index;
        
        // Stop the test, this changes limit context back to test from trigger.
        
        //CampaignMembersTaskAssignController.objWrapper lobjWrapper= new CampaignMembersTaskAssignController.objWrapper(newContactCM,index=1);
        
        
        //CampaignMembersTaskAssignController.objWrapper lobjWrapper1= new CampaignMembersTaskAssignController.objWrapper(newLeadCM,index=1);
        
        
        // controller.cmList = new List<CampaignMembersTaskAssignController.objWrapper>();
        
        test.stopTest();
    }
    
    
    public static testMethod void maiTestOfCampaignMembersTaskAssign3() {
        //
        User usr = new User();
        Group grp = new Group();
        
        //
        List<User> usrs = [Select id from user where lastname='Integration' and firstname='Admin'];
        for (User u: usrs) { usr = u; }
        
        // Create new Group
        List<Group> grps = [Select id from group where name ='Lead Nurturing Queue'];
        for (Group g: grps) { grp = g; }
        
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.Campaign_Members_Task_Assign;
        
        // Start the test, this changes governor limit context to
        // that of trigger rather than test.
        test.startTest();
        
        // Set the Page
        test.setCurrentPage(pageRef);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles'); 
        
        //Lead newLead = [SELECT Id, LastName, Company FROM Lead WHERE LastName='Doe' and Company='ABC hospital' LIMIT 1];
        
        
      //  Contact conct = [SELECT Id, LastName FROM Contact WHERE LastName='Doe' LIMIT 1];
      
      
      AccountCreateController.isFirstRun= false;
        
        Account newAccount = TestDataFactory.createtestaccountquoteprint();
        
        // Create new contacts for the campaign members
        
        Contact newContact= TestDataFactory.createTestContact(true,newAccount.id,'Doe',u.id);
        
        
        //Create State Data
        
        StateData__c stateData= new StateData__c();
        stateData.Name='CA';
        stateData.Inside_Sales_Rep_Owner__c=u.id;
        stateData.Lead_Qualification_Team_Owner__c=u.Id;
        
        insert stateData;
        
        // Create new Lead for the campaign members
        
        Lead newLead= TestDataFactory.createTestLead(true,newAccount.id,'ABC hospital','Doe',u.id);
        
        Campaign newCampaign = [SELECT Id, Name FROM Campaign WHERE Name='Test Campaign' LIMIT 1];
        
        // Assign campaign members
        
        CampaignMember newContactCM = TestDataFactory.createCampaignMemberFromContact(true,newCampaign.Id,newContact.Id,'sent');
        
        CampaignMember newLeadCM = TestDataFactory.createCampaignMemberFromLead(true,newCampaign.Id,newLead.Id,'Responded');
        
        ApexPages.StandardController sc = new ApexPages.standardController(newCampaign);
        
        //
        System.currentPageReference().getParameters().put('CampaignId', newCampaign.id);
        System.currentPageReference().getParameters().put('CampaignName', newCampaign.name);
        
        //Instantiate and construct the controller class.  
        CampaignMembersTaskAssignController controller = new CampaignMembersTaskAssignController();
        
        
        CampaignMembersWrapper cmw = new CampaignMembersWrapper();
        cmw.cm = newContactCM ;
        cmw.checked = true;    
        
        controller.selectedCampaignMembers.add(cmw);
        controller.selAssignedTo='Inside Sales Team';
        
        
        
        
        // add all
        controller.addAll();
        
        
        // Set up task
        controller.t.Subject='Test';
        controller.t.Description='Test Me';
        controller.t.ActivityDate=Date.today();
        controller.t.Priority='Normal';
        controller.t.Status='Not Started';
        controller.getProxyObject();
        
        //
        controller.selAssignedTo =System.Label.IV_Sales_Consultant;
        controller.assignTaskToCampaignMembers();    
        controller.addMembersToAssignTaskTab();    
        
        controller.selMemberstat='Responded';
        controller.selMemberType='Lead';
        controller.selAcctOwnerName='Test user';
        controller.selectedJobTitle='';
        controller.selectedLeadClassification='A';
        controller.selectedProductOpportunity='Easyseal';
        //
        controller.addFilter();
        
        controller.addAllMembers();
        
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();
    }
    
    
    
    
    public static testMethod void maiTestOfCampaignMembersTaskAssign4() {
        
        //Use the PageReference Apex class to instantiate a page
        PageReference pageRef = Page.Campaign_Members_Task_Assign;
        
        // Start the test, this changes governor limit context to
        // that of trigger rather than test.
        test.startTest();
        
        // Set the Page
        test.setCurrentPage(pageRef);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles'); 
      
      
         AccountCreateController.isFirstRun= false;
        
        Account newAccount = TestDataFactory.createtestaccountquoteprint();
        
        // Create new contacts for the campaign members
        
        Contact newContact= TestDataFactory.createTestContact(true,newAccount.id,'Doe',u.id);
        newContact.Omnicell_Job_Code__c='C1';
        update newContact;
        //Create State Data
        
        StateData__c stateData= new StateData__c();
        stateData.Name='CA';
        stateData.Inside_Sales_Rep_Owner__c=u.id;
        stateData.Lead_Qualification_Team_Owner__c=u.Id;
        
        insert stateData;
        
        // Create new Lead for the campaign members
        
        Lead newLead= TestDataFactory.createTestLead(true,newAccount.id,'ABC hospital','Doe',u.id);
        
        Campaign newCampaign = [SELECT Id, Name FROM Campaign WHERE Name='Test Campaign' LIMIT 1];
        
        // Assign campaign members
        
        CampaignMember newContactCM = TestDataFactory.createCampaignMemberFromContact(true,newCampaign.Id,newContact.Id,'sent');
        
        CampaignMember newLeadCM = TestDataFactory.createCampaignMemberFromLead(true,newCampaign.Id,newLead.Id,'Responded');
        
        ApexPages.StandardController sc = new ApexPages.standardController(newCampaign);
        
        //
        System.currentPageReference().getParameters().put('CampaignId', newCampaign.id);
        System.currentPageReference().getParameters().put('CampaignName', newCampaign.name);
        
        //Instantiate and construct the controller class.  
        CampaignMembersTaskAssignController controller = new CampaignMembersTaskAssignController();
        
        
        CampaignMembersWrapper cmw = new CampaignMembersWrapper();
        cmw.cm = newContactCM ;
        cmw.checked = true;    
        
        controller.selectedCampaignMembers.add(cmw);
        
        
        // add all
        controller.addAll();
        
        
        // Set up task
        controller.t.Subject='Test';
        controller.t.Description='Test Me';
        controller.t.ActivityDate=Date.today();
        controller.t.Priority='Normal';
        controller.t.Status='Not Started';
        controller.getProxyObject();
        
        //
        controller.selAssignedTo =System.Label.Key_Account_Manager;
        controller.assignTaskToCampaignMembers();    
        controller.addMembersToAssignTaskTab();    
        
        controller.selMemberstat='Responded';
        controller.selMemberType='Lead';
        controller.selAcctOwnerName='Test user';
        controller.selectedJobTitle='';
        controller.selectedLeadClassification='A';
        controller.selectedProductOpportunity='Easyseal';
        

        //
        
       // controller.addFilter();
        
        //controller.addAllMembers();
        
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();
    }
    
}