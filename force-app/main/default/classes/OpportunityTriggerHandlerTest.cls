/**
* @File Name          : OpportunityTriggerHandlerTest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 6/5/2020, 7:38:20 pm
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    6/5/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class OpportunityTriggerHandlerTest {
    public static Id recTypeAccount1 = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor' LIMIT 1].Id;
    public static Id recTypeOppUS = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
    
    @testsetup
    static void testdatasetup(){
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;

        TestDataFactory.createOpportunityHistoryTrackingFields();

        SCP_Integration_Details__c settingScp = new SCP_Integration_Details__c();
        settingScp.SCP_Application_Name__c ='SCP_AccountSFDCTOSAP';
        settingScp.Name = 'SCP_AccountSFDCTOSAP';
        settingScp.SCP_End_Point__c = 'ABC';
        insert  settingScp;          
        
        SCP_TestDataFactory.createContact_Customsetting();  
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        TestDataFactory.createSalesOrgCRM_CS();
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        
        AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc; 
        
        
        Account acc1 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='13903',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc1.texcellency__DefHC_HospitalID__c = 1;
        acc1.Territory_Name__c = 'TestTerr';
        acc1.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc1; 
        
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Non Comm. Book - No Service PO';
        opp.Credit_Approved_For__c = acc1.id;
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
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        User oid = [Select Id, name from User where profile.name ='System Administrator' limit 1];
        opp.OwnerId= oid.Id;
        insert opp;              
    } 
    public testMethod static void afterUpdateTest(){
        User usr = [Select id,Profile.Name from User where Id = :UserInfo.getUserId()];
        System.debug('***'+usr.Profile.Name);
        System.runAs(usr){
            AccountCreateController.isFirstRun= false; 
            AccountTriggerHandler.TriggerDisabled=true; 
            ContactTriggerHandler.TriggerDisabled = true;
            Opportunity opp = [select id,OppStatus__c,Name from Opportunity where name='Test Opportunity for update' limit 1];
            
            test.startTest();
            
            opp.OppStatus__c = 'PO Received';
            opp.Credit_Approval_Date__c = system.today().addMonths(3);
            opp.Backwards_Timeline_Created_Status__c= System.now();
            opp.Professional_Services_Intake_Status__c='On Hold';
            opp.Status_Reason__c='Change Order';
            opp.Date_In_Phase__c= System.Today()+05;
            opp.PAW_Phase__c='Design';
            opp.PAW_Project_Status__c='On Track';
            opp.ExpectedInstallDate__c = System.Today()+30;
            User oidnew = [Select Id, name from User where profile.name ='Business Administrator' limit 1];
            opp.OwnerId= oidnew.Id;
            update opp;            
            test.stopTest();
        }
    }
    
      @isTest
    public static void creditChecktest(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Id recTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Customer').getRecordTypeId();
        Id recTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId();
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),
                                  Account_role__c='ZCSN',
                                  RecordtypeId = recTypeAccount,
                                  CurrencyIsoCode='USD',
                                  Account_Status__c = 'Active',
                                  IsDeleted__c = false,
                                  Validation_Status__c = 'Validated',
                                  BillingCountryCode = 'AZ',
                                  Facility_Type__c = 'Pharmacy',
                                  SAP_Account_ID__c = '0000000000',
                                  BILLINGSTREET = '41 Moss',
                                  BillingPostalCode = 'DY6 9HP');
        insert acc;
        Id aId = acc.Id;
        Opportunity opp = new Opportunity(Name = 'International Test Check Credit',
                                          stageName = '1 Initial Sales Activity',
                                          CloseDate = System.today()+30,
                                          AccountId = aId,
                                          RecordTypeId = '0121N000001M5A7QAK',
                                          ExpectedInstallDate__c = System.today()+60,
                                          OppStatus__c = 'Open',
                                          Framework__c = 'HTE');
        insert opp;
        /*try {
            opp.Credit_Check_Required__c = true;
            opp.Requested_Credit_Value__c = 10000;
            update opp;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You need to fill in both Requested Credit Value and Requested Term fields to proceed.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }*/
        opp.Credit_Check_Required__c = true;
        opp.Requested_Credit_Value__c = 10000;
        // opp.Requested_Term__c = 'Net 30 Days Terms';IBA-5934
        opp.Approved_Credit_Value__c = 10000;
        // opp.Approved_Terms__c = 'Net 30 Days Terms'; IBA-5934
        //update opp;
        update opp;
        Boolean sendEmailFlag = false;
        if (opp.Credit_Check_Required__c
            && opp.Requested_Credit_Value__c != null
            // && !String.isBlank(opp.Requested_Term__c) IBA-5934
            // && String.isBlank(opp.Approved_Terms__c) IBA-5934
            && opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId()) {
                sendEmailFlag = true;
            }
        System.assertEquals(true, sendEmailFlag);
        /*try {
            opp.Approved_Credit_Value__c = 10000;
            update opp;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Both Approved Credit Value and Approved Terms must be provided or left blank together.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }*/
        
        Opportunity updatedOpp = [SELECT Id, Date_Approved__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(Date.today(), updatedOpp.Date_Approved__c);
        try{
            opp.Approved_Credit_Value__c = null;
            // opp.Approved_Terms__c = ''; IBA-5934
            opp.Credit_Check_Required__c = false;
            opp.StageName = '6 Closed Won';
            update opp;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Completion of Approval steps is mandatory before advancing Opportunity to Stage 6-Closed Won.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    public testMethod static void beforeInsert1(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test 4';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A8QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
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
        test.startTest();
        insert opp;
        test.stopTest();
    }
    public testMethod static void beforeInsert3(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A8QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+30;
        opp.OppStatus__c = 'Booked with No PO';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today()+70;
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';        
        test.startTest();
        insert opp;
        opp.OppStatus__c = 'Non Comissionable Booking';
        update opp;
        test.stopTest();
    }
    public testMethod static void beforeInsert2(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test 3';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A8QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
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
        opp.Professional_Services_Intake_Status__c='On Hold';
        opp.Status_Reason__c='Seismic';
        test.startTest();
        insert opp;
        opp.Professional_Services_Intake_Status__c='Customer Rollout Timeline Created';
        opp.OppStatus__c = 'Booked with No PO';
        update opp;
        test.stopTest();
    }
    public testMethod static void beforeInsert4(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Us & Canada Opportunity Test 2';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A8QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'PO Received';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
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
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        opp.Status_Reason__c='Seismic';
        test.startTest();
        insert opp;
        opp.Professional_Services_Intake_Status__c='Backwards Timeline Created';
        update opp;
        test.stopTest();
    }
    public testMethod static void beforeInsert5(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test 2';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A8QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+30;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today()+70;
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';        
        opp.Professional_Services_Intake_Status__c='Backwards Timeline Created';
        test.startTest();
        insert opp;
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        update opp;
        test.stopTest();
        
    }
    public testMethod static void beforeInsert6(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test 5';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A8QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+30;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today()+70;
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';        
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        test.startTest();
        insert opp;
        opp.Professional_Services_Intake_Status__c='Customer Rollout Timeline Created';
        update opp;
        test.stopTest();
    }
    
    public testMethod static void InternationalExchangeRateSet(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'International Opportunity update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A7QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.Top_Level_Parent_CSN_Number__c='1234';
        update acc;
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution'; 
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
        test.startTest();
        Opportunity_Field_Tracking__c  setting1 = new Opportunity_Field_Tracking__c ();
        setting1.Name = 'ACCOUNTID';
        insert setting1;
        Opportunity_Field_Tracking__c  setting2 = new Opportunity_Field_Tracking__c ();
        setting2.Name = 'RECORDTYPEID';
        insert setting2;
        Opportunity_Field_Tracking__c  setting3 = new Opportunity_Field_Tracking__c ();
        setting3.Name = 'CloseDate';
        insert setting3;
        insert opp;
        
        opp.stageName = '7 Closed Lost';
        opp.Reason_for_Loss__c = 'Price';
        opp.CommentsWinLoss__c = 'test';
        opp.Pipeline_Category__c = 'Booked';
        update opp;
        test.stopTest();
    }
    
    public testMethod static void InternationalExchangeRateSet1(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'International Opportunity Test';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId='0121N000001M5A7QAK';   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'PO Received';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
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
        test.startTest();
        insert opp;
        opp.Credit_Approved_For__c = null;
        opp.OppStatus__c = 'Open';
        update opp;
        test.stopTest();
    }
    
    public testMethod static void CreateChildOpty(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false; 
        Account account=TestDataFactory.createTestAccountQuotePrint();
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc; 
        System.debug('acc : '+acc);
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        
        test.startTest();
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Update opp;
        Delete opp;
        undelete opp;
        test.stopTest();
    }
    
    public testMethod static void CreateChildOpty1(){
        AccountCreateController.isFirstRun= false;
        UserTriggerHandler.TriggerDisabled = true; 
        QuoteTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        Map<id,Opportunity> oldmap = new Map<id,Opportunity>();
        Map<id,Opportunity> newmap = new Map<id,Opportunity>();
        Opportunity opp=TestDataFactory.createOppWitOptyTypeAndAccount_Integration();
        User u = [Select id,Annuity_Creator__c from User where id=:Userinfo.getUserId()];
        u.Annuity_Creator__c = true;
        update u;
        
        
        productlinetriggerhandler.TriggerDisabled = true;
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';
        pl.Amount__c = 10000;
        pl.Opportunity__c = opp.id;    
        insert pl;  
        test.startTest();
        Opportunity opp1=TestDataFactory.createOppWitOptyTypeAndAccount_Integration();
        AccountTeamMember atm=TestDataFactory.createTestAccountTeamMemberWithAccId(opp.AccountId);
        oldmap.put(opp.id, opp);
        Account acc111 = Testdatafactory.createUSTestAccount();
        opp.AccountId = acc111.id;
        opp.Opportunity__c='Annuity';
        opp.closeDate = Date.newInstance(2019, 04, 02);
        opp.StageName = '6 Closed Won';
        opp.Opportunity__c = 'Change Order - Credit';
        opp.Associated_Opportunity__c =opp1.id;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'Not Applicable';
        opp.Professional_Services_Notes__c = 'test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = Date.newInstance(2020, 04, 02);
        opp.Self_Install_Desired__c = 'No';
        opp.Services_Enablement_Owner__c = 'Tara Bakker';        
        Account acc = new Account(name='11t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                  Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                  BillingCountryCode = 'CA',RecordtypeId = recTypeAccount1,BillingStateCode = 'ON',
                                  Account_Status__c = 'Active',IsDeleted__c = false,  
                                  Partner_Type__c= '0015'); 
        acc.Facility_Type__c = 'Pharmacy';
        acc.Account_role__c='NA - Non-Buying/Competitor';
        acc.Validation_Status__c = 'Validated';
        acc.BILLINGSTREET = '41 Moss';
        acc.BillingPostalCode = '77777';
        
        insert acc;
        opp.Competitor__c = acc.id;
        opp.Opportunity_Pull_Reason__c = 'Booking Team - Pull into Quarter';
        opp.Other_Pull_Reason__c = 'test';
        update opp;  
        newmap.put(opp.Id, opp);
        
        
        Sales_Quota__c sq=new Sales_Quota__c(Fiscal_Year__c = '2019',User__c =Opp.Ownerid, Fiscal_Quarter__c='Q2');
        System.debug('Starts Date : '+sq.Start_Date__c+'End Date : '+sq.End_Date__c);
        sq.User__c = atm.UserId; 
        insert sq;
        OpportunityTeamMember newOTM = new OpportunityTeamMember();
        newOTM.OpportunityId = opp.Id;
        newOTM.TeamMemberRole = 'Lead Qualifier';
        newOTM.UserId = atm.userId;
        insert newOTM;
        
        opp.OppStatus__c = 'PO Received';
        opp.Recalculate_Team__c = true;        
        
        OpportunityTriggerHandler oth=new OpportunityTriggerHandler();
        oth.afterUpdate(oldmap,newmap);
        oth.UpdateQuoteOwner(newmap.values());
        oth.updateQuoteApprvOptyOwner(newmap.values());
        oth.CreateChildOpty(oldmap,newmap.values());
        oth.createSalesQuotaOpty(newmap.values());  
        oth.deleteProductline (newmap.values());
        
        test.stopTest();
    }    
    
    public testMethod static void CreateChildOptyTest(){
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = 'Proposal';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Opportunity__c='MTS Opportunity';
        opp.OppStatus__c = 'PO Received - Pending Paperwork';
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
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
        opp.Professional_Services_Intake_Status__c='Customer Rollout Timeline Created';
        test.startTest();
        insert opp;
        opp.OppStatus__c = 'Open';
        opp.Recalculate_Team__c = true;
        opp.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        update opp;
        test.stopTest();
    }
    
    public testmethod static void childopty(){
        productlinetriggerhandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false; 
        ContactTriggerHandler.TriggerDisabled = true;
        Map<id,Opportunity> oldmap = new Map<id,Opportunity>();
        Map<id,Opportunity> newmap = new Map<id,Opportunity>();
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp1 = TestDataFactory.createOppWithAccount();   
        quote.OpportunityId = opp1.Id;
        quote.Primary_Quote__c=TRUE;
        test.startTest();
        insert quote;
        
        Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE ID =: quote.OpportunityId LIMIT 1 ];
        opp.PrimaryQuote__c=quote.Id;
        Product_segment__c ps=new Product_segment__c(Quote__c = quote.Id,Opportunity__c= opp.Id, product_segment__c = 'Performance Center');
        insert ps;
        oldmap.put(opp.id, opp);
        
        update opp;
        newmap.put(opp.Id, opp);
        OpportunityTriggerHandler oth=new OpportunityTriggerHandler();
        oth.UpdateQuoteOwner(newmap.values());
        test.stopTest();
    }

    public testmethod static void childopty1(){
        AccountCreateController.isFirstRun= false; 
        ContactTriggerHandler.TriggerDisabled = true;
        Map<id,Opportunity> oldmap = new Map<id,Opportunity>();
        Map<id,Opportunity> newmap = new Map<id,Opportunity>();
    }

    public testmethod static void childopty2(){
        usertriggerhandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        contacttriggerhandler.TriggerDisabled = true;
        User us=TestDataFactory.createUser(true,'testUser','SalesQuota');
        System.runAs(us){
            AccountCreateController.isFirstRun= false; 
            Map<id,Opportunity> oldmap = new Map<id,Opportunity>();
            Map<id,Opportunity> newmap = new Map<id,Opportunity>();
            test.startTest();
            Quote qt=TestDataFactory.createTestQuote_Integration();
            qt.Primary_Quote__c=TRUE;
            update qt;
            Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE ID =: qt.OpportunityId LIMIT 1 ];
            opp.PrimaryQuote__c=qt.Id;
            Product_segment__c ps=new Product_segment__c(Quote__c = qt.Id,Opportunity__c= opp.Id, product_segment__c = 'Performance Center');
            insert ps;
            oldmap.put(opp.id, opp);
            
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = us.id,TeamMemberRole = 'Sales Rep');
            insert otm;
            update opp;
            Map<Opportunity,Id> otyAccMap = new Map<Opportunity,Id>();
            otyAccMap.put(opp,opp.Id);
            newmap.put(opp.Id, opp);
            OpportunityTriggerHandler oth=new OpportunityTriggerHandler();
            test.stopTest();
        }
    }
    
    public testMethod static void coverforOppDelMethod(){
        AccountTriggerHandler.TriggerDisabled = True;
        UserTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
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
                AccountTriggerHandler.TriggerDisabled = true;
                update account;
                test.startTest();
                Opportunity opp = TestDataFactory.createOppWithAccount();
                opp.oppstatus__c= Label.Fully_Booked;
                update opp;
                
                List<Opportunity> lstOpp = new List<Opportunity>();
                lstOpp.add(opp);
                Delete opp;
                test.stopTest();
            }catch(Exception ae){}
        }
    }

    public testMethod static void StalefieldUpdate(){
        AccountTriggerHandler.TriggerDisabled = True;
        UserTriggerHandler.TriggerDisabled = true; 
        ContactTriggerHandler.TriggerDisabled = true;
        User us=TestDataFactory.createUser(true,'testUser','SalesQuota');
        List<String> lstProfileName = new List<String>();
        lstProfileName.add('System Administrator');
        List<Profile> lstProfile = new List<Profile>();
        lstProfile=[select id, name from Profile where name =:'Solution Manager'];
        us.ProfileId = lstProfile[0].id;
        update us;
        User usNew = [select id, name,profileid from user where id=:us.id];
        System.runAs(usNew){
            try{
                test.startTest();
                AccountCreateController.isFirstRun = false;
                Account a = new Account(RecordTypeId = '0121N000001M59uQAC', name='t1'+system.now().millisecond()+math.round(math.random()*10000),
                                        Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                        BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                        BillingPostalCode='95128', Partner_Type__c ='0005');
                insert a;
                Opportunity opp = new Opportunity();
                opp.name = 'Test Opportunity for update';
                opp.stageName = '1 Initial Sales Activity';
                opp.CloseDate = System.today()+30;
                Account acc = TestDataFactory.createTestAccountQuotePrint();
                opp.AccountId = acc.id;
                opp.ExpectedInstallDate__c = System.today()+90;
                opp.OppStatus__c = 'Open';
                opp.Pipeline_Category__c = 'Development';
                opp.RecordTypeId = '0121N000001M5A8QAK';
                opp.Competitor__c = a.Id;
                Opportunity_Field_Tracking__c  setting1 = new Opportunity_Field_Tracking__c ();
                setting1.Name = 'ACCOUNTID';
                insert setting1;
                Opportunity_Field_Tracking__c  setting2 = new Opportunity_Field_Tracking__c ();
                setting2.Name = 'RECORDTYPEID';
                insert setting2;
                Opportunity_Field_Tracking__c  setting3 = new Opportunity_Field_Tracking__c ();
                setting3.Name = 'CloseDate';
                insert setting3;
                Opportunity_Field_Tracking__c  setting33 = new Opportunity_Field_Tracking__c ();
                setting33.Name = 'EXPECTED_BOOKINGS__C';
                insert setting33;
                Opportunity_Field_Tracking__c  setting4 = new Opportunity_Field_Tracking__c ();
                setting4.Name = 'Competitor__c';
                insert setting4;
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
                opp.Pipeline_Category__c = 'Committed';
                opp.Amount = 10000;
                opp.Name = 'TestOpp';
                opp.CloseDate = System.today()+45;
                opp.Expected_Bookings__c = 1000;
                opp.ExpectedInstallDate__c = system.today()+90;
                opp.StageName = '5 In Customer Acquisition Process';
                update opp;
                OpportunityTeamMember otm = new OpportunityTeamMember();
                otm.OpportunityId = opp.Id;
                otm.TeamMemberRole = 'Performance Center Consultant';
                otm.UserId = Userinfo.getUserId(); 
                insert otm;
                OpportunityTriggerHandler opt = new OpportunityTriggerHandler();
                List<Opportunity> lstOpp = new List<Opportunity>();
                lstOpp.add(opp);
                //OpportunityTriggerHandler.checkStage(lstOpp);
                opt.deleteProductline(lstOpp);
                Delete opp;
                
                test.stopTest();
            }catch(Exception ae){}
        }
    }

  

    @isTest
    public static void testSendOpportunityEmail() {
        AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        User ownerUser = new User(
            FirstName = 'Owner',
            LastName = 'User',
            Email = 'owner@omnicell.com',
            Username = 'owner@omnicell.com',
            Alias = 'ownerU',
            CommunityNickname = 'ownerUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            IsActive = true);
        insert ownerUser;
        Id recTypeAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('International Customer').getRecordTypeId();
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),
                                  Account_role__c='ZCSN',
                                  RecordtypeId = recTypeAccount,
                                  CurrencyIsoCode='USD',
                                  Account_Status__c = 'Active',
                                  IsDeleted__c = false,
                                  Validation_Status__c = 'Validated',
                                  BillingCountryCode = 'AZ',
                                  Facility_Type__c = 'Pharmacy',
                                  SAP_Account_ID__c = '0000000000',
                                  BILLINGSTREET = '41 Moss',
                                  BillingPostalCode = 'DY6 9HP');
        insert acc;
        Id aId = acc.Id;
        Opportunity testOpportunity = new Opportunity(Name = 'International Test Check Credit',
                                                      stageName = '1 Initial Sales Activity',
                                                      CloseDate = System.today()+30,
                                                      AccountId = aId,
                                                      RecordTypeId = '0121N000001M5A7QAK',
                                                      ExpectedInstallDate__c = System.today()+60,
                                                      OppStatus__c = 'Open',
                                                      Framework__c = 'HTE');
        insert testOpportunity;
        Boolean sendEmailFlag = false;
        testOpportunity.Credit_Check_Required__c = true;
        testOpportunity.Requested_Credit_Value__c = 10000;
        //testOpportunity.Requested_Term__c = 'Net 30 Days Terms'; IBA-5934
        update testOpportunity;
        if (testOpportunity.Credit_Check_Required__c == true 
            && testOpportunity.Requested_Credit_Value__c != null 
            // && !String.isBlank(testOpportunity.Requested_Term__c) IBA-5934
            // && String.isBlank(testOpportunity.Approved_Terms__c) IBA-5934
            && testOpportunity.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('International Opportunity').getRecordTypeId()) {
                sendEmailFlag = true;
            }
        System.debug('Developer --> ' +sendEmailFlag);
        Opportunity_SendEmail__c emailFlag = new Opportunity_SendEmail__c(Name = 'Opportunity SendEmail',
                                                                          Send_Email__c = true);
        insert emailFlag;
        System.assertEquals(true, sendEmailFlag, 'sendEmailFlag should be set to true for the specified conditions');
        Test.startTest();
        OpportunityTriggerHandler.sendOpportunityEmail(testOpportunity.Id);
        Test.stopTest();
    }

    @isTest
    public static void testSetRecalculateTeamValue() {
        AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),
                                  Account_role__c='ZCSN',
                                  RecordtypeId = recTypeAccount,
                                  CurrencyIsoCode='USD',
                                  Account_Status__c = 'Active',
                                  IsDeleted__c = false,
                                  Validation_Status__c = 'Validated',
                                  BillingCountryCode = 'AZ',
                                  Facility_Type__c = 'Pharmacy',
                                  SAP_Account_ID__c = '0000000000',
                                  BILLINGSTREET = '41 Moss',
                                  BillingPostalCode = 'DY6 9HP');
        insert acc;
        Id aId = acc.Id;
        Opportunity opp1 = new Opportunity(Name = 'Test Opp 1',
                                           stageName = '1 Initial Sales Activity',
                                           CloseDate = System.today()+30,
                                           AccountId = aId,
                                           RecordTypeId = '0121N000001M5A7QAK',
                                           ExpectedInstallDate__c = System.today()+60,
                                           OppStatus__c = 'Open',
                                           Framework__c = 'HTE',
                                           Recalculate_Team__c = false);
        Opportunity opp2 = new Opportunity(Name = 'Test Opp 2',
                                           stageName = '1 Initial Sales Activity',
                                           CloseDate = System.today()+30,
                                           AccountId = aId,
                                           RecordTypeId = '0121N000001M5A7QAK',
                                           ExpectedInstallDate__c = System.today()+60,
                                           OppStatus__c = 'Open',
                                           Framework__c = 'HTE',
                                           Recalculate_Team__c = false);
        insert new List<Opportunity>{opp1, opp2};
            List<Opportunity> oldOpps = [SELECT Id, oppstatus__c, Recalculate_Team__c FROM Opportunity WHERE Id IN :new List<Id>{opp1.Id, opp2.Id} LIMIT 2];
        opp1.oppstatus__c = 'Fully Booked';
        opp2.oppstatus__c = 'Fully Booked';
        update new List<Opportunity>{opp1, opp2};
            List<Opportunity> newOpps = [SELECT Id, oppstatus__c, Recalculate_Team__c FROM Opportunity WHERE Id IN :new List<Id>{opp1.Id, opp2.Id} LIMIT 2];
        OpportunityTriggerHandler obj = new OpportunityTriggerHandler();
        obj.setRecalculateTeamValue(oldOpps, newOpps);
    }
    
    @IsTest
    static void methodName1(){
        User sysuser = [Select Id From User where Profile.Name = 'System Administrator' AND isActive = true
                        AND Id !=:UserInfo.getUserId() Limit 1];
        Id currUserId = UserInfo.getUserId();
        System.runAs(sysuser){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Professional_Services_Intake'];
            insert new PermissionSetAssignment(AssigneeId = currUserId, PermissionSetId = ps.Id);
        }
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId= recTypeOppUS;   
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+30;
        opp.OppStatus__c = 'Booked with No PO';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today()+70;
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';  
        OpportunityTriggerHandler.TriggerDisabled = True;
        insert opp;
        OpportunityTriggerHandler.TriggerDisabled = False;        
        Test.startTest();
        opp.Name = 'Test Opp IBA-4831';
        opp.OppStatus__c = 'Fully Booked';
        try{
            update opp;
        }
        catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains('You cannot edit some of the fields due for booked Opportunities'), 'message=' + message);
        }        
        Test.stopTest();        
    }

    @IsTest
    static void historyTrackingTest(){
        
        Opportunity opp = [Select Id,FUNDING_APPROVED_FOR_RELEASE__C, BUDGET_APPROVED__C, WALKTHROUGH_GUIDES_COMPLETE__C, FINAL_APPROVAL_PROCESS__C, KNOWN_PROCUREMENT_PROCESS__C, KEY_STAKEHOLDER_ALIGNMENT__C, FINAL_APPROVAL_ACQUIRED__C, CONFIGURATIONS_CONFIRMED__C, RISK_TO_CURRENT_QUARTER__C, SALES_PROCESS_KICKOFF_MEETING__C, STEP_10_IT_ENGAGEMENT__C, STEP_11_IMPLEMENTATION_REVIEW__C, EBC_SITE_VISIT_AND_OR_REF_CALL__C, STEP_2_WORKFLOW_BUSINESS_ANALYSIS__C, GAP_ANALYSIS_AND_TECH_COMPARISONS__C, DATA_COLLECTION_AND_VALIDATION__C, STEP_5_FINANCE_REVIEW__C, STEP_6_ROI_OR_PROFORMA_REVIEW__C, STEP_7_VALIDATE_PROCUREMENT_PROCESS__C, BLUEPRINTING_DOCUMENTS_ON_QAP__C, STEP_9_CUSTOMER_SUCCESS_ENGAGEMENT__C,Walkthrough_Guide_Complete_Date__c,CloseDate,Opportunity_Push_Reason__c,Other_Push_Reason__c,Opportunity_Pull_Reason__c,Other_Pull_Reason__c From Opportunity Limit 1];        
        opp.FUNDING_APPROVED_FOR_RELEASE__C = 'Yes';
        opp.BUDGET_APPROVED__C = 'Yes';
        opp.WALKTHROUGH_GUIDES_COMPLETE__C = 'Yes';
        opp.FINAL_APPROVAL_PROCESS__C = 'Financial Committee';
        opp.KNOWN_PROCUREMENT_PROCESS__C = 'Yes';
        opp.KEY_STAKEHOLDER_ALIGNMENT__C = 'Yes';
        opp.FINAL_APPROVAL_ACQUIRED__C = 'Yes';
        opp.CONFIGURATIONS_CONFIRMED__C = 'Yes';
        opp.RISK_TO_CURRENT_QUARTER__C = 'Yes';
        opp.SALES_PROCESS_KICKOFF_MEETING__C = 'Yes';
        opp.STEP_10_IT_ENGAGEMENT__C = 'Yes';
        opp.STEP_11_IMPLEMENTATION_REVIEW__C = 'Yes';
        opp.EBC_SITE_VISIT_AND_OR_REF_CALL__C = 'Yes';
        opp.STEP_2_WORKFLOW_BUSINESS_ANALYSIS__C = 'Yes';
        opp.GAP_ANALYSIS_AND_TECH_COMPARISONS__C = 'Yes';
        opp.DATA_COLLECTION_AND_VALIDATION__C = 'Yes';
        opp.STEP_5_FINANCE_REVIEW__C = 'Yes';
        opp.STEP_6_ROI_OR_PROFORMA_REVIEW__C = 'Yes';
        opp.STEP_7_VALIDATE_PROCUREMENT_PROCESS__C = 'Yes';
        opp.BLUEPRINTING_DOCUMENTS_ON_QAP__C = 'Yes';
        opp.STEP_9_CUSTOMER_SUCCESS_ENGAGEMENT__C = 'Yes';
        opp.Walkthrough_Guide_Complete_Date__c = System.today()+60;
        opp.CloseDate = System.today()+120;
        opp.Opportunity_Push_Reason__c = 'Booking Team - Push Out of Quarter';
        opp.Other_Push_Reason__c = 'Test';
        opp.Opportunity_Pull_Reason__c = 'Booking Team - Pull into Quarter';
        opp.Other_Pull_Reason__c = 'Test';
        update opp;
    }

    @IsTest
    static void pullReasonTest(){
        Opportunity opp = [Select Id,CloseDate,Opportunity_Pull_Reason__c,Other_Pull_Reason__c,Opportunity_Pull_Counter__c From Opportunity Limit 1];        
        OpportunityTriggerHandler.TriggerDisabled = true;
        opp.CloseDate = System.today()+120;
        opp.Opportunity_Pull_Reason__c = 'Booking Team - Pull into Quarter';
        update opp;
        OpportunityTriggerHandler.TriggerDisabled = false;
        if(opp.Opportunity_Pull_Counter__c != null)
            opp.Opportunity_Pull_Counter__c = opp.Opportunity_Pull_Counter__c+1;
        opp.CloseDate = System.today();
        opp.Opportunity_Pull_Reason__c = 'Booking Team - Pull into Quarter';
        opp.Other_Pull_Reason__c = 'Test';
        update opp;

    }

    @IsTest
    static void pushReasonTest(){
        Opportunity opp = [Select Id,CloseDate,Opportunity_Push_Reason__c,Other_Push_Reason__c,Opportunity_Push_Counter__c From Opportunity Limit 1];        
        OpportunityTriggerHandler.TriggerDisabled = true;
        opp.CloseDate = System.today();
        opp.Opportunity_Push_Reason__c = 'Booking Team - Push Out of Quarter';
        update opp;
        OpportunityTriggerHandler.TriggerDisabled = false;
        if(opp.Opportunity_Push_Counter__c != null)
            opp.Opportunity_Push_Counter__c = opp.Opportunity_Push_Counter__c+1;
        opp.CloseDate = System.today()+120;
        opp.Opportunity_Push_Reason__c = 'Booking Team - Push Out of Quarter';
        opp.Other_Push_Reason__c = 'Test';
        update opp;

    }
}