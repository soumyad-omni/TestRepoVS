@isTest
public class OpportunityContactRoleTriggerHandlerTest {
    
    
    @isTest
    public static void OppContactRoleInsertTest(){
        AccountTriggerHandler.TriggerDisabled = True;
        UserTriggerHandler.TriggerDisabled = True;
        Account acc = TestDataFactory.createUSTestAccount();
        RecordType rtUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'NAA_Opportunity'];
        User usr1 = TestDataFactory.createUserBusinessAdmin(true, 'TestUser', 'BusinessAdmin');
        User usr2 = TestDataFactory.createSalesUser(true, 'TestSales', 'RepUser');
        Contact con1 = TestDataFactory.createTestContact(true, acc.id, 'TestCon1', usr1.id);
        Contact con2 = TestDataFactory.createTestContact(true, acc.id, 'TestCon2', usr2.id);
        Contact noGuidContact = new Contact();
        noGuidContact.AccountId = acc.Id;
        noGuidContact.Salesforce_Contact_ID__c ='5678';
        noGuidContact.LastName = 'lastName';
        ContactTriggerHandler.TriggerDisabled = True;
        insert noGuidContact;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.AccountId = acc.id;
        opp.RecordTypeId = rtUS.Id;
        opp.OppStatus__c = 'Open';
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Adam Barrios';
        OpportunityTriggerHandler.TriggerDisabled = True;
        insert opp;
        
        OpportunityContactRole ocrContNoGuid = new OpportunityContactRole();
        ocrContNoGuid.ContactId = noGuidContact.id;
        ocrContNoGuid.OpportunityId = opp.id;
        ocrContNoGuid.IsPrimary = false;
        ocrContNoGuid.Role = 'S-Shipping Contact';
        Test.startTest();
        try{
            insert ocrContNoGuid;
        }catch(Exception e) {
            String expectedMessage = 'The Contact associated with the Shipping Contact Role does not have a SAP GUID ID.';
            System.assert(e.getMessage().contains(expectedMessage), 'Expected error message: ' + expectedMessage + ', Actual error message: ' + e.getMessage());
        }
        
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        quote.Order_Type__c = 'ZHQR';
        quote.OpportunityId = opp.Id;
        quote.Shipping_Contact__c= con1.Id;
        quote.Bill_to_Account__c = acc.Id;
        quote.Status= 'E0001';
        quote.Pricebook2Id = Test.getStandardPricebookId();
        QuoteTriggerHandler.TriggerDisabled = True;
        insert quote;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con1.id;
        ocr.OpportunityId = opp.id;
        ocr.Role = 'Business User';
        ocr.IsPrimary = false;
        try{
        insert ocr;
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = con1.id;
        ocr2.OpportunityId = opp.id;
        ocr2.Role = 'Business User';
        ocr2.IsPrimary = false;
        
            insert ocr2;
        } catch(Exception e) {
            String expectedMessage = 'This Opportunity already contains a Contact Role with S-Shipping Contact. Please delete the existing Contact Role to create a new One.';
            System.assert(e.getMessage().contains(expectedMessage), 'Expected error message: ' + expectedMessage + ', Actual error message: ' + e.getMessage());
        }
        ocr.Role = 'S-Shipping Contact';
        ocr.ContactId = con2.id;
        try{
            update ocr;
        }
        catch(Exception e){
            String expectedMessage = 'You cannot change the shipping contact for this opportunity.';
            //System.assert(e.getMessage().contains(expectedMessage), 'Expected error message: ' + expectedMessage + ', Actual error message: ' + e.getMessage());
        }
        //delete ocr;
        Test.stopTest();
    }
    
    @isTest
    public static void testmethod2(){
        AccountTriggerHandler.TriggerDisabled = True;
        UserTriggerHandler.TriggerDisabled = True;
        Account acc = TestDataFactory.createUSTestAccount();
        RecordType rtUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND  DeveloperName = 'NAA_Opportunity'];
        User usr1 = TestDataFactory.createUserBusinessAdmin(true, 'TestUser', 'BusinessAdmin');
        User usr2 = TestDataFactory.createSalesUser(true, 'TestSales', 'RepUser');
        Contact con1 = TestDataFactory.createTestContact(true, acc.id, 'TestCon1', usr1.id);
        Contact con2 = TestDataFactory.createTestContact(true, acc.id, 'TestCon2', usr2.id);
        Contact noGuidContact = new Contact();
        noGuidContact.AccountId = acc.Id;
        noGuidContact.Salesforce_Contact_ID__c ='5678';
        noGuidContact.LastName = 'lastName';
        noGuidContact.SAP_Contact_GUID__c = 'ABCDEFGHIJKL111';
        noGuidContact.SAP_Contact_ID__c = '1234567890';
        ContactTriggerHandler.TriggerDisabled = True;
        insert noGuidContact;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.AccountId = acc.id;
        opp.RecordTypeId = rtUS.Id;
        opp.OppStatus__c = 'Open';
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Adam Barrios';
        OpportunityTriggerHandler.TriggerDisabled = True;
        insert opp;
        
        OpportunityContactRole ocrContNoGuid = new OpportunityContactRole();
        ocrContNoGuid.ContactId = noGuidContact.id;
        ocrContNoGuid.OpportunityId = opp.id;
        ocrContNoGuid.IsPrimary = false;
        ocrContNoGuid.Role = 'S-Shipping Contact';
        Test.startTest();
        insert ocrContNoGuid;
        ocrContNoGuid.Role = 'U-Unknown';
        update ocrContNoGuid;
        delete ocrContNoGuid;
        Test.stopTest();
    }
}