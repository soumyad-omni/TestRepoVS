@isTest
public class pandoraTaskBatchTest 
{
    public static contact con;
    public static account acct;
    public static Task tsk1;
    public static Task tsk2;
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
        acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000010012',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = 'DY6 9HP';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acct; 
        
        con = New Contact();
        con.AccountId = acct.Id;
        con.LastName = userinfo.getFirstName()+' '+userinfo.getLastName();
        insert con;
        
        tsk1 = New Task();
        insert tsk1;
        
        tsk2 = New Task();
        tsk2.Legacy_Pandora_Id__c = tsk1.Id;
        insert tsk2;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new pandoraMockDataTest1());
        database.executeBatch(New pandoraTaskBatch());
        test.stopTest();
    }
    
    private class pandoraMockDataTest1 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            if(req.getEndpoint().contains('https://login.salesforce.com/services/oauth2/token'))
            {
                res.setBody('{"instance_url":"www.omnicell.com","access_token":"1234"}');
            }
            else
            {
                res.setBody('{"records":[{"Id":"'+tsk1.Id+'","whoId":"'+con.Id+'","AccountId":"'+acct.Id+'","whatId":"'+acct.Id+'"}]}');
            }
            
            return res;
        }
    }
}