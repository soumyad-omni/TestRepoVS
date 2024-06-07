@IsTest
private with sharing class SCP_ProductMediaBatchTest 
{
    @IsTest
    static void batchtest()
    {
        ccrz__E_Product__c objprod = new ccrz__E_Product__c();
        objprod.Name = 'Test';
        objprod.ccrz__SKU__c = 'test';
        objprod.ccrz__Quantityperunit__c= 10;
        objprod.ccrz__StartDate__c = System.Today();
        objprod.ccrz__EndDate__c= System.Today().addDays(100);
        insert objprod;
        
        Test.startTest(); 
        
            Id batchId = Database.executeBatch(new SCP_ProductMediaBatch(), 1);
        
        Test.stopTest(); 
    }
}