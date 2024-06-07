@isTest
global class MockCalloutResponse implements HttpCalloutMock {
    /*
	global class MockDcRestResponseGenerator implements System.HttpCalloutMock {
    global MockDcRestResponseGenerator() {

    }
    global System.HttpResponse respond(System.HttpRequest req) {
        return null;
    }
}
     */
    
    global MockCalloutResponse() {

    }
    //CreateAccountFromProspect

    // Implement this interface method
    global System.HTTPResponse respond(System.HttpRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        /*
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"type_x":"S"}');
        res.setStatusCode(200);
        return res;
        */
        return null;
        
    }
}