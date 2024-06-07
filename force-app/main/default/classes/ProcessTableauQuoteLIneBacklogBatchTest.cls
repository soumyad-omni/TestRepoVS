@isTest
public class ProcessTableauQuoteLIneBacklogBatchTest {

     
    public static testmethod void triggerTest(){
        Quote_Line_Backlog__c qlb = new Quote_Line_Backlog__c();
        qlb.expected_booking__c = 40;
        qlb.SAP_Line_Number__c = 100;
        qlb.SAP_ORDER_LINE_ITEM_NUMBER__C = 100;
        qlb.SAP_Quote_Number__c = '5531288';
        qlb.Valid_From__c = Date.today();
        Date today= date.today();
        Date oneDayAgo =today.addDays(-1);
        Date fourMonthsLater = oneDayAgo.addMonths(4);
        qlb.Valid_To__c = fourMonthsLater;
        qlb.WBS_Code__c = 'Test12354';
        qlb.Total_Cost__c=10;
        qlb.Booking_Including_Rebate__c =40;
        qlb.Higher_Level_Item__c=0;
        insert qlb;
        Backlog_Inflow_Outflow_Tableau__c inflow = new Backlog_Inflow_Outflow_Tableau__c();
        insert inflow;
        database.executebatch(new CleanTableauQuoteLineObjectData(),200);
    }
}