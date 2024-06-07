global class MarginBookedQTDBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query ='select id, Opportunity_ID__c, Opprtunity_Expected_Booking__c, QuoteId__c, Opty_Change_Date_Convert__c, Quote_SAP_Number__c, Quote_Margin__c, Quote_Labor_Cost__c, Total_Cost__c, Quote_Overhead_Cost__c, Opportunity_Change_Date_Time__c from Opportunity_Usage_History__c where Opportunity_Expected_Closed_Date__c >= THIS_FISCAL_QUARTER and Opportunity_Forecast_Category_Order__c = \'4-Booked\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity_Usage_History__c> ouhList) 
    {
        List<Opportunity_Usage_History__c> insertOUHBookingQTD = new List<Opportunity_Usage_History__c>();
        
        for(Opportunity_Usage_History__c ouh : ouhList)
        {
            Opportunity_Usage_History__c newOUH = new Opportunity_Usage_History__c();
            newOUH.Opportunity_ID__c = ouh.Opportunity_ID__c;
            newOUH.Opportunity_Forecast_Category_Order__c = '6-Booked QTD';
            newOUH.Opprtunity_Expected_Booking__c = ouh.Opprtunity_Expected_Booking__c;
            newOUH.Quote_Margin__c = ouh.Quote_Margin__c;
            newOUH.Quote_Labor_Cost__c = ouh.Quote_Labor_Cost__c;
            newOUH.Total_Cost__c = ouh.Total_Cost__c;
            newOUH.Quote_Overhead_Cost__c = ouh.Quote_Overhead_Cost__c;
            newOUH.Opportunity_Change_Date_Time__c = ouh.Opportunity_Change_Date_Time__c;
            newOUH.QuoteId__c = ouh.QuoteId__c;
            newOUH.Quote_SAP_Number__c = ouh.Quote_SAP_Number__c;
            newOUH.Opty_Change_Date_Convert__c = ouh.Opty_Change_Date_Convert__c;
            
            insertOUHBookingQTD.add(newOUH);
        }
        
        if(!insertOUHBookingQTD.isEmpty())
            insert insertOUHBookingQTD;
    }
    
    global void finish(Database.BatchableContext BC) {
        // finish code 
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            database.executebatch(new ResetForecastDimensionProcessedFlagJob(),2000);
        }
    }
}