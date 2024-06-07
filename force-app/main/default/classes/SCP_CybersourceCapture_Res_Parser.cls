public class SCP_CybersourceCapture_Res_Parser {

    public Reply reply {get;set;} 
    public String body {get;set;} 
   // public Pgcs_transactionPayment pgcs_transactionPayment {get;set;} 
    public String sfid {get;set;} 

    public SCP_CybersourceCapture_Res_Parser(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'reply') {
                        reply = new Reply(parser);
                    } else if (text == 'body') {
                        body = parser.getText();
                    } /*else if (text == 'pgcs_transactionPayment') {
                        pgcs_transactionPayment = new Pgcs_transactionPayment(parser);
                    }*/ else if (text == 'sfid') {
                        sfid = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'SCP_CybersourceCapture_Res_Parser consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Attributes {
        public String type_Z {get;set;} 
        public String url {get;set;} 

        public Attributes(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type_Z = parser.getText();
                        } else if (text == 'url') {
                            url = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Reply {
        public String card_cardType {get;set;} 
        public String ccCaptureReply_reconciliationID {get;set;} 
        public String ccCaptureReply_amount {get;set;} 
        public String ccCaptureReply_requestDateTime {get;set;} 
        public String ccCaptureReply_reasonCode {get;set;} 
        public String ccAuthReply_ownerMerchantID {get;set;} 
        public String ccAuthReply_paymentNetworkTransactionID {get;set;} 
        public String ccAuthReply_authRecord {get;set;} 
        public String ccAuthReply_reconciliationID {get;set;} 
        public String ccAuthReply_processorResponse {get;set;} 
        public String ccAuthReply_authorizedDateTime {get;set;} 
        public String ccAuthReply_avsCodeRaw {get;set;} 
        public String ccAuthReply_avsCode {get;set;} 
        public String ccAuthReply_authorizationCode {get;set;} 
        public String ccAuthReply_amount {get;set;} 
        public String ccAuthReply_reasonCode {get;set;} 
        public String purchaseTotals_currency {get;set;} 
        public String requestToken {get;set;} 
        public String reasonCode {get;set;} 
        public String decision {get;set;} 
        public String requestID {get;set;} 
        public String merchantReferenceCode {get;set;} 

        public Reply(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'card.cardType') {
                            card_cardType = parser.getText();
                        } else if (text == 'ccCaptureReply.reconciliationID') {
                            ccCaptureReply_reconciliationID = parser.getText();
                        } else if (text == 'ccCaptureReply.amount') {
                            ccCaptureReply_amount = parser.getText();
                        } else if (text == 'ccCaptureReply.requestDateTime') {
                            ccCaptureReply_requestDateTime = parser.getText();
                        } else if (text == 'ccCaptureReply.reasonCode') {
                            ccCaptureReply_reasonCode = parser.getText();
                        } else if (text == 'ccAuthReply.ownerMerchantID') {
                            ccAuthReply_ownerMerchantID = parser.getText();
                        } else if (text == 'ccAuthReply.paymentNetworkTransactionID') {
                            ccAuthReply_paymentNetworkTransactionID = parser.getText();
                        } else if (text == 'ccAuthReply.authRecord') {
                            ccAuthReply_authRecord = parser.getText();
                        } else if (text == 'ccAuthReply.reconciliationID') {
                            ccAuthReply_reconciliationID = parser.getText();
                        } else if (text == 'ccAuthReply.processorResponse') {
                            ccAuthReply_processorResponse = parser.getText();
                        } else if (text == 'ccAuthReply.authorizedDateTime') {
                            ccAuthReply_authorizedDateTime = parser.getText();
                        } else if (text == 'ccAuthReply.avsCodeRaw') {
                            ccAuthReply_avsCodeRaw = parser.getText();
                        } else if (text == 'ccAuthReply.avsCode') {
                            ccAuthReply_avsCode = parser.getText();
                        } else if (text == 'ccAuthReply.authorizationCode') {
                            ccAuthReply_authorizationCode = parser.getText();
                        } else if (text == 'ccAuthReply.amount') {
                            ccAuthReply_amount = parser.getText();
                        } else if (text == 'ccAuthReply.reasonCode') {
                            ccAuthReply_reasonCode = parser.getText();
                        } else if (text == 'purchaseTotals.currency') {
                            purchaseTotals_currency = parser.getText();
                        } else if (text == 'requestToken') {
                            requestToken = parser.getText();
                        } else if (text == 'reasonCode') {
                            reasonCode = parser.getText();
                        } else if (text == 'decision') {
                            decision = parser.getText();
                        } else if (text == 'requestID') {
                            requestID = parser.getText();
                        } else if (text == 'merchantReferenceCode') {
                            merchantReferenceCode = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Reply consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    /*public class Pgcs_transactionPayment {
        public Attributes attributes {get;set;} 
        public String ccrz__AccountNumber__c {get;set;} 
        public String ccrz__AccountType__c {get;set;} 
        public String ccrz__Account__c {get;set;} 
        public Double ccrz__Amount__c {get;set;} 
        public String ccrz__BillTo__c {get;set;} 
        public String ccrz__CCOrder__c {get;set;} 
        public String ccrz__Comments__c {get;set;} 
        public String ccrz__Contact__c {get;set;} 
        public String ccrz__CurrencyISOCode__c {get;set;} 
        public String OwnerId {get;set;} 
        public String ccrz__PaymentType__c {get;set;} 
        public Double ccrz__RequestAmount__c {get;set;} 
        public String ccrz__SoldTo__c {get;set;} 
        public String ccrz__Storefront__c {get;set;} 
        public String ccrz__SubAccountNumber__c {get;set;} 
        public String SystemModstamp {get;set;} 
        public String ccrz__Token__c {get;set;} 
        public String ccrz__TransactionCode__c {get;set;} 
        public Object ccrz__TransactionPaymentId__c {get;set;} 
        public String ccrz__TransactionSubcode__c {get;set;} 
        public String ccrz__TransactionTS__c {get;set;} 
        public String ccrz__TransactionType__c {get;set;} 
        public String ccrz__User__c {get;set;} 
        public String ccrz__VerificationCode__c {get;set;} 
        public String CurrencyIsoCode {get;set;} 
        public String ccrz__SourceTransactionPayment__c {get;set;} 
        public String Id {get;set;} 

        public Pgcs_transactionPayment(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'attributes') {
                            attributes = new Attributes(parser);
                        } else if (text == 'ccrz__AccountNumber__c') {
                            ccrz__AccountNumber__c = parser.getText();
                        } else if (text == 'ccrz__AccountType__c') {
                            ccrz__AccountType__c = parser.getText();
                        } else if (text == 'ccrz__Account__c') {
                            ccrz__Account__c = parser.getText();
                        } else if (text == 'ccrz__Amount__c') {
                            ccrz__Amount__c = parser.getDoubleValue();
                        } else if (text == 'ccrz__BillTo__c') {
                            ccrz__BillTo__c = parser.getText();
                        } else if (text == 'ccrz__CCOrder__c') {
                            ccrz__CCOrder__c = parser.getText();
                        } else if (text == 'ccrz__Comments__c') {
                            ccrz__Comments__c = parser.getText();
                        } else if (text == 'ccrz__Contact__c') {
                            ccrz__Contact__c = parser.getText();
                        } else if (text == 'ccrz__CurrencyISOCode__c') {
                            ccrz__CurrencyISOCode__c = parser.getText();
                        } else if (text == 'OwnerId') {
                            OwnerId = parser.getText();
                        } else if (text == 'ccrz__PaymentType__c') {
                            ccrz__PaymentType__c = parser.getText();
                        } else if (text == 'ccrz__RequestAmount__c') {
                            ccrz__RequestAmount__c = parser.getDoubleValue();
                        } else if (text == 'ccrz__SoldTo__c') {
                            ccrz__SoldTo__c = parser.getText();
                        } else if (text == 'ccrz__Storefront__c') {
                            ccrz__Storefront__c = parser.getText();
                        } else if (text == 'ccrz__SubAccountNumber__c') {
                            ccrz__SubAccountNumber__c = parser.getText();
                        } else if (text == 'SystemModstamp') {
                            SystemModstamp = parser.getText();
                        } else if (text == 'ccrz__Token__c') {
                            ccrz__Token__c = parser.getText();
                        } else if (text == 'ccrz__TransactionCode__c') {
                            ccrz__TransactionCode__c = parser.getText();
                        } else if (text == 'ccrz__TransactionPaymentId__c') {
                            ccrz__TransactionPaymentId__c = parser.readValueAs(Object.class);
                        } else if (text == 'ccrz__TransactionSubcode__c') {
                            ccrz__TransactionSubcode__c = parser.getText();
                        } else if (text == 'ccrz__TransactionTS__c') {
                            ccrz__TransactionTS__c = parser.getText();
                        } else if (text == 'ccrz__TransactionType__c') {
                            ccrz__TransactionType__c = parser.getText();
                        } else if (text == 'ccrz__User__c') {
                            ccrz__User__c = parser.getText();
                        } else if (text == 'ccrz__VerificationCode__c') {
                            ccrz__VerificationCode__c = parser.getText();
                        } else if (text == 'CurrencyIsoCode') {
                            CurrencyIsoCode = parser.getText();
                        } else if (text == 'ccrz__SourceTransactionPayment__c') {
                            ccrz__SourceTransactionPayment__c = parser.getText();
                        } else if (text == 'Id') {
                            Id = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Pgcs_transactionPayment consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }*/
    
    
    public static SCP_CybersourceCapture_Res_Parser parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new SCP_CybersourceCapture_Res_Parser(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}