/*
Name       : AccountTriggerHandler_Test
Description: Test Class for AccountTriggerHandler trigger
Author     : Linda Neel
CreatedDate: 10-28-2018
*/
@isTest
public class AccountTriggerHandler_Test {
    
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;    
    
    @testsetup
    static void testdatasetup(){
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
        
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        
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
    }   
    @isTest
    static void UpdateAccount_Test () {
        List<Account> accList = new List<Account>();
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        //OpportunityTriggerHandler.opportunityChanged = true;
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        // NOTES: test 200 records
        
        // create custom setting class to include values needed in before insert trigger
        Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
        c.Name = 'AZ';
        c.Currency_Code__c = 'USD';
        Insert c; 
        
        //use to trigger feed      
        Account acct2 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                    Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                    Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                    BillingCountryCode = 'US',RecordtypeId = recTypeAccount,
                                    Account_Status__c = 'Active',IsDeleted__c = false,Own_Guarantor__c = false,  
                                    Transport_Zone__c='US00000001',Partner_Type__c= '0015'); 
        // need sap account id to satisfy sales org workflow
        acct2.SAP_Account_ID__c = '500300';
        acct2.Validation_Status__c = 'Validated';
        acct2.Facility_Type__c = 'Pharmacy';
        acct2.BILLINGSTREET = '41 Moss';
        acct2.BillingPostalCode = '77777';
        accList.add(acct2);
        //insert acct2;
        Account acct = new Account(name='My New Account',Account_role__c='ZGPO',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountryCode = 'US',RecordtypeId = recTypeAccount,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Validation_Status__c = 'Validated',  
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015');           
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = '77777';
        // get a list of accounts to use for testing
        List<Account> accountList = createAccounts(4);
        
        // create system admin to run test
        User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
        User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
        accountList[0].Validation_Status__c = 'Awaiting Validation';
        update accountList[0];
        
        test.StartTest();
        Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
        setting1.Name = 'ACCOUNT_ROLE__C';
        insert setting1;
        Account_Field_Tracking__c  setting2 = new Account_Field_Tracking__c ();
        setting2.Name = 'FACILITY_TYPE__C';
        insert setting2;
        Account_Field_Tracking__c  setting3 = new Account_Field_Tracking__c ();
        setting3.Name = 'BILLINGCITY';
        insert setting3;
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;    
        
        // make a change to initiate update
        //accountList[0].Applix_Account__c = 20040001;
        
        //System.assertEquals(20040001,accountList[0].Applix_Account__c);
        System.assertEquals('Awaiting Validation',accountList[0].Validation_Status__c);
        
        
        System.debug('Running test for no sales org');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        try{  
            accountList[1].Validation_Status__c = 'Validated';
            update accountList[1];
            system.debug('Sales Org Found');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            System.assert(e.getMessage().contains('Account Record Must Include Sales Organization Data'));
        }
        
        
        System.debug('Running test for no partner type');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        try{
            accountList[2].Validation_Status__c = 'Validated';
            accountList[2].Partner_Type__c = '';        
            SAP_Sales_Org__c sso2 = Testdatafactory.createSalesOrg(accountList[2].Id);    
            update accountList[2]; 
            system.debug('Partner Type Found');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            // System.assert(e.getMessage().contains('Account Record Must Include Partner Type'));
        }
        
        
        System.debug('Running test for no transportation zone');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        try{
            accountList[2].Validation_Status__c = 'Validated';
            accountList[2].Partner_Type__c= '0015';
            accountList[2].Transport_Zone__c = ''; 
            update accountList[2];
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            System.assert(e.getMessage().contains('Account Record Must Include Transportation Zone'));
        }
        
        
        System.debug('Running test for invalid record type');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        try{
            accountList[2].Validation_Status__c = 'Validated';
            accountList[2].Partner_Type__c= '0015';
            accountList[2].Transport_Zone__c='US00000001'; 
            accountList[2].RecordTypeId = recTypeAccount;
            accountList[2].Facility_Type__c='Children\'s Hospital';
            update accountList[2];    
            system.debug('Valid Record Type');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            // System.assert(e.getMessage().contains('Account Record Type Must be \'NAA Customer\' or \'International\'.'));
        }
        
        
        System.debug('Running test for validation');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        accountList[3].Validation_Status__c = 'Validated';
        accountList[3].Partner_Type__c= '0015';
        accountList[3].Transport_Zone__c='US00000001'; 
        accountList[3].RecordTypeId = recTypeAccount;
        update accountList[3];
        System.assertEquals('Validated',accountList[3].Validation_Status__c);
        
        // test after insert
        //acct.ParentId = accountList[3].Id;
        acct.Shipping_Instructions__c = 'Test01';
        accList.add(acct);
        
        insert accList;
        //System.assertEquals(acct.ParentId,accountList[3].Id);
        //System.assertNotEquals(null,acct.Id);
        
        // test after update
        acct.Shipping_Instructions__c = 'new01';
        update acct;
        System.assertEquals('new01',acct.Shipping_Instructions__c);   
        
        SAP_Sales_Org__c sso5 = Testdatafactory.createSalesOrg(acct2.Id); 
        
        System.debug('Running test for User Not Permitted');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        try{
            acct2.Validation_Status__c = 'Validated';
            acct2.Facility_Type__c='Children\'s Hospital';
            acct2.Account_role__c='ZCSN';
            acct2.Own_Guarantor__c = true;
            update acct2;
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            //System.assert(e.getMessage().contains('You do not have permission to change a validated account'));
        }
        
        test.StopTest();
    } 
    @istest
    static void validatedAcctest(){
        User u = [select id from User where firstname = 'TestUser'];
        System.runAs(u){
            AccountCreateController.isFirstRun= false;
            Transportation_Zone_Mapping__c tz_map2 = new Transportation_Zone_Mapping__c();
            tz_map2.TRANSPORTATION_ZONE__c = 'CA00000003';
            tz_map2.COUNTRY_CODE__c = 'CA';
            tz_map2.REGION_CODE__c = 'ON';
            insert tz_map2;
            
            Account acc = new Account(name='11t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'CA',RecordtypeId = recTypeAccount,BillingStateCode = 'ON',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Partner_Type__c= '0015'); 
            acc.Facility_Type__c = 'Pharmacy';
            acc.Account_role__c='ZGPO';
            acc.Validation_Status__c = 'Validated';
            acc.BILLINGSTREET = '41 Moss';
            acc.BillingPostalCode = '77777';
            /* Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN', Transport_Zone__c='US00000001',
Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
BillingPostalCode='95128',Transport_Zone__c='IN00000001',
SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),
Validation_Status__c = 'Validated',Country_Cluster__c='UK',Division_Account__c ='Shared Service',Region__c='',
Account_Territory__c='',Facility_Type__c='Children\'s Hospital');*/
            // Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id; 
            // acc.RecordTypeId = recTypeAccount;
            insert acc; 
            //Account acc = TestDataFactory.createTestAccountQuotePrint();
            //List<Account> accList = New List<Account>();
            //accList.add(acc);
            Map<Id,SObject> accmapOld = new Map<Id,SObject>{acc.Id => acc};
                //acc.Validation_Status__c = 'Validated';
                AccountCreateController.isFirstRun= true;
            AccountCreateController.isTriggerExecuting = false;
            Test.startTest();
            AccountTriggerHandler.checkGPORelation(new List<Id>{acc.Id});
            
            try{
                update acc;
            }catch(DMLException e){
                //System.assert(e.getMessage().contains('You do not have permission to change a validated account'));
            }
            Map<Id,SObject> accmap = new Map<Id,SObject>();
            accmap.put(acc.id, acc); 
            AccountTriggerHandler.AllowSaveWithoutPermission(accmap.values(), accmapOld);
            delete acc;
            Test.stopTest();
        }
    }
    // create account data
    static List<Account> createAccounts(Integer numberOfAccounts){
        List<Account> accList=new List<Account>();   
        for(Integer i=0;i<numberOfAccounts;i++){
            Account acc = Testdatafactory.createUSTestAccount();
            accList.add(acc);
        }
        return accList;
    }
    @isTest
    private static void accIsDeletedTest(){
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        //OpportunityTriggerHandler.opportunityChanged = true;
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        //List<Account> accList = Testdatafactory.createAccounts(2);
        Transportation_Zone_Mapping__c tz_map = new Transportation_Zone_Mapping__c();
        tz_map.TRANSPORTATION_ZONE__c = 'US00000001';
        tz_map.COUNTRY_CODE__c = 'US';
        tz_map.REGION_CODE__c = 'IL';
        insert tz_map;
        Account account = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Partner_Type__c= '0015');
        account.SAP_Account_ID__c = '500300';
        account.Validation_Status__c = 'Validated';
        account.Facility_Type__c = 'Pharmacy';
        account.BILLINGSTREET = '41 Moss';
        account.BillingPostalCode = '77777';
        // AccountTriggerHandler.TriggerDisabled = True;
        insert account;
        List<Account> accList = new List<Account>();
        accList.add(account);
        SAP_Sales_Org__c sso5 = Testdatafactory.createSalesOrg(account.Id);
        // accList[0].Transport_Zone__c = Null;
        UserTriggerHandler.TriggerDisabled = True;
        // insert accList;
        
        //Opportunity opp = Testdatafactory.createOppWithAccount();
        //opp.AccountId = accList[1].id;
        //update opp;
        
        User usr = Testdatafactory.createUser(true, 'TestFName2', 'TestLName2');
        
        // AccountTeamMember atm = new AccountTeamMember(AccountId = accList[0].Id, UserId = usr.Id, TeamMemberRole = 'System Sales Director');
        // insert atm;
        
        // OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id, UserId = usr.Id, TeamMemberRole = 'System Sales Director');
        // insert otm;
        
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.ContactInsertEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRM';
        setting.ContactUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRMUpdate';
        setting.AccountRole_SoldTo__c='ZCSN';
        //insert setting;
        
        Contact retCon = new Contact();
        retCon.AccountId = accList[0].Id;
        retCon.Salesforce_Contact_ID__c ='5678';
        retCon.SAP_Contact_GUID__c = '3467';
        retCon.LastName = 'TestLName';
        retCon.LeadSource = 'Self-generated';
        retCon.Phone = '845-294-5441';
        insert retCon;
        retCon.SAP_Contact_ID__c = '1234567890';
        update retCon;
        
        List<Account> accList2Update = new List<Account>();
        for(Account acc: accList){
            acc.IsDeleted__c = true;
            acc.name='testABC321';
            acc.Point_of_Care_TAM__c = 10;
            acc.Point_of_Care_OPM__c = 10;
            
            accList2Update.add(acc);
        }
        test.startTest();
        //SAP_Sales_Org__c sso2 = Testdatafactory.createSalesOrg(accList2Update[0].Id); 
        //accList2Update[0].Transport_Zone__c='test';
        update accList2Update;
        //delete accList2Update;
        //undelete accList2Update;
        test.stopTest();
    }
    // added to test changeowner method by tribhhuvan singh
    @isTest 
    static void changeOwnerTest(){
        usertriggerhandler.TriggerDisabled = true;
        Account_Field_Tracking__c  setting = new Account_Field_Tracking__c ();
        setting.Name = 'BILLINGCITY';
        insert setting;
        Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
        setting1.Name = 'ACCOUNT_ROLE__C';
        insert setting1;
        Account_Field_Tracking__c  setting2 = new Account_Field_Tracking__c ();
        setting2.Name = 'ISVALIDATED__C';
        insert setting2;
        Account_Field_Tracking__c  setting3 = new Account_Field_Tracking__c ();
        setting3.Name = 'RECORDTYPEID';
        insert setting3;
        
        Map<Id, Account> oldMap = new Map<Id, Account>();
        Map<Id, Account> newMap = new Map<Id, Account>();
        List<Account> actlist = new List<Account>();
        //Added by Sravan
        User usr1 = Testdatafactory.createUser(true, 'TestFName1', 'TestLName1');
        User usr2 = Testdatafactory.createUser(true, 'TestFName2', 'TestLName2');
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        Account act = new Account(name='My New Account',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                  BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Facility_Type__c='Hospice',
                                  Validation_Status__c = 'Awaiting Validation',
                                  Territory_Name__c='testCanada',
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015', ownerId= usr1.Id);
        insert act;
        
        Contact con = new Contact(AccountId=act.Id,Lastname='test');
        //Insert con;
        
        Territory_Zipcodes__c tz = new Territory_Zipcodes__c(Country__c='US',Fiscal_Year__c=2015,Territory_Name__c='testCanada',Zipcode__c='12345');
        insert tz;
        Account_Territory_Information__c ati = new Account_Territory_Information__c(Territory_Name__c='testCanada',Country_Cluster__c='US&CA',Region__c='Western Canada',Division__c='Canada',
                                                                                    Account_Territory__c='Western Canada' );
        insert ati;
        List<Account> newAcc = new List<Account>();
        newAcc.add(act);
        
        opportunity opp = new opportunity();
        opp.AccountId = act.Id;
        opp.ExpectedInstallDate__c = System.Today();
        opp.StageName = '4 Final Negotiations';
        opp.CloseDate = System.Today()+1;
        opp.Name = 'oppty1';
        opp.Services_Enablement_Owner__c='Matthew Merson';
        insert opp;
        
        OpportunityTeamMember opptyTeam = new OpportunityTeamMember();
        opptyTeam.OpportunityId = opp.Id;
        opptyTeam.UserId = act.ownerId;
        opptyTeam.TeamMemberRole = 'Account Trainer';
        insert opptyTeam;
        oldMap.put(act.Id, act);
        
        test.startTest();
        act.OwnerId = usr2.Id;
        act.Validation_Status__c = 'Validated';
        //act.Account_Role__c = 'ZIDN';
        act.Credit_Amount_Approved__c = 1000;
        act.Credit_Approved__c = true;
        try{
            System.runAs(usr1){
                update act;
            }
            newMap.put(act.id, act);
            //AccountTriggerHandler.AllowSaveWithoutPermission(newMap.values(),oldMap);
            set<String> territories = new set<String>();
            territories.add('testCanada');
            AccountTriggerHandler ath = new AccountTriggerHandler();
            AccountTriggerHandler.updateAccountFromAccountTerritoryInformation(newMap.values(),oldMap,territories);
            newAcc[0].Validation_Status__c = 'Validated';
            newAcc[0].Account_Role__c = 'ZCSN';
            newAcc[0].IsDeleted__c = False;
            newAcc[0].SAP_Account_ID__c='123456789012345678';
            newAcc[0].recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
            update newAcc[0];
            //ath.onAfterInsAccAddr(newAcc);
            newAcc[0].BillingCity = 'PhoenixAZ';
            newAcc[0].Primary_Language__c = 'IT';
            //newAcc[0].Account_Role__c = 'ZIDN';
            update newAcc[0];
            
            AccountTriggerHandler.deleteAccountTeam(newAcc);
            set<Id> usrSet = new set<Id>();
            usrSet.add(usr1.Id);
            AccountTriggerHandler.UpdateUser(usrSet);
            
            newAcc[0].Primary_Language__c = 'IT';
            update newAcc[0];
            newMap.put(newAcc[0].id, newAcc[0]);
            AccountTriggerHandler.AllowSaveWithoutPermission(newMap.values(),oldMap);
        }
        catch(Exception e){
            system.debug('Exception Message: '+e);
            //System.assert(e.getMessage().contains('You do not have permission to change a validated account'));
        }
        actlist.add(act);
        Test.stopTest();
    }
    
    @isTest 
    static void AccountTriggerHandlerTest(){
        usertriggerhandler.TriggerDisabled = true;
        Map<Id, Account> oldMap = new Map<Id, Account>();
        Map<Id, Account> newMap = new Map<Id, Account>();
        List<Account> actlist = new List<Account>();
        //Added by Sravan
        User usr1 = Testdatafactory.createUser(true, 'TestFName1', 'TestLName1');
        User usr2 = Testdatafactory.createUser(true, 'TestFName2', 'TestLName2');
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account act = new Account(name='My New Account',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                  BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Facility_Type__c='Hospice', 
                                  //ParentId = '0011N00001pYpTbQAK',
                                  Validation_Status__c = 'Validated',Own_Guarantor__c = false,
                                  Territory_Name__c='testCanada',SAP_Account_ID__c='123456789009876543',
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015', ownerId= usr1.Id);
        insert act;
        oldMap.put(act.Id,act);
        Territory_Zipcodes__c tz = new Territory_Zipcodes__c(Country__c='US',Fiscal_Year__c=2015,Territory_Name__c='testCanada',Zipcode__c='12345');
        insert tz;
        Account_Territory_Information__c ati = new Account_Territory_Information__c(Territory_Name__c='testCanada',Country_Cluster__c='US&CA',Region__c='Western Canada',Division__c='Canada',
                                                                                    Account_Territory__c='Western Canada' );
        insert ati;
        
        Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
        setting1.Name = 'ACCOUNT_ROLE__C';
        insert setting1;
        Account_Field_Tracking__c  setting2 = new Account_Field_Tracking__c ();
        setting2.Name = 'ISDELETED__C';
        insert setting2;
        Account_Field_Tracking__c  setting3 = new Account_Field_Tracking__c ();
        setting3.Name = 'RECORDTYPEID';
        insert setting3;
        
        List<Contact> conList = new List<Contact>();
        contact c = new contact(AccountId = act.Id,SAP_Contact_ID__c='123456789102354',Lastname='test',ownerId=UserInfo.getUserId());
        conList.add(c);
        For(Integer k=100; k<=350; k++){
            contact con = new contact();
            con.AccountId = act.Id;
            con.SAP_Contact_ID__c = '0000000'+k;
            con.Lastname = 'test_' + k;
            con.ownerId = UserInfo.getUserId();
            conList.add(con);
        }
        
        ContactTriggerHandler.TriggerDisabled = True;
        insert conList;
        
        
        test.startTest();
        
        
        act.Primary_Language__c='IT';
        act.Account_Role__c = 'ZGPO';
        act.IsDeleted__c = False;
        act.SAP_Account_ID__c='123456789012345678';
        act.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        act.Own_Guarantor__c = true;
        SAP_Sales_Org__c sso2 = Testdatafactory.createSalesOrg(act.Id); 
        update act;
        newMap.put(act.Id,act);
        AccountTriggerHandler ath = new AccountTriggerHandler();
        actlist.add(act); 
        Map<id,Contact> conMap = new Map<id,Contact>([SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId In: actlist]);
        System.enqueueJob(new UpdateContactOwnerFromAcc(conMap));
        //AccountTriggerHandler.updateContactOwner(conMap);
        ath.sendAllContactsToCastIron(newMap.values(),oldmap.values());
        AccountTriggerHandler.validationBasedOnUsers(oldmap,newmap,newMap.values());
        
        test.stopTest();
    }
    @isTest
    static void TiSegmentCalculationTest(){
        AccountTriggerHandler.triggerdisabled = true;
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        test.startTest();
        Target_Initiative__c ti = new Target_Initiative__c();
        ti.Name = 'Top 200 Customers';
        ti.Start_Date__c = Date.today();
        ti.End_Date__c = Date.today().addDays(3);
        insert ti;
        Account act1 = new Account(name='My New Account101',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54321',BillingStreet='test456',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   //ParentId=act0.Id,
                                   Validation_Status__c = 'Validated',
                                   Territory_Name__c='testCanada',SAP_Account_ID__c='123456789009876543',
                                   Transport_Zone__c='US00000002',Partner_Type__c= '0015');
        
        insert act1;
        Account act0 = new Account(name='My New Account100',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   ParentId =act1.id,
                                   Validation_Status__c = 'Validated',
                                   Territory_Name__c='testCanada1',SAP_Account_ID__c='123456789009876540',
                                   Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
        tia.Account__c = act0.Id;
        tia.Target_Initiative__c = ti.Id;
        insert tia;
        Set<string> accountIds = new Set<string>();
        accountIds.add(act0.id);
        AccountTriggerHandler_Top200Customer job = new AccountTriggerHandler_Top200Customer() ;
        job.accountIds = accountIds;
        job.isInsert = true;
        System.enqueueJob(job);
        
        
        
        test.stopTest(); 
    }
    @isTest 
    static void TiSegmentCalculationTest1(){
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account act0 = new Account(name='My New Account100',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   //ParentId = '0011N00001pYpTbQAK',
                                   Validation_Status__c = 'Validated',
                                   Territory_Name__c='testCanada1',SAP_Account_ID__c='123456789009876540',
                                   Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        SAP_Sales_Org__c sso = Testdatafactory.createSalesOrg(act0.Id);
        Account act1 = new Account(name='My New Account101',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54321',BillingStreet='test456',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   ParentId=act0.Id,
                                   Validation_Status__c = 'Validated',
                                   Territory_Name__c='testCanada',SAP_Account_ID__c='123456789009876543',
                                   Transport_Zone__c='US00000002',Partner_Type__c= '0015');
        
        insert act1;
        SAP_Sales_Org__c sso5 = Testdatafactory.createSalesOrg(act1.Id);
        test.startTest();
        act1.ParentId=null;
        update act1;
        test.stopTest(); 
    }
    @isTest
    static void TiSegmentCalculationTest2(){
        AccountTriggerHandler.triggerdisabled = true;
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        test.startTest();
        Target_Initiative__c ti = new Target_Initiative__c();
        ti.Name = 'Top 200 Customers';
        ti.Start_Date__c = Date.today();
        ti.End_Date__c = Date.today().addDays(3);
        insert ti;
        Account act0 = new Account(name='My New Account100',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   //ParentId = '0011N00001pYpTbQAK',
                                   Validation_Status__c = 'Validated',
                                   Territory_Name__c='testCanada1',SAP_Account_ID__c='123456789009876540',
                                   Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        
        SAP_Sales_Org__c sso1 = Testdatafactory.createSalesOrg(act0.Id); 
        Account act1 = new Account(name='My New Account101',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54321',BillingStreet='test456',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   ParentId=act0.Id,
                                   Validation_Status__c = 'Validated',
                                   Territory_Name__c='testCanada',SAP_Account_ID__c='123456789009876543',
                                   Transport_Zone__c='US00000002',Partner_Type__c= '0015');
        
        insert act1;
        SAP_Sales_Org__c sso2 = Testdatafactory.createSalesOrg(act1.Id); 
        Account act2 = new Account(name='My New Account1001',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54675',BillingStreet='test123',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   //ParentId = '0011N00001pYpTbQAK',
                                   Validation_Status__c = 'Validated',
                                   Territory_Name__c='testCanada1',SAP_Account_ID__c='123456789009876523',
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        insert act2;
        map<Id, Account> NewAcc = new map<Id, Account>();
        map<Id, Account> OldAcc = new map<Id, Account>();
        NewAcc.put(act1.id,act1);
        SAP_Sales_Org__c sso3 = Testdatafactory.createSalesOrg(act2.Id); 
        
        act1.ParentId=act2.Id;
        update act1;
        OldAcc.put(act1.id,act1);
        Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
        tia.Account__c = act1.Id;
        tia.Target_Initiative__c = ti.Id;
        insert tia;
        Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
        tia1.Account__c = act2.Id;
        tia1.Target_Initiative__c = ti.Id;
        insert tia1;
        AccountTriggerHandler_Top200Customer job1 = new AccountTriggerHandler_Top200Customer() ;
        job1.newAccounts = NewAcc;
        job1.oldAccounts = OldAcc;
        job1.isInsert = false;
        job1.topLp = false; 
        System.enqueueJob(job1);
        test.stopTest(); 
    }
    
    @isTest
    static void TiSegmentCalculationTest3(){
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        test.startTest();
        Account act0 = new Account(name='My New Account100',Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   //ParentId = '0011N00001pYpTbQAK',
                                   
                                   Territory_Name__c='testCanada1',
                                   Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        
        SAP_Sales_Org__c sso1 = Testdatafactory.createSalesOrg(act0.Id); 
        act0.Validation_Status__c = 'Invalid';
        act0.Reason_for_Invalid__c = 'test';
        update act0;
        test.stopTest(); 
    }
    @isTest
    static void TiSegmentCalculationTest4(){
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        test.startTest();
        Account act0 = new Account(name='My New Account100',Account_role__c='NA - Non-Buying/Competitor',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,Account_Type__c = 'Competitor',
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   //ParentId = '0011N00001pYpTbQAK',
                                   Master_Agreement__c = '5187012',
                                   Territory_Name__c='testCanada1',
                                   Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        
        SAP_Sales_Org__c sso1 = Testdatafactory.createSalesOrg(act0.Id); 
        act0.Validation_Status__c = 'Validated';
        act0.SAP_Account_ID__c='123456789009876523';
        update act0;
        List<Account> alist= new List<Account>();
        alist.add(act0);
        accounttriggerhandler.updateDHCExternalDataField(alist,alist);
        
        test.stopTest(); 
    }
    
    @isTest
    static void Territory(){
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        test.startTest();
        Account act0 = new Account(name='My New Account100',Account_role__c='NA - Non-Buying/Competitor',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                   BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,Account_Type__c = 'Competitor',
                                   BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Facility_Type__c='Hospice', 
                                   //ParentId = '0011N00001pYpTbQAK',
                                   Master_Agreement__c = '5187012',
                                   Territory_Name__c='testCanada1',
                                   Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        
        SAP_Sales_Org__c sso1 = Testdatafactory.createSalesOrg(act0.Id); 
        act0.Validation_Status__c = 'Validated';
        act0.SAP_Account_ID__c='123456789009876523';
        update act0;
        List<Account> alist= new List<Account>();
        alist.add(act0);
        AccountTriggerHandler.isTriggerExecuted = true;
        Set<String> accountIds = new Set<String>();
        accountIds.add(act0.id);
        RunAccountTerritoryRules job = new RunAccountTerritoryRules() ;
        job.accntIds = accountIds; 
        System.enqueueJob(job);
        
        test.stopTest(); 
    }
    
    @isTest 
    static void AccountTriggerHandlerTest2(){
        usertriggerhandler.TriggerDisabled = true;
        Map<Id, Account> oldMap = new Map<Id, Account>();
        Map<Id, Account> newMap = new Map<Id, Account>();
        List<Account> actlist = new List<Account>();
        //Added by Sravan
        User usr1 = Testdatafactory.createUser(true, 'TestFName1', 'TestLName1');
        User usr2 = Testdatafactory.createUser(true, 'TestFName2', 'TestLName2');
        Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        Account acct2 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                    Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                    Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                    BillingCountryCode = 'US',RecordtypeId = recTypeAccount,
                                    Account_Status__c = 'Active',IsDeleted__c = false,Own_Guarantor__c = false,  
                                    Transport_Zone__c='US00000001',Partner_Type__c= '0015'); 
        // need sap account id to satisfy sales org workflow
        //acct2.SAP_Account_ID__c = '500300';
        //acct2.Validation_Status__c = 'Validated';
        acct2.Facility_Type__c = 'Pharmacy';
        acct2.BILLINGSTREET = '41 Moss';
        acct2.BillingPostalCode = '77777';
        insert acct2;
        SAP_Sales_Org__c sso25 = Testdatafactory.createSalesOrg(acct2.Id);
        acct2.SAP_Account_ID__c = '500300';
        acct2.Validation_Status__c = 'Validated';
        update acct2;
        
        Account act = new Account(name='My New Account',Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                  BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                  Account_Status__c = 'Active',IsDeleted__c = false,
                                  Facility_Type__c='Hospice', 
                                  //ParentId = '0011N00001pYpTbQAK',
                                  Validation_Status__c = 'Validated',Own_Guarantor__c = false,
                                  Territory_Name__c='testCanada',SAP_Account_ID__c='123456789009876543',
                                  Transport_Zone__c='US00000001',Partner_Type__c= '0015', ownerId= usr1.Id);
        insert act;
        oldMap.put(act.Id,act);
        Territory_Zipcodes__c tz = new Territory_Zipcodes__c(Country__c='US',Fiscal_Year__c=2015,Territory_Name__c='testCanada',Zipcode__c='12345');
        insert tz;
        Account_Territory_Information__c ati = new Account_Territory_Information__c(Territory_Name__c='testCanada',Country_Cluster__c='US&CA',Region__c='Western Canada',Division__c='Canada',
                                                                                    Account_Territory__c='Western Canada' );
        insert ati;
        
        Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
        setting1.Name = 'ACCOUNT_ROLE__C';
        insert setting1;
        Account_Field_Tracking__c  setting2 = new Account_Field_Tracking__c ();
        setting2.Name = 'ISDELETED__C';
        insert setting2;
        Account_Field_Tracking__c  setting3 = new Account_Field_Tracking__c ();
        setting3.Name = 'RECORDTYPEID';
        insert setting3;
        
        test.startTest();
        contact con = new contact(AccountId = act.Id,SAP_Contact_ID__c=null,Lastname='test',ownerId=UserInfo.getUserId());
        insert con;
        act.Primary_Language__c='IT';
        act.Account_Role__c = 'ZGPO';
        act.IsDeleted__c = False;
        act.SAP_Account_ID__c='123456789012345678';
        act.recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        //act.Own_Guarantor__c = true;
        act.Credit_Approved_For__c = acct2.id;
        act.Shipping_Notes__c = 'a';
        act.Sales_Notes__c = 'b';
        act.Customer_SO_Notes__c ='c';
        SAP_Sales_Org__c sso2 = Testdatafactory.createSalesOrg(act.Id); 
        update act;
        newMap.put(act.Id,act);
        AccountTriggerHandler ath = new AccountTriggerHandler();
        actlist.add(act); 
        Map<id,Contact> conMap = new Map<id,Contact>([SELECT Id, OwnerId, AccountId FROM Contact WHERE AccountId In: actlist]);
        System.enqueueJob(new UpdateContactOwnerFromAcc(conMap));
        //AccountTriggerHandler.updateContactOwner(actlist);
        ath.sendAllContactsToCastIron(newMap.values(),oldmap.values());
        AccountTriggerHandler.validationBasedOnUsers(oldmap,newmap,newMap.values());
        
        test.stopTest();
    }
    
    @isTest 
    static void AccountTriggerHandlerTest3(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        userTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        quotetriggerhandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1();
        Quote.Supplement_Version__c = 2;
        Quote.Name = 'Test Update Quote';
        
        Quote.Master_Agreement__c = '12345';
        Quote.Shipping_Instructions__c = 'Test shipp inst';
        Quote.Service_Level__c = 'GD';
        Quote.Net_Weight__c = 20.5;
        Quote.Total_Cost__c = 100;
        Quote.Overhead_Cost__c = 50;
        
        Quote.Milestone_Invoice_Term__c = '10';
        Quote.Region__c = 'Texas';
        //Quote.Discount = 100;
        //Quote.Subtotal = 983745;
        Quote.Labor_Cost__c = 10;
        Quote.Net_Value__c = 100;
        Quote.Posting_Date__c = Date.newInstance(2019, 5, 11);
        Quote.Exchange_Rate__c = 2.0;
        Quote.EOL_Date__c = System.now()+2000;
        Quote.Fee_Increase__c = 10;
        Quote.SAP_Expected_Bookings__c = 200;
        Quote.SAP_NPV__c = 20;
        
        Quote.Freight_Price__c = 10;
        
        Quote.Supplement_Generated__c = '01';      /*Specified Value for Restricted Picklist to remove validation error*/
        Quote.Status = 'E0018';
        Quote.Primary_Quote__c = true;
        Quote.From__c = Date.newInstance(2019, 2, 11);
        Quote.ExpirationDate = Date.newInstance(2021, 2, 11);
        Quote.Has_Critical_Errors__c = true;
        
        Quote.Region__c = 'Northeast';
        Quote.Description = 'Test Desc';
        Quote.Currency__c = 'AWG';
        
        Quote.Quote_Margin__c = 10;
        Quote.Freight_Price__c = 20;
        
        Quote.Tax = 30;
        
        Quote.Total_Net__c = 200;
        Quote.IDN_Price_List__c = 'AS';
        Quote.GPO_Price_Lists__c = 'PC';
        Quote.Terms_of_Payment__c = 'MD20'; 
        Quote.Incoterms_1__c = 'COL';
        Quote.Incoterms_2__c = 'test';
        
        Quote.Sales_Operation_Counterpart__c = TestDataFactory.createUser(true,'TestUser','SalesOper').Id;
        Quote.Consultant__c = TestDataFactory.createUser(true,'TestUser','Consultant').Id;
        Quote.Sales_Consultant__c = TestDataFactory.createUser(true,'TestUser','SalesConsultant').Id;
        Quote.SSM_RD__c = TestDataFactory.createUser(true,'TestUser','SSMRD').Id;
        Quote.Order_Net_Price__c = 200;
        Quote.GSA_Result1__c = 'Test GSA';
        
        Quote.GSA_Net_Price__c = 20;
        Quote.GSA_Price_Difference__c = 12;
        Quote.Quote_Revision__c = '2';
        Quote.Quote_Number__c = '12345';
        Quote.SAP_Sales_Order_Number__c = '12345';
        Quote.Quote_Margin_Comments__c = 'test comments';
        
        Quote.Product_PO_Number__c = '12345';
        Quote.Service_PO_Number__c = '12345';
        Quote.Re_Opened__c = true;
        Quote.Reopen_Reason__c = 'Test Reason';
        
        Quote.Lease_Duration__c = 20;
        Quote.Free_Month_for_Lease__c = 2.5;
        
        Quote.Shipping_Conditions__c = 'AE';
        Quote.Service_Escalator__c = 20;
        Quote.Free_Month_Service__c = 2.5;
        Quote.Renewal_Revenue__c = 200;
        Quote.Service_Duration__c = 25;
        
        Quote.Service_Start_Date__c = Date.newInstance(2019,02,13);
        
        Quote.Net_Interest_Rate__c = 12;
        Quote.Monthly_Product_Lease_Payment__c = 50;
        Quote.Monthly_Service_Lease_payment__c = 20;
        
        Quote.Booking_Date__c = Date.newInstance(2019,02,14);
        
        Quote.Pricing_Reference_Date__c = Date.newInstance(2019,2,15);
        Quote.Requested_Delivery_Date__c = Date.newInstance(2019,12,15);
        
        Quote.Email = 'test@test.com';
        Quote.Phone = '9999999999';
        
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        Quote.Ship_to_Account__c = acc.id;
        Quote.Fax = '1234567890';
        Quote.Bill_to_Account__c = acc.id; 
        Quote.GPO_Account__c = acc.id;
        Quote.IDN_Account__c = acc.id;
        
        Quote.ProductChangeError__c = 'Test Error';
        Quote.SAPError__c = 'Test Error';
        
        Quote.Hospital_Contact_Notes__c = 'test notes';
        Quote.Inv_Text_Notes__c = 'test notes';
        Quote.Quote_Printout_Standard_Text__c = 'Test Notes';
        Quote.Other_Notes__c = 'Test notes';
        Quote.Quote_Text__c = 'Test text';
        Quote.Special_Instructions__c = 'Test spcl Inst';
        Quote.Sales_Ops_Notes__c = 'Test Notes';
        Quote.Rework_Comments__c = 'test comm';
        
        
        Test.startTest();
        update quote; 
        list<id> ac = new list<id>();
        ac.add(Quote.AccountId);
        AccountTriggerHandler.updateQuotes(ac);
        AccountTriggerHandler.validationCheck(true,true,true,true);
        Test.stopTest();
    }
}