@isTest
public with sharing class CampaignActivityPlanningController_Test {

    static testMethod void testCampaignActivityPlanningController() {

    // Get user
    //User u = [Select id, lastname, firstname from User where lastname = 'Szurley'];
   // User u = [Select id, lastname, firstname from User where profileid = '00e1N000001wGWFQA2' and isactive = true limit 1];

    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        UserTriggerHandler.TriggerDisabled = true;
        User u = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');   

    // Get Campaign Record Type Id
    
    System.runAs(u){
    RecordType rtCampTask = [Select id from RecordType where name = 'Master'];

    //
    // Create Account
    //
    AccountCreateController.isFirstRun= false;

    Account acct = TestDataFactory.createTestAccountQuotePrint();
    //
    System.AssertNotEquals(acct.Id, null);
    Id iAccount = acct.Id;
    //acct.AcuDose_Rx__c = 1; IBA-1992 Abhrajitc
    //acct.Anesthesia_Rx__c = 1; IBA-1992 Abhrajitc
    update acct;
    //
    // Create Campaign
    //
    Campaign cmp = TestDataFactory.createTestCampaign(true, 'New Test Campaign');
    //
    System.AssertNotEquals(cmp.Id, null);
    //
    // Create Task
    //
      Task retTask = new Task();
      //subject?
      retTask.WhatId = cmp.Id;
    retTask.ActivityDate = date.today();
    retTask.Priority = 'Normal';
    retTask.RecordTypeId = rtCampTask.Id;
    retTask.OwnerId = u.id;
    //IBA-4524 retTask.Campaign_Task_Type__c = 'Planning Purposes';
    insert retTask;
    
    
    //
    //Use the PageReference Apex class to instantiate a page
         PageReference pageRef = Page.Campaign_Activity_Planning;
    //
    test.startTest();
    //
      // Test the VF page named Campaign Pick Members
      test.setCurrentPageReference(pageRef);
      //
      ApexPages.StandardController sc = new ApexPages.StandardController(cmp);
          
      //Instantiate and construct the controller class.  
           CampaignActivityPlanningController controller = new CampaignActivityPlanningController(sc);
      //
      List<Task> lTasks = controller.getTsks();
      List<Task> lFollowTasks = controller.getTsksFollow();
      PageReference pgref = controller.newPlanning();
      PageReference assTasks = controller.assignTasks();
      //
    //
    test.stopTest();
    //
        
    }
    }
}