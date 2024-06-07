@isTest
public with sharing class productLineCreateControllerTest {
    public static Id US_CORE_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
    public static Id recTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('US_Customer').getRecordTypeId();
    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();  
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.ContactInsertEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRM';
        setting.ContactUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRMUpdate';
        setting.AccountRole_SoldTo__c='ZCSN';
        insert setting;

        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
          
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;

        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = true;

        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',
                                      SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',
                                      Facility_Type__c = 'Correctional Facilities',
                                      BILLINGSTREET = '41 Moss',BillingPostalCode = 'DY6 9HP');
        insert acct; 
        ContactTriggerHandler.TriggerDisabled = true;
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
        con.AccountId = acct.id;
        con.Omnicell_Job_Code__c = 'D3';
        con.SAP_Contact_ID__c='1234';
        con.Salesforce_Contact_ID__c ='5678';
        con.SAP_Contact_GUID__c = '3467';
        con.phone='1234567890';
        con.email= 'example@omnicell.com';
        con.Title = 'Test';
        insert con;
    }

    @IsTest
    static void methodName1(){
        Account acc = [Select Id From Account Limit 1];
        Contact con = [Select Id From Contact Limit 1];
        Opportunity opp = new Opportunity();
        opp.name = 'Us and CORE Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId= US_CORE_RECORD_TYPE_ID;  
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Walkthrough_Guide_Complete_Date__c = System.Today()+1;
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';        
        opp.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        OpportunityTriggerHandler.TriggerDisabled = true;
        insert opp;
        String recordsToCreate = '[{"Portfolio_Segment__c":"Acute Consumable","Amount__c":"100000"}]';
        Test.startTest();            
            SaveResultforOppCustomForm saveRes = productLineCreateController.createProductLines(recordsToCreate,opp.Id);
        Test.stopTest();        
    }

    @IsTest
    static void methodName2(){
        Account acc = [Select Id From Account Limit 1];
        Contact con = [Select Id From Contact Limit 1];
        Opportunity opp = new Opportunity();
        String recordsToCreate = '[{"Portfolio_Segment__c":"Acute Consumable","Amount__c":null}]';
        Test.startTest();            
            SaveResultforOppCustomForm saveRes = productLineCreateController.createProductLines(recordsToCreate,opp.Id);
        Test.stopTest();        
    }
}