trigger SCP_TransPay on ccrz__E_TransactionPayment__c (After Insert) {

set<id> tpids = new set<id>();
for(ccrz__E_TransactionPayment__c  tp: trigger.new  ){

   if(tp.ccrz__AccountType__c == 'po' && tp.ccrz__CCSubscription__c !=null && tp.ccrz__CCOrder__c == null  ){
   
       tpids.add(tp.id);
   }
}

if(tpids.size()>0){

SCP_TransPaymentHandler.deleteTPS(tpids) ; 

} 


}