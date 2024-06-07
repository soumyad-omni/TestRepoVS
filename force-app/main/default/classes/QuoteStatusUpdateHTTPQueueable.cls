//IBA-4846 Change AC - New Queueable Class
public class QuoteStatusUpdateHTTPQueueable implements Queueable, Database.AllowsCallouts {
    Public List<Quote> quotelist;
    String quoteId;
    public QuoteStatusUpdateHTTPQueueable(List<Quote> quotelist, String quoteId) {
        this.quotelist = quotelist;
        this.quoteId = quoteId;
    }
    public class QuoteSyncCheck {
        public String QuoteNo { get; set; }
        public String RevisionNo { get; set; }
        public Double ItemCount { get; set; }
    }
    public void execute(QueueableContext context) {
        Boolean isHttpCalloutSuccessful = false;
        if(String.isNotBlank(quoteId)) {
            isHttpCalloutSuccessful = performHttpCallout(quoteId);
        }
        String recipientEmail = System.Label.Recipient_Email_Label;
        List<String> emailList = recipientEmail.split(';');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(emailList);
        if (isHttpCalloutSuccessful) {
            // Start of IBA-5802 changes
            List<Quote_Cancel_Status__c> insQtList = new List<Quote_Cancel_Status__c>();
            for(quote qtn : quotelist){
                Quote_Cancel_Status__c qtupd = new Quote_Cancel_Status__c();
                    qtupd.QuoteId__c = qtn.Id;
                    qtupd.Status__c = '';
                    qtupd.Updated_Date__c = System.Today();
                    insQtList.add(qtupd);
            }
            Database.SaveResult[] srList = Database.insert(insQtList, false);
            // End of IBA-5802 changes

            if(!Test.isRunningTest()) {
                system.enqueueJob(new QuoteStatusUpdateQueueable(quotelist));
            }
        } else {
            System.debug('Sync between system check failed. Will proceed no furthur.');
            email.setSubject('Sync-up check failed.');
            email.setPlainTextBody('Sync between SFDC and SAP failed. Failed to start the quote Cancel weekly queueable job.');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
    private Boolean performHttpCallout(String quoteId) {
        Boolean response1 = false;
        CastIronIntegration__c csValue1 = [Select Print_Compare_End_Point__c FROM CastIronIntegration__c Where Name = 'CastIronIntegration' LIMIT 1];
        String url = csValue1.Print_Compare_End_Point__c;
        List<Quote> qtList = [SELECT Id, Quote_Revision__c, Quote_Number__c FROM Quote WHERE Id = :quoteId LIMIT 1];
        if (!qtList.isEmpty()) {
            Quote qt = qtList[0];
            string quotenumber = qt.Quote_Number__c;
            Map<String, Object> jsondata = new Map<String, Object> {'Quote_Number__c' => quotenumber};
                String jsonstrinsert = JSON.serialize(jsondata);
            Integer timeout = 120000;
            Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT id FROM Quote_Line__c WHERE Quote__r.Id = :quoteId]);
            Http h2 = new Http();
            HttpRequest req2 = new HttpRequest();
            req2.setHeader('Content-Type', 'application/json');
            req2.setHeader('accept', 'application/json');
            req2.setBody(jsonstrinsert);
            req2.setMethod('POST');
            req2.setEndpoint(url);
            req2.setTimeout(timeout);
            try{
                HttpResponse res2 = h2.send(req2);
                System.debug(res2 + '###123createresp');
                system.debug('res2.getBody()..' + res2.getBody().replace('[', ''));
                if (res2.getStatusCode() == 200) {
                    String resbody = res2.getBody().replace('[', '');
                    try{
                        QuoteSyncCheck frmjson = new QuoteSyncCheck();
                        frmjson = (QuoteSyncCheck) System.JSON.deserialize(resbody.replace(']', ''), QuoteSyncCheck.class);
                        Double sapcount = frmjson.ItemCount;
                        String sapRevNum;
                        if (frmjson.RevisionNo != null) {
                            response1 = true;
                        }
                    } catch (Exception e) {
                        System.debug('Error deserializing JSON response: ' + e.getMessage());
                    }
                }
            } catch (System.CalloutException ex) {
                System.debug('HTTP callout Excetion: ' + ex.getMessage());
                response1 = false;
            }
        }
        return response1;
    }
}