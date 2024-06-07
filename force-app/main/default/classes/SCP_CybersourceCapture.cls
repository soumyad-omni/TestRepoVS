public class SCP_CybersourceCapture Implements Queueable,Database.AllowsCallouts {

    Public String TRANSACTIONPAYMENT_ID;
    Public String INVOICE_ID;
    
    Public SCP_CybersourceCapture(String TRANSACTIONPAYMENT_ID,String INVOICE_ID){
        this.TRANSACTIONPAYMENT_ID=TRANSACTIONPAYMENT_ID;
        this.INVOICE_ID=INVOICE_ID;
    }
    
    Public void execute(QueueableContext Context){
    
        sendCreditCardSettlementCaptureAPI(TRANSACTIONPAYMENT_ID,INVOICE_ID);
    }
  
    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String CREDIT_SETTLEMENT = 'SOAP_CyberSource_Credit_Card_Settlement';
     private static final String URL = 'https://ics2wstesta.ic3.com/commerce/1.x/transactionProcessor';
     private static final String REQUEST_NOT_SUCCESSFUL = 'Request was not succesful';
    private static final String REQUEST_CREDIT_MSG = 'requestCreditMsg';
    private static final String RESPONSE_CREDIT_MSG = 'responseCreditMsg';
    private static final String ACCEPT = 'ACCEPT';
    
    /** 
    * @description - this method will authorize cybersource using token
    * @param extTp - contains transaction payment details
    * @return Map<String, Object> - It contains requestId & requesttoken after successful authorization
    */
 /*   public static Map<String, Object> authorizePaymentUsingToken(ccrz__E_TransactionPayment__c extTP){
        Map<String, Object> authInfo = new Map<String, Object>();
        ccrz__E_ContactAddr__c billTo = new ccrz__E_ContactAddr__c();
        try{
            if(extTP!=null && extTP.ccrz__CCOrder__r!=null && extTP.ccrz__CCOrder__r.ccrz__BillTo__c!=null){
                billTo = [Select id,
                         ccrz__FirstName__c,
                         ccrz__LastName__c,
                         ccrz__AddressFirstline__c,
                         ccrz__AddressSecondline__c,
                         ccrz__City__c,
                         ccrz__State__c,
                         ccrz__PostalCode__c,
                         ccrz__Country__c,
                         ccrz__HomePhone__c,
                         ccrz__StateISOCode__c,
                         ccrz__DaytimePhone__c,
                         ccrz__Email__c 
                         FROM ccrz__E_ContactAddr__c
                         WHERE Id =: extTP.ccrz__CCOrder__r.ccrz__BillTo__c];
            }
            Map<String, String> soapRequestData = FLNACC_PaymentACHCtrl.buildSoapDataEXt(extTP, billTo);
            String soapRequestText = '';
            soapRequestText = FLNAS2U_SoapBuilder.buildEnvelope(SOAP_CYBERSOURCE_CREDITCARD_AUTH_SUB_PO, soapRequestData);
            authInfo.put(REQUEST_CREDIT_MSG ,soapRequestText);
            Map<String, String> headers = new Map<String, String> {
                'user-agent' => 'Mozilla/5.0',
                'Content-type' => 'application/xml'
            };
                
            //http callout for cybersource authorization 
            String xmlString = new FLNACC_WrapperHTTPCallout(URL, 'POST', headers, soapRequestText).buildRequest();
            
            authInfo.put(RESPONSE_CREDIT_MSG,xmlString);
            if(!xmlString.Equals(REQUEST_NOT_SUCCESSFUL)){
                Dom.Document domDoc = new Dom.Document();
                domDoc.load(xmlString);
                Map<String, String> soapData = FLNAS2U_ReProcessInvoiceController.parseSoapData(domDoc);
                if(soapData.get('decision') == ACCEPT) {
                    authInfo.put('requestToken',soapData.get('requestToken'));
                    authInfo.put('requestID',soapData.get('requestId'));
                }
                else{
                    extTP.ccrz__Token__c = soapData.get('requestToken');
                    extTP.ccrz__VerificationCode__c = soapData.get('requestId');
                    extTP.ccrz__TransactionCode__c  = soapData.get('decision');
                    extTP.ccrz__TransactionSubcode__c = soapData.get('reasonCode');
                    extTP.ccrz__TransactionTS__c = Datetime.now();
                    update extTP;
                    authInfo.put('decision',soapData.get('decision'));
                    authInfo.put('reasonCode',soapData.get('reasonCode'));
                }
            }
            else{
                SCN_LGR_LoggerManager.DBLogger.error(xmlString, soapRequestText, 'authorizePaymentUsingToken', 'FLNACC_ExternalCreditCardPaymentCtrl', String.valueOf(extTP.Id));
            }
        }
        catch(exception e){
            authInfo.put('responseCreditMsg',e.getMessage());
            SCN_LGR_LoggerManager.DBLogger.error(e.getMessage() + '\n' + e.getStackTraceString(), String.valueOf(e.getLineNumber()),'authorizePaymentUsingToken', 'FLNACC_ExternalCreditCardPaymentCtrl', String.valueOf(extTP.Id));
        }
        return authInfo;
    }
    
    */ 
    /** 
    * @description - this method will capture payment in cybersource 
    * @return Map<String, String> - It contains result which is response from cybersource
    */
    
     public static Map<String, String> buildSoapData(
            String requestId,
            String amount,
            String currencyIsoCode,
         string tpid
            ) {
        
        Map<String, String> soapData = new Map<String, String>();
        soapData.put('${GRAND_TOTAL_AMOUNT}', amount);
        soapData.put('${CURRENCY}', currencyIsoCode);
        soapData.put('${AUTHREQUESTID}', requestId);
        soapData.put('${MERCHANT_REFERENCE_CODE}', tpid);
        
        
            soapData.put('${USERNAME}', 'ravim');
            soapData.put('${MERCHANT_ID}', 'mckauto');
            soapData.put('${PASSWORD}', 'Myintegration99!');
        
        return soapData;
    }
     
     
     public static  VOID  sendCreditSettlementToCybersource(
                                                                          
                                                                       string tpid){
        Map<String, Object> paymentData = new Map<String, Object>();
        
             
            String soapRequestText =  '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header>' + 
'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" soapenv:mustUnderstand="1">'+
'<wsse:UsernameToken><wsse:Username>ravim</wsse:Username><wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">Myintegration99!</wsse:Password>' +
'</wsse:UsernameToken>  </wsse:Security> </soapenv:Header> <soapenv:Body> <requestMessage xmlns="urn:schemas-cybersource-com:transaction-data-1.147">' + 
'<merchantID>mckauto</merchantID><merchantReferenceCode>TIP001222</merchantReferenceCode><purchaseTotals><currency>USD</currency>' +
'<grandTotalAmount>9</grandTotalAmount></purchaseTotals><ccCaptureService run="true">'+
'<authRequestID>6144391035806235404006</authRequestID><authRequestToken>6144391035806235404006</authRequestToken>'+
'</ccCaptureService></requestMessage></soapenv:Body></soapenv:Envelope>' ;   
            
            Map<String, String> headers = new Map<String, String> {
                'user-agent' => 'Mozilla/5.0',
                'Content-type' => 'application/x-www-form-urlencoded'
            };
                
                HttpRequest request = new HTTPRequest();
        request.setEndpoint(URL);
        request.setMethod('POST');
       request.setHeader( 'user-agent', 'Mozilla/5.0' );   
            request.setHeader( 'Content-type', 'application/x-www-form-urlencoded' ); 
            request.setBody(soapRequestText);  
            
              SYSTEM.DEBUG('###REQUEST -- '+REQUEST ); 
               SYSTEM.DEBUG('###REQUEST-- '+REQUEST.getBody()); 
                                                                            
             http http = new http();
        HTTPResponse response = http.send(request);
            SYSTEM.DEBUG('###response-- '+response); 
        SYSTEM.DEBUG('###response BODY -- '+response.getBody()); 
          Map<string,Object> replyMessageMap = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
          Map<String,object> replyMap= (Map<String,Object>)replyMessageMap.get('reply');
          String reconsilationId= (String)replyMap.get('ccCaptureReply.reconciliationID');
          System.debug('Printing reconsilation ID'+reconsilationId);
        
    }
   
    
    //Method Added  on 02-28-2021
    Public static void sendCreditCardSettlementCaptureAPI(String transactionId,String invoiceId){
    
    system.debug('###   transactionId--'+ transactionId);
     system.debug('###   invoiceId--'+ invoiceId);
     String reconsilationId='';
     string  responseCreditMsg='';
     String FAILED_STRING='FAILED';
     String PAID_STRING='PAID';
     List<ccrz__E_Invoice__c>  invoiceToUpdateList=[SELECT id
                                    , SCP_ReconcillationID__c
                                    , ccrz__Status__c
                                    , SCP_Request_From_CyberSource__c
                                     FROM ccrz__E_Invoice__c
                                     WHERE id=:invoiceId AND ccrz__Status__c!=:FAILED_STRING AND ccrz__Status__c!=:PAID_STRING AND ccrz__Status__c!='CLOSED' LIMIT 1];
     System.debug('Printing the Invoice ID'+invoiceToUpdateList);
     try{
        Map<String,Object> result = new Map<String,Object>();
        ccrz__E_TransactionPayment__c tp = [SELECT ID ,ccrz__Storefront__c FROM ccrz__E_TransactionPayment__c WHERE ID =:transactionId];
        ccrz.ccContext czontext = new ccrz.ccContext();
        czontext.storefront = tp.ccrz__Storefront__c;
        ccrz.cc_CallContext.initContext(czontext);
        String   requestCreditMsg = 'Input Param : TransactionPayment:' + tp.Id + '-Ordeuu122:'  ;
        result = ccpgcs.ccApiCyberSource.txnCapture(new Map<String, Object> {
               ccrz.ccApi.API_VERSION => 8,
               ccpgcs.cc_pgcs_ApiConstants.LOGIC_DATA => new Map<String, Object> {
               ccpgcs.cc_pgcs_ApiConstants.CCRZ_V1_SFID => tp.Id
               }
           });
           system.debug('##non external --' + result);
                                   
          responseCreditMsg = JSON.serialize((Map<String,Object>)result.get('data'));
          Map<string,Object> replyMessageMap = (Map<String,object>)JSON.deserializeUntyped(responseCreditMsg);
          Map<String,object> replyMap= (Map<String,Object>)replyMessageMap.get('reply');
          System.debug('Prinitng replyMap'+replyMap);
          reconsilationId= (String)replyMap.get('ccCaptureReply.reconciliationID');
          System.debug('Printing reconsilation ID'+reconsilationId);
          
         
                                                             
          if(!invoiceToUpdateList.isEmpty()&&!String.isBlank(reconsilationId)){
             invoiceToUpdateList[0].SCP_ReconcillationID__c=reconsilationId;
             invoiceToUpdateList[0].ccrz__Status__c='PAID';
             
             Update invoiceToUpdateList;
          }else{
              //If we are not able to get reconsilation ID then , Invoice status will not be paid.
              //Updating the incoice Status is failed and re try count =1. and also update the 
              invoiceToUpdateList[0].SCP_Request_From_CyberSource__c=responseCreditMsg;
              invoiceToUpdateList[0].ccrz__Status__c=FAILED_STRING;
        }
       }catch(Exception ex){
           System.debug('Printing Exception message'+ex.getMessage());
           System.debug('Printing Exception Stack Trace String'+ex.getStackTraceString());
           if(!invoiceToUpdateList.isEmpty()){
               invoiceToUpdateList[0].ccrz__Status__c=FAILED_STRING;
               invoiceToUpdateList[0].SCP_Request_From_CyberSource__c=ex.getMessage();
               Update invoiceToUpdateList;
           }
           new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_CybersourceCapture','sendCreditCardSettlementCaptureAPI','Transaction Id :'+transactionId+'Invoice Id :'+invoiceId,responseCreditMsg,'TransactionData ID : '+transactionId,'400',ex));
        } 
       }
}