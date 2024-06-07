global with sharing class SCP_OmniCellServiceAccount extends ccrz.ccServiceAccount {
    global virtual override Map<String,Object> getFieldsMap(Map<String, Object> inputData) {
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String)inputData.get(ccrz.ccService.OBJECTFIELDS);
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'P:account fields',objectFields);
        objectFields += ', Account_Name2__c,SAP_Customer_Number__c' ;
        if(!objectFields.contains('Name')){
           objectFields += ', Name' ;
        }
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'P:account fields after',objectFields);
        return new Map<String, Object> {ccrz.ccService.OBJECTFIELDS => objectFields};
    }
    global virtual override Map<String, Object> getSubQueryMap(Map<String, Object> inputData) {
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'Test for Custom Value are' + objectFields);
        return SCP_OmniCellServiceAccount.SUBQUERYMAP;
    }
 
    private static final Map<String, Object> SUBQUERYMAP = new Map<String, Object>{
        
        'E_Orders__r' =>'(SELECT id,Name,SAP_Order_Number__c,ccrz__EncryptedId__c FROM E_Orders__r)'
    };
}