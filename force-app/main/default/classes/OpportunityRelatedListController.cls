public with sharing class OpportunityRelatedListController {

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(Id accountId) {
        return [SELECT Id, Name, Opportunity_Number__c, StageName, Amount, Expected_Bookings__c , CurrencyIsoCode, CloseDate FROM Opportunity WHERE AccountId = :accountId Limit 4];
    }

    @AuraEnabled
    public static SaveResultforOppCustomForm createCoreOpportunity(String recordsToCreate) {
        System.debug(recordsToCreate);
        Map<String,Object> oppObj = (Map<String,Object>) JSON.deserializeUntyped(recordsToCreate);
        SaveResultforOppCustomForm result = new SaveResultforOppCustomForm();
        Opportunity oppToCreate = new Opportunity();
        try {  
            oppToCreate.Name = (String)oppObj.get('Name');
            oppToCreate.Competitor__c = (String)oppObj.get('Competitor__c');
            System.debug((String)oppObj.get('Associated_Opportunity__c'));
            if((String)oppObj.get('Associated_Opportunity__c') != ''){//IBA-6128 Sourav
                oppToCreate.Associated_Opportunity__c = (String)oppObj.get('Associated_Opportunity__c');
            }
            oppToCreate.OpportunityGroup__c = (String)oppObj.get('OpportunityGroup__c');
            oppToCreate.StageName = (String)oppObj.get('StageName');
            oppToCreate.Pipeline_Category__c = (String)oppObj.get('Pipeline_Category__c');
            if(oppObj.get('ExpectedInstallDate__c') != null){
                oppToCreate.ExpectedInstallDate__c = Date.valueOf((String)oppObj.get('ExpectedInstallDate__c'));
            }
            oppToCreate.Compelling_Event__c = (String)oppObj.get('Compelling_Event__c');
            oppToCreate.AccountId = (String)oppObj.get('AccountId');
            oppToCreate.Opportunity__c = (String)oppObj.get('Opportunity__c');
            oppToCreate.CloseDate = Date.valueOf((String)oppObj.get('CloseDate'));
            oppToCreate.CAD_Drawings_Obtained_if_Carousel_XR2__c = (String)oppObj.get('CAD_Drawings_Obtained_if_Carousel_XR2__c');
            oppToCreate.Seismic_Restraint_Required__c = (String)oppObj.get('Seismic_Restraint_Required__c');
            oppToCreate.Forecast_Probability__c = (String)oppObj.get('Forecast_Probability__c');
            oppToCreate.Legal_Resource_Required__c = (String)oppObj.get('Legal_Resource_Required__c');
            oppToCreate.RecordTypeId = (String)oppObj.get('RecordTypeId');
            if(oppObj.get('Services_Enablement_Owner__c') != null){
                oppToCreate.Services_Enablement_Owner__c = (String)oppObj.get('Services_Enablement_Owner__c');
            }
            System.debug(JSON.serialize(oppToCreate));  
            insert oppToCreate;
            result.message = 'Opportunity Created Successfully';
            result.success = true;
            oppToCreate.Id = oppToCreate.Id;
            result.oppDetails = oppToCreate; 
        } catch (Exception e) {
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                // Extract the validation rule message
                result.message = extractValidationErrorMessage(e.getMessage());
            } else {
                // Handle other exceptions if needed
                result.message = e.getMessage();
            }            
            result.success = false;
            System.debug(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static SaveResultforOppCustomForm createSpecialtyOpportunity(String recordsToCreate){
        Map<String,Object> oppObj = (Map<String,Object>) JSON.deserializeUntyped(recordsToCreate);
        SaveResultforOppCustomForm result = new SaveResultforOppCustomForm();
        Opportunity oppToCreate = new Opportunity();
        try { 
            oppToCreate.Name = (String)oppObj.get('Name');
            oppToCreate.Competitor__c = (String)oppObj.get('Competitor__c');
            /*if((String)oppObj.get('Associated_Opportunity__c') != ''){
                oppToCreate.Associated_Opportunity__c = (String)oppObj.get('Associated_Opportunity__c');
            }*/
            oppToCreate.OpportunityGroup__c = (String)oppObj.get('OpportunityGroup__c');
            oppToCreate.StageName = (String)oppObj.get('StageName');
            oppToCreate.Pipeline_Category__c = (String)oppObj.get('Pipeline_Category__c');
            if(oppObj.get('ExpectedInstallDate__c') != null){
                oppToCreate.ExpectedInstallDate__c = Date.valueOf((String)oppObj.get('ExpectedInstallDate__c'));
            }
            oppToCreate.Compelling_Event__c = (String)oppObj.get('Compelling_Event__c');
            oppToCreate.AccountId = (String)oppObj.get('AccountId');
            oppToCreate.Opportunity__c = (String)oppObj.get('Opportunity__c');
            oppToCreate.CloseDate = Date.valueOf((String)oppObj.get('CloseDate'));
            oppToCreate.CAD_Drawings_Obtained_if_Carousel_XR2__c = (String)oppObj.get('CAD_Drawings_Obtained_if_Carousel_XR2__c');
            oppToCreate.Seismic_Restraint_Required__c = (String)oppObj.get('Seismic_Restraint_Required__c');
            oppToCreate.Forecast_Probability__c = (String)oppObj.get('Forecast_Probability__c');
            oppToCreate.Legal_Resource_Required__c = (String)oppObj.get('Legal_Resource_Required__c');
            oppToCreate.RecordTypeId = (String)oppObj.get('RecordTypeId');            
            if(oppObj.get('Specialty_Open_Date__c') != null){
                oppToCreate.Specialty_Open_Date__c = Date.valueOf((String)oppObj.get('Specialty_Open_Date__c'));
            }
            if(oppObj.get('Contract_Year__c') != null){
                oppToCreate.Contract_Year__c = (String)oppObj.get('Contract_Year__c');
            }
            if(oppObj.get('How_many_contract_years__c') != null){
                oppToCreate.How_many_contract_years__c = (String)oppObj.get('How_many_contract_years__c');
            }
            System.debug(JSON.serialize(oppToCreate));                
            insert oppToCreate;
            result.message = 'Opportunity Created Successfully';
            result.success = true;
            oppToCreate.Id = oppToCreate.Id;
            result.oppDetails = oppToCreate;
        } catch(Exception e) {
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                // Extract the validation rule message
                result.message = extractValidationErrorMessage(e.getMessage());
            } else {
                // Handle other exceptions if needed
                result.message = e.getMessage();
            }            
            result.success = false;
            System.debug(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static SaveResultforOppCustomForm createAdvsOpportunity(String recordsToCreate) {
        Map<String,Object> oppObj = (Map<String,Object>) JSON.deserializeUntyped(recordsToCreate);
        SaveResultforOppCustomForm result = new SaveResultforOppCustomForm();
        Opportunity oppToCreate = new Opportunity();
        try {  
            oppToCreate.Name = (String)oppObj.get('Name');
            if((String)oppObj.get('Competitor__c') != ''){ //IBA-6128 Sourav
                oppToCreate.Competitor__c = (String)oppObj.get('Competitor__c');
            }
            if((String)oppObj.get('Associated_Opportunity__c') != ''){ //IBA-6128 Sourav
                oppToCreate.Associated_Opportunity__c = (String)oppObj.get('Associated_Opportunity__c');
            }            
            oppToCreate.OpportunityGroup__c = (String)oppObj.get('OpportunityGroup__c');
            oppToCreate.StageName = (String)oppObj.get('StageName');
            oppToCreate.Pipeline_Category__c = (String)oppObj.get('Pipeline_Category__c');
            if(oppObj.get('ExpectedInstallDate__c') != null){
                oppToCreate.ExpectedInstallDate__c = Date.valueOf((String)oppObj.get('ExpectedInstallDate__c'));
            }
            oppToCreate.Compelling_Event__c = (String)oppObj.get('Compelling_Event__c');
            oppToCreate.AccountId = (String)oppObj.get('AccountId');
            oppToCreate.Opportunity__c = (String)oppObj.get('Opportunity__c');
            if(oppToCreate.Opportunity__c == 'Adv Svc Renewal'){ //IBA-6128 Sourav
                oppToCreate.Adv_Svc_Renewal_Type__c = (String)oppObj.get('Adv_Svc_Renewal_Type__c');
            }
            oppToCreate.CloseDate = Date.valueOf((String)oppObj.get('CloseDate'));
            oppToCreate.CAD_Drawings_Obtained_if_Carousel_XR2__c = (String)oppObj.get('CAD_Drawings_Obtained_if_Carousel_XR2__c');
            oppToCreate.Seismic_Restraint_Required__c = (String)oppObj.get('Seismic_Restraint_Required__c');
            oppToCreate.Forecast_Probability__c = (String)oppObj.get('Forecast_Probability__c');
            oppToCreate.Legal_Resource_Required__c = (String)oppObj.get('Legal_Resource_Required__c');
            oppToCreate.RecordTypeId = (String)oppObj.get('RecordTypeId');
            if(oppObj.get('Services_Enablement_Owner__c') != null){
                oppToCreate.Services_Enablement_Owner__c = (String)oppObj.get('Services_Enablement_Owner__c');
            }
            System.debug(JSON.serialize(oppToCreate));  
            insert oppToCreate;
            result.message = 'Opportunity Created Successfully';
            result.success = true;
            oppToCreate.Id = oppToCreate.Id;
            result.oppDetails = oppToCreate;
        } catch (Exception e) {
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                // Extract the validation rule message
                result.message = extractValidationErrorMessage(e.getMessage());
            } else {
                // Handle other exceptions if needed
                result.message = e.getMessage();
            }            
            result.success = false;
            System.debug(e.getMessage());
        }
        return result;
    }

    public static String extractValidationErrorMessage(String inputString){
        String matchStr = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,';
        String extractedPart = '';
        Integer startIndex = inputString.indexOf(matchStr);
        if (startIndex != -1) {
            Integer endIndex = inputString.indexOf(':', startIndex);    
            if (endIndex != -1) {
                extractedPart = inputString.substring(startIndex +matchStr.length(), endIndex).trim();
            }
        }
        return extractedPart;
    }
}