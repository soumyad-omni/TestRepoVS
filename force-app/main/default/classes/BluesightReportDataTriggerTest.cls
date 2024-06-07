@isTest
public class BluesightReportDataTriggerTest {
    public static testmethod void BluesightReportDataTriggerTest(){
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'BluesightReportDataTriggerDisable';
        setting111.IsDisabled__c = false;
        insert setting111;
        AccountTriggerHandler.TriggerDisabled=true;
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;   
        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
 
        insert acct;
        Bluesight_Report_Data__c blrep=new Bluesight_Report_Data__c(Account_Number__c=acct.SAP_Account_Id__c);//,ECC_Installation_Date__c=2023-01-01T00:00:00) ;
		insert blrep;
    }
}