public class ContactIntegrationToC4C {
    @InvocableMethod(label='Send Contact Updates To C4C' description='Send the Contact Information From Saleforce To C4C Via Mulesoft')
    public static void sendContactsToC4c(List<Contact> contacts){
        Set<Id> contactIDs = new Set<Id>();
        for(Contact con:contacts){
            contactIDs.add(con.Id);
        }
        List<Contact> cons = [Select id,name,C4CContactUUID__c from Contact Where id in:contactIDs];
        for(Contact con:cons){
            sendContactDataToC4C(con.id,con.C4CContactUUID__c);
        }
    }
    @future (callout=true)
    public static void sendContactDataToC4C(Id contactId,String contactUUID){
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        //SFToC4CContactRequest  contactReqWrapper= new SFToC4CContactRequest();
        SFToC4CAccountRequest wrapper = SFToC4CContactRequest.createRequestWrapper(contactId);
        String contactJSONData = System.JSON.serialize(wrapper, true);
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_ContactSFToCRM');
        String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
        String endpoint = c4cSettings.Mulesoft_Endpoint__c+'/Contact';
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        req.setBody(contactJSONData);
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        HttpResponse res=h.send(req);
        if(res.getstatusCode() == 200){
            System.debug(res+'###123createresp');
            system.debug('res.getBody()..'+res.getBody()+'..');
            system.debug('res.getStatus()..'+res.getStatus());
            SFToC4CAccountRequest.AccountResponse resp = (SFToC4CAccountRequest.AccountResponse) System.JSON.deserialize(res.getBody(), SFToC4CAccountRequest.AccountResponse.class);
            if(resp != null){ 
                if(contactUUID == null || contactUUID == ''){
                    Contact con = new Contact(id=contactId);
                    con.C4CContactUUID__c = resp.UUID;
                    ContactTriggerHandler.TriggerDisabled = true;
                    update con;
                }
                
            }
        }
        
    }

}