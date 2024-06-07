@isTest
public class updateLead_test {
    
    @testsetup
        static void testdatasetup(){
            Job_title_Classification__c j = new Job_title_Classification__c(Classification__c = 'A-Strategic Buyer',
                     name = 'A1');
        	insert j;
        } 
    
    @isTest
    static void test1() {
        Test.startTest();
        Lead l = new Lead(LastName = 'Test Lead',
                     Company = 'Test Company',
                     Omnicell_Job_Title__c = 'A1');
        insert l;
        
		List<lead> le = [SELECT id,Classification__c,Omnicell_Job_Title__c FROM Lead WHERE LastName = 'Test Lead'];
        list<id> lid = new list<id>();
        for(lead ll : le){
            lid.add(ll.id);
        }        
        
        updatelead.updateleadrecord(lid);
        Test.stopTest();
    }

}