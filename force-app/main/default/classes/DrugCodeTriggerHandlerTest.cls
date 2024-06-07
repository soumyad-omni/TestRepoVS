@isTest
public class DrugCodeTriggerHandlerTest {
    
    @testSetup 
    public static void dataSetup(){
        ccrz__E_Attribute__c drugparent = new ccrz__E_Attribute__c(Name = 'NDC',ccrz__AttributeID__c = 'NDC',ccrz__DisplayName__c = 'NDC',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 2);
        insert drugparent;
        ccrz__E_Attribute__c drugChild = new ccrz__E_Attribute__c(Name = 'NDC2',ccrz__AttributeID__c = 'NDC2',ccrz__DisplayName__c = 'NDC2',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 22, ccrz__ParentAttribute__c = drugparent.Id);
        insert drugChild;
    }
    
    @isTest
    public static void testMethod1(){
        
        Test.startTest();
        	DrugCode__c newDrug = SCP_TestDataFactory.createDrugCode('12345678901');
        	newDrug.DrugCodes__c = '12345678900';
        	update newDrug;
        	delete newDrug;
        	undelete newDrug;
        Test.stopTest();        
    }

}