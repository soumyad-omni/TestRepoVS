global class contactReportBatch_WS implements Database.Batchable<sobject>, Database.AllowsCallouts {
   
   global Database.Querylocator start (Database.BatchableContext BC) {
      return Database.getQueryLocator('SELECT id FROM contact limit 100');
   }
   
   
   global void execute (Database.BatchableContext BC, List<contact> scope) {
      	system.debug('inside ws');
       
       	string endpoint = '';
        list<CastIronIntegration__c> cstint = [select Contact_Report__c from CastIronIntegration__c limit 1];
        for(CastIronIntegration__c c:cstint){
           endPoint = c.Contact_Report__c;
        }
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('accept','application/json');
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setBody('[]');
        request.setTimeout(120000);
        Http h= new Http();
        HttpResponse response = h.send(request);
        
   }
   
   
   global void finish(Database.BatchableContext BC) {
      
   }
}