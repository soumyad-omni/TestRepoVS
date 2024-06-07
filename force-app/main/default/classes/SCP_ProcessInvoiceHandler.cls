public class SCP_ProcessInvoiceHandler {
  
    	private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    	private static final String CREDIT_SETTLEMENT = 'SOAP_CyberSource_Credit_Card_Settlement';
    	//private static String URL = 'https://ics2wstesta.ic3.com/commerce/1.x/transactionProcessor';
        
     	public static  Map<String, Object> sendCreditSettlementToCybersource(ccrz__E_TransactionPayment__c  tp){
       	
        SCP_Integration_Details__c  connectionDetails = [select Id,SCP_End_Point__c,SCP_Key_Client_Id__c,SCP_Password_Client_Secret__c from SCP_Integration_Details__c where name='SCP_Cybersource_Capture'];
        String URL = connectionDetails.SCP_End_Point__c;
        String clientKey = connectionDetails.SCP_Key_Client_Id__c;
        String password  = connectionDetails.SCP_Password_Client_Secret__c;	
        
        Map<String, Object> paymentData = new Map<String, Object>();
       	system.debug('##sendCreditSettlementToCybersource ');
        
       	Map<String, String> soapRequestData = NEW Map<String, String>();
        soapRequestData.put('${GRAND_TOTAL_AMOUNT}', '10');
        soapRequestData.put('${CURRENCY}', 'USD');
        soapRequestData.put('${AUTHREQUESTID}', tp.ccrz__VerificationCode__c);
        soapRequestData.put('${MERCHANT_REFERENCE_CODE}', 'RMATtp');
         soapRequestData.put('${AUTHREQUESTTOKEN}', tp.ccrz__Token__c);
         soapRequestData.put('${USERNAME}', 'ravim'  );
         soapRequestData.put('${MERCHANT_ID}', clientKey);
         soapRequestData.put('${PASSWORD}',password);
         system.debug('### soapRequestText SETTLE --'+soapRequestData);    
         String soapRequestText = scp_SoapBuilder.buildEnvelope(CREDIT_SETTLEMENT, soapRequestData);
                                                                            
         system.debug('### soapRequestText SETTLE 1 eneveloper  --'+soapRequestText); 
            
        HttpRequest req = new HttpRequest();
        req.setEndPoint(URL);
        req.setMethod('POST');
        req.setHeader('user-agent', 'Mozilla/5.0');
        req.setheader('content-type', 'application/x-www-form-urlencoded');
        req.SetBody(soapRequestText);

        Http http = new Http();
        HTTPResponse res = http.send(req);
    
       	system.debug('## xmlString--'+RES.getBody());
       
        
        return paymentData;
    }
         
}