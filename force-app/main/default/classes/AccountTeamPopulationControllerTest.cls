@isTest
    public class AccountTeamPopulationControllerTest {

    public static testmethod void AccountTeamPopulationControllerTestMethod(){
        Default_Currency_by_Country_Code__c setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        
        Roles1__mdt Roles1= new Roles1__mdt();
        Roles1.List_of_Roles__c= 'Area Account Executive,Client Success Executive,Health System Executive - Govt,Health Systems Executive,Inside Sales Rep,Key Account Manager,Multiple Account Manager,Nursing Consultant,Pharmacy Consultant,Sales Associate,Sales Rep';
        Roles1.AllTypes__c='AllTypes';
        //insert Roles1;
        
        AccountTeamPopulationController atpc = new AccountTeamPopulationController();
        
        AccountCreateController.isFirstRun= false; 

        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        Test.startTest();
          AccountTeamPopulationController.updateAccountTeamMember(acc2.id);
          AccountTeamPopulationController.updateAccountTeamMember1(acc1.id);        
        Test.stopTest();
    }
}