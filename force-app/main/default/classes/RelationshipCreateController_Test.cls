@isTest
public class RelationshipCreateController_Test {
    
  	@testSetup
    static void dataSetup(){
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_AccountSFDCTOSAP';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'http://uat-aloha-accounts.us-w1.cloudhub.io/AccountSFDCToSAP';
        insert setting;
         SCP_Integration_Details__c  setting2 = new SCP_Integration_Details__c ();
        setting2.Name = 'SCP_AccountRelationshipSFDCtoSAP';
        setting2.SCP_Method_Type__c = 'POST';
        setting2.SCP_Timeout__c = 120000;
        setting2.SCP_End_Point__c = 'http://uat-aloha-accounts.us-w1.cloudhub.io/AccountRelationshipsfromSFDC';
        insert setting2;
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
      
        CastIronIntegration__c  setting3 = new CastIronIntegration__c ();
        setting3.Name = 'CastIronIntegration';
        setting3.Accountendpoint__c= 'https://appconndatadev.omnicell.com/AccountSFtoSAPDEV';
        setting3.AccountRelationship__c= 'https://appconndatadev.omnicell.com/AccountRelSFDCtoSAPDEV';
        insert setting3;
        
    }
    
 
    @isTest
    private static void CreateNewRelationship_Test(){
        try{
            Test.setMock(HttpCalloutMock.class, new Relationship_mock());
            AccountCreateController.isFirstRun= false;
            AccountTriggerHandler.TriggerDisabled = True;
            Account acc = TestDataFactory.createTestAccountQuotePrint();
            SAP_Sales_Org__c sso = [select id, account__c from SAP_Sales_Org__c where account__c =:acc.Id];                
            String distributionChannel = 'test';
            String relationshipType = 'Z1';
            String division = '00';
            String counter = '1';
            Test.startTest();
            RelationshipCreateController.CreateNewRelationship(sso.account__c, sso.id, acc.Id, distributionChannel, relationshipType, division, counter, 'X');
            Test.stopTest();
        }catch(Exception e){
            System.Debug('*****'+e);
        }
    }
    
    @isTest
    private static void UpdateAccountRelationship_Test(){
        
        Test.setMock(HttpCalloutMock.class, new Relationship_mock());
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = True;
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        SAP_Sales_Org__c sso = [select id, account__c from SAP_Sales_Org__c where account__c =:acc1.Id];
        Account acc2 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015', Validation_Status__c = 'Validated',SAP_Account_ID__c='0000013903',Facility_Type__c = 'Correctional Facilities');
        acc2.Facility_Type__c = 'Pharmacy';
        acc2.BILLINGSTREET = '41 Moss';
        acc2.BillingPostalCode = 'DY6 9HP';
        insert acc2; 
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc2.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        SAP_Sales_Org__c sso1 = [select id, account__c from SAP_Sales_Org__c where account__c =:acc2.Id];        
        List<account> aList = new List<accounT>();
        aList.add(new account(id = sso.account__c, Validation_Status__c = 'Validated', IsValidated__c = true, Account_Status__c = 'Active') );
        
        update aList;        
        Test.startTest();   
        Relationship__c relation = new Relationship__c(Affiliated_Relationship__c = 'Partnership',
                                                       Primary_Account__c = sso.account__c,
                                                       Primary_Account_Sales_Org__c = sso.id,
                                                       Secondary_Account__c = acc2.id
                                                      );
        insert relation;     
        
        
        RelationshipCreateController.UpdateAccountRelationshipmain(relation.Id, sso.account__c, sso.id, acc1.id, relation.SAP_Division__c,relation.Relationship__c,relation.PARZA__c,relation.Primary_Account__c, relation.Primary_Account_Sales_Org__c,relation.Secondary_Account__c,relation.SAP_Division__c, relation.PARZA__c,relation.Relationship__c,relation,relation);
        Test.stopTest();
        
    }
     
    @isTest
    private static void deleteAccountRelationship_Test(){
        
        Test.setMock(HttpCalloutMock.class, new Relationship_mock());
        
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = True;
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        SAP_Sales_Org__c sso = [select id, account__c from SAP_Sales_Org__c where account__c =:acc1.Id];
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        SAP_Sales_Org__c sso1 = [select id, account__c from SAP_Sales_Org__c where account__c =:acc2.Id];        
        List<account> aList = new List<accounT>();
        aList.add(new account(id = sso.account__c, Validation_Status__c = 'Validated', IsValidated__c = true, Account_Status__c = 'Active') );
        aList.add(new account(id = sso1.account__c, Validation_Status__c = 'Validated', IsValidated__c = true, Account_Status__c = 'Active') );
        update aList;        
        
        Relationship__c relation = new Relationship__c(Affiliated_Relationship__c = 'Partnership',
                                                       Primary_Account__c = sso.account__c,
                                                       Primary_Account_Sales_Org__c = sso.id,
                                                       Secondary_Account__c = acc2.id
                                                      );
        insert relation;
        string relationshipType = '';
        string division = '';
        string praza = '';
        Test.startTest();
        RelationshipCreateController.deleteAccountRelationship(division, relationshipType, praza, sso.account__c, sso.id, acc1.id,'X');
        Test.stopTest();
    }
    
