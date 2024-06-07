@isTest
public with sharing class OpportunityRelatedListControllerTest {
    public static Id US_CORE_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
    public static Id US_ADV_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Canada_Advanced_Services').getRecordTypeId();
    public static Id US_SPL_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('US_Canada_Specialty').getRecordTypeId();
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
    static void genericMethod1(){
        Account acc = [Select Id From Account Limit 1];
        Contact con = [Select Id From Contact Limit 1];        
        Test.startTest();            
            List<Opportunity> opportunityList = OpportunityRelatedListController.getOpportunities(acc.id);
        Test.stopTest();        
    }

    @IsTest
    static void createCOREOpportunity1(){
        Account acc = [Select Id From Account Limit 1];
        Map<String,Object> oppObj = new Map<String,Object>();
        oppObj.put('Name', 'Test Core Opportunity');
        oppObj.put('OpportunityGroup__c', 'Purchase');//Advanced Services
        oppObj.put('StageName', '1 Solution Design');
        oppObj.put('Pipeline_Category__c', 'Development');
        oppObj.put('ExpectedInstallDate__c', '2024-04-30');
        oppObj.put('Compelling_Event__c', 'End of Life/End of Support');
        oppObj.put('AccountId', acc.Id);
        oppObj.put('Opportunity__c', 'Omnicell Opportunity');//Adv Svc Renewal//Specialty
        oppObj.put('CloseDate', '2024-04-20');
        oppObj.put('CAD_Drawings_Obtained_if_Carousel_XR2__c', 'Yes');
        oppObj.put('Seismic_Restraint_Required__c', 'Yes');
        oppObj.put('Forecast_Probability__c', 'High');
        oppObj.put('Legal_Resource_Required__c', 'No Legal Needed');
        oppObj.put('RecordTypeId', US_CORE_RECORD_TYPE_ID);
        oppObj.put('Services_Enablement_Owner__c', 'Adam Barrios');
       
        Test.startTest();
            OpportunityRelatedListController.createCoreOpportunity(JSON.serialize(oppObj));
        Test.stopTest();
        
    }

    @IsTest
    static void createCOREOpportunity2(){
        Account acc = [Select Id From Account Limit 1];
        Map<String,Object> oppObj = new Map<String,Object>();
        oppObj.put('Name', 'Test Core Opportunity');
        oppObj.put('OpportunityGroup__c', 'Purchase');//Advanced Services
        oppObj.put('StageName', '1 Solution Design');
        oppObj.put('Pipeline_Category__c', 'Development');
        //oppObj.put('ExpectedInstallDate__c', '2024-04-30');
        oppObj.put('Compelling_Event__c', 'End of Life/End of Support');
        oppObj.put('AccountId', acc.Id);
        oppObj.put('Opportunity__c', 'Omnicell Opportunity');//Adv Svc Renewal//Specialty        
        oppObj.put('CAD_Drawings_Obtained_if_Carousel_XR2__c', 'Yes');
        oppObj.put('Seismic_Restraint_Required__c', 'Yes');
        oppObj.put('Forecast_Probability__c', 'High');
        oppObj.put('Legal_Resource_Required__c', 'No Legal Needed');
        oppObj.put('RecordTypeId', US_CORE_RECORD_TYPE_ID);
        oppObj.put('Services_Enablement_Owner__c', 'Adam Barrios');
       
        Test.startTest();
        try{
            OpportunityRelatedListController.createCoreOpportunity(JSON.serialize(oppObj));
            oppObj.put('CloseDate', '2024-04-20');
            OpportunityRelatedListController.createCoreOpportunity(JSON.serialize(oppObj));
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }            
        Test.stopTest();
        
    }

    @IsTest
    static void createAdvOpportunity1(){
        Account acc = [Select Id From Account Limit 1];
        Map<String,Object> oppObj = new Map<String,Object>();
        oppObj.put('Name', 'Test Core Opportunity');
        oppObj.put('OpportunityGroup__c', 'Advanced Services');//Advanced Services
        oppObj.put('StageName', '1 Solution Design');
        oppObj.put('Pipeline_Category__c', 'Development');
        oppObj.put('ExpectedInstallDate__c', '2024-04-30');
        oppObj.put('Compelling_Event__c', 'End of Life/End of Support');
        oppObj.put('AccountId', acc.Id);
        oppObj.put('Opportunity__c', 'Adv Svc Renewal');//Adv Svc Renewal//Specialty
        oppObj.put('CloseDate', '2024-04-20');
        oppObj.put('CAD_Drawings_Obtained_if_Carousel_XR2__c', 'Yes');
        oppObj.put('Seismic_Restraint_Required__c', 'Yes');
        oppObj.put('Forecast_Probability__c', 'High');
        oppObj.put('Legal_Resource_Required__c', 'No Legal Needed');
        oppObj.put('RecordTypeId', US_ADV_RECORD_TYPE_ID);
        oppObj.put('Services_Enablement_Owner__c', 'Adam Barrios');
       
        Test.startTest();
            OpportunityRelatedListController.createAdvsOpportunity(JSON.serialize(oppObj));
        Test.stopTest();
        
    }

    @IsTest
    static void createAdvOpportunity2(){
        Account acc = [Select Id From Account Limit 1];
        Map<String,Object> oppObj = new Map<String,Object>();
        oppObj.put('Name', 'Test Core Opportunity');
        oppObj.put('OpportunityGroup__c', 'Advanced Services');//Advanced Services
        oppObj.put('StageName', '1 Solution Design');
        oppObj.put('Pipeline_Category__c', 'Development');
        //oppObj.put('ExpectedInstallDate__c', '2024-04-30');
        oppObj.put('Compelling_Event__c', 'End of Life/End of Support');
        oppObj.put('AccountId', acc.Id);
        oppObj.put('Opportunity__c', 'Adv Svc Renewal');//Adv Svc Renewal//Specialty        
        oppObj.put('CAD_Drawings_Obtained_if_Carousel_XR2__c', 'Yes');
        oppObj.put('Seismic_Restraint_Required__c', 'Yes');
        oppObj.put('Forecast_Probability__c', 'High');
        oppObj.put('Legal_Resource_Required__c', 'No Legal Needed');
        oppObj.put('RecordTypeId', US_ADV_RECORD_TYPE_ID);
        oppObj.put('Services_Enablement_Owner__c', 'Adam Barrios');
       
        Test.startTest();
        try{
            OpportunityRelatedListController.createAdvsOpportunity(JSON.serialize(oppObj));
            oppObj.put('CloseDate', '2024-04-20');
            OpportunityRelatedListController.createAdvsOpportunity(JSON.serialize(oppObj));
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }            
        Test.stopTest();
        
    }

    @IsTest
    static void createSpecialtyOpportunity1(){
        Account acc = [Select Id From Account Limit 1];
        Map<String,Object> oppObj = new Map<String,Object>();
        oppObj.put('Name', 'Test Core Opportunity');
        oppObj.put('OpportunityGroup__c', 'Purchase');
        oppObj.put('StageName', '1 Solution Design');
        oppObj.put('Pipeline_Category__c', 'Development');
        oppObj.put('ExpectedInstallDate__c', '2024-04-30');
        oppObj.put('Compelling_Event__c', 'End of Life/End of Support');
        oppObj.put('AccountId', acc.Id);
        oppObj.put('Opportunity__c', 'Specialty');
        oppObj.put('CloseDate', '2024-04-20');
        oppObj.put('CAD_Drawings_Obtained_if_Carousel_XR2__c', 'Yes');
        oppObj.put('Seismic_Restraint_Required__c', 'Yes');
        oppObj.put('Forecast_Probability__c', 'High');
        oppObj.put('Legal_Resource_Required__c', 'No Legal Needed');
        oppObj.put('RecordTypeId', US_SPL_RECORD_TYPE_ID);
        oppObj.put('Services_Enablement_Owner__c', 'Adam Barrios');
        oppObj.put('Contract_Year__c', '1');
        oppObj.put('How_many_contract_years__c', '1');
        oppObj.put('Specialty_Open_Date__c', '2024-04-20');
        Test.startTest();
            OpportunityRelatedListController.createSpecialtyOpportunity(JSON.serialize(oppObj));
        Test.stopTest();
        
    }

    @IsTest
    static void createSpecialtypportunity2(){
        Account acc = [Select Id From Account Limit 1];
        Map<String,Object> oppObj = new Map<String,Object>();
        oppObj.put('Name', 'Test Core Opportunity');
        oppObj.put('OpportunityGroup__c', 'Purchase');
        oppObj.put('StageName', '1 Solution Design');
        oppObj.put('Pipeline_Category__c', 'Development');
        oppObj.put('Compelling_Event__c', 'End of Life/End of Support');
        oppObj.put('AccountId', acc.Id);
        oppObj.put('Opportunity__c', 'Specialty');        
        oppObj.put('CAD_Drawings_Obtained_if_Carousel_XR2__c', 'Yes');
        oppObj.put('Seismic_Restraint_Required__c', 'Yes');
        oppObj.put('Forecast_Probability__c', 'High');
        oppObj.put('Legal_Resource_Required__c', 'No Legal Needed');
        oppObj.put('RecordTypeId', US_SPL_RECORD_TYPE_ID);
        oppObj.put('Services_Enablement_Owner__c', 'Adam Barrios');
        oppObj.put('Contract_Year__c', '1');
        oppObj.put('How_many_contract_years__c', '1');
        oppObj.put('Specialty_Open_Date__c', '2024-04-20');
       
        Test.startTest();
        try{
            OpportunityRelatedListController.createSpecialtyOpportunity(JSON.serialize(oppObj));
            oppObj.put('CloseDate', '2024-04-20');
            OpportunityRelatedListController.createSpecialtyOpportunity(JSON.serialize(oppObj));
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }            
        Test.stopTest();
        
    }
}