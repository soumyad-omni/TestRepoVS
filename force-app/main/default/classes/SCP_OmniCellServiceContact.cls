global with sharing class SCP_OmniCellServiceContact extends ccrz.ccServiceContact {
    global virtual override Map<String,Object> getFieldsMap(Map<String, Object> inputData) {
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'contact fields',objectFields);
        //objectFields += ', Account_Name2__c' ;
        /*if(!objectFields.contains('Name')){
           objectFields += ', Name' ;
        }*/
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'P:account fields after',objectFields);
        return new Map<String, Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }

}