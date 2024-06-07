/**
 * @File Name          : netValue_compare.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 07-14-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    26/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class netValue_compare {

    @AuraEnabled
    public static boolean getvalue(string key) {
        boolean val = false;
        Map<Integer, Map<String, Object>> myMaps = new Map<Integer, Map<String, Object>>();
        Map<string, object> maps = new Map<String,Object>();
        Quote qt = [select id, Quote_Number__c, SAP_Sales_Order_Number__c, SAP_Expected_Bookings__c, Net_Value_Match__c, NetValue_isClicked__c from Quote where ID =:key];
        string quotenumber = qt.Quote_Number__c;
        string salesordr = qt.SAP_Sales_Order_Number__c;
        Map<String, Object> jdata = new Map<String, Object> {'Quote_Number__c' => quotenumber, 'SAP_Sales_Order_Number__c' => salesordr};
        String jsonstrinsert = JSON.serialize(jdata);
        
        try
                {
        string comp = 'CastIronIntegration';
        
        string endpoint = '';
        list<CastIronIntegration__c> cstint = [select Net_Value_endpoint__c from CastIronIntegration__c limit 1];
        for(CastIronIntegration__c c:cstint){
           endPoint = c.Net_Value_endpoint__c;
        }
        Integer timeout = 120000;
        Http h2= new Http();
        HttpRequest req2= new HttpRequest();
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept','application/json');
        system.debug('sending json for creating quote line: ' + jsonstrinsert); 
        req2.setBody(jsonstrinsert);
        req2.setMethod('POST');
        req2.setEndpoint(endPoint);
        req2.setTimeout(timeout); 
        HttpResponse res=h2.send(req2);
        System.debug('res	'+res);
        system.debug('res.getBody()..	'+res.getBody());        
            decimal netValue = 0.0;
            string curr = '';
            decimal ex_rate = 0.0;
            decimal net = 0.0;
            decimal usdval = 0.0;
            string netval2 = '';
        
        if(res.getStatusCode() == 200){
            val = true;
            qt.NetValue_isClicked__c = true;
            list<object> des = (list<Object>)JSON.deserializeUntyped(res.getBody());
            if(des != null){ 
                for(Integer i=0;i<des.size();i++){
                    myMaps.put(i, (Map<String, Object>)des[i]);
                    system.debug('myMaps: '+myMaps);
                    
                        maps = myMaps.get(i);
                        netValue = (decimal)maps.get('NET_VAL_HD');
                        curr = (string)maps.get('CURRENCY');
                        ex_rate = (decimal)maps.get('EXCHG_RATE_V');
                           
                        if(curr == 'USD'){
                            qt.Net_Value_Match__c = netvalue.setScale(2);
                            system.debug('net	'+netvalue.setScale(2));
                        }else{
                            net = netvalue.setScale(2);
                            usdval = net/ex_rate;
                            qt.Net_Value_Match__c = usdval.setScale(2);
                        }
                        
                        if(curr != 'USD'){
                            netval2 = curr + ' ' + netvalue.setScale(2);
                            qt.Currency_Net_Value__c = netval2;
                        }else{
                            qt.Currency_Net_Value__c = ' ';
                        }
                    }
                } 
            
            QuoteTriggerHandler.TriggerDisabled = true;
            update qt;
        }
    }catch(Exception e){
                  System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                  ErrorLogging.Log(e, 'callOutMethodUpdate','App');
                }
        return val;
    }
    
    @AuraEnabled
    public static boolean isrendered(string key){
        boolean val;
        list<Quote> qt = new list<Quote>();
        
        qt = [select id,Status,SAP_Sales_Order_Number__c from Quote WHERE Id=:key];       
        val = false;
        //IBA-1702 advanced services - added E0024
        if (qt[0].Status == 'E0013' || qt[0].Status == 'E0014' || qt[0].Status == 'E0019' || qt[0].Status == 'E0023' || qt[0].Status == 'E0024'){
            if(qt[0].SAP_Sales_Order_Number__c != null){
                val = true;
            }
            
        }
        system.debug('val	'+val);
        return val;
       
   }
    
}