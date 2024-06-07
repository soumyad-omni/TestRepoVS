@isTest
public class SegmentProcess_controllerTest {
    
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
        
        Account_Segment_ParentId__c asp1 = new Account_Segment_ParentId__c(ParentId__c = accountList[3].parentid);
        insert asp1;
        SegmentProcess_controller.updateSegment();
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
    static void TIParentSegment(){
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
        ExternalDataTriggerHandler.TriggerDisabled = true;
       	Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account act0 = new Account(name='My New Account100',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                      BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Facility_Type__c='Hospice', 
                                      //ParentId = '0011N00001pYpTbQAK',
                                      //Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada1',//SAP_Account_ID__c='1234'+system.now().millisecond()+math.round(math.random()*10000),
                                      Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        
        Account act1 = new Account(name='My New Account101',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                      BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54321',BillingStreet='test456',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Facility_Type__c='Hospice', 
                                      ParentId=act0.Id,
                                      //Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada',//SAP_Account_ID__c='1234'+system.now().millisecond()+math.round(math.random()*10000),
                                      Transport_Zone__c='US00000002',Partner_Type__c= '0015');
       
       	insert act1;
       
        Account act2 = new Account(name='My New Account1001',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                      BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54675',BillingStreet='test123',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Facility_Type__c='Hospice', 
                                      //ParentId = '0011N00001pYpTbQAK',
                                      //Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada1',//SAP_Account_ID__c='1234'+system.now().millisecond()+math.round(math.random()*10000),
                                      Transport_Zone__c='US00000003',Partner_Type__c= '0015');
		
        insert act2;

        //create target initiaitve
        Target_Initiative__c ti01 = new Target_Initiative__c();
        ti01.Name          = 'Top Accounts';
        ti01.Start_Date__c = System.today();
        ti01.End_Date__c   = System.today()+60;
        ti01.Use_for_segmentation__c = true;
        ti01.Type_of_account_propagation__c = 'Apply to entire hierarchy';    
        insert ti01;
                        
        // add an account to target initiative
        Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
        tia1.Target_Initiative__c = ti01.id;
        tia1.Account__c = act1.id;
        insert tia1;
		
        Target_Initiative_Account__c tia2 = new Target_Initiative_Account__c();
        tia2.Target_Initiative__c = ti01.Id;
        tia2.Account__c = act2.Id;
        insert tia2;
    	
		   		
        Set<Id> topChilds= new Set<Id>{act0.Id,act1.Id};
    	
        Map<Id,Set<Id>> parentChildMap = new Map<Id,Set<Id>>();
        parentChildMap.put(act0.Id,new Set<Id>{act1.id});
        parentChildMap.put(act2.Id,new Set<Id>{act1.id});
        Set<Id> oldTopChilds;
        Set<Id> acctSet = new Set<Id>{act1.id};
		Set<string> accountIds = new Set<string>();
        accountIds.add(act2.id);
       test.startTest();
			act1.ParentId=act2.Id;
        	update act1;
        	map<integer,Set<Id>> allHier = new map<integer,Set<Id>>();
        	System.enqueueJob(new TIParentSegment2(topChilds,oldTopChilds,false,0,allHier));
  		test.stopTest(); 
    }

}