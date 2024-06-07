@isTest(seeAllData=false)
public class ShoppingCartPSIUploadBatchTest{
    
    @testSetup()
    static void setupData(){
        ccrz__E_Product__c pd = new ccrz__E_Product__c(Name = 'Test',
                                                       ccrz__SKU__c = 'ABC',
                                                       ccrz__ProductType__c = 'Product',
                                                       ccrz__StartDate__c = Date.today(),
                                                       ccrz__EndDate__c = Date.today(),
                                                       ccrz__ProductStatus__c = 'Released');
        insert pd;
    }
         
    @isTest static void runBatch2(){        
        Test.startTest();
        Database.executeBatch(new ShoppingCartPSIUploadBatch(),200);
        Test.stopTest();
    } 
}