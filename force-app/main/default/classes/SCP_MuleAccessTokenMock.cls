@isTest
global class SCP_MuleAccessTokenMock implements HttpCalloutMock {
    global Integer responseNumber = 0;
    
    global SCP_MuleAccessTokenMock(Integer resNumber){
        responseNumber = resNumber;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        if(responseNumber==1){
          res.setBody('{"access_token": "aH9UETv-m3Z6G3yMrqMDvh0ojgIgeg-8F6E7lrCX0jEj0opUkDAHbk6vY7uBeoUW_aP2GVDbObSrAo9Lzfnsaw","token_type": "Bearer","expires_in": 3600}');
        }
        
        res.setStatusCode(200);
        return res;
    }

}