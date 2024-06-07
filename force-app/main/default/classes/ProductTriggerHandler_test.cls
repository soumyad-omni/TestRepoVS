@isTest
public class ProductTriggerHandler_test {
    
    public static testmethod void ProductTriggerHandler_test1(){
        
        Run_Product_line_Update__c  setting111 = new Run_Product_line_Update__c ();
        setting111.Name = 'Run Product line Update';
        setting111.Run_Product_line_Update__c = true;
        insert setting111;
        
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        list<product2> pd = [SELECT Id,Segment_Changed__c,DW_Product_Line__c,Portfolio_Segment__c FROM Product2 WHERE Name = 'TestProduct-SV'];
        pd[0].Segment_Changed__c = true;
        pd[0].DW_Product_Line__c = 'testdw1';
        //pd[0].Portfolio_Segment__c = 'Anesthesia Cabinets';
        update pd;
        
    }

}