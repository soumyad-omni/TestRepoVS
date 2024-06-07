global with sharing class SCP_CyberSourceTxnOverride extends ccrz.ccLogic {
    //static final ccpgcs.ccLogicDataMap LOGIC_DATAMAP = new ccpgcs.ccLogicDataMap();
    global override Map<String, Object> process(Map<String, Object> inputData) 
    {
        System.debug('##### TXN process InputData-->' + inputData);
        /*// call the default process method
        inputData = (Map<String,Object>)LOGIC_DATAMAP.process(inputData);
        // get the existing mappings at key 'data'
        Map<String,Object> dataMap = (Map<String,Object>)inputData.get('data');
        // find the cc cart using the cart encrypted ID (aka OOTB merchant reference number)
        final String cartEncId = (String)dataMap.get('merchant_defined_data13');
        ccrz__E_Cart__c cart = [SELECT Name FROM ccrz__E_Cart__c WHERE ccrz__EncryptedId__c=:cartEncId LIMIT 1];
        if (null != cart) {
            // replace OOTB merchant reference number value with cart name (OOTB autonumber)
            dataMap.put('reference_number', cart.Name); 
        }
        // update the working map
        inputData.put('data', dataMap);
        // return the results*/
        return super.process(inputData);
    }
    global override Map<String, Object> preProcess(Map<String, Object> inputData) {
        System.debug('##### TXN preprocess InputData-->' + inputData);
        return super.preProcess(inputData);
    }
    global override Map<String, Object> postProcess(Map<String, Object> inputData) {
        System.debug('##### TXN postprocess InputData-->' + inputData);
        return super.postProcess(inputData);
    }
}