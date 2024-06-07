trigger SCP_DeleteStoredPayCredit on ccrz__E_StoredPayment__c (  after insert) {

 SCP_TransPaymentHandler.deleteSPS( trigger.newMap.keyset());
}