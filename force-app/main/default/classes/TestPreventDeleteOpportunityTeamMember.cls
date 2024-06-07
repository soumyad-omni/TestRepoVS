@isTest
public with sharing class TestPreventDeleteOpportunityTeamMember {
    @IsTest
    static void testDelete(){
        Opportunity opp = TestDataFactory.createOppWithAccount();
         User usr = Testdatafactory.createUser(true, 'TestFName', 'TestLName');
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id, 
                                                                UserId = usr.Id, 
                                                                TeamMemberRole = 'System Sales Director');
        insert otm;
        update otm;
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usysadmin = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');
        System.runAs(usysadmin){
            delete otm;
        }
        Test.stopTest();
        
    }

    @IsTest
    static void testNormalUserDelete(){
        Opportunity opp = TestDataFactory.createOppWithAccount();
         User usr = Testdatafactory.createUser(true, 'TestFName', 'TestLName');
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id, 
                                                                UserId = usr.Id, 
                                                                TeamMemberRole = 'System Sales Director');
        insert otm;
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Development']; 
        User usysadmin = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');
        System.runAs(usysadmin){
            DmlException expectedException;
            try {
                delete otm;
            } catch (DmlException d) {
                expectedException = d;
            }
            //system.assertNotEquals(null, expectedException, 'Only Business Administrator/System Administrator/International Sales Ops/Booking Team can edit/delete record!');
        }
        Test.stopTest();
        
    }
     @IsTest
    static void testNormalUserUpdate(){
        Opportunity opp = TestDataFactory.createOppWithAccount();
         User usr = Testdatafactory.createUser(true, 'TestFName', 'TestLName');
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id, 
                                                                UserId = usr.Id, 
                                                                TeamMemberRole = 'System Sales Director');
        insert otm;
        
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Development']; 
        User usysadmin = new User( Alias = 'test', Email='test@omnicell.com', 
                          UserName='test@omnicell.com.omnidev',EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles');
        System.runAs(usysadmin){
            DmlException expectedException;
            try {
                otm.TeamMemberRole = 'Client Success Executive';
                update otm;
            } catch (DmlException d) {
                expectedException = d;
            }
            //system.assertNotEquals(null, expectedException, 'Only Business Administrator/System Administrator/International Sales Ops/Booking Team can edit/delete record!');
        }
        Test.stopTest();
        
    }
}