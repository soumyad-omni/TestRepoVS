global class CleanCurrentQuoteLineResult implements Database.Batchable<SObject> {
    private Integer numberOfDays;
    public CleanCurrentQuoteLineResult(Integer numberOfDays){
        this.numberOfDays = numberOfDays;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date thresholdDate = Date.today().addDays((numberOfDays*-1));
        string cqlresultquery='select id,Average_Cost__c,Average_Selling_Price__c,Change_Date_Convert__c,Changed_Date__c,Cost__c,expected_booking__c,Higher_Level_Item__c,Is_Processed__c,Labor_Cost__c,Margin__c,Derived_Portfolio_Segment__c,Opportunity__c,Opportunity_Forecast_Category__c,Opportunity_Forecast_Category_Order__c,Order_Type__c,Overhead_Cost__c,Portfolio_Segment__c,Power_of_One__c,Product__c,Product_Description__c,Quantity__c,Quote__c,Quote_Line__c,Requested_land_date_RLD__c,RLD_Quarter__c,SAP_Line_Number__c,SAP_Order_Number__c,SAP_Quote_Number__c,Simplified_Segment__c,Total_Cost__c	,Valid_From__c,Valid_To__c from Current_Quote_Line_Result__c where CreatedDate<:thresholdDate AND Valid_To__c<TODAY';
         return database.getQueryLocator(cqlresultquery);
    }
    global void execute(Database.BatchableContext bc, List<Current_Quote_Line_Result__c> scope) {
        if (!scope.isEmpty()) {
            List<Current_Quote_Line_Result__c> cqlr = (List<Current_Quote_Line_Result__c>) scope;
            list<Backlog_Inflow_Outflow__c> backlogifof = new list<Backlog_Inflow_Outflow__c>();
        for(Current_Quote_Line_Result__c cq:cqlr){
          Backlog_Inflow_Outflow__c baclLogInflowOutflow = new Backlog_Inflow_Outflow__c();
            baclLogInflowOutflow.Average_Cost__c = cq.Average_Cost__c;
            baclLogInflowOutflow.Average_Selling_Price__c=cq.Average_Selling_Price__c;
            baclLogInflowOutflow.Change_Date_Convert__c=cq.Change_Date_Convert__c;
            baclLogInflowOutflow.Changed_Date__c=cq.Changed_Date__c;
            baclLogInflowOutflow.Cost__c=cq.Cost__c;
          baclLogInflowOutflow.Derived_Portfolio_Segment__c=cq.Derived_Portfolio_Segment__c;
            baclLogInflowOutflow.expected_booking__c=cq.expected_booking__c;
            baclLogInflowOutflow.Higher_Level_Item__c=cq.Higher_Level_Item__c;
            baclLogInflowOutflow.Is_Processed__c=cq.Is_Processed__c;
            baclLogInflowOutflow.Labor_Cost__c=cq.Labor_Cost__c;
            baclLogInflowOutflow.Margin__c=cq.Margin__c;
            baclLogInflowOutflow.Opportunity__c=cq.Opportunity__c;
            baclLogInflowOutflow.Opportunity_Forecast_Category__c=cq.Opportunity_Forecast_Category__c;
            baclLogInflowOutflow.Opportunity_Forecast_Category_Order__c=cq.Opportunity_Forecast_Category_Order__c;
            baclLogInflowOutflow.Order_Type__c=cq.Order_Type__c;
            baclLogInflowOutflow.Overhead_Cost__c=cq.Overhead_Cost__c;
            baclLogInflowOutflow.Portfolio_Segment__c=cq.Portfolio_Segment__c;
            baclLogInflowOutflow.Power_of_One__c=cq.Power_of_One__c;
            baclLogInflowOutflow.Product__c=cq.Product__c;
            baclLogInflowOutflow.Product_Description__c=cq.Product_Description__c;
            baclLogInflowOutflow.Quantity__c=cq.Quantity__c;
            baclLogInflowOutflow.Quote__c=cq.Quote__c;
            baclLogInflowOutflow.Quote_Line__c=cq.Quote_Line__c;
            baclLogInflowOutflow.Requested_land_date_RLD__c=cq.Requested_land_date_RLD__c;
            baclLogInflowOutflow.RLD_Quarter__c=cq.RLD_Quarter__c;
            baclLogInflowOutflow.SAP_Line_Number__c=cq.SAP_Line_Number__c;
            baclLogInflowOutflow.SAP_Order_Number__c=cq.SAP_Order_Number__c;
          baclLogInflowOutflow.SAP_Quote_Number__c=cq.SAP_Quote_Number__c;
            baclLogInflowOutflow.Simplified_Segment__c=cq.Simplified_Segment__c;
            baclLogInflowOutflow.Total_Cost__c=cq.Total_Cost__c;
            baclLogInflowOutflow.Valid_From__c=cq.Valid_From__c;
            baclLogInflowOutflow.Valid_To__c=cq.Valid_To__c;
            baclLogInflowOutflow.Is_Current_Quote_Line_Result__c = true;
            baclLogInflowOutflow.Current_Quote_Line_Result__c = cq.id;
            backlogifof.add(baclLogInflowOutflow);
        } 
            insert backlogifof;
            Database.DeleteResult[] deleteResults = Database.delete(cqlr, false);
            for (Database.DeleteResult deleteResult : deleteResults) {
                if (deleteResult.isSuccess()) {
                    System.debug('Record deleted successfully: ' + deleteResult.getId());
                } else {
                    System.debug('Error deleting record: ' + deleteResult.getErrors()[0].getMessage());
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc) {
        CleanQuoteLineBacklog secondJob = new CleanQuoteLineBacklog(numberOfDays);
        Database.executeBatch(secondJob,5000);
    }
}