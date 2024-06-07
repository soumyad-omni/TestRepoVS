global with sharing class SCP_ccOCBServiceCartItem extends ccrz.ccServiceCartItem
{
    global override Map<String, Object> getFieldsMap(Map<String, Object> inputData) 
    {
        Map<String, Object> outputData = super.getFieldsMap(inputData);

        // Add custom fields
        String fields = (String) outputData.get(ccrz.ccService.OBJECTFIELDS);
        fields += ',SCP_Availability_Message__c';
        fields += ',Machines__r.Machine_Name__c';
        fields += ',Machine_Type__c';
       /* fields += ',Brand_Name__c';
        fields += ',Generic_Drug_Name__c';
        fields += ',Manufacturer_Name__c';
        fields += ',Drug_Strength__c ';*/
		fields += ',Material__c ';
        
        
        fields += ',DrugCodes__r.DrugCodes__c';
        fields += ',DrugCodes__r.Brand_Name__c';
        fields += ',DrugCodes__r.Generic_Drug_Name__c';
        fields += ',DrugCodes__r.Manufacturer_Name__c';
        fields += ',DrugCodes__r.Drug_Strength__c';
        
        
        outputData.put(ccrz.ccService.OBJECTFIELDS, fields);

        return outputData;
    }
    
}