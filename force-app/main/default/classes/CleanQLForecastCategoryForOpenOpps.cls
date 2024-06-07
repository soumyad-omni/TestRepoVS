global class CleanQLForecastCategoryForOpenOpps implements Database.Batchable<SObject>{
    global Database.queryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('select id,Is_Manually_Added__c ,Opportunity_Name__c ,Primary_Quote_ID__c,Primary_Quote_SAP_Number__c,Opportunity_ID__c,Opportunity_ID__r.name,opportunity_ID__r.Pipeline_Category__c,Opportunity_ID__r.PrimaryQuote__r.Quote_Number__c,Opportunity_ID__r.PrimaryQuote__c,Opportunity_ID__r.CreatedDate,Opportunity_Forecast_Category__c, Opportunity_Change_Datetime__c,Opportunity_Created_Date__c from Forecast_Dimension__c where Opportunity_Status__c = \'Open\' order by Opportunity_ID__c,Opportunity_Change_Datetime__c asc');
    }
    
    global void execute (Database.BatchableContext BC, List<Forecast_Dimension__c> forecastData){
        processForecastCategoryData(forecastData);
    }
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            database.executebatch(new MarginQLReportsScheduleJob(),10000);
        }
    }
    
    public void processForecastCategoryData(List<Forecast_Dimension__c> forecastDimensionData){
        //List<Forecast_Dimension__c> forecastDimensionData = [select id,Is_Manually_Added__c ,Opportunity_Name__c ,Primary_Quote_ID__c,Primary_Quote_SAP_Number__c,Opportunity_ID__c,Opportunity_ID__r.name,opportunity_ID__r.Pipeline_Category__c,Opportunity_ID__r.PrimaryQuote__r.Quote_Number__c,Opportunity_ID__r.PrimaryQuote__c,Opportunity_ID__r.CreatedDate,Opportunity_Forecast_Category__c, Opportunity_Change_Datetime__c,Opportunity_Created_Date__c from Forecast_Dimension__c where Opportunity_Status__c = 'Open' order by Opportunity_ID__c,Opportunity_Change_Datetime__c asc];
        Map<String,Forecast_Dimension__c> OppData = new Map<String,Forecast_Dimension__c>();
        List<Forecast_Dimension__c> forecastDataToInsert = new List<Forecast_Dimension__c>();
        Set<id> oppIds = new Set<id>();
        Map<id,Forecast_Dimension__c> oppMapData = new Map<id,Forecast_Dimension__c>();
        for(Forecast_Dimension__c fd:forecastDimensionData){
            String key = fd.Opportunity_ID__c+fd.Opportunity_Forecast_Category__c;
            oppIds.add(fd.Opportunity_ID__c);
            oppMapData.put(fd.Opportunity_ID__c, fd);
            if(fd.Opportunity_Forecast_Category__c == 'Development' && fd.Is_Manually_Added__c){
                OppData.put(key,fd);
                
            }else if(fd.Opportunity_Forecast_Category__c != 'Development'){
                OppData.put(key,fd);
            }
            
        }
        for(Id oppId:oppIds){
            Forecast_Dimension__c forecastData = oppMapData.get(oppId);
            //For Development
            String devKey = oppId+ 'Development';
            Forecast_Dimension__c developmentData;
            System.debug('OppData.get(devKey):'+OppData.get(devKey));
            if((OppData.get(devKey) == null || (OppData.get(devKey) != null && !OppData.get(devKey).Is_Manually_Added__c)))
            {
                System.debug('Inside the New Development Creation Logic');
                developmentData = new Forecast_Dimension__c();
                developmentData.Opportunity_Change_Datetime__c = forecastData.Opportunity_ID__r.CreatedDate;
                developmentData.Opportunity_ID__c = oppId;
                developmentData.Opportunity_Forecast_Category__c = 'Development';
                developmentData.Opportunity_Name__c = forecastData.Opportunity_ID__r.name;
                developmentData.Primary_Quote_ID__c = forecastData.Opportunity_ID__r.PrimaryQuote__c ;
                /*if(forecastData.Opportunity_ID__r.PrimaryQuote__c != null){
developmentData.Primary_Quote_SAP_Number__c = Integer.valueOf(forecastData.Opportunity_ID__r.PrimaryQuote__r.Quote_Number__c);
}*/
                developmentData.Opportunity_Created_Date__c = forecastData.Opportunity_ID__r.CreatedDate;
                developmentData.Is_Manually_Added__c = true;
                forecastDataToInsert.add(developmentData);
            }else if(OppData.get(devKey) != null){
                developmentData = OppData.get(devKey);
            }
            String upsideKey = oppId+ 'Upside';
            String committedKey = oppId+ 'Committed';
            Forecast_Dimension__c upsideData = new Forecast_Dimension__c();
            
            if(OppData.get(upsideKey) == null && OppData.get(committedKey) != null){
                upsideData.Opportunity_Change_Datetime__c = developmentData.Opportunity_Change_Datetime__c;
                upsideData.Opportunity_ID__c = oppId;
                upsideData.Opportunity_Forecast_Category__c = 'Upside';
                upsideData.Opportunity_Name__c = developmentData.Opportunity_Name__c;
                upsideData.Primary_Quote_ID__c = developmentData.Primary_Quote_ID__c ;
                //upsideData.Primary_Quote_SAP_Number__c =developmentData.Primary_Quote_SAP_Number__c;
                upsideData.Opportunity_Created_Date__c = developmentData.Opportunity_Created_Date__c;
                upsideData.Is_Manually_Added__c = true;
                forecastDataToInsert.add(upsideData);
            }     
        }
        System.debug('Records Being Inserted:'+forecastDataToInsert.size());
        if(!forecastDataToInsert.isEmpty())
        {
            insert forecastDataToInsert;
        }
    }
    
}