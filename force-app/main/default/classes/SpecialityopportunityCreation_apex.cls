public class SpecialityopportunityCreation_apex {
    
    public static boolean TriggerDisabled= false;
    
    @AuraEnabled(cacheable=true) //IBA-5024 Soumya
    public static ResultWrapper getData(String opportunityid){  
        ResultWrapper wrapper = new ResultWrapper();
        Opportunity OpportunityCount = [SELECT Name,Contract_Year__c, StageName, CustomerType__c, Specialty_Open_Date__c,How_many_contract_years__c, Competitor__c,CurrencyIsoCode,AccountId,RecordTypeId,OpportunityGroup__c from Opportunity where Id =: opportunityid];
        System.debug('OpportunityCount:'+ OpportunityCount);
        wrapper.Name = OpportunityCount.Name;
        wrapper.specialtyOpenDate = OpportunityCount.Specialty_Open_Date__c;
        wrapper.conYear = OpportunityCount.Contract_Year__c;
        wrapper.HowManyContractYears = OpportunityCount.How_many_contract_years__c;
        wrapper.AccountName = OpportunityCount.AccountId;
        wrapper.OpportunityRecordType = OpportunityCount.RecordTypeId;
        wrapper.OpportunityCurrency = OpportunityCount.CurrencyIsoCode;
         wrapper.CustomerType = OpportunityCount.CustomerType__c;
        if(OpportunityCount.Competitor__c != null){
            wrapper.competitorValue = OpportunityCount.Competitor__c;
        }
        else{wrapper.competitorValue = '';}
        Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get('Opportunity').getDescribe();
        Schema.DescribeFieldResult fieldDescribe = sobjectDescribe.fields.getMap().get('StageName').getDescribe();
        Schema.DescribeFieldResult fieldDescribeForecast = sobjectDescribe.fields.getMap().get('Pipeline_Category__c').getDescribe();
        Schema.DescribeFieldResult fieldDescribeProbability = sobjectDescribe.fields.getMap().get('Forecast_Probability__c').getDescribe();
        
        
        String picLabel = '';
        //Below list contains all the US & CA Picklist values for Stage //IBA-4200 - Start
        List<US_and_CA_Opp_Stages__c> us_caStage = US_and_CA_Opp_Stages__c.getall().values();
        Set<String> nonUSPicklist = new Set<String>();
        for(US_and_CA_Opp_Stages__c u:us_caStage){
            nonUSPicklist.add(u.Name);
        }                   //IBA-4200 - End
        
        for(Schema.PicklistEntry a : fieldDescribe.getPicklistvalues()){
            if(nonUSPicklist.contains(a.getValue())){ //IBA-4200
                picLabel += a.getValue() + ';';
            }
        }
        picLabel = picLabel.removeEnd(';');
        wrapper.stageValue = picLabel;
        String picLabelForecast = '';
        for(Schema.PicklistEntry a : fieldDescribeForecast.getPicklistvalues()){
            
            picLabelForecast += a.getValue() + ';';
        }
        wrapper.forecastCategory = picLabelForecast;
        String picLabelprobability = '';
        for(Schema.PicklistEntry a : fieldDescribeProbability.getPicklistvalues()){
            
            picLabelprobability += a.getValue() + ';';
        }
     
        wrapper.forecastProbability = picLabelprobability;
        
        String picLabelresourceReq = '';//IBA-4200 - Start
        Schema.DescribeFieldResult legalResourceRequiredPicklist = sobjectDescribe.fields.getMap().get('Legal_Resource_Required__c').getDescribe();
        for(Schema.PicklistEntry a : legalResourceRequiredPicklist.getPicklistvalues()){
            
            picLabelresourceReq += a.getValue() + ';';
        }
        wrapper.legalResourceRequired = picLabelresourceReq;
        
        String picLabelcompellingEvent = '';
        Schema.DescribeFieldResult compellingEventPicklist = sobjectDescribe.fields.getMap().get('Compelling_Event__c').getDescribe();
        for(Schema.PicklistEntry a : compellingEventPicklist.getPicklistvalues()){
            
            picLabelcompellingEvent += a.getValue() + ';';
        }
        wrapper.compellingEvent = picLabelcompellingEvent;
        
        String picLabelseismicRestraintRequired = '';
        Schema.DescribeFieldResult seismicRestraintRequiredPicklist = sobjectDescribe.fields.getMap().get('Seismic_Restraint_Required__c').getDescribe();
        for(Schema.PicklistEntry a : seismicRestraintRequiredPicklist.getPicklistvalues()){
            picLabelseismicRestraintRequired += a.getValue() + ';';
        }
        picLabelseismicRestraintRequired = picLabelseismicRestraintRequired.removeEnd(';');
        wrapper.seismicRestraintRequired = picLabelseismicRestraintRequired;
        
        String picLabelCADDrawingsObtained = '';
        Schema.DescribeFieldResult CADDrawingsObtainedPicklist = sobjectDescribe.fields.getMap().get('CAD_Drawings_Obtained_if_Carousel_XR2__c').getDescribe();
        for(Schema.PicklistEntry a : CADDrawingsObtainedPicklist.getPicklistvalues()){
            
            picLabelCADDrawingsObtained += a.getValue() + ';';
        }
        picLabelCADDrawingsObtained = picLabelCADDrawingsObtained.removeEnd(';');
        wrapper.CADDrawingsObtained = picLabelCADDrawingsObtained;//IBA-4200 - End
        
        return wrapper;
    }

    @AuraEnabled
    public static void saveData(String opportunityDetails, String opportunityid){  
        Opportunity updateOriginalContractYr = [select id, Contract_Year__c from Opportunity where id = : opportunityId];
        System.debug('updateOriginalContractYr '+updateOriginalContractYr);
        if(updateOriginalContractYr != null){
            updateOriginalContractYr.Contract_Year__c = '1';
        }
        System.debug('opportunityDetails '+ opportunityDetails);
        List<Opportunity> specialityOpportuity =  (List<Opportunity>)System.JSON.deserialize(opportunityDetails, List<Opportunity>.class);
        System.debug('specialityOpportuity'+specialityOpportuity);
        if(specialityOpportuity.size() > 0){
            try{
                    System.debug('@@@Successfully Created');
                    AccountTriggerHandler.TriggerDisabled =true;
                    OpportunityTriggerHandler.TriggerDisabled =true;
                    insert specialityOpportuity;
                 if(updateOriginalContractYr != null){
                    update updateOriginalContractYr;
                 }   
                }
                catch(system.Dmlexception e){
                    AccountTriggerHandler.TriggerDisabled = false;
                    OpportunityTriggerHandler.TriggerDisabled =false;
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'specialityOpportuity','App'); 
        }
        }
    }

    Public class ResultWrapper{
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String conYear {get; set;}
        @AuraEnabled public date specialtyOpenDate {get; set;}
        @AuraEnabled public String HowManyContractYears {get; set;}
        @AuraEnabled public String stageValue {get; set;}
        @AuraEnabled public String forecastCategory {get; set;}
        @AuraEnabled public String forecastProbability {get; set;}
        @AuraEnabled public String competitorValue {get; set;}
        @AuraEnabled public String OpportunityRecordType {get; set;}
        @AuraEnabled public String OpportunityGroup {get; set;}
        @AuraEnabled public String CustomerType {get; set;}
        @AuraEnabled public String OpportunityCurrency {get; set;}
        @AuraEnabled public String AccountName {get; set;}
        @AuraEnabled public String legalResourceRequired {get; set;}//IBA-4200 - Start
        @AuraEnabled public String compellingEvent {get; set;}
        @AuraEnabled public String seismicRestraintRequired {get; set;}
        @AuraEnabled public String CADDrawingsObtained {get; set;}  //IBA-4200 - End
    }

    @AuraEnabled
    public static saveResult createOpp(string oppList) { //IBA-5024 Soumya
        saveResult result = new saveResult();
        try{
            List<Opportunity> specialityOpportuity =  (List<Opportunity>)System.JSON.deserialize(oppList, List<Opportunity>.class);
            for(opportunity opp:specialityOpportuity){
                opp.Contract_Year__c = string.valueOf(opp.Contract_Year__c);
                opp.id = null;
            }
            insert specialityOpportuity;
            result.success = true;
        }catch(Exception e){
            result.success = false;
            result.errorMessage = e.getMessage();
            system.debug(e.getMessage());
        }
        
        return result;
    }

    public class saveResult { //IBA-5024 Soumya
        @AuraEnabled
        public Boolean success { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }

        public saveResult() {
            this.success = true;
        }
    }
}