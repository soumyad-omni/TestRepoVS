@isTest
private class AccountCreditControllerTest {
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.AccountCreditAppConnect_Endpoint__c= 'https://appconndatadev.omnicell.com/AccountSFtoSAPDEV';
        insert setting;
        
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c(Name = 'SCP_Mulesoft_Authorization', SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token',SCP_Key_Client_Id__c='ooooiiii',SCP_Method_Type__c='POST',SCP_Password_Client_Secret__c='xxxxxxxbbbbbbbbbxx',SCP_Grant_Type__c='CLIENT_CREDENTIALS');
		insert obj2;
        
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008654';
        insert setting2;
        ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
        setting3.Name = 'Omnicell - St.Petes';
        setting3.CRM_Code__c = 'O 50008663';
        insert setting3;
        ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c ();
        setting4.Name = 'Omnicell Inc.';
        setting4.CRM_Code__c = 'O 50000029';
        insert setting4;
        ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c ();
        setting5.Name = 'Omnicell Ltd';
        setting5.CRM_Code__c = 'O 50008655';
        insert setting5;
        ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c ();
        setting6.Name = 'Omnicell SAS';
        setting6.CRM_Code__c = 'O 50011128';
        insert setting6;
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
    }
    
    private static testMethod void test() {
        OpportunityTriggerHandler.TriggerDisabled = true;
        userTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_Credit_Check';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'https://mulesoft.omnicell.com/';
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
        
        AccountCreditWrapperClass.cls_PS_CREDIT_ACCOUNT_DETAIL_ALL data = new AccountCreditWrapperClass.cls_PS_CREDIT_ACCOUNT_DETAIL_ALL();
        data.CRED_LIMIT = '20000';
        //data.CRED_ACCNT = '00000';
        data.RCVBL_VALS = '23000';
        data.CRED_LIAB = '20000';
        //data.CURRENCY_x = 'USA';
        data.RISK_CATEG = 'AA';
        data.BLOCKED = 'NA';
        data.NXT_REVIEW = 'AA';
        data.SECURED_ITEMS = '40000';
        //data.DATA_TOO_OLD = 'NA';
        // data.DATA_NOT_FOUND = 'NA';
        data.AGING_IN_DAYS = 'NA';
        data.AGING_IN_HOURS = 'NA';
        data.ORDER_VALS = '20000';
        data.TOTAL_LIABILITIES = '20000';
        
        AccountCreditWrapperClass.cls_RETURNS data1 = new AccountCreditWrapperClass.cls_RETURNS();
        data1.TYPE = 'NA';
        data1.ID = '12345';
        data1.LOG_MSG_NO = 'NA';
        //data1.LOG_NO = 'NA';
        data1.MESSAGE = 'NA';
        data1.MESSAGE_V1 = 'NA';
        data1.MESSAGE_V2 = 'NA';
        //data1.MESSAGE_V3 = 'NA';
        //data1.MESSAGE_V4 = 'NA';
        data1.NUMBERS = '1234';
        
        Quote quote = TestDataFactory.createTestQuote1();
        quote.Quote_Number__c = '0005390316';
        update quote;
        String json = '{ "output":{ "PS_CREDIT_ACCOUNT_DETAIL_ALL":{ "CRED_LIMIT":0.0000, "RCVBL_VALS":0.0000, "CRED_LIAB":0.0000, "NXT_REVIEW":"0000-00-00", "SECURED_ITEMS":0.0000, "AGING_IN_DAYS":"00", "AGING_IN_HOURS":"00", "ORDER_VALS":0.00, "TOTAL_LIABILITIES":0.00 }, "RETURN_x":{ "TYPE_x":"E", "ID":"F4", "NUMBER_x":"711", "MESSAGE":"Credit limit not maintained for account 80070297 area OM00", "LOG_MSG_NO":"000000", "MESSAGE_V1":"80070297", "MESSAGE_V2":"OM00" } }}';
        AccountCreditWrapperClass.parse(json);
        
        Account a = TestDataFactory.createUSTestAccount();
        String accId = a.id;
        test.startTest();
        //Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
        Test.setMock(HttpCalloutMock.class, new AccountCredit_Mock(201));
        AccountCreditController.showAccountCreditDetails(accId);
        AccountCreditController.getAccountDetails(accId);
        test.stopTest();
    }
    
}