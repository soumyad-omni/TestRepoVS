@isTest
global class C4CIntegrationMock implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"UUID": "ABC123112233"}');
        response.setStatusCode(200);
        return response; 
    }
}