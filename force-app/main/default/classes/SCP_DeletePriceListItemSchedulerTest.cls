/*** 
Test Class For - SCP_DeletePriceListItemScheduler and SCP_DeletePriceListItemBatch
Developer - Subramanyam Gopinath  
***/

@isTest
public class SCP_DeletePriceListItemSchedulerTest{

    public static testMethod void testschedule() {
        
        Test.StartTest();
        SCP_DeletePriceListItemScheduler sch1 = new SCP_DeletePriceListItemScheduler();
        
        String sch = '0 0 1 * * ?'; 
        system.schedule('Test SCP_DeletePriceListItemScheduler Batch', sch, sch1);
        
        ccrz__E_PriceList__c Pricelist = SCP_TestDataFactory.createPriceList(1)[0];
        insert Pricelist;
        
        ccrz__E_Product__c Product = SCP_TestDataFactory.createProducts(1)[0];
        insert Product;
        
        ccrz__E_SubProdTerm__c spt = SCP_TestDataFactory.createSPT(Product,1)[0];
        insert spt;
        
        List<ccrz__E_PriceListItem__c> pricelistitem = SCP_TestDataFactory.createPriceListItem(Product,Pricelist,spt,1);
        insert pricelistitem;
        
        SCP_DeletePriceListItemBatch batch1 = new SCP_DeletePriceListItemBatch();
        batch1.execute(null,pricelistitem);
        Test.stopTest(); 
    }
}