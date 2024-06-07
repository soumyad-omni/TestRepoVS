@isTest
public class ToplevelParent_test {
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
        
        Opportunity_Field_Tracking__c s1 = new Opportunity_Field_Tracking__c();
        s1.name ='ASSOCIATED_OPPORTUNITY__C';
        insert s1;
        
        Opportunity_Field_Tracking__c s2 = new Opportunity_Field_Tracking__c();
        s2.name ='COMPETITOR__C';
        insert s2;
        
        Opportunity_Field_Tracking__c s3 = new Opportunity_Field_Tracking__c();
        s3.name ='Contract_Year__c';
        insert s3;
        Opportunity_Field_Tracking__c s4 = new Opportunity_Field_Tracking__c();
        s4.name ='AccountId';
        insert s4;
        
        Opportunity_Field_Tracking__c s5 = new Opportunity_Field_Tracking__c();
        s5.name ='Competitor__c';
        insert s5;
        
        Opportunity_Field_Tracking__c  setting11 = new Opportunity_Field_Tracking__c ();
        setting11.Name = 'ACCOUNTID';
        insert setting11;
        Opportunity_Field_Tracking__c  setting12 = new Opportunity_Field_Tracking__c ();
        setting12.Name = 'AMOUNT';
        insert setting12;
         Opportunity_Field_Tracking__c  setting333 = new Opportunity_Field_Tracking__c ();
        setting333.Name = 'EXPECTED_BOOKINGS__C';
         insert setting333;
        Opportunity_Field_Tracking__c  setting13 = new Opportunity_Field_Tracking__c ();
        setting13.Name = 'NAME';
        insert setting13;
        Opportunity_Field_Tracking__c  setting22 = new Opportunity_Field_Tracking__c ();
        setting22.Name = 'RECORDTYPEID';
        insert setting22;
        Opportunity_Field_Tracking__c  setting33 = new Opportunity_Field_Tracking__c ();
        setting33.Name = 'CloseDate';
         insert setting33;
         Opportunity_Field_Tracking__c  setting44= new Opportunity_Field_Tracking__c ();
        setting44.Name = 'Competitor__c';
         insert setting44;
         Opportunity_Field_Tracking__c  setting211 = new Opportunity_Field_Tracking__c ();
        setting211.Name = 'RECORDTYPEID';
        insert setting211;
        SCP_TestDataFactory.createContact_Customsetting();  
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        
    }   
    @isTest
    static void UpdateAccount_Test () {
        List<Account> accList = new List<Account>();
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        
        Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
        c.Name = 'AZ';
        c.Currency_Code__c = 'USD';
        Insert c; 
        
        
        
        List<Account> accountList = createAccounts(4);
        
        User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
        User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
        accountList[0].Validation_Status__c = 'Awaiting Validation';
        update accountList[0];
        
        test.StartTest();
        Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
        setting1.Name = 'ACCOUNT_ROLE__C';
        insert setting1;
        
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
            accountList[2].parentid = accountList[1].id;
            accountList[2].Top_level_1__c = accountList[1].id;
            accountList[2].Top_level_2__c = accountList[1].name;
            update accountList[2]; 
            system.debug('Partner Type Found');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            
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
        
        
        
        
        
        System.debug('Running test for validation');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        accountList[3].Validation_Status__c = 'Validated';
        accountList[3].Partner_Type__c= '0015';
        accountList[3].Transport_Zone__c='US00000001'; 
        accountList[3].RecordTypeId = recTypeAccount;
        accountList[3].parentid = accountList[2].id;
        accountList[3].Top_level_1__c = accountList[1].id;
        accountList[3].Top_level_2__c = accountList[1].name;
        update accountList[3];
        
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        
        list<account> accounts = new list<account>();
        accounts.add(accountList[1]);
        set<string> paccounts = new set<string>();
        paccounts.add(accountList[1].id);
        TopLevelParent_update2 job = new TopLevelParent_update2() ;
        job.accounts = accounts;
        job.paccounts = paccounts;
        
        System.enqueueJob(job);
        
        test.StopTest();
    } 
    
    @isTest
    static void UpdateAccount_Test2 () {
        List<Account> accList = new List<Account>();
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        
        Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
        c.Name = 'AZ';
        c.Currency_Code__c = 'USD';
        Insert c; 
        
        
        
        List<Account> accountList = createAccounts(4);
        
        OpportunityTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.AccountId = accountList[2].id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Non Comm. Book - No Service PO';
        opp.Credit_Approved_For__c = accountList[2].id;
        //opportunitytriggerhandler.TriggerDisabled = true;
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today();
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        insert opp;
        
        User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
        User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
        accountList[0].Validation_Status__c = 'Awaiting Validation';
        update accountList[0];
        
        test.StartTest();
        Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
        setting1.Name = 'ACCOUNT_ROLE__C';
        insert setting1;
        
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
            accountList[2].parentid = accountList[1].id;
            accountList[2].Top_level_1__c = accountList[1].id;
            accountList[2].Top_level_2__c = accountList[1].name;
            update accountList[2]; 
            system.debug('Partner Type Found');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            
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
        
        
        
        
        
        System.debug('Running test for validation');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        accountList[3].Validation_Status__c = 'Validated';
        accountList[3].Partner_Type__c= '0015';
        accountList[3].Transport_Zone__c='US00000001'; 
        accountList[3].RecordTypeId = recTypeAccount;
        accountList[3].parentid = accountList[2].id;
        accountList[3].Top_level_1__c = accountList[1].id;
        accountList[3].Top_level_2__c = accountList[1].name;
        update accountList[3];
        
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        
        map<id,list<account>> parentChildmap = new map<id,list<account>>();
        list<account> accnts = new list<account>();
        accnts.add(accountList[2]);
        parentChildmap.put(accountList[1].id, accnts);
        
        list<Id> accountids = new list<Id>();
        accountids.add(accountList[1].id);
        Set<string> accountIdst = new Set<string>();
        Set<Id> oldTopChilds;
        Set<Id> topChilds;
        TopLevelParent_update3 updatechild = new TopLevelParent_update3(accountids,parentChildmap,accountList[1],topChilds,oldTopChilds,false,false,accountIdst,false);
        Database.executeBatch(updatechild, 1);
        
        
        test.StopTest();
    } 
    static List<Account> createAccounts(Integer numberOfAccounts){
        List<Account> accList=new List<Account>();   
        for(Integer i=0;i<numberOfAccounts;i++){
            Account acc = Testdatafactory.createUSTestAccount();
            accList.add(acc);
        }
        return accList;
    }
    @isTest
    static void UpdateAccount_Test3 () {
        List<Account> accList = new List<Account>();
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        
        Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
        c.Name = 'AZ';
        c.Currency_Code__c = 'USD';
        Insert c; 
        
        
        
        List<Account> accountList = createAccounts(4);
        
        User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
        User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
        accountList[0].Validation_Status__c = 'Awaiting Validation';
        update accountList[0];
        
        test.StartTest();
        list<account> accounts = new list<account>();
        accounts.add(accountList[0]);
        set<string> paccounts = new set<string>();
        paccounts.add(accountList[0].id);
        TopLevelParent_update2 job = new TopLevelParent_update2() ;
        job.accounts = accounts;
        job.paccounts = paccounts;
        
        System.enqueueJob(job);
        
        test.StopTest();
    } 
    
    @isTest
    static void UpdateAccount_Test4 () {
        List<Account> accList = new List<Account>();
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        
        Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
        c.Name = 'AZ';
        c.Currency_Code__c = 'USD';
        Insert c; 
        
        
        
        List<Account> accountList = createAccounts(4);
        
        User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
        User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
        accountList[0].Validation_Status__c = 'Awaiting Validation';
        update accountList[0];
        
        test.StartTest();
        Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
        setting1.Name = 'ACCOUNT_ROLE__C';
        insert setting1;
        
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
            accountList[2].parentid = accountList[1].id;
            accountList[2].Top_level_1__c = accountList[1].id;
            accountList[2].Top_level_2__c = accountList[1].name;
            update accountList[2]; 
            system.debug('Partner Type Found');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            
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
        
        
        
        
        
        System.debug('Running test for validation');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        accountList[3].Validation_Status__c = 'Validated';
        accountList[3].Partner_Type__c= '0015';
        accountList[3].Transport_Zone__c='US00000001'; 
        accountList[3].RecordTypeId = recTypeAccount;
        accountList[3].parentid = accountList[2].id;
        accountList[3].Top_level_1__c = accountList[1].id;
        accountList[3].Top_level_2__c = accountList[1].name;
        update accountList[3];
        
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        
        map<id,list<account>> parentChildmap = new map<id,list<account>>();
        list<account> accnts = new list<account>();
        accnts.add(accountList[2]);
        list<account> accnts1 = new list<account>();
        accnts1.add(accountList[3]);
        parentChildmap.put(accountList[1].id, accnts);
        parentChildmap.put(accountList[2].id, accnts1);
        
        list<Id> accountids = new list<Id>();
        accountids.add(accountList[1].id);
        Set<string> accountIdst = new Set<string>();
        Set<Id> oldTopChilds;
        Set<Id> topChilds;
        TopLevelParent_update3 updatechild = new TopLevelParent_update3(accountids,parentChildmap,accountList[1],topChilds,oldTopChilds,false,false,accountIdst,false);
        Database.executeBatch(updatechild, 1);
                
        test.StopTest();
    } 
    
    @isTest
    static void UpdateAccount_Test5() {
        List<Account> accList = new List<Account>();
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        
        Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
        c.Name = 'AZ';
        c.Currency_Code__c = 'USD';
        Insert c; 
        
        
        
        List<Account> accountList = createAccounts(4);
        
        User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
        User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
        accountList[0].Validation_Status__c = 'Awaiting Validation';
        update accountList[0];
        
        test.StartTest();
           
        
        
        
        
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
            accountList[2].parentid = accountList[1].id;
            accountList[2].Top_level_1__c = accountList[1].id;
            accountList[2].Top_level_2__c = accountList[1].name;
            update accountList[2]; 
            system.debug('Partner Type Found');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            
        }
        
        
        
        System.debug('Running test for validation');
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        accountList[3].Validation_Status__c = 'Validated';
        accountList[3].Partner_Type__c= '0015';
        accountList[3].Transport_Zone__c='US00000001'; 
        accountList[3].RecordTypeId = recTypeAccount;
        accountList[3].parentid = accountList[2].id;
        accountList[3].Top_level_1__c = accountList[1].id;
        accountList[3].Top_level_2__c = accountList[1].name;
        update accountList[3];
        
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        
        list<account> accounts = new list<account>();
        accounts.add(accountList[2]);
        set<string> paccounts = new set<string>();
        paccounts.add(accountList[1].id);
        TopLevelParent_update2 job = new TopLevelParent_update2() ;
        job.accounts = accounts;
        job.paccounts = paccounts;
        
        System.enqueueJob(job);
        
        test.StopTest();
    } 
    
    @isTest
    static void UpdateAccount_Test6() {
        List<Account> accList = new List<Account>();
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        
        AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
        
        Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
        c.Name = 'AZ';
        c.Currency_Code__c = 'USD';
        Insert c; 
        
        
        
        List<Account> accountList = createAccounts(4);
        
        User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
        User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
        accountList[0].Validation_Status__c = 'Awaiting Validation';
        update accountList[0];
        
        test.StartTest();
           
        
        
        
        
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
            accountList[2].parentid = accountList[1].id;
            accountList[2].Top_level_1__c = accountList[1].id;
            accountList[2].Top_level_2__c = accountList[1].name;
            update accountList[2]; 
            system.debug('Partner Type Found');
        }
        catch(Exception e){
            system.debug('Error ' + e.getMessage());
            
        }
           
        
        
        
        AccountCreateController.isTriggerExecuting = false;
        AccountCreateController.isFirstRun = true;
        
        list<account> accounts = new list<account>();
        accounts.add(accountList[2]);
        set<string> paccounts = new set<string>();
        paccounts.add(accountList[1].id);
        TopLevelParent_update2 job = new TopLevelParent_update2() ;
        job.accounts = accounts;
        job.paccounts = paccounts;
        
        System.enqueueJob(job);
        
        test.StopTest();
    } 
}