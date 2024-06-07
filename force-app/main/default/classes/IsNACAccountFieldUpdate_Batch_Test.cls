/**********************************************************************
Name:  IsNACAccountFieldUpdate_Batch_Test
======================================================
======================================================
Purpose: 
This is the test class for IsNACAccountFieldUpdate_Batch                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Sahid Hussain              11/14/2021      					        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
private class IsNACAccountFieldUpdate_Batch_Test {
     @testSetup
     static void IsNACAccountFieldUpdateBatchTest(){
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
         insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
		Account a = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital', /*Territory_Assignment_Criteria__c = 'NAC CSE', */
                                  BillingStreet='South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  Segment__c = '340B Sentry 17', BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a.Annual_Bill_Date__c = System.today()+100;
        a.Service_Escalator__c = 10;
        a.PO_BOX__c = '90202';
        a.texcellency__DefHC_HospitalID__c = 1;
        a.Territory_Name__c = 'TestTerr';
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        a.Is_NAC_Account__c='Yes';
         AccountTriggerHandler.TriggerDisabled = true;
        //a.Youreka_Mobile__c = true;
     //   a.current_Date_sys__c = System.now();    IBA-4149
        insert a; 
        String oldValues = '{"id": "'+a.Id+'","SAP_Account_ID__c": "3100000275"}';  
        
        SAP_Sales_Org__c sp = new SAP_Sales_Org__c(Account__c = a.id);
        sp.Sales_Office__c='OMNE';
        sp.Incoterms_2__c = 'San Francisco';
        sp.Incoterms_1__c = 'CPT';
        insert sp; 
        
          list<Account_History__c> accHistoryL = new list<Account_History__c>();
          Account_History__c accHistory = new Account_History__c();
          accHistory.Account__c = a.Id;
          accHistory.Field__c = 'Is NAC Account?';
        
        /*
        System.debug('recTypeAccountUS: '+ recTypeAccountUS);

        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  RecordtypeId = recTypeAccountUS, Account_Territory__c = 'North MO, West IL and IA', Territory_Assignment_Criteria__c = 'NAC CSE',
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated',
                                  Segment__c = '340B Sentry 17', Division_Account__c = 'United States', Region__c = 'Midwest', Transport_Zone__c = 'US00000002',
                                  Country_Cluster__c = 'US&CA', Transportation_Zone_Country__c = 'US');
        acc.BillingCountryCode = 'AZ';
		insert acc; */
    }
    @isTest static void test() {
        Test.startTest();
        IsNACAccountFieldUpdate_Batch IsNACfield = new IsNACAccountFieldUpdate_Batch();
       // Id batchId = Database.executeBatch(IsNACfield);
       Database.executeBatch(IsNACfield);
        Test.stopTest();
    }
}