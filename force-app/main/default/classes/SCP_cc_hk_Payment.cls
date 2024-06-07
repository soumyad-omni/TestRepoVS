global  class SCP_cc_hk_Payment  extends ccrz.cc_hk_Payment{

    global override Map<String,Object> fetchTransactionPayment(Map<String,Object> inputData) {
     
        Map<String,Object> ccMap = new Map<String,Object>();
        Map<String,Object> payment = new Map<String,Object>();
        Map<String,Object> ccOrder = new Map<String,Object>();
        Map<String,Object> invoiceAppliedFor = new Map<String,Object>();
        Map<String,Object> invoiceAppliedTo = new Map<String,Object>();
        String invId;
        List<String> orderIds = new List<String>();
        if(!Test.isRunningTest()){
            ccMap = super.fetchTransactionPayment(inputData);
        }else{
          ccMap=inputData;
        }
        payment = (Map<String,Object>)ccMap.get('payment');
        
        if(payment.get('ccOrder')!=null)
            ccOrder = (Map<String,Object>)payment.get('ccOrder');
        
        if(payment.get('invoiceAppliedFor')!=null){
            invoiceAppliedFor = (Map<String,Object>)payment.get('invoiceAppliedFor');
            if(invoiceAppliedFor.get('sfid')!=null){
                invId = (String)invoiceAppliedFor.get('sfid');
                invId = invId.length()>15 ? invId.subString(0,15):invId;
                ccrz__E_Invoice__c inv = [select id,ccrz__InvoiceId__c from ccrz__E_Invoice__c where id =: invId]; 
                if(inv!=null){
                    invoiceAppliedFor.put('invoiceID',inv.ccrz__InvoiceId__c);
                    payment.put('invoiceAppliedFor',invoiceAppliedFor);
                }
            }
        }
        if(payment.get('invoiceAppliedTo')!=null){
            invoiceAppliedTo = (Map<String,Object>)payment.get('invoiceAppliedTo');
            if(invoiceAppliedTo.get('sfid')!=null){
                invId = (String)invoiceAppliedTo.get('sfid');
                ccrz__E_Invoice__c inv = [select id,ccrz__InvoiceId__c from ccrz__E_Invoice__c where id =: invId]; 
                if(inv!=null){
                    invoiceAppliedTo.put('invoiceID',inv.ccrz__InvoiceId__c);
                    payment.put('invoiceAppliedTo',invoiceAppliedTo);
                }
            }
        }
        system.debug('invoiceAppliedFor-->'+payment.get('invoiceAppliedFor'));
        system.debug('invoiceAppliedTo-->'+payment.get('invoiceAppliedTo'));
                
        if(ccOrder.get('sfid')!=null){
            String orderId = ccOrder.get('sfid').toString();
            String query = 'SELECT Id,SAP_Order_Number__c FROM ccrz__E_Order__c WHERE Id =:orderId';
            ccrz__E_Order__c orderObject =  Database.query(query);
            ccOrder.put('SAPOrderNumber',orderObject.SAP_Order_Number__c);
            payment.put('ccOrder',ccOrder);
            ccMap.put('payment',payment);
        }
        system.debug('ccMap-->'+ccMap); 
        return ccMap;
    }    
}