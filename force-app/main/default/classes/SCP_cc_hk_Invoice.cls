global with sharing class SCP_cc_hk_Invoice  extends ccrz.cc_hk_Invoice{

    /*** 
    Purpose - This method is to bring custom fields on to Invoice List Page
    Developer - Ravi M
    ***/
    global override Map<String,Object> fetchInvoices(Map<String,Object> inputData) {
       
       ccrz.ccLog.log(LoggingLevel.DEBUG, 'inputData---', inputData);
       Map<String,Object> ccMap;
       if (!Test.isRunningTest()){
            ccMap = super.fetchInvoices(inputData);
       }
       else{
           ccMap =  inputData;    
       }
        List<Map<String,Object>> invoices = (List<Map<String,Object>>) ccMap.get('invoices');
        List<String> invoiceIds = new List<String>();
        Map<String,Map<String,Object>> additionalData = new Map<String,Map<String,Object>>();

        // Get all the invoice ids that were returned from the ootb function.
        for(Map<String, Object> invoice : invoices) {
            invoiceIds.add(invoice.get('sfid').toString());
        }
        String query = 'SELECT Id,ccrz__CCOrder__r.SAP_Order_Number__c FROM ccrz__E_Invoice__c WHERE Id IN :invoiceIds';

        List<ccrz__E_Invoice__c> invoiceObjects =  Database.query(query);
         ccrz.ccLog.log(LoggingLevel.DEBUG, 'invoiceObjects ', invoiceObjects );
        for(ccrz__E_Invoice__c t: invoiceObjects) {
            Map<String, Object> tData = new Map<String, Object>{
                    'SAPOrderNumber' => t.ccrz__CCOrder__r.SAP_Order_Number__c 
            };
            additionalData.put(t.Id, tData);
        }
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'additionalData', additionalData);

        for (Integer i = 0; i < invoices.size() ; i++) {
            Map<String, Object> invoice = invoices[i];
            String key = invoice.get('sfid').toString();

            if(additionalData.containsKey(key)) {
                invoice.putAll(additionalData.get(key));
            }
        }
        ccMap.put('invoices',invoices);
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'fetchInvoices:ccMap', ccMap);
        system.debug('## HK INVOICE ccMap--'+ ccMap);

        return ccMap;
	}
    
    /*** 
    Purpose - This method is to bring custom fields on to Invoice Detail Page
    Developer - Sanjana K.R
    ***/
    global override Map<String,Object> fetchInvoice(Map<String,Object> inputData) {
    
       
       ccrz.ccLog.log(LoggingLevel.DEBUG, 'fetchInvoice:inputData', inputData);
       Map<String,Object> ccMap;
       Map<String,Object> invoice;
       if (!Test.isRunningTest()){
            ccMap = super.fetchInvoice(inputData); 
       }
       Id invoiceID = (Id) inputData.get('invoiceId');
       
       String query = 'SELECT Id,ccrz__CCOrder__r.SAP_Order_Number__c FROM ccrz__E_Invoice__c WHERE Id =:     invoiceId limit 1';
       ccrz__E_Invoice__c invoiceObjects  =  Database.query(query);
       
       Map<String, Object> tData = new Map<String, Object>{
                    'SAPOrderNumber' => invoiceObjects.ccrz__CCOrder__r.SAP_Order_Number__c 
       };
       
       ccrz.ccLog.log(LoggingLevel.DEBUG, 'fetchInvoice:ccMap', ccMap);        
       if (!Test.isRunningTest()){
           invoice = (Map<String,Object>) ccMap.get('invoice');
           invoice.putAll(tData);
       }
       ccrz.ccLog.log(LoggingLevel.DEBUG, 'fetchInvoice:invoice after', invoice);
       ccrz.ccLog.log(LoggingLevel.DEBUG, 'fetchInvoice:ccMap return---', ccMap);
       return ccMap;
    }


}