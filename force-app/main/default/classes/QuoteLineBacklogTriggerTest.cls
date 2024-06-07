@isTest
public class QuoteLineBacklogTriggerTest {
	 public static testmethod void triggerTest()
    {
        Product2 prod1 = new Product2(Name = 'TestProduct-SV123',Family = 'test123',External_ID__c = '1234567890123123',ProductCode = 'TestProduct-SV123',DW_Product_Line__c = 'testdw123',SAP_Product_Type__c = 'testsap123');
        insert prod1;
        Backlog_Inflow_Outflow__c inflow = new Backlog_Inflow_Outflow__c();
        insert inflow;
        Quote_Line_Backlog__c qlb = new Quote_Line_Backlog__c();
        qlb.expected_booking__c = 0;
        qlb.SAP_Line_Number__c = 100;
        qlb.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
        qlb.SAP_Quote_Number__c = '5531288';
        qlb.Product__c = prod1.Id;
        qlb.Valid_From__c = Date.today();
        qlb.Valid_To__c = Date.today();
        insert qlb;
        
        Current_Quote_Line_Result__c cqlr = new Current_Quote_Line_Result__c();
        cqlr.Derived_Portfolio_Segment__c = 'Advance Services';
        cqlr.Opportunity_Forecast_Category__c = 'Booked';
        cqlr.expected_booking__c = 10;
        cqlr.Valid_To__c = Date.newInstance(2999, 12, 31);
        insert cqlr;
         database.executebatch(new ResetInflowOutFlowObjectData(),200);
    }
    public static testMethod void averageTriggerTest(){
        Quote_line_average__c qla = new Quote_line_average__c();
        qla.Valid_To__c = Date.newInstance(2999, 12, 31);
        insert qla;
    }
}