@isTest
public class ProductDisplayURLPopulateClassTest {
    @isTest(SeeAllData=true) static void testmethod1() {
        product2 p = new product2(name='Test Product1',ProductCode='MED-FRM-211-OC',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Test Product Line',DW_Product_Segment__c='Test Product Segment',DW_Business_Segment__c='Test Business Segment', External_ID__c='t'+system.now());
        p.Family = 'License';
        insert p;
        
        product2 p1 = new product2(name='Test Product2',ProductCode='MED-FRM-220-OC',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Test Product Line',DW_Product_Segment__c='Test Product Segment',DW_Business_Segment__c='Test Business Segment', External_ID__c='t'+system.now()+ '2');
        p1.Family = 'License';
        insert p1;
        ProductDisplayURLPopulateClass pdc = new ProductDisplayURLPopulateClass();
        pdc.setDisplayURLForProducts();
    }
}