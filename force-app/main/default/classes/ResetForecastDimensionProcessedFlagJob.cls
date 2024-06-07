global class ResetForecastDimensionProcessedFlagJob implements Database.Batchable<SObject>, schedulable{
    global Database.queryLocator start(Database.BatchableContext bc){
        //Query ForecastDimension records with IsProcessedFlag True
         if(Test.isRunningTest()){
             return Database.getQueryLocator('Select id, Is_Processed__c from Forecast_Dimension__c where Is_Processed__c=true limit 100');
         }
        else{
            return Database.getQueryLocator('Select id, Is_Processed__c from Forecast_Dimension__c where Is_Processed__c=true');
        }
        
    }
    global void execute (Database.BatchableContext BC, List<Forecast_Dimension__c> forecastData){
        //Re-set the Flag To False.
        List<Forecast_Dimension__c> forecastDataToUpdate = new List<Forecast_Dimension__c>();
        for(Forecast_Dimension__c fc:forecastData){
            Forecast_Dimension__c data = new Forecast_Dimension__c(id=fc.id);
            data.Is_Processed__c = false;
            forecastDataToUpdate.add(data);
        }
        if(!forecastDataToUpdate.isEmpty()){
            update forecastDataToUpdate;
        }
    }
	global void execute(SchedulableContext SC) {
        database.executebatch(new ResetForecastDimensionProcessedFlagJob());
    }
    global void finish(Database.BatchableContext BC){
        //Nothing here
    }
}