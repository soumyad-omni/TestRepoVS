@isTest
public class updateAccountVaccinationFieldValueTest {
    public testmethod static void testCode1() {
        AccountTriggerHandler.TriggerDisabled = true;
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.Segment__C = 'Covid Req';
        acc.PIS_HIS__c  = 'Other'; 
        insert acc; 
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        Account acc1 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='201 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc1.texcellency__DefHC_HospitalID__c = 1;
        acc1.Territory_Name__c = 'TestTerr';
        acc1.Requires_Covid_19_vaccination__c = true;
        acc1.Segment__C = 'Top Account';
        acc1.PIS_HIS__c  = 'Other'; 
        insert acc1; 
        SAP_Sales_Org__c ssoc1 = new SAP_Sales_Org__c(Account__c=acc1.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc1;
        
        Test.startTest();
        updateAccountVaccinationFieldValue c = new updateAccountVaccinationFieldValue();
        Database.executeBatch(c);
        Test.stopTest();
        
        List<Account> listacc = [Select id,segment__C,Requires_Covid_19_vaccination__c from Account];
        for(Account a: listacc) {
            if(a.segment__C == 'Covid Req') {
                System.assertEquals(a.Requires_Covid_19_vaccination__c,true);
            }
            if(a.segment__C == 'Top Account') {
                System.assertEquals(a.Requires_Covid_19_vaccination__c,false);
            }
        }
    } 
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleAccountVaccinationFieldUpdate sh1 = new ScheduleAccountVaccinationFieldUpdate();
        String sch = '0 5 * * * ?'; 
        system.schedule('Account Status Update Job', sch, sh1); 
        Test.stopTest(); 
    } 
    
}