global with sharing class SCP_ccOCBServiceCart extends ccrz.ccServiceCart 
{

  global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) 
  {
  inputData = super.getFieldsMap(inputData); 
  String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS); 
  objectFields += ',Reference_Number__c ' ; 
  inputData.put(ccrz.ccService.OBJECTFIELDS,objectFields); 
  system.debug('inputData--->'+inputData);
  ccrz.ccLog.log(System.LoggingLevel.DEBUG,'Test for Custom Value are' + objectFields);
  return inputData;
  }
}