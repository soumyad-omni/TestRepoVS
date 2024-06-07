@isTest
public class OppDuplicateManagement_Test {
    
    @testsetup
    static void testdatasetup(){
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
    }
    
    public testmethod static void checkboxAutomation1(){
        AccountCreateController.isFirstRun= false;
        Test.startTest();
        //Account acc = TestDataFactory.createTestAccountQuotePrint();
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Opportunity opp2 = new Opportunity();
        opp2.name = 'Test Opportunity';
        opp2.stageName = '1 Solution Design';
        opp2.CloseDate = System.today()+30;
        //Account acc = TestDataFactory.createTestAccountQuotePrint();
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        Account acc1 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='13903',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc1.texcellency__DefHC_HospitalID__c = 1;
        acc1.Territory_Name__c = 'TestTerr';
        acc1.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        acc1.Credit_Date_Approved__c = system.today() - 1500;
        insert acc1;
        opp2.Services_Enablement_Owner__c = 'Tara Bakker';
        opp2.OppStatus__c = 'Open';
        //insert opp;
        //Opportunity opp2 = TestDataFactory.createOppWithAccount();
        opp2.AccountId= acc1.id;//opp.AccountId;
        opp2.ExpectedInstallDate__c=Date.newInstance( 2021, 12, 12);
        opp2.Date_Approved__c = system.today() - 10;
        insert opp2;
        
        /*Opportunity opp = TestDataFactory.createOpportunity();
        opp.AccountId = acc.id;
        Update opp;
        Opportunity opp2 = TestDataFactory.createOpportunity();
        opp2.AccountId=acc.Id;
        Update opp2;*/
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OppDuplicateManagement odm = new OppDuplicateManagement(sc);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(opp2);
        OppDuplicateManagement odm1 = new OppDuplicateManagement(sc1);
        Test.stopTest();
    }
    
    /*public static testmethod void OppDuplicateManagement(){
        Opportunity opp = new Opportunity(name='test opportunity',stageName='Won');
        Account acc=new Account(name='Test acc',Account_role__c='ZCSN',Account_Territory__c='AZ');
        insert acc;
        opp.CloseDate = System.today()+30;
        opp.AccountId = acc.id;
        opp.Opportunity__c = 'Omnicell Opportunity';
        insert opp;
        Opportunity opp1 = new Opportunity(name='test opportunity1',stageName='Won');
        opp1.CloseDate = System.today()+30;
        opp1.AccountId = acc.id;
        insert opp1;
        Test.startTest();
      	  	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        	OppDuplicateManagement odm = new OppDuplicateManagement(sc);
        	ApexPages.StandardController sc1 = new ApexPages.StandardController(opp1);
        	OppDuplicateManagement odm1 = new OppDuplicateManagement(sc1);
        Test.stopTest();
    }*/
}