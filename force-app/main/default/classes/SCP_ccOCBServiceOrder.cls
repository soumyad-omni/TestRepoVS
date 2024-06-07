/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-30-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class SCP_ccOCBServiceOrder extends ccrz.ccServiceOrder 
{

  global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) 
  {
  inputData = super.getFieldsMap(inputData); 
  String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS); 
  objectFields += ',Reference_Number__c,SAP_Order_Number__c,Attachment_id__c  ' ; // SCP-769
  inputData.put(ccrz.ccService.OBJECTFIELDS,objectFields); 
  system.debug('inputData--->'+inputData);
  ccrz.ccLog.log(System.LoggingLevel.DEBUG,'Test for Custom Value are' + objectFields);
  return inputData;
  }
}