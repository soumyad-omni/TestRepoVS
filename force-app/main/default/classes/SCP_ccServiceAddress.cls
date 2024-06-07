global with sharing class SCP_ccServiceAddress extends ccrz.ccServiceAddress 
{

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) 
    {
        inputData = super.getFieldsMap(inputData); 
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS); 
        objectFields += ',Company_Name_2__c ,NewFirstName__c,SAP_Contact_ID__c,SAP_Customer_Number__c' ; 
        inputData.put(ccrz.ccService.OBJECTFIELDS,objectFields); 
        system.debug('inputData--->'+inputData);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'$$$$ cc contact Address service output-->' + objectFields);
        return inputData;
    }
  
  
}