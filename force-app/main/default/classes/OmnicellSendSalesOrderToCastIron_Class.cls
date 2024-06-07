/**********************************************************************
Name:  OmnicellSendSalesOrderToCastIron_Class
Copyright © 2018
======================================================
======================================================
Purpose: 
Once Quote.Status=Booked via lightning component 'Create Sales Order' button gets enabled.After clicking button,pass Quote Number/Status/Create Sales Order through CastIron to SAP.                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                  Description
0.1          Amruta Dhumal         08/10/2018            Developed by CG Team    INITIAL DEVELOPMENT
***********************************************************************/

global class OmnicellSendSalesOrderToCastIron_Class{
    
    
    /* @AuraEnabled
public static void updateCheck(Id quoteId){

system.debug('method 1...');
List<Quote> quotelist = new List<Quote>([select id,Create_Sales_Order__c from Quote where Id =:quoteId]);
List<Quote> updatequotelist = new List<Quote>();

for (Quote qte : quotelist)
{
Quote q =new Quote();
q.id = qte.id;
q.Create_Sales_Order__c = true;

updatequotelist.add(q);

}
try{
//update updatequotelist;

}
catch(Exception e){
System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
ErrorLogging.Log(e, 'updateCheck','App');
}
callOutMethod(quoteId);

}*/        
    //IBA-2225 Abhrajitc Start
    @AuraEnabled
    public static boolean getquotedetails(Id quoteId){
        List<ID> userId = new List<ID>();
        User us = [select id,User_ID__c,Name from User where Name Like 'Admin Integration' limit 1];
        if (us.User_ID__c != null) {
            userId.add(us.User_ID__c);
            System.debug('Userid :::::' +userId);
        }
        system.debug('Quote ID: '+ quoteId);
        List<Quote> qf = [SELECT Id, Status, ECC_Sales_Order_Number__c, LastModifiedById FROM Quote where Id =: quoteId AND ECC_Sales_Order_Number__c = null AND (Status = 'E0013' OR Status = 'E0023'OR Status = 'E0019' OR Status = 'E0024') AND LastModifiedById =: userId];
        System.debug('Size:' +qf.size());
        if(qf != null && qf.size()>0){
            System.debug('Condition True');
            return true;
            
        }else{
            System.debug('Condition False');
            return false;
            
        }
    } 
    //IBA-2225 End
    //@Future(callout=true)
    @AuraEnabled
    public static void callOutMethod(Id quoteId){
        
        system.debug('method 2...');
        
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        
        String endpoint = csValue1.QuoteHeaderUpdateEndpoint__c; 
        
        
        String quotename='';
        String jsonstr ='';
        String qteid ='';
        String SapQuoteNumber = '';
        Id templateId;
        String errormsg =''; 
        
        // Fetch email templateid 
        templateId = [select id, name from EmailTemplate where developername = 'SalesOrderCreated_in_SAP'].id;
        
        
        Quote [] quoteList = [SELECT Id,OwnerId,Name,Create_Sales_Order__c,Status,Opportunity_Owner__c, Order_Type__c,Quote_Number__c,LineItemCount,Master_Agreement__c,Lease_Duration__c,Free_Month_for_Lease__c,Service_Duration__c,Free_Month_Service__c,Pricing_Reference_Date__c,IDN_Price_List__c,GPO_Price_Lists__c,Incoterms_1__c,Shipping_Conditions__c,Sales_Org__c FROM Quote WHERE Id =:quoteId];
        
        
        if(quoteList.size()>0)
        {
            for( Quote qte : quoteList) 
            {
                quotename = qte.Name;
                qteid = qte.Id;
                
            }  
        }
        
        Quote q = [SELECT Id,OwnerId,Name,Opportunity_Owner__c,Associated_Sales_Order__c,Associated_Opportunity_Number__c,Early_Adopter_Flag__c,Opportunity_ID__c,Resident_Operator_Duration__c,Create_Sales_Order__c,Status,Order_Type__c,Quote_Number__c,LineItemCount,Master_Agreement__c,Lease_Duration__c,Free_Month_for_Lease__c,Service_Duration__c,Free_Month_Service__c,Pricing_Reference_Date__c,IDN_Price_List__c,GPO_Price_Lists__c,Incoterms_1__c,Shipping_Conditions__c,Sales_Org__c FROM Quote WHERE Id =:qteid];
        
        
        string status= q.Status != null ? q.Status : '';
        string quotenumber = q.Quote_Number__c != null ? q.Quote_Number__c : '';
        boolean theString = q.Create_Sales_Order__c;
        String createsales = (theString) ? '1' : '0';
        String salesOrder = q.Associated_Sales_Order__c != null ? q.Associated_Sales_Order__c : '';
        // String associateQuoteNumber = q.Associated_Opportunity_Number__c != null ? q.Associated_Opportunity_Number__c : '';
        String associatedOpportunityNumber = q.Associated_Opportunity_Number__c != null ? q.Associated_Opportunity_Number__c : '';
        String OpportunityId = q.Opportunity_ID__c != null ? q.Opportunity_ID__c : '';
        Boolean adopterFlag = q.Early_Adopter_Flag__c;
        Decimal residentOperator = q.Resident_Operator_Duration__c != null ? q.Resident_Operator_Duration__c : 0;
        try{
            
            if(q.Quote_Number__c!=null)
            {
                
                //jsonstr='{"SAP Quote Number" :"'+quotenumber+'","Status" : "'+status+'","Create Sales Order" : "'+createsales+'"}'; 
                jsonstr='{"SAP Quote Number" :"'+quotenumber+'","Status" : "'+status+'","Create Sales Order" : "1","Associated Opportunity Number" :"'+associatedOpportunityNumber+'","Opportunity ID" :"'+OpportunityId+'","Associated Sales Order":"'+salesOrder+'","Early Adopter Flag":'+adopterFlag+',"Resident Operator Duration":'+residentOperator+'}'; 
                System.debug('ALH jsonstr='+jsonstr);                 
            }
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            //req.setClientCertificateName('CastIronIntegration');
            req.setHeader('Content-Type','application/json');
            req.setHeader('accept','application/json');
            req.setBody(jsonstr);
            req.setMethod('POST');
            req.setTimeout(120000);
            req.setEndpoint(endPoint);
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
                    ErrorLogging.IntegrationLog(errormsg, 'callOutMethod','App');
                }
                
            }    
            
        }
        catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'callOutMethod','App');
        } 
        
        
    }
    
}