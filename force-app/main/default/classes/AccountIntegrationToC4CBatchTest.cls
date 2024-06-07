@isTest
public class AccountIntegrationToC4CBatchTest {
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;    
    
    public static testmethod void IntegrationToC4CBatchTest(){
        Test.setMock(HttpCalloutMock.class, new C4CIntegrationMock());
        SCP_TestDataFactory.createContact_Customsetting();
        C4C_Integration__c c4cSettings = new C4C_Integration__c(Name = 'C4CData');
        c4cSettings.Mulesoft_Endpoint__c = 'http://uat-sfdc-sap-integration.us-w1.cloudhub.io';
        c4cSettings.External_Party_Internal_Id__c = 'SFDCCNT300';
        c4cSettings.Recipient_Party_Internal_Id__c = '0M27IIA';
        c4cSettings.Sender_Party_Internal_Id__c = '0M27IIA';
        insert c4cSettings;
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_Mulesoft_Authorization';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting.SCP_Is_Active__c = true;
        insert setting;
        
        SCP_TestDataFactory.createContact_Customsetting();
        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = 'DY6 9HP';
        acct.C4C_Batch_Process_Status__c = 'Processing';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acct; 
        database.executebatch(new AccountIntegrationToC4CBatch(),45);
    }
}