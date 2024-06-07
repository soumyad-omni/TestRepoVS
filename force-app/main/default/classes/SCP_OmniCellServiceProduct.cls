global with sharing class SCP_OmniCellServiceProduct extends ccrz.ccServiceProduct {
    
    /**
     * @description Get additional field list
     * @param     inputData Object Fields
     * @return   map of all additional object fields included 
     */
    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) { 
        ccrz.ccLog.log(System.LoggingLevel.Debug, 'getFieldsMap:inputData', inputData); 
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',Minimum_Quantity__c';
        if(!objectFields.contains('ProductWeight__c')){
            objectFields += ',ccrz__ProductWeight__c';
        }
        return new Map<String, Object>{
        ccrz.ccService.OBJECTFIELDS => objectFields 
        };
    }
}