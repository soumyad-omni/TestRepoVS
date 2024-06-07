global class AccountIntegrationToC4CBatch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    global Database.queryLocator start(Database.BatchableContext bc){
        String accountsQuery = 'Select id,C4C_Address_UUID__c, C4C_UUID__c,SAP_Customer_Number__c from Account where C4C_Batch_Process_Status__c = \'Processing\'';
        return database.getQueryLocator(accountsQuery);
    }
    global void execute (Database.BatchableContext BC, List<Account> accountsToProcess){
        
        for(Account ac : accountsToProcess){
            C4C_Integration__c c4cSettings = C4C_Integration__c.getValues('C4CData');
            CreateC4CJsonRequest  accReqWrapper= new CreateC4CJsonRequest();
            SFToC4CAccountRequest wrapper = accReqWrapper.createRequestWrapper(ac.Id,ac.SAP_Customer_Number__c);
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
                
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    
}