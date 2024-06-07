@isTest

private class OCB_UserRegisterServiceTest {

    static testMethod void myUnitTest() {
       RestRequest req = new RestRequest(); 
       RestResponse res = new RestResponse();

       req.addHeader('httpMethod', 'POST');
       req.requestUri = '/services/apexrest/OCB_UserRegisterService/';       
       String JSONMsgBody = '{"CSN":"123456","email":"test@test.com"}';
       String JsonMsg=JSON.serialize(JSONMsgBody);
       req.requestBody = Blob.valueof(JsonMsg);
       RestContext.request = req; 
       RestContext.response= res;
         
        Account account = new Account();
        account.Name = 'test corp';
        account.phone= '01123123';
        account.billingcity='London';
        account.billingpostalcode='SW1635HJ';
        account.billingcountryCode='US';
        account.Facility_Type__c='Home Health';
        account.billingstreet='address 1';
        account.Account_Role__c = 'ZCSN';
        account.SAP_Account_ID__c ='123458';
        insert account;

         //Insert contact for Account
        Contact c = new Contact();
        c.AccountId = account.ID;
        c.FirstName = 'test';
        c.LastName = 'test';
        c.email = 'test@test.com';
        insert c;

         Test.startTest();
        
         String result = OCB_UserRegisterService.CreateUser('1234','test@expl.com');
         System.assertEquals('Account Role type should be Sold To for user enablement',result);
         //Account is type of SOLD TO
         String result2 = OCB_UserRegisterService.CreateUser(account.SAP_Account_ID__c,c.email);
         System.assert(result2.contains('User is Created'));
         //Contact is already enabled for portal
         String result3 = OCB_UserRegisterService.CreateUser(account.SAP_Account_ID__c,c.email);
         //System.assert(result3.contains('User was created previously'));
         
         Test.stopTest();
                  

   }

}