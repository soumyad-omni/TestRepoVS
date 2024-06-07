/***********************************************************************************************************
Name:  ContractTriggerHandlerTest
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Test class for the handler class ContractTriggerHandler

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          2/08/2018      Developed by CG team     INITIAL DEVELOPMENT
0.2          Haripriya Maturi          7/08/2018                               Added version history
*************************************************************************************************************/
@isTest
public class ContractTriggerHandlerTest {
    public testmethod static void testContracts(){
        
        Default_Currency_by_Country_Code__c countryCurrencyCode = new Default_Currency_by_Country_Code__c(Name='US',Currency_Code__c='USD');
        insert countryCurrencyCode;
         AccountCreateController.isFirstRun= false; 
        //Account acc=new Account(name='Test account',Account_role__c='ZCSN',Account_Territory__c='NJ', BillingCountryCode='US');
        //insert acc;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        Id recTypeContract = [SELECT Id FROM RecordType WHERE SObjectType = 'Contracts__c' AND Name = 'Boilerplate' LIMIT 1].Id;
        
        Contracts__c contr = new Contracts__c();
        contr.Account__c = acc.Id;
        contr.Type__c = 'Boilerplate Master Agreement';
        contr.Has_all_Checklist_Document_Been_Uploaded__c = true;
        contr.RecordTypeId = recTypeContract;
        contr.Bookings_Team_Approved__c = false;
        contr.Status__c = 'Pending';
        
        insert contr;
       	Set<Id> conIds = new Set<Id>();
        //conIds.add(contr.id);
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Approve.');
            req.setObjectId(contr.Id);
            //Submit the approval request
            Approval.ProcessResult result = Approval.process(req);
        contr.Bookings_Team_Approved__c = true;
        test.startTest();
        update contr;
        delete contr;
        undelete contr;
		test.stopTest();

    }
}