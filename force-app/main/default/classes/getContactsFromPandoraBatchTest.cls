@isTest
public class getContactsFromPandoraBatchTest 
{
    public static testmethod void method1()
    {
        Pandora_Endpoint_Details__c cs = New Pandora_Endpoint_Details__c();
        cs.Name ='Pandora';
        cs.Client_Id__c = '123';
        cs.Client_Secret__c = '123';
        cs.UserName__c = '123@omnicell.com';
        cs.Password__c = '123';
        insert cs;
        
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        SCP_TestDataFactory.createContact_Customsetting();
        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000010012',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = 'DY6 9HP';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acct; 
        
        Contact con = New Contact();
        con.AccountId = acct.Id;
        con.LastName = 'test';
        insert con;
            
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new pandoraMockDataTest());
        database.executebatch(new getContactsFromPandoraBatch('10012,10012'));	
        test.stopTest();
    }
}