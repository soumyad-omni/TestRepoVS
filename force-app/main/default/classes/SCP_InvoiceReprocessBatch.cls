Public class SCP_InvoiceReprocessBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

 Public Database.querylocator start(Database.BatchableContext bc) {
    
        String FAILED_STATUS='Failed';
        
        
        String queryString='SELECT id FROM ccrz__E_Invoice__c WHERE ccrz__Status__c=:FAILED_STATUS AND SCP_Retry_Count__c=1 ';
    
        return Database.getQueryLocator(queryString);
    } 
    
    Public void execute(Database.BatchableContext BC, List<ccrz__E_Invoice__c> unProcessedInvoices){
        
        //Since we are creating invoices for each tp and updating invoice id on TP. we will have one to one mapping.
        Map<String,String> InvoiceToTpIdsMap= new Map<String,String>();
        Set<id>InvoiceIds= new Set<id>(); 
        for(ccrz__E_Invoice__c invoices:unProcessedInvoices){
            InvoiceIds.add(invoices.id);
        }
        
        List<ccrz__E_TransactionPayment__c> TransactionPaymentList=[SELECT id,ccrz__InvoiceAppliedTo__c FROM ccrz__E_TransactionPayment__c WHERE ccrz__InvoiceAppliedTo__c=:InvoiceIds ];
        
        For(ccrz__E_TransactionPayment__c tp:TransactionPaymentList){
            if(tp.ccrz__InvoiceAppliedTo__c!=null){
                InvoiceToTpIdsMap.put(tp.ccrz__InvoiceAppliedTo__c,tp.id);
            }
        }
        
        System.debug('Printing the map'+InvoiceToTpIdsMap);
        
        for(String s:InvoiceToTpIdsMap.Keyset()){
            if(Limits.getLimitCallouts()>=Limits.getCallouts()){
                System.debug('Printing Invoke API call');
                SCP_CyberSourceCaptureAPI.CyberSourceCaptureSOAP(InvoiceToTpIdsMap.get(s),s); 
            }    
        }  
    }
    
    public void finish(Database.BatchableContext BC){
    
    }

}