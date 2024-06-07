@isTest(seeAllData=true)
public class ShoppingCartImageUploadBatch2Test{
        
    @isTest static void runBatch(){
        Test.startTest();
        Database.executeBatch(new ShoppingCartImageUploadBatch2(),200);
        Test.stopTest();
    }
}