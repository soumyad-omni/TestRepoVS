@istest
public class SCP_CybersourceCapture_Res_Parser_Test {
    
    @istest
    Public static void SCP_CybersourceCapture_Res_Parser_TestMethod(){
        String jsonAttr = '{"type":"Z","url":"google.com","test":"consumeObj"}';
        String jsonStr = '{"reply":{"card.cardType":"cctype","ccCaptureReply.reconciliationID":"capReply","ccCaptureReply.amount":"1000","ccCaptureReply.reasonCode":"505","ccAuthReply.ownerMerchantID":"777","ccAuthReply.paymentNetworkTransactionID":"45688","ccAuthReply.authRecord":"1233","ccAuthReply.reconciliationID":"45322","ccAuthReply.processorResponse":"78900","ccAuthReply.authorizedDateTime":"11111995","ccAuthReply.avsCodeRaw":"test434","ccAuthReply.avsCode":"4334","ccAuthReply.authorizationCode":"59987","ccAuthReply.amount":"50000","ccAuthReply.reasonCode":"567","purchaseTotals.currency":"USD","requestToken":"6788","reasonCode":"7800","decision":"Yes","requestID":"1111","merchantReferenceCode":"345","ccCaptureReply.requestDateTime":"04042021"},"body":"test123","sfid":"test123"}';
        Test.startTest();
        SCP_CybersourceCapture_Res_Parser.parse(jsonStr);
        SCP_CybersourceCapture_Res_Parser.Attributes attrObj = new SCP_CybersourceCapture_Res_Parser.Attributes(System.JSON.createParser(jsonAttr));
        Test.stopTest();
    }

}