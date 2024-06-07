@isTest
public class cleanCurrentQuoteLineResultScheduleTest {
	public static testmethod void triggerTest(){
        Quote_Line_Backlog__c qlb = new Quote_Line_Backlog__c();
        qlb.expected_booking__c = 40;
        qlb.SAP_Line_Number__c = 100;
        qlb.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
        qlb.SAP_Quote_Number__c = '5531288';
        qlb.Valid_From__c = Date.today()-1;
        qlb.Valid_To__c = Date.today()-1;
        qlb.WBS_Code__c = 'Test12354';
        qlb.Total_Cost__c=10;
        qlb.Booking_Including_Rebate__c =40;
        qlb.Higher_Level_Item__c=0;
        insert qlb;
        Current_Quote_Line_Result__c cqlr = new Current_Quote_Line_Result__c();
        cqlr.Derived_Portfolio_Segment__c = 'Advanced Services';
        cqlr.Opportunity_Forecast_Category__c = 'Booked';
        cqlr.Valid_From__c = Date.today()-1;
        cqlr.Valid_To__c = Date.today()-1;
        cqlr.expected_booking__c = 10;
        insert cqlr;
        Test.StartTest();
		SceduleApexjobOnCurrentQuoteLineResult testsche = new SceduleApexjobOnCurrentQuoteLineResult(-2);
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
        //CleanCurrentQuoteLineResult firstJob = new CleanCurrentQuoteLineResult(-2);
        //Database.executeBatch(firstJob,2000);
    }
}