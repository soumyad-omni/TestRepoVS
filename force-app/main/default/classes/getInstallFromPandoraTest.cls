@isTest
public class getInstallFromPandoraTest 
{
    public static contact con;
    public static account acct;
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
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new pandoraMockDataTest1());
        getInstallFromPandora.createInstalls();
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
                res.setBody('{"records":[{"Id":"123","name":"'+userinfo.getFirstName()+' '+userinfo.getLastName()+'","Contact__c":"'+con.Id+'","CSN__c":"10012","System_Multi__c":"'+acct.Id+'","Primary_Pandora_Support_Technician__c":"'+userinfo.getUserId()+'"}]}');
            }
            
            return res;
        }
    }
}