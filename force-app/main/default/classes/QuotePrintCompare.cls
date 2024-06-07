public class QuotePrintCompare {
    public class QuotePrintCompareJsonDes {
        public String QuoteNo{get; set;}
        public String RevisionNo{get; set;}
        public Double ItemCount{get; set;}
    }
    public class comparewrapper{
        @AuraEnabled public list<subcomparewrapper> lstsubcompare{get;set;}
        @AuraEnabled public string message{get;set;}
        @AuraEnabled public boolean isFieldmatch{get;set;}
        @AuraEnabled public string sapRev{get;set;} //IBA-1845
        
        
        public comparewrapper(list<subcomparewrapper> lstsubcompare, string message, boolean isFieldmatch,string sapRev){
            this.lstsubcompare = lstsubcompare;
            this.message=message;
            this.isFieldmatch = isFieldmatch;
            this.sapRev = sapRev; //IBA-1845
        }
    }
    
    public class subcomparewrapper{
        @AuraEnabled public string Source{get;set;}
        @AuraEnabled public string Product{get;set;}
        @AuraEnabled public string Qty{get;set;}
        @AuraEnabled public string Contract_List_Price{get;set;}
        @AuraEnabled public string Unit_Price{get;set;}
        @AuraEnabled public string Extended_Price{get;set;}
        @AuraEnabled public string Unit_Services{get;set;}
        @AuraEnabled public string Extended_Services{get;set;}
        @AuraEnabled public string isRenewal{get;set;}
        
        public subcomparewrapper(string Source, string Product, string Qty, string Contract_List_Price, string Unit_Price, string Extended_Price, string Unit_Services, String Extended_Services, string isRenewal){
            this.Source =Source;
            this.Product = Product;
            this.Qty=Qty;
            this.Contract_List_Price=Contract_List_Price;
            this.Unit_Price=Unit_Price;
            this.Extended_Price=Extended_Price;
            this.Unit_Services=Unit_Services;
            this.Extended_Services=Extended_Services;
            this.isRenewal=isRenewal;
        }
    }
    
    @AuraEnabled
    Public static comparewrapper compareQuoteLine(String recordID){
        
        Quote quot = [select id, name, Quote_Number__c from Quote where ID =:recordID];
        string saprevNum1 = ''; //IBA-1845 added saprevNum1
        string quotenumber = quot.Quote_Number__c;
        Map<String, Object> jsondata = new Map<String, Object> {'Quote_Number__c' => quotenumber};
            String jsonstrinsert = JSON.serialize(jsondata);
        final string comp_creds = 'CastIronIntegration';
        
        CastIronIntegration__c compCreds = CastIronIntegration__c.getInstance(comp_creds);
        //Compare_Integration_Creds__c compCreds = Compare_Integration_Creds__c.getInstance(comp_creds);
        system.debug(comp_creds+'@@@comp_creds'+compCreds +'@@@Compare_Integration_Creds__c');
        
        
        String EndPoint1 = compCreds.Print_Compare_End_Point__c;
        //Integer timeout = Integer.valueOf(compCreds.Timeout__c);
        Integer timeout = 120000;
        Map<Id, Quote_Line__c> qline = new Map<Id, Quote_Line__c>([SELECT id FROM Quote_Line__c WHERE Quote__r.Id =: recordID]);
        //system.debug('Total number of records in SFDC and SAP, SFDC : '+qline.size()+' SAP : '+Itemcount);
        double sfdcQuotelinecount = qline.size();
        List<subcomparewrapper> subcompwrap = new List<subcomparewrapper>();
        if(sfdcQuotelinecount > 0){
            Http h2= new Http();
            HttpRequest req2= new HttpRequest();
            req2.setHeader('Content-Type','application/json');
            req2.setHeader('accept','application/json');
            system.debug('sending json for creating quote line: ' + jsonstrinsert); 
            req2.setBody(jsonstrinsert);
            req2.setMethod('POST');
            req2.setEndpoint(EndPoint1);
            req2.setTimeout(timeout); 
            HttpResponse res2=h2.send(req2);
            System.debug(res2+'###123createresp');
            system.debug('res2.getBody()..'+res2.getBody().replace('[',''));
            String resbody = res2.getBody().replace('[','');
            String message = '';
            QuotePrintCompareJsonDes frmjson = new QuotePrintCompareJsonDes();
            frmjson = (QuotePrintCompareJsonDes)System.JSON.deserialize(resbody.replace(']',''), QuotePrintCompareJsonDes.class);
            Double sapcount = frmjson.ItemCount;
            String sapRevNum;
            if(frmjson.RevisionNo != null){
            	sapRevNum = (frmjson.RevisionNo).replace(' ','');
            }
            saprevNum1 = sapRevNum; //IBA-1845
            
            System.debug('sapcount : '+sapcount);
            System.debug('sapRevnum : '+sapRevNum);
            System.debug('Sfdccount : '+sfdcQuotelinecount);
            
            
            
            /*Map<String, Object> level1 = (Map<String, Object>)JSON.deserializeUntyped(res2.getBody());
//List<Object> level2list = (List<Object>) level1.get('Quote_Line__c');
string Itemcount = (string)level1.get('ItemCount');
if(Itemcount == null){
Itemcount = '0';
}*/
            //system.debug('Total no of records in SAP: '+level2list.size());
            Integer sapQuoteLinecount = 0;
            /*if(level2list != null){ //added by sravan on 23 AUG
sapQuoteLinecount = level2list.size();
}*/
            Boolean  isRevision = false;
            //Map<Id, Quote> quotemap = new Map<Id, Quote>([select id, name, Quote_Number__c,Quote_Revision__c  from Quote where ID =:recordID]);
            Quote qu = [select id, name, Quote_Number__c,Quote_Revision__c  from Quote where ID =:recordID];
            
            //for(Quote qu: quotemap.values()){
            System.debug('sfdcrevnum : '+qu.Quote_Revision__c);
            //System.debug('Revision num SAP : '+level1.get('RevisionNo')+'SFDC  :'+qu.Quote_Revision__c);
            if(qu.Quote_Revision__c ==sapRevnum){
                if(double.valueOf(sfdcQuotelinecount)==double.valueOf(sapcount)){
                    isRevision = true;
                }
                else if(sfdcQuotelinecount!=double.valueOf(sapcount)){
                    String errormsg = 'Quote lines are being synced from SAP. Refresh the page to try printing again after a few minutes.';
                    return new comparewrapper(subcompwrap,errormsg,false,saprevNum1); //IBA-1845 added saprevNum1
                }
            }
            else{
                message = 'Quote is being synced from SAP. Refresh the page to try printing again after a few minutes.';
            }
            //}
            comparewrapper compwrap;
            if(subcompwrap.isEmpty() && isRevision == true && (double.valueOf(sapcount)== double.valueOf(sfdcQuotelinecount))){
                //if(double.valueOf(Itemcount)== double.valueOf(sfdcQuotelinecount)){
                compwrap = new comparewrapper(subcompwrap, 'Quotes are Identical!',false,saprevNum1); //IBA-1845 added saprevNum1
                // }
                
            }else{
                compwrap = new comparewrapper(subcompwrap, message,true,saprevNum1);  //IBA-1845 added saprevNum1
            }
            return compwrap;
        }
        else{
            String errormsg = 'Quote does not have quote lines. If you have added products to the quote, they are currently being synced from SAP. Refresh the page to try printing again after a few minutes.';
            return new comparewrapper(subcompwrap, errormsg ,true,saprevNum1); //IBA-1845 added saprevNum1
        }
    }
    
}