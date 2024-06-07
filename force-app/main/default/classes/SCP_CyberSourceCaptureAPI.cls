Public Class SCP_CyberSourceCaptureAPI Implements Queueable,Database.AllowsCallouts{

    Public String TRANSACTION_PAYMENT_ID;
    Public String INVOICE_ID;
    public static integer retrycount = 0; 
    
    
    Public SCP_CyberSourceCaptureAPI(String TRANSACTION_PAYMENT_ID,String INVOICE_ID){
        this.TRANSACTION_PAYMENT_ID=TRANSACTION_PAYMENT_ID;
        this.INVOICE_ID=INVOICE_ID;
    }
    
   Public void Execute(QueueableContext qc){
       CyberSourceCaptureSOAP(TRANSACTION_PAYMENT_ID,INVOICE_ID);
   }

    Public Static void CyberSourceCaptureSOAP(String tpId,String invoiceId){
        
        
        
        List<ccrz__E_Invoice__c> invoiceToUpdate = new List<ccrz__E_Invoice__c>();
        List<ccrz__E_TransactionPayment__c> transactionPayment= new List<ccrz__E_TransactionPayment__c>();
        List<ccrz__E_InvoiceItem__c> invoiceItemsToUpdate= new List<ccrz__E_InvoiceItem__c>();
        List<Account> billToAccount= new List<Account>();
        List<Contact> contactOnInvoice= new List<Contact>();
        List<sObject> sObjectsToUpdate= new List<sObject>();// List to Update.
        
        String FAILED_STRING='Failed';
        String CLOSED_STRING='Closed';
        //Variables that need to be set from contact and Account.
        String FIRST_NAME;
        String LAST_NAME;
        String PHONE_NUMBER;
        String BILLING_STREET;
        String BILLING_CITY;
        String BILLING_STATE;
        String BILLING_POSTAL_CODE;
        String BILLING_COUNTRY;
        String Email;
        //End
        
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_Cybersource_Capture');
        String SOAP_PASSWORD=Label.SCP_CyberSource_Password;
        String SOAPrequestBody='';
        String reasonCode='';
        String reconciliationID='';
        string responseBody='';
        HttpRequest request = new HTTPRequest();
        HTTPResponse response= new HTTPResponse();
        boolean isChildOrder = false;
        String AUTHREQUESTID,AUTHREQUESTTOKEN;
        // while loop -- <2 
        
        while (retrycount < 2) {
        
        try{
           // invoiceId='122';
            // date format issues 
        invoiceToUpdate = [SELECT id
                                , SCP_ReconcillationID__c
                                , Name
                                , OwnerId
                                , ccrz__InvoiceId__c
                                , ccrz__CCOrder__c,ccrz__CCOrder__r.ccrz__Order__c
                                , ccrz__BillTo__c
                                , ccrz__Contact__c
                                , ccrz__Status__c
                                , SCP_Request_From_CyberSource__c
                                , SCP_Response_Code_From_CyberScource__c
                                , ccrz__CurrencyCode__c
                                , SCP_Retry_Count__c
                                , ccrz__RemainingAmount__c
                                  FROM ccrz__E_Invoice__c
                                  WHERE id=:invoiceId AND ccrz__Status__c!=:CLOSED_STRING LIMIT 1];
       
                                                           
        transactionPayment=[SELECT  id,ccrz__AccountType__c,OwnerId,ccrz__CurrencyISOCode__c, ccrz__Contact__c,ccrz__BillTo__c,ccrz__Amount__c,ccrz__RequestAmount__c,ccrz__Token__c,ccrz__VerificationCode__c,ccrz__SubAccountNumber__c FROM ccrz__E_TransactionPayment__c WHERE id=:tpId];
        List<ccrz__E_Invoice__c> invCount = new List<ccrz__E_Invoice__c>();
          
       invCount =[SELECT ID,ccrz__CCOrder__c From ccrz__E_Invoice__c where ccrz__CCOrder__c =: invoiceToUpdate[0].ccrz__CCOrder__c ];
            
        system.debug('##invCount-- '+ invCount);    
            
        System.debug('Printing Invoice details'+invoiceToUpdate);
        System.debug('Printing TransactionPAyment details'+transactionPayment);
        
        if(!invoicetoUpdate.isEmpty()){
            if(invoiceToUpdate[0].ccrz__BillTo__c!=null){
                billToAccount=[SELECT id,Name,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode FROM Account WHERE id=:invoiceToUpdate[0].ccrz__BillTo__c];
            }
            
            if(invoiceToUpdate[0].ccrz__Contact__c!=null){
                contactOnInvoice=[SELECT id,FirstName,LastName,Email,Phone FROM Contact Where id=:invoiceToUpdate[0].ccrz__Contact__c];
            }
            
             invoiceItemsToUpdate=[SELECT id,ccrz__Status__c FROM ccrz__E_InvoiceItem__c WHERE ccrz__Invoice__c=:invoiceToUpdate[0].id AND ccrz__Status__c!=:CLOSED_STRING ];
        }
        
        if(!contactOnInvoice.isEmpty()){
            FIRST_NAME = rePLaceSpecialChar(contactOnInvoice[0].FirstName);//Added replace logic for IBA-2226
            LAST_NAME = rePLaceSpecialChar(contactOnInvoice[0].LastName);//Added replace logic for IBA-2226
            PHONE_NUMBER=contactOnInvoice[0].Phone;
            Email =contactOnInvoice[0].Email;
        }
        
        if(!billToAccount.isEmpty()){
            BILLING_STREET = rePLaceSpecialChar(billToAccount[0].BillingStreet);//Added replace logic for IBA-2226
            BILLING_CITY = rePLaceSpecialChar(billToAccount[0].BillingCity);//Added replace logic for IBA-2226
            BILLING_STATE = rePLaceSpecialChar(billToAccount[0].BillingState);//Added replace logic for IBA-2226
            BILLING_POSTAL_CODE=billToAccount[0].BillingPostalCode;
            BILLING_COUNTRY = rePLaceSpecialChar(billToAccount[0].BillingCountry);//Added replace logic for IBA-2226
        }
        
        System.debug('######Printing Bill to Account Details'+billToAccount);
        System.debug('Printing Contact on Invoice Details'+contactOnInvoice);
        
        //if(!invoiceToUpdate.isEmpty()&&!transactionPayment.isEmpty()&&!billToAccount.isEmpty()&&!contactOnInvoice.isEmpty()){
            //Construct the SOAP BODY.
           /* SOAPrequestBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header>' +
    '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" soapenv:mustUnderstand="1">'+
    '<wsse:UsernameToken><wsse:Username>'+connectionDetails.SCP_Key_Client_Id__c+'</wsse:Username>'+
    '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+SOAP_PASSWORD+'</wsse:Password>' 
    +'</wsse:UsernameToken></wsse:Security></soapenv:Header><soapenv:Body><requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.147">' +
    '<merchantID>'+connectionDetails.SCP_Key_Client_Id__c+'</merchantID><merchantReferenceCode>'+invoiceToUpdate[0].ccrz__InvoiceId__c+'</merchantReferenceCode>' +
    
    '<billTo><firstName>'+FIRST_NAME+'</firstName><lastName>'+LAST_NAME+'</lastName><street1>'+BILLING_STREET+'</street1><city>'+BILLING_CITY+'</city><state>'+BILLING_STATE+'</state><postalCode>'+BILLING_POSTAL_CODE+'</postalCode><country>'+BILLING_COUNTRY+'</country>' +
    '<phoneNumber>'+PHONE_NUMBER+'</phoneNumber><email>'+Email+'</email></billTo>' +


    '<purchaseTotals><currency>'+invoiceToUpdate[0].ccrz__CurrencyCode__c+'</currency>' +
    '<grandTotalAmount>'+transactionPayment[0].ccrz__Amount__c+'</grandTotalAmount></purchaseTotals><ccCaptureService run="true">'+
    '<authRequestID>'+transactionPayment[0].ccrz__VerificationCode__c+'</authRequestID><authRequestToken>'+transactionPayment[0].ccrz__Token__c+'</authRequestToken>'+
    '<sequence>' +invCount.size()+ '</sequence><totalCount>99</totalCount>' +  
                '</ccCaptureService></requestMessage></soapenv:Body></soapenv:Envelope>' ; 
            
       // }
        */
        if(invoiceToUpdate[0].ccrz__CCOrder__r.ccrz__Order__c!=null){//this is for subscription orders
            isChildOrder = true; 
            SOAPrequestBody = '<?xml version="1.0" encoding="UTF-8"?>'+
                            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'+
                            '<soapenv:Header>'+
                                '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" soapenv:mustUnderstand="1">'+
                                    '<wsse:UsernameToken>'+
                                        '<wsse:Username>'+connectionDetails.SCP_Key_Client_Id__c+'</wsse:Username>'+
                                        '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+SOAP_PASSWORD+'</wsse:Password>'+
                                    '</wsse:UsernameToken>'+
                                '</wsse:Security>'+
                            '</soapenv:Header>'+
                            '<soapenv:Body>'+
                                '<requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.147">'+
                                    '<merchantID>'+connectionDetails.SCP_Key_Client_Id__c+'</merchantID>'+
                                    '<merchantReferenceCode>'+transactionPayment[0].id+'</merchantReferenceCode>'+
                                    '<billTo>'+
                                        '<firstName>'+FIRST_NAME+'</firstName>'+
                                        '<lastName>'+LAST_NAME+'</lastName>'+
                                        '<street1>'+BILLING_STREET+'</street1>'+
                                        '<city>'+BILLING_CITY+'</city>'+
                                        '<state>'+BILLING_STATE+'</state>'+
                                        '<postalCode>'+BILLING_POSTAL_CODE+'</postalCode>'+
                                        '<country>'+BILLING_COUNTRY+'</country>';
                                        if(PHONE_NUMBER !=Null)
                                            SOAPrequestBody = SOAPrequestBody +'<phoneNumber>'+PHONE_NUMBER+'</phoneNumber>';
                                        if(Email!=Null)
                                            SOAPrequestBody = SOAPrequestBody +'<email>'+Email+'</email>';
                                            
                                    SOAPrequestBody = SOAPrequestBody +'</billTo>'+
                                    '<purchaseTotals>'+
                                        '<currency>'+invoiceToUpdate[0].ccrz__CurrencyCode__c+'</currency>'+
                                        '<grandTotalAmount>'+transactionPayment[0].ccrz__Amount__c+'</grandTotalAmount>'+
                                    '</purchaseTotals>'+                                    
                                    '<recurringSubscriptionInfo>'+
                                        '<subscriptionID>'+transactionPayment[0].ccrz__Token__c+'</subscriptionID>'+
                                    '</recurringSubscriptionInfo>'+
                                    '<ccAuthService run="true" />'+
                               '</requestMessage>'+
                            '</soapenv:Body>'+
                            '</soapenv:Envelope>';
            
        }else{//this is for normal orders
            SOAPrequestBody='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header>' +
                            '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" soapenv:mustUnderstand="1">'+
                            '<wsse:UsernameToken><wsse:Username>'+connectionDetails.SCP_Key_Client_Id__c+'</wsse:Username>'+
                            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+SOAP_PASSWORD+'</wsse:Password>'
                            +'</wsse:UsernameToken></wsse:Security></soapenv:Header><soapenv:Body><requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.147">' +
                            '<merchantID>'+connectionDetails.SCP_Key_Client_Id__c+'</merchantID><merchantReferenceCode>'+invoiceToUpdate[0].ccrz__InvoiceId__c+'</merchantReferenceCode>' +
                           
                            '<billTo><firstName>'+FIRST_NAME+'</firstName><lastName>'+LAST_NAME+'</lastName><street1>'+BILLING_STREET+'</street1><city>'+BILLING_CITY+'</city><state>'+BILLING_STATE+'</state><postalCode>'+BILLING_POSTAL_CODE+'</postalCode><country>'+BILLING_COUNTRY+'</country>';
            if(PHONE_NUMBER !=Null)
                SOAPrequestBody = SOAPrequestBody +='<phoneNumber>'+PHONE_NUMBER+'</phoneNumber>';
            if(Email!=Null)
                SOAPrequestBody = SOAPrequestBody +='<email>'+Email+'</email>';
   
            SOAPrequestBody = SOAPrequestBody += '</billTo>' +'<purchaseTotals><currency>'+invoiceToUpdate[0].ccrz__CurrencyCode__c+'</currency>' +
                            '<grandTotalAmount>'+transactionPayment[0].ccrz__Amount__c+'</grandTotalAmount></purchaseTotals><ccCaptureService run="true">'+
                            '<authRequestID>'+transactionPayment[0].ccrz__VerificationCode__c+'</authRequestID><authRequestToken>'+transactionPayment[0].ccrz__Token__c+'</authRequestToken>'+
                            '<sequence>' +invCount.size()+ '</sequence><totalCount>99</totalCount>' +
                            '</ccCaptureService></requestMessage></soapenv:Body></soapenv:Envelope>' ;
        }
        if(!String.isEmpty(SOAPrequestBody)){
            
            request.setEndpoint(connectionDetails.SCP_End_Point__c);
            request.setMethod(connectionDetails.SCP_Method_Type__c);
            request.setHeader( 'user-agent', 'Mozilla/5.0' );  
            request.setHeader( 'Content-type', 'application/x-www-form-urlencoded' );
            request.setBody(SOAPrequestBody);  
           
            SYSTEM.DEBUG('###REQUEST -- '+REQUEST );
            SYSTEM.DEBUG('###REQUEST-- '+REQUEST.getBody());
                                                                           
            http http = new http();
            if(!Test.isRunningTest()){
                response = http.send(request);   
            }else{
                HttpResponse rsp=new HttpResponse();
                rsp.setStatusCode(200);
                rsp.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><wsu:Timestamp xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="Timestamp-1639083282"><wsu:Created>2021-03-15T01:00:29.650Z</wsu:Created></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><c:replyMessage xmlns:c="urn:schemas-cybersource-com:transaction-data-1.147"><c:merchantReferenceCode>I-0000000081</c:merchantReferenceCode><c:requestID>6157700293926835303009</c:requestID><c:decision>ACCEPT</c:decision><c:reasonCode>100</c:reasonCode><c:requestToken>Axj//wSTTc9CEG6bdbJhABsQ3bNWTFu2YKI4fQ10UAVEcPobL2aQTm4nCGMMmkj1YhkbyJBg/k03PM5ySPhF0xQAgjBt</c:requestToken><c:purchaseTotals><c:currency>USD</c:currency></c:purchaseTotals><c:ccCaptureReply><c:reasonCode>100</c:reasonCode><c:requestDateTime>2021-03-15T01:00:29Z</c:requestDateTime><c:amount>3185.42</c:amount><c:reconciliationID>76521760</c:reconciliationID></c:ccCaptureReply></c:replyMessage></soap:Body></soap:Envelope>');
                response=rsp;
            }
            
            SYSTEM.DEBUG('###response-- '+response); 
            System.debug('Printing response Body'+response.getBody());
            
            if(String.isNotBlank(response.getBody()) && isChildOrder){
                DOM.Document doc= new DOM.Document();
                doc.load(response.getBody());
                
                Map<String, String> soapData = parseSubsSoapData(doc);
                if(soapData.get('decision') == 'ACCEPT') {
                    System.debug('requestToken-->'+soapData.get('requestToken'));
                    System.debug('requestId-->'+soapData.get('requestId'));
                    AUTHREQUESTID = soapData.get('requestId');
                    AUTHREQUESTTOKEN = soapData.get('requestToken');
                }
                //capture API for child order 
                if(AUTHREQUESTID != null && AUTHREQUESTTOKEN !=null){
                    
                    SOAPrequestBody = '<?xml version="1.0" encoding="UTF-8"?>'+
                                        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">'+
                                        '<soapenv:Header>'+
                                        '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'+
                                        '<wsse:UsernameToken>'+
                                        '<wsse:Username>'+connectionDetails.SCP_Key_Client_Id__c+'</wsse:Username>'+
                                        '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+SOAP_PASSWORD+'</wsse:Password>'+
                                        '</wsse:UsernameToken>'+
                                        '</wsse:Security>'+
                                        '</soapenv:Header>'+
                                        '<soapenv:Body>'+
                                        '<requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.147">'+        
                                        '<merchantID>'+connectionDetails.SCP_Key_Client_Id__c+'</merchantID>'+
                                        '<merchantReferenceCode>'+transactionPayment[0].id+'</merchantReferenceCode>'+  
                                        '<purchaseTotals>'+          
                                        '<currency>'+transactionPayment[0].ccrz__CurrencyISOCode__c+'</currency>' +       
                                        '<grandTotalAmount>'+transactionPayment[0].ccrz__Amount__c+'</grandTotalAmount>'+       
                                        '</purchaseTotals>'+      
                                        '<ccCaptureService run="true">'+         
                                        '<authRequestID>'+AUTHREQUESTID+'</authRequestID>'+
                                        '<authRequestToken>'+AUTHREQUESTTOKEN+'</authRequestToken>'+      
                                        '</ccCaptureService>'+    
                                        '</requestMessage>'+   
                                        '</soapenv:Body>'+
                                        '</soapenv:Envelope>';
                    
                    request.setBody(SOAPrequestBody);
                    http = new http();
                    if(!Test.isRunningTest()){
                        response = http.send(request);   
                    }else{
                        HttpResponse rsp=new HttpResponse();
                        rsp.setStatusCode(200);
                        rsp.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"><wsu:Timestamp xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" wsu:Id="Timestamp-1639083282"><wsu:Created>2021-03-15T01:00:29.650Z</wsu:Created></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><c:replyMessage xmlns:c="urn:schemas-cybersource-com:transaction-data-1.147"><c:merchantReferenceCode>I-0000000081</c:merchantReferenceCode><c:requestID>6157700293926835303009</c:requestID><c:decision>ACCEPT</c:decision><c:reasonCode>100</c:reasonCode><c:requestToken>Axj//wSTTc9CEG6bdbJhABsQ3bNWTFu2YKI4fQ10UAVEcPobL2aQTm4nCGMMmkj1YhkbyJBg/k03PM5ySPhF0xQAgjBt</c:requestToken><c:purchaseTotals><c:currency>USD</c:currency></c:purchaseTotals><c:ccCaptureReply><c:reasonCode>100</c:reasonCode><c:requestDateTime>2021-03-15T01:00:29Z</c:requestDateTime><c:amount>3185.42</c:amount><c:reconciliationID>76521760</c:reconciliationID></c:ccCaptureReply></c:replyMessage></soap:Body></soap:Envelope>');
                        response=rsp;
                    }
               if(String.isNotBlank(response.getBody())){
                DOM.Document doc1= new DOM.Document();
                doc1.load(response.getBody());

                Dom.XMLNode root= doc1.getRootElement();
                
                Dom.XMLNode level1=root.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
                System.debug('Printing level1 Child Elemtn'+level1);
                
                Dom.XMLNode level2=level1.getChildElement('replyMessage','urn:schemas-cybersource-com:transaction-data-1.147');
                System.debug('Printing the level 2 child element'+level2);
                
                Dom.XMLNode level3;
                if(level2.getChildElement('ccCaptureReply','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                    level3=level2.getChildElement('ccCaptureReply','urn:schemas-cybersource-com:transaction-data-1.147');
                    
                }else if(level2.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                    reasonCode=level2.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147').getText();
                }
                
                System.debug('Printing level3'+level3);
                if(level3!=null){
                    if(level3.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                    reasonCode=level3.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147').getText();
                    }
                    
                    if(level3.getChildElement('reconciliationID','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                        reconciliationID=level3.getChildElement('reconciliationID','urn:schemas-cybersource-com:transaction-data-1.147').getText();
                    }
                }  
           }
                    SYSTEM.DEBUG('###response-- '+response); 
                    System.debug('Printing response Body'+response.getBody());
               }
            
            }else if(String.isNotBlank(response.getBody())){
                DOM.Document doc= new DOM.Document();
                doc.load(response.getBody());

                Dom.XMLNode root= doc.getRootElement();
                
                Dom.XMLNode level1=root.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
                System.debug('Printing level1 Child Elemtn'+level1);
                
                Dom.XMLNode level2=level1.getChildElement('replyMessage','urn:schemas-cybersource-com:transaction-data-1.147');
                System.debug('Printing the level 2 child element'+level2);
                
                Dom.XMLNode level3;
                if(level2.getChildElement('ccCaptureReply','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                    level3=level2.getChildElement('ccCaptureReply','urn:schemas-cybersource-com:transaction-data-1.147');
                    
                }else if(level2.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                    reasonCode=level2.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147').getText();
                }
                
                System.debug('Printing level3'+level3);
                if(level3!=null){
                    if(level3.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                    reasonCode=level3.getChildElement('reasonCode','urn:schemas-cybersource-com:transaction-data-1.147').getText();
                    }
                    
                    if(level3.getChildElement('reconciliationID','urn:schemas-cybersource-com:transaction-data-1.147')!=null){
                        reconciliationID=level3.getChildElement('reconciliationID','urn:schemas-cybersource-com:transaction-data-1.147').getText();
                    }
                }  
           }
        }
        
        update transactionPayment;
        System.debug('Printing Reconciliation ID'+reconciliationID+' and the reason Code from the response'+reasonCode);
        if(String.isNotBlank(reconciliationID)&&String.isNotBlank(reasonCode)){
            if(reasonCode=='100'||reasonCode=='110'){
                invoiceToUpdate[0].SCP_ReconcillationID__c=reconciliationID;        
                invoiceToUpdate[0].ccrz__Status__c=CLOSED_STRING;
                invoiceToUpdate[0].ccrz__RemainingAmount__c=0;
             //   if(!invoiceItemsToUpdate.isEmpty()){
                    //for(ccrz__E_InvoiceItem__c invoiceItem: invoiceItemsToUpdate){
                     //   invoiceItem.ccrz__Status__c=CLOSED_STRING;
                      //  invoiceItemsToUpdate.add(invoiceItem);
                  //  }
                    //update invoiceItemsToUpdate;
              //  }
            }else{
                invoiceToUpdate[0].ccrz__Status__c=FAILED_STRING;
                invoiceToUpdate[0].SCP_Retry_Count__c=1;
                if(System.isBatch()){
                   invoiceToUpdate[0].SCP_Retry_Count__c++;
                }
            }
        }else{
              invoiceToUpdate[0].ccrz__Status__c=FAILED_STRING;
              invoiceToUpdate[0].SCP_Retry_Count__c=1;
              if(System.isBatch()){
                    invoiceToUpdate[0].SCP_Retry_Count__c++;
              }
        }
        invoiceToUpdate[0].OwnerId = transactionPayment[0].OwnerId;
        invoiceToUpdate[0].SCP_Request_From_CyberSource__c=response.getBody();
        invoiceToUpdate[0].SCP_Response_Code_From_CyberScource__c=reasonCode;
         new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Information('SCP_CyberSourceCaptureAPI','CyberSourceCaptureSOAP',invoiceId,'Status on Invoice is '+invoiceToUpdate[0].ccrz__Status__c+' and reconciliationId of Invoice is'+invoiceToUpdate[0].SCP_ReconcillationID__c,response.getBody(),SOAPrequestBody,string.valueof(response.getStatusCode())));
        
        Update invoiceToUpdate;
       
        break; //while 
            
        }catch(exception ex){
            
            // if static retry count >=1  while 
            
            Boolean isUpdateFailed=false;
            System.debug('Printing Exception from catch'+ex.getStackTraceString());
            System.debug('Printing retry count'+retrycount);
            if(!invoiceToUpdate.isEmpty()){
               invoiceToUpdate[0].ccrz__Status__c=FAILED_STRING;
               invoiceToUpdate[0].SCP_Retry_Count__c=1; 
               if(System.isBatch()){
                    invoiceToUpdate[0].SCP_Retry_Count__c++;
              }
            }
            retrycount++;
            // ravi m --below shuold be update --- karthik to check 
            //Change the below insert statement to Update since we need to update the exsisting invoice.
            Database.SaveResult[] srResult= Database.Update(invoiceToUpdate,false);
            for(Database.SaveResult sr:srResult){
                if(!sr.isSuccess()){ 
                    isUpdateFailed=True;
                }
            }
            
            
          new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_CyberSourceCaptureAPI','CyberSourceCaptureSOAP',invoiceId,response.getBody(),SOAPrequestBody,string.valueof(response.getStatusCode()),ex));
             
        }
    
        }
        
    }
    
    public static Map<String, String> parseSubsSoapData(DOM.Document doc) {
        Map<String, String> soapData = new Map<String, String>();
        try {
            dom.XMLNode envelope = doc.getRootElement();
            System.debug('envelope-->'+envelope);
            dom.XMLNode body = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            System.debug('body -->'+body);
            List<dom.XmlNode> nodeList = body.getChildElements();
            if (nodeList != null && nodeList.size() > 0) {
                dom.XMLNode reply = nodeList.get(0);
                String c = reply.getNamespaceFor('c');
                System.debug('c-->'+c);
                soapData.put('requestToken', reply.getChildElement('requestToken', c).getText());
                soapData.put('decision', reply.getChildElement('decision', c).getText());
                soapData.put('transactionCode', reply.getChildElement('reasonCode', c).getText());
                soapData.put('requestId', reply.getChildElement('requestID', c).getText());
                soapData.put('merchantReferenceCode', reply.getChildElement('merchantReferenceCode', c).getText());
                soapData.put('reasonCode', reply.getChildElement('reasonCode', c).getText());
                //soapData.put('invalidField', reply.getChildElement('invalidField', c).getText());
                //soapData.put('missingField', reply.getChildElement('missingField', c).getText());

                Dom.XmlNode ccCaptureReply = reply.getChildElement('ccCaptureReply', c);
                if (ccCaptureReply != null){
                    soapData.put('amount', ccCaptureReply.getChildElement('amount', c).getText());
                }

                dom.XMLNode subsc = reply.getChildElement('paySubscriptionCreateReply', c);
                if (subsc != null){
                    soapData.put('subscriptionId', subsc.getChildElement('subscriptionID', c).getText());
                }
            }
            System.debug('soapData-->'+soapData);
        }catch(Exception e){
            System.debug(e);
        }
        return soapData;
    }
    Public static String rePLaceSpecialChar(String replaceString){//Added for IBA-2226
        if(replaceString != '' && replaceString != null){//IBA-6252
        replaceString = replaceString.replaceAll('&', '&amp;');
        replaceString = replaceString.replaceAll('<', '&lt;');
        replaceString = replaceString.replaceAll('>', '&gt;');
        replaceString = replaceString.replaceAll('"', '&quot;');
        replaceString = replaceString.replaceAll('\'', '&apos;');
        }
        return replaceString; 
    }
}