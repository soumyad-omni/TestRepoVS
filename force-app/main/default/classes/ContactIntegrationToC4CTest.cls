@isTest
public class ContactIntegrationToC4CTest {
     public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
     public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;    
       
    @testsetup
    static void testdatasetup(){
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
            AccountTriggerHandler.TriggerDisabled = true;
            insert acct; 
            UserTriggerHandler.TriggerDisabled = True;
            User u = TestDataFactory.createUserBusinessAdmin(true, 'TestUser', 'BusinessAdmin');
            UserTriggerHandler.TriggerDisabled = True;
            User u1 = TestDataFactory.createSalesUser(true, 'TestSales', 'RepUser');
            SCP_TestDataFactory.createCastIron();
        
            /*Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;*/
            
            Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
            
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
            
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
        Account_Field_Tracking__c  setting311 = new Account_Field_Tracking__c ();
        setting311.Name = 'PARENTID';
        insert setting311;
        Account_Field_Tracking__c  setting312 = new Account_Field_Tracking__c ();
        setting312.Name = 'RECORDTYPEID';
        insert setting312;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
        con.SAP_Contact_ID__c = '112334';
        update con;
    }
    static testMethod void testContactIntegrationCallout() {
        Test.setMock(HttpCalloutMock.class, new C4CIntegrationMock());  
        List<Contact> newcon = [Select id,name from Contact];
        ContactIntegrationToC4C.sendContactsToC4c(newcon);
    }
    static testMethod void testAccountIntegrationCallout() {
        Test.setMock(HttpCalloutMock.class, new C4CIntegrationMock());  
        List<Account> accs = [Select id,SAP_Account_ID__c,SAP_Customer_Number__c from Account];
        AccountIntegrationToC4C.sendAccountInfoToC4c(accs);
    }
    static testMethod void testAccountContactRelationship(){
        Test.setMock(HttpCalloutMock.class, new C4CIntegrationMock());  
        List<Contact> newcon = [Select id,name from Contact];
        RelationIntegrationWithC4C.sendAccountContactsRelationshipToC4c(newcon);
    }
    static testMethod void testAccountRelationship(){
        Test.setMock(HttpCalloutMock.class, new C4CIntegrationMock());
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        SAP_Sales_Org__c sso = [select id from SAP_Sales_Org__c where account__c =:acc1.Id];
        Account acc2 = [Select id from account where SAP_Account_ID__c = '0000013903' Limit 1];
        GPO_Account__c gpo = new GPO_Account__c();
            gpo.name = 'test';
            gpo.Account_Id__c = '0011k00000CjPQVAA3';
            insert gpo;
        test.starttest();
        Relationship__c rel = new Relationship__c();
            rel.Primary_Account__c = acc1.Id;
            rel.Secondary_Account__c = acc2.Id;
            rel.Primary_Account_Sales_Org__c = sso.Id;
            rel.Relationship__c ='ZG';
            try{
                insert rel;
            }catch(Exception e){
                system.debug('Error ' + e.getMessage());
                System.assert(e.getMessage().contains('Primary Account has not been validated or is archived'));
                System.assert(e.getMessage().contains('Secondary Account has not been validated or is archived'));
            }
        List<Relationship__c> relList = new List<Relationship__c>();
        relList.add(rel);
        Test.setMock(HttpCalloutMock.class, new C4CIntegrationMock()); 
        RelationIntegrationWithC4C.sendRelationshipDataToC4C(relList);
            test.stoptest();
    }
}