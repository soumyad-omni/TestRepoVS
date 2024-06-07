/**
 * @File Name          : SpecialityopportunityCreation_Test.cls
 * @Description        : Component test class (IBA-3640)
 * Ver       Date            Author      		    Modification
 * 1.0    19/12/2022   		Pritha Nandi          Initial Version
**/


@isTest
public class SpecialityopportunityCreation_Test {
    
    @testsetup
    static void testdatasetup(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.Opportunity__c = 'Specialty';
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
                opp.Pipeline_Category__c = 'Development';
                opp.Self_Install_Desired__c = 'No';
                opp.Professional_Services_Notes__c = 'Test';
                opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
                opp.Lease_Expiration_Date__c = System.Today()+1;
                opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
                opp.ExpectedInstallDate__c = System.Today();
                opp.How_many_contract_years__c = '3';
                opp.Contract_Year__c = '3';
                opp.Specialty_Open_Date__c = System.Today()+30;
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
        insert opp;
    }
    
    public testMethod static void getDataTest(){
        Opportunity opp = [select id from Opportunity where name='Test Opportunity' limit 1];
        String opportunityId= opp.Id;
        test.startTest();
        SpecialityopportunityCreation_apex.getData(opportunityId);
        test.stopTest();
    }
    
    public testMethod static void saveDataTest(){
        
        Opportunity opp = [select id,AccountId,CurrencyIsoCode,RecordTypeId,CustomerType__c from Opportunity where name='Test Opportunity' limit 1];
        String opportunityId= opp.Id;
        Opportunity oppChild = new Opportunity();
        String childOpp = '[{ "Name": "Test Opportunity Child", "Specialty_Open_Date__c" : "2022-12-30", "CloseDate" : "2022-12-31", "StageName" : "1 Solution Design", "Pipeline_Category__c" : "Upside", "Forecast_Probability__c" : "High", "Associated_Opportunity__c" : "'+opportunityId+'", "Opportunity__c" : "Specialty", "How_many_contract_years__c": "3", "CurrencyIsoCode " : "USD ","RecordTypeId" : "'+opp.RecordTypeId+'","AccountID":"'+opp.AccountId+'"}]';
        test.startTest();
        SpecialityopportunityCreation_apex.saveData(childOpp,opportunityId);
        test.stopTest();
    }
    
}