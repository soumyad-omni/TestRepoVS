@isTest
public class UpdateOppGuarantorBatchTest
{
    public static testmethod void method1()
    {
        Account_SendEmail_Off__c aso = new Account_SendEmail_Off__c();
        aso.name = 'Account SendEmail Off';
        aso.Account_SendEmail_Off__c = true;
        insert aso;
        
        Account_DataLoad__c ad = new Account_DataLoad__c();
        ad.name = 'Dataload';
        insert ad;
        
        Account acc1 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='13903',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc1.texcellency__DefHC_HospitalID__c = 1;
        acc1.Territory_Name__c = 'TestTerr';
        acc1.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc1; 
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc1.id;
        opp.stageName = 'Open';
        opp.Name = 'test_opp';
        opp.CloseDate = system.today().adddays(10);
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Open';
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
        AccountTriggerHandler.TriggerDisabled = false;
        test.startTest();
        acc1.Own_Guarantor__c = true;
        update acc1;
        test.stopTest();
    }
}