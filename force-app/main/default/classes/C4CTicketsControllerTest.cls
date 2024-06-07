@isTest
private class C4CTicketsControllerTest {

@testsetup
     static void testdatasetup(){
        CastIronIntegration__c  setting2 = new CastIronIntegration__c ();
        setting2.Name = 'CastIronIntegration';
        setting2.C4CServiceTicketAppConnect_Endpoint__c= 'https://appconndatadev.omnicell.com/ODataC4CtoSFDC';
        insert setting2;
           SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_C4CTickets';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'http://uat-aloha-odatac4c-to-sfdc.us-w1.cloudhub.io/api/odata';
        insert setting;
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1uat';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTuat';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        SCP_TestDataFactory.createIntDetails_Auth();
        
        
         
        }
    
    
    private static testMethod void testC4CController() {
        accountTriggerHandler.TriggerDisabled = true;
        Test.setMock(HttpCalloutMock.class, new C4CServiceTickets_mock());
        Default_Currency_by_Country_Code__c currencyCode = new Default_Currency_by_Country_Code__c(Name = 'AZ', Currency_Code__c = 'USD');
        insert currencyCode;
        Account objAccount = new Account(Name = 'Test Account',Validation_Status__c='Validated', Account_Role__c = 'ZCSN', BillingStreet = '330 Brookline Avenue', BillingCity = 'Boston', 
                                         BillingPostalCode = '2215', BillingCountryCode = 'AZ', SAP_Account_ID__c = '310210',Facility_Type__c = 'Health System');
        insert objAccount;
        Test.startTest();
        C4CTicketsController.getTickets(objAccount.Id);
        Test.StopTest();
        String Json = '{"output":{"ServiceRequestCollection":[{"ID":"280522","ActionName":"Recalibrated","AssignedToName":"Sergii Zubyk","ContactName":"Kathy Sarnecki","ProductID":"MED-FRM-103","ReportedOnDate":"2018-11-09T20:52:14Z","SerialID":"136507","ServicePriorityCodeText":"Normal","ServiceRequestUserLifeCycleStatusCodeText":"Completed","Subject":"OC: KGHW4WE2: The label printer is not printing. Reboot fixed an issue."}]}}';
        SAPC4CTickets_AppConnect.deserialize(json);
        
        SAPC4CTickets_AppConnect.ServiceRequestCollection data = new SAPC4CTickets_AppConnect.ServiceRequestCollection('AA','AA','AA');
        data.ID = 'AA';
        data.ProductID = 'AA';
        data.ReportedOnDate = 'AA';
        data.SerialID = 'AA';
        data.ServicePriorityCodeText = 'AA';
        data.ServiceRequestUserLifeCycleStatusCodeText = 'AA';
        data.Subject = 'AA';
        
        
        SAPC4CTickets_AppConnect.ServiceRequestTextCollection data1 = new SAPC4CTickets_AppConnect.ServiceRequestTextCollection('AA','AA','AA',Date.newInstance(2000,1,1),Date.newInstance(2000,1,1),'AA','AA','AA','AA','AA','AA','AA','AA',Date.newInstance(2000,1,1)); 
        SAPC4CTickets_AppConnect n = new SAPC4CTickets_AppConnect();
        n.serialize();
        n.getBackendMessage();
        n.inputSetName = 'AA';
        n.get('Test');
        n.getTopTypeName();
    }

}