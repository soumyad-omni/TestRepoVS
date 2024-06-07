@isTest
public class ScheduledUpdateTerritoryInAccountsTest {
  	public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        SCP_Integration_Details__c  setting11 = new SCP_Integration_Details__c ();
        setting11.Name = 'SCP_ContactSFToCRM';
        setting11.SCP_Method_Type__c = 'POST';
        setting11.SCP_Timeout__c = 120000;
        setting11.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM';
        insert setting11;
        
        Trigger_Configuration__c  usertrg = new Trigger_Configuration__c();
        usertrg.Name = 'UserTriggerDisabled';
        usertrg.IsDisabled__c = true;
        insert usertrg;

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
        
        
        AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c =  System.today();
        Account acc = TestDataFactory.createTestAccountQuotePrint();
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
        opp.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        insert opp;

		Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
           	acct.Facility_Type__c = 'Pharmacy';
           	acct.BILLINGSTREET = '41 Moss';
            acct.BillingPostalCode = 'DY6 9HP';
            insert acct;        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
                        String orgId=UserInfo.getOrganizationId(); 
                        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
                        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
                        String uniqueName=orgId+dateString+RandomId; 
                        User uu=new User(firstname = 'ABC', 
                                         lastName = 'XYZ', 
                                         email = uniqueName + '@test' + orgId + '.org', 
                                         Username = uniqueName + '@test' + orgId + '.org', 
                                         EmailEncodingKey = 'ISO-8859-1', 
                                         Alias = uniqueName.substring(18, 23), 
                                         TimeZoneSidKey = 'America/Los_Angeles', 
                                         LocaleSidKey = 'en_US', 
                                         LanguageLocaleKey = 'en_US', 
                                         ProfileId = pf.Id
                                        );
        UserTriggerHandler.TriggerDisabled = true;
        insert uu;
    } 
    
    
        @istest
    private static void testUpdateTerritorryAssignmentInAcct() {

        User usr = [Select id from User where Name ='Admin Integration' limit 1];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, 
                          BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from Account LIMIT 1];
        
        System.RunAs(usr)
        {
            Test.startTest();
                OpportunityTriggerHandler.TriggerDisabled = true;
            	accounttriggerhandler.TriggerDisabled = true;
                Opportunity opp = new Opportunity();
                opp.name = 'Test Opportunity for update';
                opp.stageName = '1 Initial Sales Activity';
                opp.CloseDate = System.today()+30;
                opp.AccountId = account.id;
                opp.OppStatus__c = 'Open';
                opp.ExpectedInstallDate__c = System.today();
            	opp.Services_Enablement_Owner__c = 'Tara Bakker';
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
    private static void testUpdateTerritorryAssignmentInAcct11() {

        User usr = [Select id from User where Name ='Admin Integration' limit 1];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select  Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, 
                          BillingPostalCode,Territory_Name__c,texcellency__DefHC_HospitalID__c, BillingCountry,IsDeleted__c from Account LIMIT 1];
        
        System.RunAs(usr)
        {
            Test.startTest();
                OpportunityTriggerHandler.TriggerDisabled = true;
            	accounttriggerhandler.TriggerDisabled = true;
                Opportunity opp = new Opportunity();
                opp.name = 'Test Opportunity for update';
                opp.stageName = '1 Initial Sales Activity';
                opp.CloseDate = System.today()+30;
                opp.AccountId = account.id;
                opp.OppStatus__c = 'Open';
                opp.ExpectedInstallDate__c = System.today();
            	opp.Services_Enablement_Owner__c = 'Tara Bakker';
                insert opp;
                insertTestTerritory(account.Id);
                List<Account> accList = new List<Account>();
                accList.add(account);
                Map<Id, Account> oldMap = new Map<Id, Account>();
               BCH_UpdateOwnerInAccounts.updateAccountTerritoryName(accList);
            Test.stopTest();
        }
    }
    
          @istest
    private static void testTerritorryAndOwnerAssignmentInBatch() {

        User usr = [Select id from User where Name ='Admin Integration' limit 1];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select   Country_Cluster__c, OwnerId,Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, 
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
        ati.Region__c = 'Western Canada'; 
        ati.Division__c = 'Canada';
        ati.Account_Territory__c = 'Western Canada';
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
    private static void testTerritorryAndOwnerAssignmentInBatch11() {

        User usr = [Select id from User where Name ='Admin Integration' limit 1];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select   Country_Cluster__c, OwnerId,Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, 
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
        ati.Region__c = 'Western Canada'; 
        ati.Division__c = 'Canada';
        ati.Account_Territory__c = 'Western Canada';
        ati.Territory_Name__c = 'TestTerr';
        //insert ati;
        
        Map<String,Account_Territory_Information__c> accntTerritoryInfoMap = new Map<String,Account_Territory_Information__c>();
        accntTerritoryInfoMap.put('TestTerr',ati);
        BCH_UpdateOwnerInAccounts.setAccountFields(account,accntTerritoryInfoMap);
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
                BCH_UpdateOwnerInAccounts.updateAccountTerritoryName(acclist);
            Test.stopTest();
        }
    }
    
         @istest
    private static void territorryBulkAssignmentTest1() {

        User usr = [Select id from User where Name ='Admin Integration' limit 1];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, 
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

        User usr = [Select id from User where Name ='Admin Integration' limit 1];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, 
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
    @istest
    private static void territorryBulkAssignmentTest11() {

        User usr = [Select id from User where Name ='Admin Integration' limit 1];
        AccountCreateController.isFirstRun= false;        
        Account account=[Select Country_Cluster__c, Division_Account__c, Region__c,   Account_Territory__c ,Id, Name, 
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
               ScheduledUpdateTerritoryInAccountsRetry sh1 = new ScheduledUpdateTerritoryInAccountsRetry();
               String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
            Test.stopTest();
            BCH_UpdateOwnerInAccounts.SendCsvEmail('test');
        }
    }
    

    private static List<ObjectTerritory2Association> insertTestTerritory(Id AccId)
    {
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
       // ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = AccId, 
                                                                                                 //    Territory2Id =objTerr.Id, 
                                                                                                 //    AssociationCause='Territory');
        insert objObjectTerritory2Association;
       // UserTerritory2Association objUserTerritory2Association2 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u2.Id, RoleInTerritory2='Sales / Marketing Administrator');
        //insert objUserTerritory2Association2 ;
       List<ObjectTerritory2Association> otaList = new List<ObjectTerritory2Association>();
       otaList.add(objObjectTerritory2Association); 
      return otaList;
    }
   
    
}