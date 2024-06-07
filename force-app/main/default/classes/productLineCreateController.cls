public with sharing class productLineCreateController {
    
    @AuraEnabled
    public static SaveResultforOppCustomForm createProductLines(String recordsToCreate, String oppId) {
        List<Object> productLineObjList = (List<Object>) JSON.deserializeUntyped(recordsToCreate);
        List<Product_Line__c> allProductLines = new List<Product_Line__c>();
        SaveResultforOppCustomForm result = new SaveResultforOppCustomForm();
        try{
            for(Object obj:productLineObjList){
                Product_Line__c prodLine = new Product_Line__c();
                Map<String,Object> objMap = (Map<String,Object>)obj;
                prodLine.Portfolio_Segment__c = (String)objMap.get('Portfolio_Segment__c');
                prodLine.Amount__c = Decimal.valueOf((String)objMap.get('Amount__c'));                
                prodLine.Opportunity__c = oppId;
                allProductLines.add(prodLine);
            }
            insert allProductLines;
            result.message = 'Product Line Created Successfully';
            result.success = true;  
        }
        catch (Exception e) {
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                // Extract the validation rule message
                result.message = OpportunityRelatedListController.extractValidationErrorMessage(e.getMessage());
            } else {
                // Handle other exceptions if needed
                result.message = e.getMessage();
            }            
            result.success = false;
            System.debug(e.getMessage());
        }
        return result;
    }
}