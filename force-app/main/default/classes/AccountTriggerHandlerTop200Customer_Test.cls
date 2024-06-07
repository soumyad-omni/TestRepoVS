/*
Name       : AccountTriggerHandler_Top200Customer_Test
Description: Test Class for AccountTriggerHandler_Top200Customer trigger
Author     :  Supriya Ambre
CreatedDate: 10-16-2018
*/
@isTest
public class AccountTriggerHandlerTop200Customer_Test{
    static testmethod void UpdateIsTop200 () {
        AccountTriggerHandler.TriggerDisabled = true;
        Trigger_Configuration__c tc=new Trigger_Configuration__c();
        tc.name='AccountTrigger_Top200CustomerDisabled';
        tc.IsDisabled__c=FALSE;
        insert tc;
        
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
        
        
        
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        Target_Initiative__c ti = new Target_Initiative__c();
        ti.Name = 'Top 200 Customers';
        ti.Start_Date__c = Date.today();
        ti.End_Date__c = Date.today().addDays(3);
        insert ti;
        
        AccountCreateController.isFirstRun= false;
        // Account Act= Testdatafactory.createTestAccount();
        Account Act= TestDataFactory.createTestAccountQuotePrint();
        Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
        tia.Account__c = Act.Id;
        tia.Target_Initiative__c = ti.Id;
        insert tia;
        
        
        
        
        /*Account acc=new Account();
acc.name='Test Account 1234';
acc.BillingStreet = 'Test Street';
acc.BillingCity = 'Test City';
//acc.BillingStateCode = 'AZ';
acc.BillingPostalCode = '1111';
acc.BillingCountryCode = 'AZ';

acc.Account_role__c='ZCSN';
acc.Account_Territory__c='AZ';
acc.Validation_Status__c = 'Awaiting Validation';
acc.Account_Status__c = 'Prospect'; 
acc.Recordtypeid=Act.recordtypeid;
acc.IsDeleted__c = false;
insert acc;*/
        
        
        Account acc= Testdatafactory.createTestAccount();
        acc.Facility_Type__c='Short-term Acute Care Hospital';
        acc.parentid= Act.id;
        
        update acc;
        
        
        /*  Account acc1=new Account();
acc1.name='Test Account 123';
acc1.BillingStreet = 'Test Street';
acc1.BillingCity = 'Test City';
//acc1.BillingStateCode = 'CA';
acc1.BillingPostalCode = '1111';
acc1.BillingCountryCode = 'AZ';
acc1.Account_role__c='ZCSN';
acc1.Account_Territory__c='AZ';
acc1.Validation_Status__c = 'Awaiting Validation';
acc1.Account_Status__c = 'Prospect'; 
acc1.Recordtypeid=Act.recordtypeid;
acc1.IsDeleted__c = false;
acc1.parentid=Act.id;
insert acc1;*/
        
        
      /*  Account acc1 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   RecordtypeId = recTypeAccount,
                                   Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated'); //IBA-1992 Abhrajitc  */
         Account acc1 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                         Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                         BillingPostalCode='95178', SAP_Account_ID__c='123956'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc1.texcellency__DefHC_HospitalID__c = 1;
        acc1.Territory_Name__c = 'TestTerr';
        acc1.parentid= Act.id;
        
        insert acc1;
        
        
    }
    
}