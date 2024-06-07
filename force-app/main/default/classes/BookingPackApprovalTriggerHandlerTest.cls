@isTest
public class BookingPackApprovalTriggerHandlerTest { 
    public testMethod static void Internationalopportunity(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Trigger_Configuration__c tc = new Trigger_Configuration__c();
        tc.Name = 'BookingPackTriggerDisabled';
        tc.IsDisabled__c = false;
        insert tc;
        Set<Id> testIds = new Set<Id>();
        Map<id,Booking_Pack_Approval__c> oldmap = new Map<id,Booking_Pack_Approval__c>();
        Map<id,Booking_Pack_Approval__c> newmap = new Map<id,Booking_Pack_Approval__c>();
        Opportunity opp = new Opportunity();
        opp.name = 'International Opportunity';
        opp.stageName = '1 Discover';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId();   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution';
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today();
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        //opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        User oid = [Select Id, name from User where profile.name ='System Administrator' limit 1];
        opp.OwnerId= oid.Id;
        //test.startTest();
        insert opp;
        
        opp.stageName = '6 Closed Won';
        opp.Reason_for_Loss__c = 'Price';
        opp.CommentsWinLoss__c = 'test';
        opp.Pipeline_Category__c = 'Booked';
        opp.Credit_Check_Required__c=false;
        update opp;
        test.startTest();
        Booking_Pack_Approval__c bpa = new Booking_Pack_Approval__c();
        bpa.Request_Type__c = 'Submit Booking Approval';
        bpa.Status__c = 'Paperwork Validated';
        bpa.Comment__c = 'Test Record';
        bpa.Opportunity_Name__c = opp.id;
        bpa.Papwerwork_Submitted_Date__c = System.today();
        bpa.Paperwork_Validated_Date__c = System.today();
        bpa.Approve_Reject_Comments__c = 'Approved';
        insert bpa;
        
        oldmap.put(bpa.Id, bpa);
        newmap.put(bpa.Id, bpa);
        
        BookingPackApprovalTriggerHandler bpath = new BookingPackApprovalTriggerHandler();
        bpath.updateOpportunityAfterApproval(newmap.values());
        BookingPackApprovalTriggerHandler.updateApprovalOrRejectionComment(newmap.keySet());
        test.stopTest();
    }
}