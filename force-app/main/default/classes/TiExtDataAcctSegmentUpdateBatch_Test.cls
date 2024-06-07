@isTest
public class TiExtDataAcctSegmentUpdateBatch_Test {
    public static testmethod void ExtDataSegmentTest(){
       	Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
        
        AccountTriggerHandler.TriggerDisabled = true;    
            insert acct; 
        External_Data__c extData=new External_Data__c(AccountID__c=acct.Id,Account_Segment__c='Test Segment',isTiSegmentChanged__c=true);
        	insert extData;
        test.startTest();
        TiExtDataAcctSegmentUpdateBatch extDataBatch = new TiExtDataAcctSegmentUpdateBatch();
        Database.executeBatch(extDataBatch);
        test.stopTest();
    }
}