@isTest
public class MachineTriggerHandlerTest {
    
    @testSetup 
    public static void dataSetup(){
        ccrz__E_Attribute__c machineparent = new ccrz__E_Attribute__c(Name = 'MACHINE',ccrz__AttributeID__c = 'MACHINE',ccrz__DisplayName__c = 'MACHINE',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 2);
        insert machineparent;
        ccrz__E_Attribute__c machineChild = new ccrz__E_Attribute__c(Name = 'machine2',ccrz__AttributeID__c = 'MACHINE2',ccrz__DisplayName__c = 'Machine2',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 22, ccrz__ParentAttribute__c = machineparent.Id);
        insert machineChild;
    }
    
    @isTest
    public static void testMethod1(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        Test.startTest();
        	Machine__c newmachine = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        	newmachine.Machine_Name__c = 'PACMED34348';
        	update newmachine;
        	delete newmachine;
        	undelete newmachine;
        Test.stopTest();        
    }

}