/* 
* Class Name       :SCP_TransPaymentHandler
* Description      :Handler class to update CC Transaction Payment fields
* Created By       :Sanjana K.R
* Created On       :Apr 30,2021

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date           Story                                 Description
* ----------------------------------------------------------------------------------------------------------------
* Sanjana K.R             30/4/2021
*/

Public class SCP_TransPaymentHandler {

      
    
    @future 
      public Static void deleteSPS(set<Id> spsList){
        list<ccrz__E_StoredPayment__c> delList = new list<ccrz__E_StoredPayment__c>();

        for(ccrz__E_StoredPayment__c  sp: [select id,ccrz__AccountType__c  from ccrz__E_StoredPayment__c where ID IN : spsList]) {

            if(sp.ccrz__AccountType__c == 'sopcc' ){
               delList.add( sp); 
           }
    }

    if(delList.size()>0 )
         delete delList ; 
    }
    
      
      public Static void deleteTPS(set<Id> tpsList){
        list<ccrz__E_TransactionPayment__c  > delList = new list<ccrz__E_TransactionPayment__c  >();

        for(ccrz__E_TransactionPayment__c  sp: [select id from ccrz__E_TransactionPayment__c   where ID IN : tpsList]) {

                delList.add( sp); 
           
    }
        system.debug('### delList--'+delList) ; 
        
    if(delList.size()>0 )
         delete delList ; 
    }
    
    

}