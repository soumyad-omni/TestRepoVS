global class CleanQLForecastCategoryBatch implements Database.Batchable<SObject>, schedulable{
    
    global Database.queryLocator start(Database.BatchableContext bc){
        
            return Database.getQueryLocator('select Is_Manually_Added__c ,id,Opportunity_Name__c ,Primary_Quote_ID__c,Primary_Quote_SAP_Number__c,Opportunity_ID__c,Opportunity_ID__r.name,Opportunity_ID__r.PrimaryQuote__r.Quote_Number__c,Opportunity_ID__r.PrimaryQuote__c,Opportunity_ID__r.CreatedDate,Opportunity_Forecast_Category__c, Opportunity_Change_Datetime__c,Opportunity_Created_Date__c from Forecast_Dimension__c where Opportunity_Status__c = \'Booked\' order by Opportunity_ID__c,Opportunity_Change_Datetime__c asc');
    }
    
    global void execute (Database.BatchableContext BC, List<Forecast_Dimension__c> forecastData){
        processForecastCategoryData(forecastData);
    }
    global void execute(SchedulableContext SC) {
        database.executebatch(new CleanQLForecastCategoryBatch());
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            database.executebatch(new CleanQLForecastCategoryForOpenOpps(),2000);
        }
    }
    
    public void processForecastCategoryData(List<Forecast_Dimension__c> forecastDimensionData){
        //List<Forecast_Dimension__c> forecastDimensionData = [select Is_Manually_Added__c ,id,Opportunity_Name__c ,Primary_Quote_ID__c,Primary_Quote_SAP_Number__c,Opportunity_ID__c,Opportunity_ID__r.name,Opportunity_ID__r.PrimaryQuote__r.Quote_Number__c,Opportunity_ID__r.PrimaryQuote__c,Opportunity_ID__r.CreatedDate,Opportunity_Forecast_Category__c, Opportunity_Change_Datetime__c,Opportunity_Created_Date__c from Forecast_Dimension__c where Opportunity_Status__c = 'Booked' order by Opportunity_ID__c,Opportunity_Change_Datetime__c asc];
        Map<String,Forecast_Dimension__c> OppData = new Map<String,Forecast_Dimension__c>();
        List<Forecast_Dimension__c> forecastDataToInsert = new List<Forecast_Dimension__c>();
        Set<id> oppIds = new Set<id>();
        Map<id,Forecast_Dimension__c> oppMapData = new Map<id,Forecast_Dimension__c>();
        for(Forecast_Dimension__c fd:forecastDimensionData){
            String key = fd.Opportunity_ID__c+fd.Opportunity_Forecast_Category__c;
            OppData.put(key,fd);
            oppIds.add(fd.Opportunity_ID__c);
            oppMapData.put(fd.Opportunity_ID__c, fd);
        }
        for(Id oppId:oppIds){
            Forecast_Dimension__c forecastData = oppMapData.get(oppId);
            //For Development
            //If Manually Created Development Forecast Category exists then do not create.
            String devKey = oppId+ 'Development';
            Forecast_Dimension__c developmentData;
            if((OppData.get(devKey) == null || (OppData.get(devKey) != null && !OppData.get(devKey).Is_Manually_Added__c)))
            {
                developmentData = new Forecast_Dimension__c();
                developmentData.Opportunity_Change_Datetime__c = forecastData.Opportunity_ID__r.CreatedDate;
                developmentData.Opportunity_ID__c = oppId;
                developmentData.Opportunity_Forecast_Category__c = 'Development';
                developmentData.Opportunity_Name__c = forecastData.Opportunity_ID__r.name;
                developmentData.Primary_Quote_ID__c = forecastData.Opportunity_ID__r.PrimaryQuote__c ;
                if(forecastData.Opportunity_ID__r.PrimaryQuote__c != null && forecastData.Opportunity_ID__r.PrimaryQuote__r.Quote_Number__c != null){
                    developmentData.Primary_Quote_SAP_Number__c = Integer.valueOf(forecastData.Opportunity_ID__r.PrimaryQuote__r.Quote_Number__c);
                }
                developmentData.Opportunity_Created_Date__c = forecastData.Opportunity_ID__r.CreatedDate;
                developmentData.Is_Manually_Added__c = true;
                forecastDataToInsert.add(developmentData);
            }else if(OppData.get(devKey) != null){
                developmentData = OppData.get(devKey);
            }
            //For Upside
            String upsideKey = oppId+ 'Upside';
            Forecast_Dimension__c upsideData = new Forecast_Dimension__c();
            
            if(OppData.get(upsideKey) == null){
                upsideData.Opportunity_Change_Datetime__c = developmentData.Opportunity_Change_Datetime__c;
                upsideData.Opportunity_ID__c = oppId;
                upsideData.Opportunity_Forecast_Category__c = 'Upside';
                upsideData.Opportunity_Name__c = developmentData.Opportunity_Name__c;
                upsideData.Primary_Quote_ID__c = developmentData.Primary_Quote_ID__c ;
                upsideData.Primary_Quote_SAP_Number__c =developmentData.Primary_Quote_SAP_Number__c;
                upsideData.Opportunity_Created_Date__c = developmentData.Opportunity_Created_Date__c;
                upsideData.Is_Manually_Added__c = true;
                forecastDataToInsert.add(upsideData);
            }
            //For Committed 
            
            String committedKey = oppId+ 'Committed';
            Forecast_Dimension__c committedData = new Forecast_Dimension__c();
                         

            if(OppData.get(committedKey) == null){
                if(OppData.get(upsideKey) != null){
                    committedData.Opportunity_Change_Datetime__c = OppData.get(upsideKey).Opportunity_Change_Datetime__c;
                    committedData.Opportunity_ID__c = oppId;
                    committedData.Opportunity_Forecast_Category__c = 'Committed';
                    committedData.Opportunity_Name__c = OppData.get(upsideKey).Opportunity_Name__c;
                    committedData.Primary_Quote_ID__c = OppData.get(upsideKey).Primary_Quote_ID__c;
                    committedData.Primary_Quote_SAP_Number__c = OppData.get(upsideKey).Primary_Quote_SAP_Number__c;
                    committedData.Opportunity_Created_Date__c = OppData.get(upsideKey).Opportunity_Created_Date__c;
                    committedData.Is_Manually_Added__c = true;
                    forecastDataToInsert.add(committedData);
                }else{
                    committedData.Opportunity_Change_Datetime__c = developmentData.Opportunity_Change_Datetime__c;
                    committedData.Opportunity_ID__c = oppId;
                    committedData.Opportunity_Forecast_Category__c = 'Committed';
                    committedData.Opportunity_Name__c = developmentData.Opportunity_Name__c;
                    committedData.Primary_Quote_ID__c = developmentData.Primary_Quote_ID__c;
                    committedData.Primary_Quote_SAP_Number__c = developmentData.Primary_Quote_SAP_Number__c;
                    committedData.Opportunity_Created_Date__c = developmentData.Opportunity_Created_Date__c;
                    committedData.Is_Manually_Added__c = true;
                    forecastDataToInsert.add(committedData);
                }
                
            }
        
            else if (OppData.get(upsideKey) != null && OppData.get(committedKey).Opportunity_Change_Datetime__c  < OppData.get(upsideKey).Opportunity_Change_Datetime__c ){
                    committedData.Opportunity_Change_Datetime__c = OppData.get(upsideKey).Opportunity_Change_Datetime__c;
                    committedData.Opportunity_ID__c = oppId;
                    committedData.Opportunity_Forecast_Category__c = 'Committed';
                    committedData.Opportunity_Name__c = OppData.get(upsideKey).Opportunity_Name__c;
                    committedData.Primary_Quote_ID__c = OppData.get(upsideKey).Primary_Quote_ID__c;
                    committedData.Primary_Quote_SAP_Number__c = OppData.get(upsideKey).Primary_Quote_SAP_Number__c;
                    committedData.Opportunity_Created_Date__c = OppData.get(upsideKey).Opportunity_Created_Date__c;
                    committedData.Is_Manually_Added__c = true;
                    forecastDataToInsert.add(committedData);
            }
             
       
        }
        System.debug('Records Being Inserted:'+forecastDataToInsert.size());
        if(!forecastDataToInsert.isEmpty())
        {
            insert forecastDataToInsert;
        }
    }
    
}