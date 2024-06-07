@isTest
public class UserUpdateFromOpticWebServiceTest 
{
    @isTest public static void method1()
    {
        Trigger_Configuration__c  cs = new Trigger_Configuration__c ();
        cs.Name = 'CoveredPersonInOpticIntegration';
        cs.IsDisabled__c = false;
        insert cs;
        
        Id profId = [SELECT id FROM Profile WHERE name = 'System Administrator'].Id;
        
        User usr = new User();
        usr.FirstName = 'Optic';
        usr.LastName = 'Integration';
        usr.Alias = 'optic';
        usr.Email = 'test.optic@omnicell.com';
        usr.UserName = 'test.optic@omnicell.com';
        usr.ProfileId = profId;
        usr.EmailEncodingKey='UTF-8';
        usr.LanguageLocaleKey='en_US';
        usr.LocaleSidKey='en_US';
        usr.TimeZoneSidKey='America/Los_Angeles';
        UserTriggerHandler.TriggerDisabled = True;
        insert usr;
        
        test.startTest();
        RestRequest req = new RestRequest();
        String reqBody = '[{"salesforceUserRecordId": "'+usr.Id+'","FirstName":"Optic","LastName" : "Integration","Email": "test.optic@omnicell.com","EmployeeNumber": "1111","OmnicellEmployeeNumber": "1111","IsActive": false,"IsCovered": true,"Manager": "2222","ManagerName": "Optic Manager","ManagerEmail": "testOpticManager@omnicell.com"}]';
        req.requestBody=Blob.valueof(reqBody);
        
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateUserFromOptic'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        UserUpdateFromOpticWebService.post();
        UserUpdateFromOpticWebService.saveErrorLogException('errorMessage', 'errorLocation', 'RestResource' ,'JSON');
        
        reqBody = '[{"salesforceUserRecordId": "test"}]';
        req.requestBody=Blob.valueof(reqBody);
        RestContext.request = req;
        UserUpdateFromOpticWebService.post();
        
        reqBody = '';
        req.requestBody=Blob.valueof(reqBody);
        RestContext.request = req;
        UserUpdateFromOpticWebService.post();
        test.stopTest();
    }
}