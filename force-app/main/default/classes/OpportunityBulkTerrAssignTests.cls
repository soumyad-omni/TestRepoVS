@isTest
public class OpportunityBulkTerrAssignTests { 
    
    @testsetup
    static void testdatasetup(){
        accounttriggerhandler.triggerdisabled= true;
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
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
        
        NAC_Health_System_Owned_Opp_Team__c NACRole = new NAC_Health_System_Owned_Opp_Team__c();
        NACRole.Name = 'AO';
        NACRole.Role__c = 'Account Owner';
        insert NACRole;
        AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c =  System.today();
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        insert opp;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false; 
        Account account=TestDataFactory.createTestAccountQuotePrint();
        account.Name = 'Test IBA-4942';
        account.Territory_Assignment_Criteria__c = 'NAC Health System Owned';
        account.SAP_Account_ID__c = '0000013903';
        update account;
        Opportunity opp2 = new Opportunity();
        opp2.name = 'Test Opportunity IBA-4942';
        opp2.stageName = '1 Solution Design';
        opp2.CloseDate = System.today()+30;
        opp2.ExpectedInstallDate__c = System.today()+60;
        opp2.AccountId = account.Id;
        insert opp2;  
    }
    
    @isTest
    public static void afterUpdateTest(){
        accounttriggerhandler.triggerdisabled= true;
        AccountCreateController.isFirstRun= false; 
        Opportunity opp = [select id from Opportunity where name='Test Opportunity for update' limit 1];
        update opp;
        Map<Id, SObject> newItems = new Map<Id, SObject>();
        newItems.put(opp.Id, opp);
        Id idValue = 'a30000000444444';
        OpportunityTerrBulkAssign.Territory2Priority tp = new OpportunityTerrBulkAssign.Territory2Priority(idValue,2,true);
    }
    
    @istest
    private static void testUpdateTerritorryAssignmentInAcct() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,    //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from Account LIMIT 1];
        
