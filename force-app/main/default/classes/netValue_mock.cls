@isTest(seeAllData=false)
global class netValue_mock implements HttpCalloutMock {
    public string isMockresponse;
    
    
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        
            res.setHeader('Content-Type','application/json');
            res.setBody('[{"NET_VAL_HD":134212.420000000,"CURRENCY":"USD","EXCHG_RATE_V":0.0}]');
            res.setStatusCode(200);
       
        return res;
    }

}