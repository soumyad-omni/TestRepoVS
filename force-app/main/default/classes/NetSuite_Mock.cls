@isTest
public with sharing class NetSuite_Mock implements HttpCalloutMock{
    public NetSuite_Mock() {
        
    }
    public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{ "SalesOrder_NetsuiteId": "4293", "LineItems_NetsuiteIds": [ { "sap_item_number" : 200, "NetsuiteId" : "1648" }, {"sap_item_number" : 400, "NetsuiteId" : "1646" }, { "sap_item_number" : 600, "NetsuiteId" : "1650" }] }');
        res.setStatusCode(201);   
        return res;
    }
}