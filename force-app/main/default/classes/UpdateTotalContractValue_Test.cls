/**
 * @File Name          : UpdateTotalContractValue_Test.cls
 * @Description        : Test Class for Updation of expected booking in both child and parent opportunity (IBA-3640)
 * Ver       Date            Author      		    Modification
 * 1.0    19/12/2022   		Pritha Nandi          Initial Version
**/


@isTest
public class UpdateTotalContractValue_Test {
    
    @testsetup
    static void testdatasetup(){
                AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.Opportunity__c = 'Specialty';
        opp.Contract_Year__c = '3';
        opp.Specialty_Open_Date__c = System.today()+30;
        opp.How_many_contract_years__c = '3';
        opp.CustomerType__c = 'New Customer';
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc; 
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Non Comm. Book - No Service PO';
        opp.Expected_Bookings__c = 1000;
        insert opp;
        Opportunity oppOriginal = [select id, Expected_Bookings__c,OppStatus__c from Opportunity where name='Test Opportunity' LIMIT 1]; 
         Opportunity opp1 = new Opportunity();
        opp1.name = 'Test Opportunity 2';
        opp1.stageName = '1 Initial Sales Activity';
        opp1.CloseDate = System.today()+30;
        opp1.Opportunity__c = 'Specialty';
        opp1.Contract_Year__c = '3';
        opp1.Specialty_Open_Date__c = System.today()+30;
        opp1.How_many_contract_years__c = '3';
        opp1.CustomerType__c = 'New Customer';
        opp1.AccountId = acc.id;
        opp1.ExpectedInstallDate__c = System.today()+60;
        opp1.OppStatus__c = 'Non Comm. Book - No Service PO';
        opp1.Expected_Bookings__c = 100;
        opp1.Associated_Opportunity__c = oppOriginal.Id;
        insert opp1; 
    }
    public testMethod static void UpdateTotalContractValueTest(){
       List<Opportunity> opp = [select id, Expected_Bookings__c,Associated_Opportunity__c,Total_Contract_Value__c,Name from Opportunity where name='Test Opportunity']; 
        test.startTest();
        	UpdateTotalContractValue updater = new UpdateTotalContractValue (opp);
           ID jobID = System.enqueueJob(updater);
    }
}