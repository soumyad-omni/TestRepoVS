public with sharing class AccountIntegrationToC4C {
    @InvocableMethod(label='Send Account Udpates To C4C' description='Send the Account Data From Saleforce To C4C Via Mulesoft')
    public static void sendAccountInfoToC4c(List<Account> accounts){
        Set<id> accountIds = new Set<id>();
        for(Account acc : accounts){
            accountIds.add(acc.id);
        }
        List<Account> accountsData = [Select id,name,SAP_Customer_Number__c,C4C_Address_UUID__c from Account where id in:accountIds];
        for(Account acct:accountsData){
            sendAccoutDataToC4CCallout(acct.Id, acct.SAP_Customer_Number__c,acct.C4C_Address_UUID__c);
        }
    }
    //@future (callout=true)
    /*public static Account sendAccoutDataToC4C(Account acc, String SAPECCId){
        Id accId = acc.Id;
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        CreateC4CJsonRequest  accReqWrapper= new CreateC4CJsonRequest();
        SFToC4CAccountRequest wrapper = accReqWrapper.createRequestWrapper(accId,SAPECCId);
        String acctJSONData = System.JSON.serialize(wrapper, true);
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_ContactSFToCRM');
        String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
        String endpoint = c4cSettings.Mulesoft_Endpoint__c+'/Update';
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
            SFToC4CAccountRequest.AccountResponse resp = (SFToC4CAccountRequest.AccountResponse) System.JSON.deserialize(res.getBody(), SFToC4CAccountRequest.AccountResponse.class);
            if(resp != null){
                acc.C4C_Address_UUID__c = resp.UUID;
                acc.C4C_UUID__c = resp.UUID;
            }
        }
        return acc;
    }*/
    @future (callout=true)
    public static void sendAccoutDataToC4CCallout(Id accId,String SAPECCId, String c4cAddressUIID){
        //Id accId = acc.Id;
        C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
        CreateC4CJsonRequest  accReqWrapper= new CreateC4CJsonRequest();
        SFToC4CAccountRequest wrapper = accReqWrapper.createRequestWrapper(accId,SAPECCId);
        String acctJSONData = System.JSON.serialize(wrapper, true);
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_ContactSFToCRM');
        String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
        String endpoint = c4cSettings.Mulesoft_Endpoint__c+'/Update';
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
            SFToC4CAccountRequest.AccountResponse resp = (SFToC4CAccountRequest.AccountResponse) System.JSON.deserialize(res.getBody(), SFToC4CAccountRequest.AccountResponse.class);
            Account acc = new Account(Id = accId);
            if(resp != null && (c4cAddressUIID == null || c4cAddressUIID =='') ){
                acc.C4C_Address_UUID__c = resp.UUID;
                acc.C4C_UUID__c = resp.UUID;
            }
            acc.SyncToC4C__c = false;
            AccountTriggerHandler.TriggerDisabled = true;
            update acc;
        }
    }
}