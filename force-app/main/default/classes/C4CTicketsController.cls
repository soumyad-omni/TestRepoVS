public with sharing class C4CTicketsController {
    @AuraEnabled
    public static SAPC4CTickets_AppConnect getTickets(Id recordId) {
        List<Account> accs = [SELECT SAP_Customer_Number__c FROM Account WHERE Id =:recordId];
        String customerNumber = accs.size() > 0 && String.isNotBlank(accs[0].SAP_Customer_Number__c) && String.isNotEmpty(accs[0].SAP_Customer_Number__c) ? accs[0].SAP_Customer_Number__c : '';
        String ReportedOnDate = String.valueOf(json.serialize(Datetime.now().addMonths(-18)));
        ReportedOnDate = ReportedOnDate.replaceAll('\"', '');
        //Commented this Overcast code for SF-BUG-957
       /* if(String.isBlank(customerNumber) || String.isEmpty(customerNumber)) return new SAPC4CTickets();
        
        //Define the selection query
        overcast.Query q = new overcast.Query();
        q.limit_x = 201;
        overcast.Predicate p = new overcast.Predicate('', overcast.Predicate.FilterType.AND1, '');
        List<overcast.Predicate> sp = new List<overcast.Predicate>();
        sp.add(new overcast.Predicate('CustomerID', overcast.Predicate.FilterType.EQUALS, customerNumber));
        sp.add(new  overcast.Predicate('ReportedOnDate', overcast.Predicate.FilterType.GREATER_THAN_OR_EQUAL_TO, String.valueOf(Datetime.now().addMonths(-18))));
        p.subFilters = sp;
        q.where_x = p;
        
        System.debug('filter...' +sp);*/
        
        //957 Start
        try{
            String responseString = '';
            String errormsg = '';
            Map<String, Object> jsondata = new Map<String, Object>{
                'CustomerID' => customerNumber,
                'ReportedOnDate' => ReportedOnDate};
             
             String jsonstring = JSON.serialize(jsondata);
             System.debug('rj........' +jsonstring);
            // CastIronIntegration__c CI = CastIronIntegration__c.getInstance('CastIronIntegration');
            // String endpoint =   CI.C4CServiceTicketAppConnect_Endpoint__c;
             SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_C4CTickets');
             String endpoint =   connectionDetails.SCP_End_Point__c;
             String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
            
             Http h= new Http();
             HttpRequest req= new HttpRequest();
            
             req.setHeader('Authorization', 'Bearer '+accessToken);
             req.setHeader('Content-Type','application/json');
             req.setHeader('accept','application/json');
             req.setBody(jsonstring);
            system.debug('C4c body'+jsonstring);
             //req.setMethod('POST');
             req.setMethod(connectionDetails.SCP_Method_Type__c);
             req.setEndpoint(endpoint);
            // req.setTimeout(120000); 
             req.setTimeout((Integer)connectionDetails.SCP_Timeout__c);
            system.debug('C4C request'+req);
             HttpResponse res=h.send(req);
             responseString = res.getBody();
             System.debug('C4C responseString...' +responseString);
             if(res.getStatusCode() == 200){
                 system.debug('res.getBody()..'+res.getBody()); 
                 SAPC4CTickets_AppConnect response = SAPC4CTickets_AppConnect.deserialize(res.getBody());
                 return response;
                 
                }
            SAPC4CTickets_AppConnect response1 = new SAPC4CTickets_AppConnect();
            return response1;
            
         }catch (Exception ex){
             System.debug('Error Occurred : ' + ex.getMessage());
            SAPC4CTickets_AppConnect response2 = new SAPC4CTickets_AppConnect();
            return response2;
        } 
        //957 End
        
        //Commented this Overcast code for SF-BUG-957
        //Instantiate and execute the request
        //SAPC4CTickets request = new SAPC4CTickets();
        //System.debug('********'+q);
        //return Test.isRunningTest() ? null : request.runQuery(q);
        //return request;
    }
}