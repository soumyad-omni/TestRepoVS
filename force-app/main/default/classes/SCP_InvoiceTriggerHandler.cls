Public with sharing class SCP_InvoiceTriggerHandler{

    Public Static void  processAfterInsertEvent(List<ccrz__E_Invoice__c> invoiceNewList,Map<id,ccrz__E_Invoice__c> invoiceNewMap){
    
        List<id> orderIdSet= new List<id>();
        Set<id> transactionPaymentID= new Set<id>();
        String TRANSACTIONTYPE='authorization,create_payment_token';
        String TRANSACTION_CODE_ACCEPT='ACCEPT';
        Map<String,Map<String,String>> tpOrdMap = new Map<String,Map<String,String>>();
        Map<String,String> tpInvMap;
         
        String setInvID;
        list<id> contId= new list<id>();//IBA-4532
        list<string> contVerId= new list<string>();//IBA-4532
        Map<Id,Id> invIdconVId = new Map<Id,Id> ();//IBA-4532
        list<ContentVersion> cvList = new list<ContentVersion>();
        Map<Id,Id> invIdOrdId = new Map<Id,Id> ();
        Map<Id,Id> OrdIdInvId = new Map<Id,Id> ();
        for( ccrz__E_Invoice__c inv  :invoiceNewList){
               contId.add(inv.ccrz__Contact__c);//IBA-4532
                if(inv.Attachment_Body__c != null && inv.Attachment_Body__c != ''){//IBA-4532
                    cvList.add(createPdf(inv));
                }
               invIdOrdId.put(inv.id, inv.ccrz__CCOrder__c );
               OrdIdInvId.put(  inv.ccrz__CCOrder__c ,inv.id);
        }
        //IBA-4532 start
        if(cvList.size()>0){
            insert cvList;
            
            for(ContentVersion c:cvList){
                contVerId.add(c.id);
                invIdconVId.put(c.id,c.Title);
            }
        }
        
        
        
        map<id,ContentVersion> contVerMap = new map<id,ContentVersion>();
        
        if(contVerId.size() > 0){
            
            list<ContentDocumentLink> cdl = new list<ContentDocumentLink>();
            
            for(ContentVersion cv:[SELECT id,VersionData, PathOnClient,Title ,FileType,ContentDocumentId FROM ContentVersion WHERE Id =:contVerId]){
                string invoId = invIdconVId.get(cv.id);
                contVerMap.put(invoId,cv);
                cdl.add(createContentDocL(invoId,cv.ContentDocumentId));
            }
            
            if(cdl.size()>0){
                insert cdl;
            }
        }
        
        Map<Id,contact> contMap = new Map<Id,contact>([select id,email from contact where id =:contId]);
        //IBA-4532 end
        
        map<id,ccrz__E_Order__c> childOrd = new map<id,ccrz__E_Order__c> ();
        map<ID,id> childOrdParents = new map<id,id>(); 
        map<id,ccrz__E_Order__c> parOrd = new map<id,ccrz__E_Order__c> ();
        for ( ccrz__E_Order__c ords : [ select ccrz__CCSubscription__c, ccrz__Order__c
                                         
                                        FROM ccrz__E_Order__c WHERE ID IN: invIdOrdId.VALUES()]
            ){
            system.debug('*ords.ccrz__CCSubscription__c***'+ords.ccrz__CCSubscription__c);
            if(ords.ccrz__CCSubscription__c != null ){
                childOrd.put(ords.id, ords);
                childOrdParents.put(  ords.ccrz__Order__c,ords.id ); // parent,child 
                }
            else
                 parOrd.put(ords.id, ords);
                  system.debug('parOrd-->'+parOrd); 
        
        }
        
         
        
        // query tps
        map<id,ccrz__E_TransactionPayment__c> parOrdTP = new map<id,ccrz__E_TransactionPayment__c> ();
        List<ccrz__E_TransactionPayment__c> paymentTransactionList=[SELECT id,ccrz__Account__c,ccrz__CCOrder__r.ccrz__Order__c ,OwnerId,ccrz__AccountNumber__c,ccrz__AccountType__c,ccrz__Address__c,ccpgcs__Address__c,ccrz__Amount__c,ccrz__BillTo__c,ccrz__CCOrder__c,ccrz__CCSubscription__c
                                                                          ,ccrz__Comments__c,ccrz__Contact__c,ccrz__CurrencyISOCode__c,ccrz__ExpirationMonth__c,ccrz__ExpirationYear__c,ccrz__InvoiceAppliedFor__c,ccrz__InvoiceAppliedTo__c
                                                                          ,ccrz__ParentTransactionPayment__c,ccpgcs__PayerAuthenticationCavv__c,ccpgcs__PayerAuthenticationEci__c,ccpgcs__PayerAuthenticationReasonCode__c,ccpgcs__PayerAuthenticationTransactionId__c
                                                                          ,ccpgcs__PayerAuthenticationXid__c,ccrz__PaymentType__c,ccrz__RequestAmount__c,ccrz__SoldTo__c,ccrz__SourceTransactionPayment__c,ccrz__StoredPayment__c,ccrz__Storefront__c,ccrz__SubAccountNumber__c 
                                                                          ,ccrz__Token__c,ccpgcs__TokenInstrumentIdentifier__c,ccrz__TransactionCode__c,ccrz__TransactionSubcode__c,ccrz__TransactionTS__c,ccrz__TransactionType__c
                                                                          ,ccrz__User__c,ccrz__VerificationCode__c  FROM ccrz__E_TransactionPayment__c 
                WHERE ccrz__TransactionType__c=:TRANSACTIONTYPE AND ( ccrz__CCOrder__c in:  childOrdParents.KEYSET() OR  ccrz__CCOrder__c in: parOrd.keyset()  ) 
                AND ccrz__TransactionCode__c=:TRANSACTION_CODE_ACCEPT];
        
       if(!paymentTransactionList.isEmpty()){        
        for( ccrz__E_TransactionPayment__c tp: paymentTransactionList ) {
             system.debug('parOrd.get(tp.ccrz__CCOrder__c)-->'+parOrd.get(tp.ccrz__CCOrder__c));  
            
             if(childOrdParents.get(tp.ccrz__CCOrder__c)!= null){
              parOrdTP.PUT( childOrdParents.get(tp.ccrz__CCOrder__c) , tp ); 
             //   parOrdTP.PUT( tp.ccrz__CCOrder__c, tp ); 
            } 
            else if(parOrd.get(tp.ccrz__CCOrder__c)!= null)
              parOrdTP.PUT( tp.ccrz__CCOrder__c, tp ); 
             
        }   
        
        List<ccrz__E_TransactionPayment__c> payTransList = new List<ccrz__E_TransactionPayment__c>();
         system.debug('## parOrdTP--'+ parOrdTP);
        for( ccrz__E_Invoice__c inv  :invoiceNewList){
                
               ccrz__E_TransactionPayment__c paymentTransaction = new ccrz__E_TransactionPayment__c(); 
               ccrz__E_TransactionPayment__c  tPay = new ccrz__E_TransactionPayment__c(); 
               
                tPay = parOrdTP.get(inv.ccrz__CCOrder__c);
            system.debug('## tpay--'+ tpay); 
            
                  paymentTransaction = tPay.Clone(false,true);
                setInvID = inv.id; 
                paymentTransaction.ccrz__Amount__c=invoiceNewMap.get(setInvID).ccrz__OriginalAmount__c;
                paymentTransaction.ccrz__RequestAmount__c=invoiceNewMap.get(setInvID).ccrz__OriginalAmount__c;
                paymentTransaction.OwnerId = tPay.OwnerId;
                
                 if( parOrd.get(inv.ccrz__CCOrder__c) == null ) 
                paymentTransaction.ccrz__CCSubscription__c =  childOrd.get(inv.ccrz__CCOrder__c).ccrz__CCSubscription__c;
                
                paymentTransaction.ccrz__InvoiceAppliedTo__c=invoiceNewMap.get(setInvID).id;
                paymentTransaction.ccrz__InvoiceAppliedFor__c=invoiceNewMap.get(setInvID).id;
                paymentTransaction.ccrz__TransactionType__c='INVOICE';
                
                if( parOrd.get(inv.ccrz__CCOrder__c) == null ) 
                 paymentTransaction.ccrz__CCOrder__c=  invIdOrdId.get(inv.id );  
                 
                payTransList.add(paymentTransaction);
                
             

              
            }
           SYSTEM.DEBUG('## payTransList--'+payTransList); 
            insert payTransList;
             
            Map<Id,id> tpInvId = new Map<Id,id>(); 
           Map<Id,ccrz__E_TransactionPayment__c> ordTPID = new Map<Id,ccrz__E_TransactionPayment__c>(); 
            
           SYSTEM.DEBUG('## payTransList invIdOrdId.VALUES()--'+invIdOrdId.VALUES());
           
            for( ccrz__E_TransactionPayment__c tp: [select ccrz__CCOrder__c, ccrz__Amount__c  from  ccrz__E_TransactionPayment__c where // Added ccrz__Amount__c to suppress $0 transactions IBA-2250
                                                    ccrz__CCOrder__c IN: invIdOrdId.VALUES()
                                                      AND ccrz__TransactionType__c='INVOICE'
                                                        ] ) {
            
               tpInvId.put( tp.id, OrdIdInvId.get(tp.ccrz__CCOrder__c));
                ordTPID.PUT(tp.ccrz__CCOrder__c, tp );                                              
            
            } 

         SYSTEM.DEBUG('## payTransList tpInvId--'+ tpInvId); 
        
        // for(id  tPay :  tpInvId.keyset()){
             //   id jobId=System.enqueueJob(new SCP_CyberSourceCaptureAPI(tPay , tpInvId.get(tPay)));
          //  }
         
         ccrz__E_Invoice__c invToUpdate;
         List<ccrz__E_Invoice__c> invToUpdateList = new List<ccrz__E_Invoice__c>();
         for( ccrz__E_Invoice__c inv  :invoiceNewList){
             if (ordTPID.get(inv.ccrz__CCOrder__c).ccrz__Amount__c <= 0) { // Added condition to suppress $0 transactions IBA-2250
                invToUpdate = new ccrz__E_Invoice__c(id = inv.id, ccrz__Status__c = 'Closed', ccrz__RemainingAmount__c = 0, SCP_Retry_Count__c = 2);
                invToUpdateList.add(invToUpdate);
             }
             else{ // IBA-2250 ends here letting call to Cybersource as usual
	            id jobId=System.enqueueJob(new SCP_CyberSourceCaptureAPI( ordTPID.get(inv.ccrz__CCOrder__c).id , inv.id)) ;  
             }
         }
           if (invToUpdateList.size() > 0){ // If Cybersource was not called, uodate the invoice IBA-2250
               update invToUpdateList;
           }
    }
        
    }
    //Start IBA-4532
    public static ContentVersion createPdf(ccrz__E_Invoice__c inv){
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; 
        conVer.PathOnClient = inv.Name+'.pdf'; 
        conVer.Title = inv.id; 
        conVer.Tag__c = 'Invoice';//IBA-6018
        conVer.VersionData = EncodingUtil.base64Decode(inv.Attachment_Body__c); 
        return conVer;
    }
    
    public static ContentDocumentLink createContentDocL(string inv, string conDoc){
        
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = inv; 
        conDocLink.ContentDocumentId = conDoc;  
        conDocLink.shareType = 'V';
        conDocLink.Visibility = 'AllUsers';//IBA-6018
        //insert conDocLink;
        return conDocLink;
    }
    //End IBA-4532
}