        System.RunAs(usr)
        {
            Test.startTest();
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.AccountId = account.id;
            opp.OppStatus__c = 'Open';
            opp.ExpectedInstallDate__c = System.today();
            insert opp;
            insertTestTerritory(account.Id);
            List<Account> accList = new List<Account>();
            accList.add(account);
            Map<Id, Account> oldMap = new Map<Id, Account>();
            BCH_UpdateTerritoryInAccounts.updateAccountTerritoryName(accList,oldMap);
            Test.stopTest();
        }
    }
    
    @istest
    private static void territorryAssignmentToBCHOppsByTrigger() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,      //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        
        System.RunAs(usr)
        {
            List<Quota_Carrying_Team_Role__c> qctrList = new List<Quota_Carrying_Team_Role__c>();
            Quota_Carrying_Team_Role__c qctr1 = new Quota_Carrying_Team_Role__c();
            qctr1.Name = 'Inside Sales Rep';
            Quota_Carrying_Team_Role__c qctr2 = new Quota_Carrying_Team_Role__c();
            qctr2.Name = 'Sales Consultant';
            Quota_Carrying_Team_Role__c qctr3 = new Quota_Carrying_Team_Role__c();
            qctr3.Name = 'Account Owner';
            qctrList.add(qctr1);
            qctrList.add(qctr2);
            qctrList.add(qctr3);
            insert qctrList;
            
            List<Product_Based_Team_Role__c> pbtrList = new List<Product_Based_Team_Role__c>();
            Product_Based_Team_Role__c pbtr1 = new Product_Based_Team_Role__c();
            pbtr1.Portfolio_Segment1__c = 'Services';
            pbtr1.Team_Role__c = 'Inside Sales Rep';
            Product_Based_Team_Role__c pbtr2 = new Product_Based_Team_Role__c();
            pbtr2.Portfolio_Segment1__c= 'Services';
            pbtr2.Team_Role__c = 'Inside Sales Rep';
            pbtrList.add(pbtr1);
            pbtrList.add(pbtr2);
            insert pbtrList;
            
            Test.startTest();
            
            QuoteTriggerHandler.TriggerDisabled = true;
            AccountTriggerHandler.TriggerDisabled = true;
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.AccountId = account.id;
            opp.OppStatus__c = 'Open';
            opp.ExpectedInstallDate__c = System.today();
            insert opp;
            Opportunity_Team_Members_History__c otmh = new Opportunity_Team_Members_History__c(Opportunity__c = opp.Id,
                                                                                               User__c = UserInfo.getUserId(),
                                                                                               Team_Role__c = 'AccountOwner',
                                                                                               ParentId__c = '',
                                                                                               OpportunityAccessLevel__c = 'Public Read Only',
                                                                                               Compensation__c = false,
                                                                                               Deleted_Record__c = true);
            insert otmh;
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id,
                                                                  UserId = UserInfo.getUserId(),
                                                                  TeamMemberRole = 'AccountOwner');
            insert otm;
            List<Id> idList = new List<Id>(); 
            idList.add(opp.Id);
            List<ObjectTerritory2Association> otaList = insertTestTerritory(account.Id);
            Territory2 terr = [Select id from Territory2 where name = 'TestTerritory222'];
            Id territory2Id = terr.Id;
            List<Opportunity> oppList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                         WHERE Id IN :idList ];  
            CreateOpportunityTeamMembers.otaTestList = otaList;
            List<Opportunity> oppFullList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                             WHERE Id IN :idList and Account.IsDeleted__c = false
                                             AND (OppStatus__c ='PO Received - Pending Paperwork' OR 
                                                  OppStatus__c ='PO Received' OR OppStatus__c ='Open')];
            CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
            job.oppFullList = oppFullList; 
            System.enqueueJob(job);
            Test.stopTest();
        }
    }
    
    @istest
    private static void territorryAssignmentToOppsByTrigger() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,      //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        
        System.RunAs(usr)
        {
            List<Quota_Carrying_Team_Role__c> qctrList = new List<Quota_Carrying_Team_Role__c>();
            Quota_Carrying_Team_Role__c qctr1 = new Quota_Carrying_Team_Role__c();
            qctr1.Name = 'Inside Sales Rep';
            Quota_Carrying_Team_Role__c qctr2 = new Quota_Carrying_Team_Role__c();
            qctr2.Name = 'Sales Consultant';
            Quota_Carrying_Team_Role__c qctr3 = new Quota_Carrying_Team_Role__c();
            qctr3.Name = 'Account Owner';
            qctrList.add(qctr1);
            qctrList.add(qctr2);
            qctrList.add(qctr3);
            insert qctrList;
            
            List<Product_Based_Team_Role__c> pbtrList = new List<Product_Based_Team_Role__c>();
            Product_Based_Team_Role__c pbtr1 = new Product_Based_Team_Role__c();
            pbtr1.Portfolio_Segment1__c = 'Services';
            pbtr1.Team_Role__c = 'Inside Sales Rep';
            Product_Based_Team_Role__c pbtr2 = new Product_Based_Team_Role__c();
            pbtr2.Portfolio_Segment1__c= 'Services';
            pbtr2.Team_Role__c = 'Inside Sales Rep';
            pbtrList.add(pbtr1);
            pbtrList.add(pbtr2);
            insert pbtrList;
            
            Test.startTest();
            
            QuoteTriggerHandler.TriggerDisabled = true;
            AccountTriggerHandler.TriggerDisabled = true;
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.AccountId = account.id;
            opp.OppStatus__c = 'Open';
            opp.ExpectedInstallDate__c = System.today();
            insert opp;
            List<Id> idList = new List<Id>(); 
            idList.add(opp.Id);
            insertTestTerritory(account.Id);
            AccountTriggerHandler.setOwnerIdInAccountsBasedOnTerritoryRole(new List<Account>{account});
            Territory2 terr = [Select id from Territory2 where name = 'TestTerritory222'];
            Id territory2Id = terr.Id;
            List<Opportunity> oppList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                         WHERE Id IN :idList ];  
            CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
            job.oppList = oppList; 
            job.territory2Id = territory2Id; 
            System.enqueueJob(job);
            
            Test.stopTest();
        }
    }
    
    @istest
    private static void territorryAssignmentToAccountsByTrigger() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,        //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        test.startTest();
        account.billingPostalCode = '95128';
        update account;
        
        System.RunAs(usr)
        {
            
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.AccountId = account.id;
            opp.OppStatus__c = 'Open';
            opp.ExpectedInstallDate__c =  System.today();
            insert opp;
            insertTestTerritory(account.Id);
            List<Id> idList = new List<Id>(); 
            idList.add(opp.Id);
            Territory2 terr = [Select id from Territory2 where name = 'TestTerritory222'];
            Id territory2Id = terr.Id;
            OpportunityTerrBulkAssign handler = new OpportunityTerrBulkAssign();
            OpportunityTerrBulkAssign.Territory2Priority tp = new OpportunityTerrBulkAssign.Territory2Priority(territory2Id,1,false);
            handler.getOpportunityTerritory2Assignments(idList); 
            List<id> accIds = new List<id>();
            accIds.add(account.id);
            AccountTriggerHandler.setOwnerIdInAccountsBasedOnTerritoryRole(new List<Account>{account});
            TerritoryUtility.populateAccountTeamMemberList(accIds);
            
        }
        Test.stopTest();
    }
    
    @istest
    private static void testTerritorryAndOwnerAssignmentInBatch() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select   Country_Cluster__c, OwnerId,Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,         //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        Territory_Zipcodes__c zipcode = new Territory_Zipcodes__c();
        zipcode.Zipcode__c = '95128';
        zipcode.Territory_Name__c = 'TestTerr';
        zipcode.Country__c = 'test cont';
        insert zipcode;
        /* Territory_DHC__c dhc = new Territory_DHC__c();
dhc.Definitive_ID__c = 1;
dhc.Territory_Name__c = 'TestTerr';
insert dhc;*/
        AccountTriggerHandler.TriggerDisabled = true;
        account.Territory_Name__c = 'TestTerr';
        //Territory_Name__c,Country_Cluster__c,Region__c,Division__c,Account_Territory__c 
        // FROM Account_Territory_Information__c
        Account_Territory_Information__c ati = new Account_Territory_Information__c();
        ati.Country_Cluster__c = 'US&CA';
        ati.Region__c = 'Northwest'; 
        ati.Division__c = 'United States';
        ati.Account_Territory__c = 'North CA';
        ati.Territory_Name__c = 'TestTerr';
        //insert ati;
        
        Map<String,Account_Territory_Information__c> accntTerritoryInfoMap = new Map<String,Account_Territory_Information__c>();
        accntTerritoryInfoMap.put('TestTerr',ati);
        BCH_UpdateTerritoryInAccounts.setAccountFields(account,accntTerritoryInfoMap);
        insert ati;
        System.RunAs(usr)
        {
            OpportunityTriggerHandler.TriggerDisabled = true;
            insertTestTerritory(account.Id);
            List<Account> acclist = new List<Account>();
            acclist.add(account);
            Map<Id, Account> oldMap = new Map<Id, Account>();
            oldMap.put(account.id,account);
            Test.startTest();                
            BCH_UpdateTerritoryInAccounts.updateAccountTerritoryName(acclist,oldMap);
            Test.stopTest();
        }
    }
    
    @istest
    private static void territorryAssignmentTest() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select ownerid, Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,        //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        
        System.RunAs(usr)
        {
            Test.startTest();
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.AccountId = account.id;
            opp.OppStatus__c = 'Open';
            opp.ExpectedInstallDate__c = System.today();
            insert opp;
            insertTestTerritory(account.Id);
            List<Account> acclist = new List<Account>();
            acclist.add(account);
            List<id> accIds = new List<id>();
            accIds.add(account.id);
            AccountTriggerHandler.setOwnerIdInAccountsBasedOnTerritoryRole(acclist);
            Map<Id, Account> oldAccountMap = new Map<Id, Account>();
            for(Account acct: acclist)
            {
                oldAccountMap.put(acct.Id,acct);
            }
            UpdateTerritoryInAccounts.setAccountOwnerInSAP(acclist,oldAccountMap,accIds);
            Test.stopTest();
        }
    }
    
    @istest
    private static void territorryBulkAssignmentTest1() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,          //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        //SELECT Zipcode__c,Territory_Name__c  FROM Territory_Zipcodes__c
        Territory_Zipcodes__c zipcode = new Territory_Zipcodes__c();
        zipcode.Zipcode__c = '95128';
        zipcode.Territory_Name__c = 'TestTerr';
        insert zipcode;
        System.RunAs(usr)
        {
            insertTestTerritory(account.Id);
            Test.startTest();       
            list<account> accountList = [select id from account];
            list<id> acc = new list<id>();
            for(Account a:accountList){
                acc.add(a.id);
            }
            BCH_UpdateTerritoryInAccounts updateTerritoryInAccountsBatch = new BCH_UpdateTerritoryInAccounts(acc);
            Database.executeBatch(updateTerritoryInAccountsBatch, 30);  
            Test.stopTest();
        }
    }
    
    @istest
    private static void territorryBulkAssignmentTest() {
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,         //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        //SELECT Zipcode__c,Territory_Name__c  FROM Territory_Zipcodes__c
        Territory_Zipcodes__c zipcode = new Territory_Zipcodes__c();
        zipcode.Zipcode__c = '95128';
        zipcode.Territory_Name__c = 'TestTerr';
        insert zipcode;
        System.RunAs(usr)
        {
            insertTestTerritory(account.Id);
            Test.startTest();              
            ScheduledUpdateTerritoryInAccounts sh1 = new ScheduledUpdateTerritoryInAccounts();
            String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
            Test.stopTest();
        }
    }
    
    private static void territorryUtilityTest() {
        accounttriggerhandler.triggerdisabled= true;
        List<Id> accIds = new List<Id>();
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,     //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        accIds.add(account.id);
        //SELECT Zipcode__c,Territory_Name__c  FROM Territory_Zipcodes__c
        Territory_Zipcodes__c zipcode = new Territory_Zipcodes__c();
        zipcode.Zipcode__c = '95128';
        zipcode.Territory_Name__c = 'TestTerr';
        insert zipcode;
        System.RunAs(usr)
        {
            insertTestTerritory(account.Id);
            Test.startTest();              
            TerritoryUtility.populateAccountTeamMemberList(accIds);
            Test.stopTest();
        }
    }
    
    @istest
    private static void runTerritoryExecutionTest() {
        accounttriggerhandler.triggerdisabled= true;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name,             //IBA-4149
                         BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from account LIMIT 1];
        Territory_Zipcodes__c zipcode = new Territory_Zipcodes__c();
        zipcode.Zipcode__c = '95128';
        zipcode.Zipcode__c = 'TestTerr';
        insert zipcode;
        System.RunAs(usr)
        {
            Test.startTest();              
            RunAccountTerritoryController.updateTerritory(String.valueOf(account.Id));
            Test.stopTest();
        }
    }
    
    private static List<ObjectTerritory2Association> insertTestTerritory(Id AccId){
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Test' LIMIT 1];
        List<Profile> adminProfile = [select id, name from Profile where  name = 'System Administrator'];
        
        Territory2Model terrModel = new Territory2Model();
        terrModel.DeveloperName='ModelName'; // required field
        terrModel.Name = 'Name'; // required field
        //  terrModel.ActivatedDate = Date.today();
        insert terrModel ;
        
        Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory222', Territory2ModelId=terrModel.Id, 
                                            Name='TestTerritory222', Territory2TypeId=terriType[0].Id);
        insert objTerr;
        
        
        User u = TestDataFactory.createUser(true,'XLLASTNAME_12345','XLLASTNAME_12345');
        
        UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u.Id, RoleInTerritory2='Account Owner');
        insert objUserTerritory2Association;
        delete objUserTerritory2Association;
        objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u.Id, RoleInTerritory2='Account Owner');
        insert objUserTerritory2Association;
        
        ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = AccId, 
                                                                                                     Territory2Id =objTerr.Id, 
                                                                                                     AssociationCause='Territory2Manual');
        insert objObjectTerritory2Association;
        List<ObjectTerritory2Association> otaList = new List<ObjectTerritory2Association>();
        otaList.add(objObjectTerritory2Association); 
        return otaList;
    }
    
    @isTest
    public static void coverforOppDelMethod(){
        accounttriggerhandler.triggerdisabled= true;
        usertriggerhandler.triggerdisabled = true;
        User us=TestDataFactory.createUser(true,'testUser','SalesQuota');
        List<String> lstProfileName = new List<String>();
        lstProfileName.add('System Administrator');
        List<Profile> lstProfile = [select id, name from Profile where name =:'Solution Manager'];
        us.ProfileId = lstProfile[0].id;
        update us;
        User usNew = [select id, name,profileid from user where id=:us.id];
        System.runAs(usNew){
            try{
                AccountCreateController.isFirstRun= false; 
                Account account=TestDataFactory.createTestAccountQuotePrint();
                account.Division_Account__c ='Atlantic';
                update account;
                
                test.startTest();
                
                Opportunity opp = TestDataFactory.createOppWithAccount();
                opp.oppstatus__c= Label.Fully_Booked;
                opp.ExpectedInstallDate__c = System.today();
                update opp;
                
                List<Opportunity> lstOpp = new List<Opportunity>();
                lstOpp.add(opp);
                //OpportunityTriggerHandler.checkStage(lstOpp);
                Delete opp;
                unDelete opp;
                test.stopTest();
            }catch(Exception ae){}
        }
    }
    
    @isTest
    public static void testmethod1(){
        Account account= [Select Id From Account Where Name = 'Test IBA-4942'];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr = [Select id from User where Id != :UserInfo.getUserId() and ProfileId =: p.Id and isActive = true Limit 1];
         System.RunAs(usr){
            List<Quota_Carrying_Team_Role__c> qctrList = new List<Quota_Carrying_Team_Role__c>();
            Quota_Carrying_Team_Role__c qctr1 = new Quota_Carrying_Team_Role__c();
            qctr1.Name = 'Inside Sales Rep';
            Quota_Carrying_Team_Role__c qctr2 = new Quota_Carrying_Team_Role__c();
            qctr2.Name = 'Sales Consultant';
            Quota_Carrying_Team_Role__c qctr3 = new Quota_Carrying_Team_Role__c();
            qctr3.Name = 'Account Owner';
            qctrList.add(qctr1);
            qctrList.add(qctr2);
            qctrList.add(qctr3);
            insert qctrList;
            
            List<Product_Based_Team_Role__c> pbtrList = new List<Product_Based_Team_Role__c>();
            Product_Based_Team_Role__c pbtr1 = new Product_Based_Team_Role__c();
            pbtr1.Portfolio_Segment1__c = 'Services';
            pbtr1.Team_Role__c = 'Inside Sales Rep';
            Product_Based_Team_Role__c pbtr2 = new Product_Based_Team_Role__c();
            pbtr2.Portfolio_Segment1__c= 'Services';
            pbtr2.Team_Role__c = 'Inside Sales Rep';
            pbtrList.add(pbtr1);
            pbtrList.add(pbtr2);
            insert pbtrList;
            
            Test.startTest();
            
            QuoteTriggerHandler.TriggerDisabled = true;
            AccountTriggerHandler.TriggerDisabled = true;
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.AccountId = account.id;
            opp.OppStatus__c = 'Open';
            opp.ExpectedInstallDate__c = System.today();
            insert opp;
            Opportunity_Team_Members_History__c otmh = new Opportunity_Team_Members_History__c(Opportunity__c = opp.Id,
                                                                                               User__c = UserInfo.getUserId(),
                                                                                               Team_Role__c = 'AccountOwner',
                                                                                               ParentId__c = '',
                                                                                               OpportunityAccessLevel__c = 'Public Read Only',
                                                                                               Compensation__c = false,
                                                                                               Deleted_Record__c = true);
            insert otmh;
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.Id,
                                                                  UserId = UserInfo.getUserId(),
                                                                  TeamMemberRole = 'AccountOwner');
            insert otm;
            List<Id> idList = new List<Id>(); 
            idList.add(opp.Id);
            List<ObjectTerritory2Association> otaList = insertTestTerritory(account.Id);
            Territory2 terr = [Select id from Territory2 where name = 'TestTerritory222'];
            Id territory2Id = terr.Id;
            List<Opportunity> oppList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                         WHERE Id IN :idList ];  
            CreateOpportunityTeamMembers.otaTestList = otaList;
            
            List<Opportunity> oppFullList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                             WHERE Id IN :idList and Account.IsDeleted__c = false
                                             AND (OppStatus__c ='PO Received - Pending Paperwork' OR 
                                                  OppStatus__c ='PO Received' OR OppStatus__c ='Open')];
            CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
             job.role =  'Account Owner';
             job.user = UserInfo.getUserId();
            job.oppFullList = oppFullList; 
            System.enqueueJob(job);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testmethod2(){
        Account account= [Select Id From Account Where Name = 'Test IBA-4942'];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr = [Select id from User where Id != :UserInfo.getUserId() and ProfileId =: p.Id and isActive = true Limit 1];
        System.RunAs(usr){
            List<ObjectTerritory2Association> otaList = insertTestTerritory(account.Id);
        }
        List<Opportunity> oppList = [SELECT Id, AccountId, Territory2Id, OwnerId, Account.Facility_Type__c from Opportunity 
                                         WHERE AccountId =:account.Id ]; 
        CreateOpportunityTeamMembers job = new CreateOpportunityTeamMembers();
        job.oppFullList = oppList; 
        System.enqueueJob(job);
    }
}