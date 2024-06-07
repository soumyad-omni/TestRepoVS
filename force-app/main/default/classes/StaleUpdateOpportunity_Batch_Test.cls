@isTest
public class StaleUpdateOpportunity_Batch_Test {

    @isTest
    static void test_Run1() {
        Test.StartTest();
        //OpportunityTriggerHandler.isFirstRun = false;
        Opportunity opp1 = TestDataFactory.createOppWithAccount_Integration();
        String opp = opp1.id;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();
    }
/*
    @isTest
    static void test_Run2() {
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Account a = new Account(RecordTypeId = '0121N000001M59uQAC', name='t1'+system.now().millisecond()+math.round(math.random()*10000),
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128', Partner_Type__c ='0005');
        insert a;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+730;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Development';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Competitor__c = a.Id;
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-234;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-235;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();
    }

    @isTest
    static void test_Run3(){
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Account a1 = new Account(RecordTypeId = '0121N000001M59uQAC', name='t1'+system.now().millisecond()+math.round(math.random()*10000),
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128', Partner_Type__c ='0005');
        insert a1;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+750;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Committed';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Competitor__c = a1.Id;
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-740;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-740;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();        
    }
*/
	@isTest    
    static void test_Run4(){
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+740;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Booked';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-740;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-740;
        opp.ForecastUpdate_Date__c = System.today()-740;
        opp.Last_Update_on_Opportunity_Stage__c = System.today()-740;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();        
    }
    /*
    @isTest
    static void test_Run5(){
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Account a2 = new Account(RecordTypeId = '0121N000001M59uQAC', name='GreenField',
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128', Partner_Type__c ='0005');
        insert a2;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+750;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Committed';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Competitor__c = a2.Id;
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-100;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-100;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();        
    }
    @isTest
    static void test_Run6() {
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Account a = new Account(RecordTypeId = '0121N000001M59uQAC', name='t1'+system.now().millisecond()+math.round(math.random()*10000),
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128', Partner_Type__c ='0005');
        insert a;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+730;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Upside';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Competitor__c = a.Id;
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-234;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-235;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        
        opp.Pipeline_Category__c = 'Booked';
        opp.ForecastUpdate_Date__c = System.today()-235;
        update opp;
        StaleUpdateatOpportunity_Batch suo1 = new StaleUpdateatOpportunity_Batch();
        Id batchId1 = Database.executeBatch(suo1);
        Test.stopTest();
    }
    @isTest
    static void test_Run7(){
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Account a2 = new Account(RecordTypeId = '0121N000001M59uQAC', name='t1'+system.now().millisecond()+math.round(math.random()*10000),
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128', Partner_Type__c ='0005');
        insert a2;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+750;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Booked';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Competitor__c = a2.Id;
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-100;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-100;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();
    }
    @isTest
    static void test_Run8(){
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Account a1 = new Account(RecordTypeId = '0121N000001M59uQAC', name='t1'+system.now().millisecond()+math.round(math.random()*10000),
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128', Partner_Type__c ='0005');
        insert a1;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+330;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Committed';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Competitor__c = a1.Id;
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-100;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-100;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();
    } 
    @isTest
    static void test_Run9(){
        Test.startTest();
        AccountCreateController.isFirstRun = false;
        Account a1 = new Account(RecordTypeId = '0121N000001M59uQAC', name='t1'+system.now().millisecond()+math.round(math.random()*10000),
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128', Partner_Type__c ='0005');
        insert a1;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+330;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+90;
        opp.OppStatus__c = 'Open';
        opp.Pipeline_Category__c = 'Upside';
        opp.RecordTypeId = '0121N000001M5A8QAK';
        opp.Competitor__c = a1.Id;
        insert opp;

        opp.Last_Update_on_Expected_Close_Date__c = System.today()-50;
        opp.Last_Update_on_Expected_Install_Date__c = System.today()-50;
        update opp;
        StaleUpdateatOpportunity_Batch suo = new StaleUpdateatOpportunity_Batch();
        Id batchId = Database.executeBatch(suo);
        Test.stopTest();
    } */
}