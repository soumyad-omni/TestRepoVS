@isTest
public class MarginBookedQTDBatchTest {
    public static testMethod void method1()
    {
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        //acc.PIS_HIS__c  = 'test';
        acc.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today();
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.ExpectedInstallDate__c = System.today()+60;
        insert opp;
        
        Opportunity_Usage_History__c ouh = new Opportunity_Usage_History__c();
        ouh.Opportunity_ID__c = opp.id;
        ouh.Opprtunity_Expected_Booking__c = 100;
        ouh.Opportunity_Forecast_Category_Order__c = '4-Booked';
        insert ouh;
        
        test.startTest();
        database.executebatch(new MarginBookedQTDBatch());
        test.stopTest();
    }
}