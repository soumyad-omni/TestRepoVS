public with sharing class RelationIntegrationWithC4C {
    @InvocableMethod(label='Send Account and Contact Relationship To C4C' description='Send the Account and Contact Relationship From Saleforce To C4C Via Mulesoft')
    public static void sendAccountContactsRelationshipToC4c(List<Contact> contacts){
        System.debug('I am inside the sendAccountContactsRelationshipToC4c invocable Method');
        Set<id> contactIds = new Set<id>();
        for(Contact con : contacts){
            contactIds.add(con.id);
        }
        List<Contact> contactsData = [Select id,name,SAP_Contact_Number__c, account.SAP_Customer_Number__c from contact where id in:contactIds];
        for(Contact c:contactsData){
            System.debug('Calling the SendAccountContactRelationship with Parameters:'+c.account.SAP_Customer_Number__c+' And '+c.SAP_Contact_Number__c);
            SendAccountContactRelationship(c.account.SAP_Customer_Number__c,c.SAP_Contact_Number__c, c.Id);
        }
        
    }
    
    public static void sendRelationshipDataToC4C(List<Relationship__c> relations){
        for(Relationship__c rel:relations){
            sendRelationshipDataToC4C(rel.id);
        }
    }
    @future (callout=true)
    public static void sendRelationshipDataToC4C(Id relationshipId){
        List<Relationship__c> relations = [Select id,name,Primary_CSN__c,Secondary_CSN__c,Relationship__c from Relationship__c where id =:relationshipId];
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        CreateC4CRelationshipJsonRequest  RelReqWrapper= new CreateC4CRelationshipJsonRequest();
        SFToC4CRelationshipRequest wrapper = RelReqWrapper.createRelationshipRequestWrapper(relations);
        String acctJSONData = System.JSON.serialize(wrapper, true);
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_ContactSFToCRM');
        String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
        String endpoint = c4cSettings.Mulesoft_Endpoint__c+'/Relationship';
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        req.setBody(acctJSONData);
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        HttpResponse res=h.send(req);
        if(res.getstatusCode() == 200){
            System.debug(res+'###123createresp');
            system.debug('res.getBody()..'+res.getBody()+'..');
            system.debug('res.getStatus()..'+res.getStatus());
            /*String avgId = 'aEM230000008L3BGAU';
            Quote_Line_Average__c qla = [Select id,Request__c from Quote_Line_Average__c where Id = :avgId];
            qla.Request__c = acctJSONData;
            update qla;*/
        }
    }
    
    @future (callout=true)
    public static void SendAccountContactRelationship(String accountId, String SAPcontactId, Id contactId){
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
 		CreateC4CRelationshipJsonRequest  RelReqWrapper= new CreateC4CRelationshipJsonRequest();
        SFToC4CRelationshipRequest wrapper = RelReqWrapper.createContactRelationshipRequestWrapper(accountId,SAPcontactId);
        String acctJSONData = System.JSON.serialize(wrapper, true);
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_ContactSFToCRM');
        String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
        String endpoint = c4cSettings.Mulesoft_Endpoint__c+'/Relationship';
        Http h= new Http();
        HttpRequest req= new HttpRequest();
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        req.setBody(acctJSONData);
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        HttpResponse res=h.send(req);
        if(res.getstatusCode() == 200){
            System.debug(res+'###123createresp');
            system.debug('res.getBody()..'+res.getBody()+'..');
            system.debug('res.getStatus()..'+res.getStatus());
            ContactTriggerHandler.TriggerDisabled = true;
            Contact c = new Contact(id = contactId, Integrated_To_C4C__c = true);
            update c;
        }
    }
}