    @isTest
    private static void testmethod1(){
        List<Account> accList = new List<Account>();
        Account acc = new Account(name='Parent'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        acc.SAP_Account_ID__c = '500300';
        acc.Validation_Status__c = 'Validated';
        acc.Facility_Type__c = 'Pharmacy';
        acc.BILLINGSTREET = '41 Moss';
        acc.BillingPostalCode = '77777';
        acc.Account_Role__c = 'ZCSN';
        accList.add(acc);
        Account acc2 = new Account(name='Child'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        acc2.SAP_Account_ID__c = '500301';
        acc2.Validation_Status__c = 'Validated';
        acc2.Facility_Type__c = 'Pharmacy';
        acc2.BILLINGSTREET = 'Moss Moss13';
        acc2.BillingPostalCode = '77777';
        acc2.Account_Role__c = 'ZCSN';
        acc2.Sales_Notes__c = 'Test';
        acc2.Shipping_Notes__c = 'Test';
        acc2.Customer_AR_Notes__c = 'Test';
        acc2.Customer_SO_Notes__c = 'Test';
        accList.add(acc2);
        
        Account acc3 = new Account(name='BillTo'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        acc3.SAP_Account_ID__c = '500302';
        acc3.Validation_Status__c = 'Validated';
        acc3.Facility_Type__c = 'Pharmacy';
        acc3.BILLINGSTREET = 'Moss Moss';
        acc3.BillingPostalCode = '77777';
        acc3.Account_Role__c = 'ZCSB';
        accList.add(acc3);
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = True;
        insert accList;
        acc2.ParentId = acc.Id;
        update acc2;
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc2.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        SAP_Sales_OrgTriggerHandler.TriggerDisabled = True;
        insert ssoc;
        Relationship__c relation = new Relationship__c(Relationship__c = 'RE',
                                                       Primary_Account__c = acc.id,
                                                       Primary_Account_Sales_Org__c = ssoc.id,
                                                       Secondary_Account__c = acc3.id,
                                                       Default_Partner_Flag__c = True
                                                      );
        insert relation;
        String distributionChannel = 'test';
        String relationshipType = 'Z1';
        String division = '00';
        String counter = '1';
        string praza = '';
        Test.startTest();
        	RelationshipCreateController.CreateNewRelationship(ssoc.account__c, ssoc.id, acc2.Id, 
                                                               distributionChannel, relationshipType, division, counter, 'X');
        
        	RelationshipCreateController.UpdateAccountRelationshipmain(relation.Id, ssoc.account__c, ssoc.id, acc2.id, 
                                relation.SAP_Division__c,relation.Relationship__c,relation.PARZA__c,
                                relation.Primary_Account__c, relation.Primary_Account_Sales_Org__c,
                                relation.Secondary_Account__c,relation.SAP_Division__c, relation.PARZA__c,
                                relation.Relationship__c,relation,relation);
        
        	RelationshipCreateController.deleteAccountRelationship(division, relationshipType, praza, ssoc.account__c, ssoc.id, ssoc.account__c,'X');
        
        Test.stopTest();
    }
    
    @isTest
    private static void testmethod2(){
        List<Account> accList = new List<Account>();
        Account acc = new Account(name='Parent'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        acc.SAP_Account_ID__c = '500300';
        acc.Validation_Status__c = 'Validated';
        acc.Facility_Type__c = 'Pharmacy';
        acc.BILLINGSTREET = '41 Moss';
        acc.BillingPostalCode = '77777';
        acc.Account_Role__c = 'ZCSN';
        accList.add(acc);
        Account acc2 = new Account(name='Child'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        acc2.SAP_Account_ID__c = '500301';
        acc2.Validation_Status__c = 'Validated';
        acc2.Facility_Type__c = 'Pharmacy';
        acc2.BILLINGSTREET = 'Moss Moss';
        acc2.BillingPostalCode = '77777';
        acc2.Account_Role__c = 'ZCSN';
        acc2.Sales_Notes__c = 'Test';
        acc2.Shipping_Notes__c = 'Test';
        acc2.Customer_AR_Notes__c = 'Test';
        acc2.Customer_SO_Notes__c = 'Test';
        accList.add(acc2);
        
        Account acc3 = new Account(name='BillTo'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        acc3.SAP_Account_ID__c = '500302';
        acc3.Validation_Status__c = 'Validated';
        acc3.Facility_Type__c = 'Pharmacy';
        acc3.BILLINGSTREET = 'Moss Moss';
        acc3.BillingPostalCode = '77777';
        acc3.Account_Role__c = 'ZCSB';
        accList.add(acc3);
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = True;
        insert accList;
        acc2.ParentId = acc.Id;
        update acc2;
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc2.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        SAP_Sales_OrgTriggerHandler.TriggerDisabled = True;
        insert ssoc;
        Relationship__c relation = new Relationship__c(Relationship__c = 'RE',
                                                       Primary_Account__c = acc.id,
                                                       Primary_Account_Sales_Org__c = ssoc.id,
                                                       Secondary_Account__c = acc3.id,
                                                       Default_Partner_Flag__c = True
                                                      );
        insert relation;
        String distributionChannel = 'test';
        String relationshipType = 'Z1';
        String division = '00';
        String counter = '1';
        string praza = '';
        Test.startTest();
        	RelationshipCreateController.CreateNewRelationship(ssoc.account__c, ssoc.id, acc2.Id, 
                                                               distributionChannel, relationshipType, division, counter, 'X');
        
        	RelationshipCreateController.UpdateAccountRelationshipmain(relation.Id, ssoc.account__c, ssoc.id, acc2.id, 
                                relation.SAP_Division__c,relation.Relationship__c,relation.PARZA__c,
                                relation.Primary_Account__c, relation.Primary_Account_Sales_Org__c,
                                relation.Secondary_Account__c,relation.SAP_Division__c, relation.PARZA__c,
                                relation.Relationship__c,relation,relation);
        
        	RelationshipCreateController.deleteAccountRelationship(division, relationshipType, praza, ssoc.account__c, ssoc.id, ssoc.account__c,'X');
        
        Test.stopTest();
    }
}