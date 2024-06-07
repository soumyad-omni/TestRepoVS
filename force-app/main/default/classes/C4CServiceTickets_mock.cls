@isTest(seeAllData=false)
global class C4CServiceTickets_mock implements HttpCalloutMock {
    
    public string isMockresponse;
    
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        
            res.setHeader('Content-Type','application/json');
            res.setBody('{"CustomerID":"10957","ReportedOnDate":"2020-03-31T11:27:17Z"}');
            res.setStatusCode(200);
       
        return res;
    }
}