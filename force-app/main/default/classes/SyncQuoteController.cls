public class SyncQuoteController {

    public class QuotePrintCompareJsonDes {
        public String QuoteNo{get; set;}
        public String RevisionNo{get; set;}
        public Double ItemCount{get; set;}
    }
    
    @AuraEnabled
    public static void sendQuotetocastiron(Id qId){
        Set<Id> qIds = new Set<Id>();
        qIds.add(qId);
        Map<String,String> qtOrderTypechangeMap = new Map<String,String>();//IBA-3929 - Sourav - Start
        qtOrderTypechangeMap.put(qId,'0');
        OmnicellQuoteToCastIron_Class.callOutMethodUpdate(qIds,qtOrderTypechangeMap);//IBA-3929 - Sourav - End
    }
    @AuraEnabled
    public static boolean checkStatus(Id qId){
     
        Quote q = [select id,status from quote where id=:qId];
        if(q.status == 'E0014' || q.status == 'E0013' || q.status == 'E0019' || q.status == 'E0017')
            return true;
        else
            return false;
    }
    
    
    @AuraEnabled
    public static boolean checkfuturejob(Id qId){
        List<AsyncApexJob> a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email, ExtendedStatus
                          from AsyncApexJob where 
                          ApexClassId in (select id from ApexClass where name='OmnicellQuoteToCastIron_Class') 
                          and MethodName='callOutMethodUpdate' 
                          and createdbyid =:userinfo.getUserId()
                          order by createddate desc limit 1];
        if(a.size()>0){
        if(a[0].Status == 'Completed' || a[0].Status == 'Aborted' || a[0].Status == 'Failed')
            return false; 
        else
            return true;
        }
        else{
            return false;
        }
    }
    @AuraEnabled
    public static boolean getRevisionNum(Id qId){
			Quote q = [select id,Quote_Number__c,Quote_Revision__c,lastmodifieddate from quote where id=:qId limit 1];
            string quotenumber = q.Quote_Number__c;
            Integer timeout = 120000;
        	Map<String, Object> jsondata = new Map<String, Object> {'Quote_Number__c' => quotenumber};
            String jsonstrinsert = JSON.serialize(jsondata);
        	final string comp_creds = 'CastIronIntegration';
        	CastIronIntegration__c compCreds = CastIronIntegration__c.getInstance(comp_creds);
        	String EndPoint1 = compCreds.Print_Compare_End_Point__c;
        	Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            req2.setBody(jsonstrinsert);
            req2.setMethod('POST');
            req2.setEndpoint(EndPoint1);
            req2.setTimeout(timeout); 
            HttpResponse res2=h2.send(req2);
            String resbody = res2.getBody().replace('[','');
            String message = '';
            QuotePrintCompareJsonDes frmjson = new QuotePrintCompareJsonDes();
            frmjson = (QuotePrintCompareJsonDes)System.JSON.deserialize(resbody.replace(']',''), QuotePrintCompareJsonDes.class);
            String sapRevNum;
            if(frmjson.RevisionNo != null){
            	sapRevNum = (frmjson.RevisionNo).replace(' ','');
            }
            System.debug('rev num sfdc : '+q.Quote_Revision__c+' sap : '+saprevnum);
            if(q.Quote_Revision__c == sapRevNum)
            	return true;
            else if(q.Quote_Revision__c != sapRevNum && q.LastModifiedDate > System.now().addMinutes(-10))
                return true;
            else
                return false;
    }
}