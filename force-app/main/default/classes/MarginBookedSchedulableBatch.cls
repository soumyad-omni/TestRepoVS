global class MarginBookedSchedulableBatch implements Database.Batchable<sObject>, schedulable {
    // Database.Stateful 
    String query;
    
    global MarginBookedSchedulableBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(Test.isRunningTest()){
            query ='Select Opportunity_ID__r.Expected_Bookings_Real__c,Primary_Quote_ID__c,Opportunity_Change_Datetime__c,Opportunity_Created_Date__c, Opportunity_ID__c,Opportunity_Forecast_Category__c,Primary_Quote_SAP_Number__c '+
                +'from Forecast_Dimension__c WHERE Opportunity_Forecast_Category__c =\'Booked\' order by Opportunity_ID__c,Opportunity_Change_Datetime__c ASC LIMIT 100';
        }else{
            query ='Select Opportunity_ID__r.Expected_Bookings_Real__c,Primary_Quote_ID__c,Opportunity_Change_Datetime__c,Opportunity_Created_Date__c, Opportunity_ID__c,Opportunity_Forecast_Category__c,Primary_Quote_SAP_Number__c '+
                +'from Forecast_Dimension__c WHERE Opportunity_Forecast_Category__c =\'Booked\'  and Is_Processed__c = false and Opportunity_ID__r.Pipeline_Category__c = \'Booked\' order by Opportunity_ID__c,Opportunity_Change_Datetime__c ASC';
        }
//1 row
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Forecast_Dimension__c> lstFC) {
        // execute code
        List<Opportunity_Usage_History__c> lstOppUsageHistory = new List<Opportunity_Usage_History__c>();
        Set<id> oppIds = new Set<id>();
        Map<String,Forecast_Dimension__c> oppCategoryDataMap = new Map<String,Forecast_Dimension__c>();
        for( Forecast_Dimension__c fc :lstFC){
            oppIds.add(fc.Opportunity_ID__c);
        }
        List<Forecast_Dimension__c> forcastDataForOpps = [Select Opportunity_ID__r.Expected_Bookings_Real__c,Primary_Quote_ID__c,Opportunity_Change_Datetime__c,Opportunity_Created_Date__c, Opportunity_ID__c,Opportunity_Forecast_Category__c,Primary_Quote_SAP_Number__c  
                                                          from Forecast_Dimension__c 
                                                          WHERE Opportunity_Forecast_Category__c ='Booked'  and Is_Processed__c = false and Opportunity_ID__r.Pipeline_Category__c = 'Booked' and Opportunity_ID__c in:oppIds order by Opportunity_ID__c,Opportunity_Change_Datetime__c ASC];
        Set<id> oppIdsToProcess = new Set<id>();
        for(Forecast_Dimension__c fc :forcastDataForOpps){
            oppCategoryDataMap.put(fc.Opportunity_ID__c+'Booked',fc);
            oppIdsToProcess.add(fc.Opportunity_ID__c);
        }
        Map<id,List<COGS_Dimension__c>> oppRelatedCogsDimension = new Map<id,List<COGS_Dimension__c>>();
        List<COGS_Dimension__c > cogsDimentions =[Select Id, COGS_Primary_Quote_SAP_Number__c, 
                                                       COGS_Primary_Quote_Labor_Cost__c,    
                                                       COGS_Primary_Quote_Material_Cost__c,
                                                       COGS_Primary_Quote_Overhead_Cost__c,
                                                       COGS_Primary_Quote_Margin__c,    
                                                       COGS_Primary_Quote_Expected_Booking__c,  
                                                       COGS_Primary_Quote_Change_Datetime__c,
												       Primary_Quote_ID__c, 
                                                       Primary_Opportunity_Id__c  from COGS_Dimension__c 
                                                       WHERE Primary_Quote_ID__r.Primary_Quote__c = true
                                                  		AND Primary_Opportunity_Id__c in :oppIds
                                                 	   ORDER BY COGS_Primary_Quote_Change_Datetime__c desc];
        System.debug('Number of Cogs Records:'+cogsDimentions.size());
        for(COGS_Dimension__c cog:cogsDimentions){
            if(oppRelatedCogsDimension.get(cog.Primary_Opportunity_Id__c) != null){
                List<COGS_Dimension__c> cogData = oppRelatedCogsDimension.get(cog.Primary_Opportunity_Id__c);
                cogData.add(cog);
                oppRelatedCogsDimension.put(cog.Primary_Opportunity_Id__c, cogData);
            }else{
                List<COGS_Dimension__c> cogData = new List<COGS_Dimension__c>();
                cogData.add(cog);
                oppRelatedCogsDimension.put(cog.Primary_Opportunity_Id__c, cogData);   
            }
        }
            
            //69 rows were returned
        for(id oppId: oppIdsToProcess){
                Forecast_Dimension__c fc = oppCategoryDataMap.get(oppId+'Booked');
                Opportunity_Usage_History__c oppUH = new Opportunity_Usage_History__c();
                oppUH.Quote_Margin__c = 0;
                oppUH.Quote_Labor_Cost__c = 0;
                oppUH.Quote_Overhead_Cost__c = 0;
                oppUH.Total_Cost__c = 0;
                if(fc != null){
                    oppUH.QuoteId__c = fc.Primary_Quote_ID__c;
                    oppUH.Quote_SAP_Number__c = fc.Primary_Quote_SAP_Number__c;
                    oppUH.Opprtunity_Expected_Booking__c = fc.Opportunity_ID__r.Expected_Bookings_Real__c;
            	}
            	
            if(oppRelatedCogsDimension.get(oppId) != null){
                //lets find the first non-null margin value
                for (COGS_Dimension__c cogs : oppRelatedCogsDimension.get(oppId)) {
                    if (cogs.COGS_Primary_Quote_Change_Datetime__c <= fc.Opportunity_Change_Datetime__c && cogs.COGS_Primary_Quote_Margin__c != null) {
                        oppUH.Quote_Margin__c = cogs.COGS_Primary_Quote_Margin__c;
                        break;
                    }
                }
                //lets also find the first non-null expected bookings
                /*for (COGS_Dimension__c cogs : oppRelatedCogsDimension.get(oppId)) {
                    if (cogs.COGS_Primary_Quote_Change_Datetime__c <= fc.Opportunity_Change_Datetime__c  && cogs.COGS_Primary_Quote_Expected_Booking__c != null) {
                        oppUH.Opprtunity_Expected_Booking__c = fc.Opportunity_ID__r.Expected_Bookings_Real__c;
                        break;
                    }
                }*/
                //labor
                for (COGS_Dimension__c cogs : oppRelatedCogsDimension.get(oppId)) {
                    if (cogs.COGS_Primary_Quote_Change_Datetime__c <= fc.Opportunity_Change_Datetime__c  && cogs.COGS_Primary_Quote_Labor_Cost__c != null) {
                        oppUH.Quote_Labor_Cost__c = cogs.COGS_Primary_Quote_Labor_Cost__c;
                        break;
                    }
                }
                //overhead
                for (COGS_Dimension__c cogs : oppRelatedCogsDimension.get(oppId)) {
                    if (cogs.COGS_Primary_Quote_Change_Datetime__c <= fc.Opportunity_Change_Datetime__c && cogs.COGS_Primary_Quote_Overhead_Cost__c != null) {
                        oppUH.Quote_Overhead_Cost__c = cogs.COGS_Primary_Quote_Overhead_Cost__c;
                        break;
                    }
                }
                //material Cost
                for (COGS_Dimension__c cogs : oppRelatedCogsDimension.get(oppId)) {
                    if (cogs.COGS_Primary_Quote_Change_Datetime__c <= fc.Opportunity_Change_Datetime__c && cogs.COGS_Primary_Quote_Material_Cost__c != null) {
                        oppUH.Total_Cost__c = cogs.COGS_Primary_Quote_Material_Cost__c;
                        break;
                    }
                }
                
            }   
                oppUH.Opportunity_Forecast_Category__c = fc.Opportunity_Forecast_Category__c;
                oppUH.Opportunity_ID__c = oppId;
                oppUH.Opportunity_Change_Date_Time__c=fc.Opportunity_Change_Datetime__c ;
            	if(oppUH.Opportunity_Change_Date_Time__c != null)
                	oppUH.Opty_Change_Date_Convert__c = changeFormat(oppUH.Opportunity_Change_Date_Time__c);
                if(fc.Opportunity_Forecast_Category__c == 'Development'){
                    oppUH.Opportunity_Forecast_Category_Order__c = '1-Development';
                }else if(fc.Opportunity_Forecast_Category__c == 'Upside'){
                    oppUH.Opportunity_Forecast_Category_Order__c = '2-Upside';
                }else if(fc.Opportunity_Forecast_Category__c == 'Committed'){
                    oppUH.Opportunity_Forecast_Category_Order__c = '3-Committed';
                }else if(fc.Opportunity_Forecast_Category__c == 'Booked'){
                    oppUH.Opportunity_Forecast_Category_Order__c = '4-Booked';
                }
                
                lstOppUsageHistory.add(oppUH);
            
        }
        system.debug('@@lstOppUsageHistory'+lstOppUsageHistory);
        if(!lstOppUsageHistory.isEmpty()){
            insert  lstOppUsageHistory;
        }
        List<Forecast_Dimension__c> processedForecastData = new List<Forecast_Dimension__c>();
        for(Forecast_Dimension__c forecastData: forcastDataForOpps){
            Forecast_Dimension__c fd = new Forecast_Dimension__c(id=forecastData.id);
            fd.Is_Processed__c = true;
            processedForecastData.add(fd);
        }
        if(!processedForecastData.isEmpty()){
            update processedForecastData;
        }
        //system.debug('@@lstFC'+lstFC);
        //if(!lstFC.isEmpty())
        //    update lstFC;
        
    }
    
    
    global void finish(Database.BatchableContext BC) {
        // finish code 
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where Id = :bc.getJobId()];
        System.debug('job Status : '+a.status);
        if(a.Status == 'Completed' && a.NumberOfErrors == 0 && a.ExtendedStatus == null){
            database.executebatch(new MarginBookedQTDBatch(),2000);
        }
    }
    
    global void execute(SchedulableContext SC) {
        database.executebatch(new MarginBookedSchedulableBatch());
    }
    
    global static void start(integer hour){
        string jobName = 'job name';
        if (hour == 0) database.executebatch(new MarginBookedSchedulableBatch());
        else {
            jobName = jobName += ' - ' + datetime.now().format();
            string cron = '0 0 ' + string.valueof(hour) + ' * * ?';
            system.schedule(jobName, cron, new MarginBookedSchedulableBatch());
        }
    }
    public static Decimal changeFormat(DateTime inputDate){
        String outputDate = ''+inputDate.year() + String.ValueOf(inputDate.month()).leftpad(2,'0') + String.ValueOf(inputDate.day()).leftpad(2,'0')+ String.ValueOf(inputDate.hour()).leftpad(2,'0')+ String.ValueOf(inputDate.minute()).leftpad(2,'0');
		return Decimal.valueOf(outputDate);
    }
}