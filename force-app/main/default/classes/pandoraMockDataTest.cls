@isTest
global class pandoraMockDataTest implements HttpCalloutMock {
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setStatusCode(200);
        
        if(req.getEndpoint().contains('https://login.salesforce.com/services/oauth2/token'))
        {
            res.setBody('{"instance_url":"www.omnicell.com","access_token":"1234"}');
        }
        else
        {
            res.setBody('{"records":[{"Id":"123","account":{"CSN__c":"10012"}}]}');
        }
        
        return res;
    }
}