public class BluesightReportController {
    @future(callout=true)
    public static void BluesightReportCallout() {
        String endPoint;
        String errormsg =''; 
        String jsonstr ='';
        system.debug('Insight bluesight call');
        /* Date dateToday = Date.today();
String sMonth = String.valueof(dateToday.month());
String sDay = String.valueof(dateToday.day());
if(sMonth.length()==1){
sMonth = '0' + sMonth;
}
if(sDay.length()==1){
sDay = '0' + sDay;
}
String currentdate = String.valueof(dateToday.year()) + sMonth + sDay ;
List<CastIronIntegration__c> listCodes = CastIronIntegration__c.getAll().values();
if(listCodes.size() > 0){
endPoint = listCodes[0].BluesightReport_AppConnect_EndPoint__c;
*/
        // jsonstr='{"IV_CHG_DATE_FROM" :"'+currentdate+'","IV_CHG_DATE_TO" : "'+currentdate+'}'; 
        //  System.debug('ALH jsonstr='+jsonstr);  
        try{
            SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_Bluesight');
            endpoint =   connectionDetails.SCP_End_Point__c;
            String accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
            
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            
            req.setHeader('Authorization', 'Bearer '+accessToken);
            //  req.setHeader('Content-Type','application/json');
            //   req.setHeader('accept','application/json');
            //   req.setBody(jsonstr);
            req.setMethod(connectionDetails.SCP_Method_Type__c);
            req.setEndpoint(endpoint);
            req.setTimeout((Integer)connectionDetails.SCP_Timeout__c);
            system.debug('request'+req);
            HttpResponse res=h.send(req);
            if(res.getStatusCode() == 200){
                System.debug(res+'###123createresp');
                system.debug('res.getBody()..'+res.getBody());
                
            }
            if(res.getstatusCode() != 200){
                system.debug('errorbody..'+res.getBody());
                system.debug('errorstatus..'+res.getStatus());
                
                errormsg = res.getStatus();
                system.debug('errormsg..'+errormsg);
                if(errormsg!=null){
                    system.debug('callingclass..');
                    //ErrorLogging.IntegrationLog(errormsg, 'callOutMethod','App');
                }
                
            }  
        }  
        catch (Exception ex){
            System.debug('Error Occurred : ' + ex.getLineNumber()+ex.getMessage());
        } 
    }
}