/**********************************************************************
Name:  OmnicellQuoteLineToCastIron_Class
Copyright © 2018
======================================================
======================================================
Purpose: 
Once QuoteLine is created/updated,invoke REST api class to connect to CastIron.                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                  Description
0.1          Amruta Dhumal         31/8/2018            Developed by CG Team    INITIAL DEVELOPMENT
***********************************************************************/

global class OmnicellQuoteLineToCastIron_Class{
    
    //Created new method by Jay related with demo 
   public static string prepareDataForQuoteLineUpdate(string quotelineid, string quotelinename,Quote_Line__c ql )
   {        
        string quotenumber = ql.Quote__r.Quote_Number__c;
        string quote = ql.Quote__c;
        string createdby = ql.CreatedBy.Omnicell_Employee_Number__c;
        decimal discountpercent = ql.Discount_Percent__c;
        string lastmodifiedby = ql.LastModifiedBy.Omnicell_Employee_Number__c;
        //datetime lastmoddate = ql.LastModifiedDate;
        
        Datetime lastdte = ql.LastModifiedDate;
        string lastmoddate = Datetime.newInstance(lastdte.year(), lastdte.month(),lastdte.day()).format('YYYYMMdd');
        //String lastmoddate = dtlastdte.format('YYYYMMDD');
        System.debug(lastmoddate);
        
        string quoteid = ql.Quote__r.Id;
        
        string description = ql.Line_Item_Description__c;
        if(description == null)
        {
          description = '';
        }
        decimal listprice = ql.List_Price__c;
        string prod = ql.Product__r.ProductCode;
        System.debug('***** '+ prod);
        if(prod == null)
        {
          prod = '';
        }       
        decimal quantity = ql.Quantity__c;
        if(quantity == null)
        {
          quantity = 0;
        }
        System.debug('*****quantity '+ quantity);
        decimal discountamount = ql.Discount_Amount__c;
        //string unitmeasure = ql.Unit_of_Measure__c; && 'Unit of Measure' => unitmeasure, commented as part of IBA-3424
        if(quantity == null)
        {
          quantity = 0;
        }
        decimal custprice = ql.Customer_Price__c;
        decimal priceoverride = ql.Price_Override__c;
        string curr = ql.CurrencyIsoCode;
        decimal rebatebuyout = ql.Rebate_Buyout_Adjustment__c;
        
        decimal margin = ql.Margin__c;
        string parloc = ql.Par_Location__c;
        if(parloc == null)
        {
          parloc = '';
        }
        boolean extconfig = ql.External_Config__c;
        string picurl = ql.Picture_URL__c;
        //date reqdeliverydate = ql.Requested_Delivery_Date__c;
        
        
        string reqdeliverydate='';
        Date reqdte = ql.Requested_Delivery_Date__c;
        if(reqdte!=null){
        reqdeliverydate = Datetime.newInstance(reqdte.year(), reqdte.month(),reqdte.day()).format('YYYYMMdd');
        System.debug(reqdeliverydate); 
        }
        
        if(reqdeliverydate == null)
        {
          reqdeliverydate = '';
        }
        
        decimal highlevelitem = ql.Higher_Level_Item__c;
        if(highlevelitem == null)
        {
          highlevelitem = 0;
        }
        string linestatus = ql.Line_Status__c;
        //datetime crtdate = ql.CreatedDate;
        
        Datetime crdte = ql.CreatedDate;
        string crtdate = Datetime.newInstance(crdte.year(), crdte.month(),crdte.day()).format('YYYYMMdd');
        //String crtdate = dtcrdte.format('YYYYMMDD');
        System.debug(crtdate);
        
        decimal saplinenumber = ql.SAP_Line_Number__c;
        if(saplinenumber == null)
        {
          saplinenumber = 0;
        }
        string pricerefmodel = ql.Pricing_Reference_Model__r.ProductCode;
        if(pricerefmodel == null)
        {
          pricerefmodel = '';
        }
        
        string pricerefdescription = ql.Pricing_Reference_Description__c;
        decimal prodcost = ql.Product_Cost__c;
        decimal overheadcost = ql.Overhead_Cost__c;
        if(overheadcost == null)
        {
          overheadcost = 0;
        }
        decimal laborcost = ql.Labor_Cost__c;
        decimal leasebuyout = ql.Lease_Buyout_Price__c;
        if(leasebuyout == null)
        {
          leasebuyout = 0;
        }
        string pricing = ql.Pricing__c;
        if(pricing == null)
        {
          pricing = '';
        }
        decimal priceamt = ql.Pricing_Amount__c;
        if(priceamt == null)
        {
          priceamt = 0;
        }
        
        string saplineitemguid = ql.SAP_Line_Item_GUID__c;
        if(saplineitemguid == null)
        {
          saplineitemguid = '';
        }
        //IBA-1915
        decimal lineDuration = ql.Line_Duration__c;
        if(lineDuration == null) 
        {
          lineDuration = 0; 
        }
	                        
       Map<String, Object> jsondata = new Map<String, Object> {
           'SF Quote Header ID' => quote,
               'SAP Quote ID' => quotenumber,
               'Product' => prod,
               'Quantity' => quantity,
               'Par Location' => parloc,
               'Requested Delivery Date' => reqdeliverydate,
               'Higher Level Item' => highlevelitem,
               'SAP Line Number' => saplinenumber,
               'Pricing Reference ID' => pricerefmodel,
               'Pricing' => pricing,
               'Pricing Amount' => priceamt,
               'SAP Line Item GUID' => saplineitemguid,
               'Line Status' => linestatus,
               'SF ID' => ql.id,
               'LineDuration' => lineDuration,
               'Change Status' => 'U'
               };
       
       String jsonstrupdate = JSON.serialize(jsondata);
       return jsonstrupdate; 
   }
    
   //Created new method by Jay related with demo 
   public static string prepareDataForQuoteLineInsert(string quotelineid, string quotelinename,Quote_Line__c ql )
   {
       
        //create a map that will hold the values of the list 
        Map<id,Quote> qmap = new Map<id,Quote>();
        
       // Quote_Line__c ql = [SELECT Id,Name,Lease_Buyout_Price__c,Quote__c,Quote__r.Id,Quote__r.Quote_Number__c,CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c FROM Quote_Line__c WHERE Id =:quotelineid];
        system.debug('ql..'+ql);
        
        string quotenumber = ql.Quote__r.Quote_Number__c;
        string quote = ql.Quote__c;
        string createdby = ql.CreatedBy.Omnicell_Employee_Number__c;
         
        decimal discountpercent = ql.Discount_Percent__c;
        if(discountpercent == null)
        {
          discountpercent = 0;
        }
        string lastmodifiedby = ql.LastModifiedBy.Omnicell_Employee_Number__c;
        
        string quoteid = ql.Quote__r.Id;
        //datetime lastmoddate = ql.LastModifiedDate;
        
        Datetime lastdte = ql.LastModifiedDate;
        string lastmoddate = Datetime.newInstance(lastdte.year(), lastdte.month(),lastdte.day()).format('YYYYMMdd');
        //String lastmoddate = dtlastdte.format('YYYYMMDD');
        System.debug('lastmoddate...'+lastmoddate);
        
        string description = ql.Line_Item_Description__c;
        if(description == null)
        {
          description = '';
        }
        
        
        decimal listprice = ql.List_Price__c;
        string prod = ql.Product__r.ProductCode;
        if(prod == null)
        {
          prod = '';
        }
        decimal quantity = ql.Quantity__c;
        if(quantity == null)
        {
          quantity = 0;
        }
        decimal discountamount = ql.Discount_Amount__c;
        /*string unitmeasure = ql.Unit_of_Measure__c; && 'Unit of Measure' => unitmeasure, commented as part of IBA-3424
        if(unitmeasure == null)
        {
          unitmeasure = '';
        }*/
        decimal custprice = ql.Customer_Price__c;
        decimal priceoverride = ql.Price_Override__c;
        string curr = ql.CurrencyIsoCode;
        decimal rebatebuyout = ql.Rebate_Buyout_Adjustment__c;
        
        decimal margin = ql.Margin__c;
        string parloc = ql.Par_Location__c;
        if(parloc == null)
        {
          parloc = '';
        }
        boolean extconfig = ql.External_Config__c;
        string picurl = ql.Picture_URL__c;
       // date reqdeliverydate = ql.Requested_Delivery_Date__c;
        
        string reqdeliverydate='';
        Date reqdte = ql.Requested_Delivery_Date__c;
        if(reqdte!=null){
        reqdeliverydate = Datetime.newInstance(reqdte.year(), reqdte.month(),reqdte.day()).format('YYYYMMdd');
        System.debug('reqdeliverydate....'+reqdeliverydate); 
        }
        if(reqdeliverydate == null)
        {
          reqdeliverydate = '';
        }
        
        
        
        decimal highlevelitem = ql.Higher_Level_Item__c;
        if(highlevelitem == null)
        {
          highlevelitem = 0;
        }
        string linestatus = ql.Line_Status__c;
        //datetime crtdate = ql.CreatedDate;
        
        Datetime crdte = ql.CreatedDate;
        string crtdate = Datetime.newInstance(crdte.year(), crdte.month(),crdte.day()).format('YYYYMMdd');
        //String crtdate = dtcrdte.format('YYYYMMDD');
        System.debug(crtdate);
        
        
        
        decimal saplinenumber = ql.SAP_Line_Number__c;
        if(saplinenumber == null)
        {
          saplinenumber = 0;
        }
        string pricerefmodel = ql.Pricing_Reference_Model__r.ProductCode;
        if(pricerefmodel == null)
        {
          pricerefmodel = '';
        }
        string pricerefdescription = ql.Pricing_Reference_Description__c;
        decimal prodcost = ql.Product_Cost__c;
        decimal overheadcost = ql.Overhead_Cost__c;
        decimal laborcost = ql.Labor_Cost__c;
        decimal leasebuyout = ql.Lease_Buyout_Price__c;
        if(leasebuyout == null)
        {
          leasebuyout = 0;
        }
        string pricing = ql.Pricing__c;
        if(pricing == null)
        {
          pricing = '';
        }
        decimal priceamt = ql.Pricing_Amount__c;
        if(priceamt == null)
        {
          priceamt = 0;
        }
        string saplineitemguid = ql.SAP_Line_Item_GUID__c;
        if(saplineitemguid == null)
        {
          saplineitemguid = '';
        }
        //IBA-1915
        decimal lineDuration = ql.Line_Duration__c;
        if(lineDuration == null) 
        {
          lineDuration = 0; 
        }
            Map<String, Object> jsondata = new Map<String, Object> {
                        'SF Quote Header ID' => quote,
                        'SAP Quote ID' => quotenumber,
                        'Product' => prod,
                        'Quantity' => quantity,
                        'Par Location' => parloc,
                        'Requested Delivery Date' => reqdeliverydate,
                        'Higher Level Item' => highlevelitem,
                        'SAP Line Number' => saplinenumber,
                        'Pricing Reference ID' => pricerefmodel,
                        'Pricing' => pricing,
                        'Pricing Amount' => priceamt,
                        'SAP Line Item GUID' => saplineitemguid,
                        'Line Status' => linestatus,
                        'LineDuration' => lineDuration,
                        'SF ID' => ql.id,
                        'Change Status' => 'C'
                      };
                   
                    //Added below code by Rajat to fix SF-BUG-393
                    String jsonstrinsert =  JSON.serialize(jsondata);
                return jsonstrinsert;
        
   }
    //new method created to send delete json in array by Pavan Palla-Jan Release
  public static String prepareDataForQuoteLineDelete(Quote_Line__c ql){
      string quotenumber = ql.Quote__r.Quote_Number__c;
      string quote = ql.Quote__c;
      string createdby = ql.CreatedBy.Omnicell_Employee_Number__c;
      decimal discountpercent = ql.Discount_Percent__c;
      string lastmodifiedby = ql.LastModifiedBy.Omnicell_Employee_Number__c;
      //datetime lastmoddate = ql.LastModifiedDate;
      
      Datetime lastdte = ql.LastModifiedDate;
      string lastmoddate = Datetime.newInstance(lastdte.year(), lastdte.month(),lastdte.day()).format('YYYYMMdd');
      //String lastmoddate = dtlastdte.format('YYYYMMDD');
      System.debug(lastmoddate);
      
      string quoteid = ql.Quote__r.Id;
      
      string description = ql.Line_Item_Description__c;
      if(description == null)
      {
          description = '';
      }
      decimal listprice = ql.List_Price__c;
      string prod = ql.Product__r.ProductCode;
      if(prod == null)
      {
          prod = '';
      }
      decimal quantity = ql.Quantity__c;
      if(quantity == null)
      {
          quantity = 0;
      }
      decimal discountamount = ql.Discount_Amount__c;
      //string unitmeasure = ql.Unit_of_Measure__c; && 'Unit of Measure' => unitmeasure, commented as part of IBA-3424
      if(quantity == null)
      {
          quantity = 0;
      }
      decimal custprice = ql.Customer_Price__c;
      decimal priceoverride = ql.Price_Override__c;
      string curr = ql.CurrencyIsoCode;
      decimal rebatebuyout = ql.Rebate_Buyout_Adjustment__c;
      
      decimal margin = ql.Margin__c;
      string parloc = ql.Par_Location__c;
      if(parloc == null)
      {
          parloc = '';
      }
      boolean extconfig = ql.External_Config__c;
      string picurl = ql.Picture_URL__c;
      //date reqdeliverydate = ql.Requested_Delivery_Date__c;
      
      
      string reqdeliverydate='';
      Date reqdte = ql.Requested_Delivery_Date__c;
      if(reqdte!=null){
          reqdeliverydate = Datetime.newInstance(reqdte.year(), reqdte.month(),reqdte.day()).format('YYYYMMdd');
          System.debug(reqdeliverydate); 
      }
      
      if(reqdeliverydate == null)
      {
          reqdeliverydate = '';
      }
      
      decimal highlevelitem = ql.Higher_Level_Item__c;
      if(highlevelitem == null)
      {
          highlevelitem = 0;
      }
      string linestatus = ql.Line_Status__c;
      //datetime crtdate = ql.CreatedDate;
      
      Datetime crdte = ql.CreatedDate;
      string crtdate = Datetime.newInstance(crdte.year(), crdte.month(),crdte.day()).format('YYYYMMdd');
      //String crtdate = dtcrdte.format('YYYYMMDD');
      System.debug(crtdate);
      
      
      
      decimal saplinenumber = ql.SAP_Line_Number__c;
      if(saplinenumber == null)
      {
          saplinenumber = 0;
      }
      string pricerefmodel = ql.Pricing_Reference_Model__r.ProductCode;
      if(pricerefmodel == null)
      {
          pricerefmodel = '';
      }
      
      string pricerefdescription = ql.Pricing_Reference_Description__c;
      decimal prodcost = ql.Product_Cost__c;
      decimal overheadcost = ql.Overhead_Cost__c;
      if(overheadcost == null)
      {
          overheadcost = 0;
      }
      decimal laborcost = ql.Labor_Cost__c;
      decimal leasebuyout = ql.Lease_Buyout_Price__c;
      if(leasebuyout == null)
      {
          leasebuyout = 0;
      }
      string pricing = ql.Pricing__c;
      if(pricing == null)
      {
          pricing = '';
      }
      decimal priceamt = ql.Pricing_Amount__c;
      if(priceamt == null)
      {
          priceamt = 0;
      }
      
      string saplineitemguid = ql.SAP_Line_Item_GUID__c;
      if(saplineitemguid == null)
      {
          saplineitemguid = '';
      }
      //IBA-1915
      decimal lineDuration = ql.Line_Duration__c;
        if(lineDuration == null) 
        {
          lineDuration = 0; 
        }      
      
      Map<String, Object> jsondata = new Map<String, Object> {
                  'SF Quote Header ID' => quote,
                      'SAP Quote ID' => quotenumber,
                      'Product' => prod,
                      'Quantity' => quantity,
                      'Par Location' => parloc,
                      'Requested Delivery Date' => reqdeliverydate,
                      'Higher Level Item' => highlevelitem,
                      'SAP Line Number' => saplinenumber,
                      'Pricing Reference ID' => pricerefmodel,
                      'Pricing' => pricing,
                      'Pricing Amount' => priceamt,
                      'SAP Line Item GUID' => saplineitemguid,
                      'LineDuration' => lineDuration,
                      'SF ID' => ql.id,
                      'Change Status' => 'D'
                      };
                          //Added below code by Rajat to fix SF-BUG-393
      String jsonstrdelete = JSON.serialize(jsondata);
      return jsonstrdelete;
  }
    
   @future(callout=true)   
    public static void callOutMethodInsert(set<Id> qliId){
    
        List<String> jsonStrings = new List<String>();
        
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        String endpoint = csValue1.QuoteLineInsertEndpoint__c; 
        system.debug('endpoint...'+endpoint);
        
        String quotelinename='';
        String jsonstr ='';
        String quotelineid ='';
        String SapQuoteNumber = '';
        string errormsg =''; 
        
        
        Quote_Line__c [] quotelineList = [SELECT Id,Name,Line_Duration__c,Lease_Buyout_Price__c,Quote__c,Quote__r.Id,Quote__r.Quote_Number__c,CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c  FROM Quote_Line__c WHERE Id IN :qliId];
        system.debug('quoteList...'+quotelineList);
        
        //changes done by Jay related with demo Start Point
         if(quotelineList.size()>0)
         {
          for( Quote_Line__c qli : quotelineList) 
           {
            quotelinename = qli.Name;
            quotelineid = qli.Id;
            system.debug('quotelinename...'+quotelinename);
            system.debug('quotelineid...'+quotelineid);
            jsonStrings.add(prepareDataForQuoteLineInsert(quotelineid,quotelinename,qli));
           }  
        }
         if(quotelineList[0].Quote__r.Quote_Number__c!=null)
            {
                try
                {
                    String EndPoint1 = (endPoint); 
                    Http h2= new Http();
                    HttpRequest req2= new HttpRequest();
                    //req2.setClientCertificateName('CastIronIntegration');
                    req2.setHeader('Content-Type','application/json');
                    req2.setHeader('accept','application/json');
                  //  system.debug('sending json for creating quote line: ' + jsonstrinsert); 
                    string jsonStringFinal = JSON.serialize(jsonStrings);            
                    jsonStringFinal = jsonStringFinal.replace('\\"', '"');
                    jsonStringFinal = jsonStringFinal.replace('"{', '{');
                    jsonStringFinal = jsonStringFinal.replace('}"', '}');
                    System.debug('Quote Line Insert jsonStringFinal'+jsonStringFinal);
                    req2.setBody(jsonStringFinal);
                    req2.setMethod('POST');
                    req2.setEndpoint(EndPoint1);
                    req2.setTimeout(120000); 
                    HttpResponse res2=h2.send(req2);
                    
                     System.debug(res2+'###123createresp');
                     if(res2.getStatusCode() == 200){
                     System.debug(res2+'###123createresp');
                     system.debug('res2.getBody()..'+res2.getBody());
                   }
                    if(res2.getstatusCode() != 200){
                     system.debug('errorbody..'+res2.getBody());
                     system.debug('errorstatus..'+res2.getStatus());
                    
                       errormsg = res2.getStatus();
                       system.debug('errormsg..'+errormsg);
                       if(errormsg!=null){
                        system.debug('callingclass..');
                       ErrorLogging.IntegrationLog(errormsg, 'callOutMethodInsert','App');
                     }
                      
                  }     
                }
                catch(Exception e){
                  System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                  ErrorLogging.Log(e, 'callOutMethodInsert','App');
            }
             
          }
        //changes done by Jay related with demo End Point
        //}
    }
    
    @future(callout=true)
    public static void callOutMethodUpdate(set<Id> qliId){
    
        List<String> jsonStrings = new List<String>();
        
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        String endpoint = csValue1.QuoteLineUpdateEndpoint__c; 
        system.debug('endpoint...'+endpoint);
        
        String quotelinename='';
        String jsonstr ='';
        String quotelineid ='';
        String SapQuoteNumber = '';
        string errormsg ='';
        
        Quote_Line__c [] quotelineList = [SELECT Id,Name,Quote__r.Id,Quote__c,Lease_Buyout_Price__c,Quote__r.Quote_Number__c,
                            CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,
                            LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,
                            Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,
                            Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,
                            Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Line_Duration__c,
                            Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,
                            Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c FROM Quote_Line__c WHERE Id IN :qliId];
        system.debug('quoteList...'+quotelineList);
        
         if(quotelineList.size()>0)
         {
          for( Quote_Line__c qli : quotelineList) 
           {
            quotelinename = qli.Name;
            quotelineid = qli.Id;
            jsonStrings.add(prepareDataForQuoteLineUpdate(quotelineid,quotelinename,qli));
            system.debug('quotelinename...'+quotelinename);
            system.debug('quotelineid...'+quotelineid);
           }  
        }
        
       
         if(quotelineList[0].Quote__r.Quote_Number__c!=null)
            {
                try
                {
                    String EndPoint1 = endPoint;
                    string jsonStringFinal = JSON.serialize(jsonStrings);            
                    jsonStringFinal = jsonStringFinal.replace('\\"', '"');
                    jsonStringFinal = jsonStringFinal.replace('"{', '{');
                    jsonStringFinal = jsonStringFinal.replace('}"', '}');                    
                    System.debug('Update Jsonfinal str'+jsonStringFinal);
                    Http h2= new Http();
                    HttpRequest req2= new HttpRequest();
                    //req2.setClientCertificateName('CastIronIntegration');
                    req2.setHeader('Content-Type','application/json');
                    req2.setHeader('accept','application/json');
                    req2.setHeader('X-HTTP-METHOD-Override','PATCH');
                    req2.setBody(jsonStringFinal);
                    req2.setMethod('POST');
                    req2.setEndpoint(EndPoint1);
                    req2.setTimeout(120000); 
                    HttpResponse res2=h2.send(req2);
                    System.debug(res2+'###123createresp');
                     if(res2.getStatusCode() == 200){
                      System.debug(res2+'###123createresp');
                      system.debug('res2.getBody()..'+res2.getBody());
                   } 
                   if(res2.getstatusCode() != 200){
                     system.debug('errorbody..'+res2.getBody());
                     system.debug('errorstatus..'+res2.getStatus());
                    
                       errormsg = res2.getStatus();
                       system.debug('errormsg..'+errormsg);
                       if(errormsg!=null){
                        system.debug('callingclass..');
                       ErrorLogging.IntegrationLog(errormsg, 'callOutMethodUpdate','App');
                     }
                      
                  }     
                }
                catch(Exception e){
                  System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                  ErrorLogging.Log(e, 'callOutMethodUpdate','App');
            } 
            }
       }
       
  /*     
   @future(callout=true)
    public static void callOutMethodDelete(set<Id> qliId){
    System.debug('QLID : '+qliId);
    system.debug('in method 3...');
        List<Quote_Line__c> q = [select id,quote__c from Quote_Line__c where id=:qliId];
        System.debug('Q : '+q);
        CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
        String endpoint = csValue1.QuoteLineUpdateEndpoint__c; 
        system.debug('endpoint...'+endpoint);
        system.debug('qliId...'+qliId);
        
        String quotelinename='';
        String jsonstr ='';
        String quotelineid ='';
        String SapQuoteNumber = '';
        string errormsg ='';
        
        Quote_Line__c [] quotelineList = [SELECT Id,Quote__c,Quote__r.Id,Name,Lease_Buyout_Price__c,CreatedById,Discount_Percent__c,LastModifiedById,LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c FROM Quote_Line__c WHERE Id IN :qliId ALL ROWS];
        system.debug('quoteList...'+quotelineList);
        
         if(quotelineList.size()>0)
         {
          for( Quote_Line__c qli : quotelineList) 
           {
            quotelinename = qli.Name;
            quotelineid = qli.Id;
            system.debug('quotelinename...'+quotelinename);
            system.debug('quotelineid...'+quotelineid);
           }  
        }
        
        Quote_Line__c ql = [SELECT Id,Name,Quote__r.Id,Quote__c,Lease_Buyout_Price__c,Quote__r.Quote_Number__c,CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c FROM Quote_Line__c WHERE Id =:quotelineid ALL ROWS];
        system.debug('ql..'+ql);
        
        string quotenumber = ql.Quote__r.Quote_Number__c;
        string quote = ql.Quote__c;
        string createdby = ql.CreatedBy.Omnicell_Employee_Number__c;
        decimal discountpercent = ql.Discount_Percent__c;
        string lastmodifiedby = ql.LastModifiedBy.Omnicell_Employee_Number__c;
        //datetime lastmoddate = ql.LastModifiedDate;
        
        Datetime lastdte = ql.LastModifiedDate;
        string lastmoddate = Datetime.newInstance(lastdte.year(), lastdte.month(),lastdte.day()).format('YYYYMMdd');
        //String lastmoddate = dtlastdte.format('YYYYMMDD');
        System.debug(lastmoddate);
        
        string quoteid = ql.Quote__r.Id;
        
        string description = ql.Line_Item_Description__c;
        if(description == null)
        {
          description = '';
        }
        decimal listprice = ql.List_Price__c;
        string prod = ql.Product__r.ProductCode;
        if(prod == null)
        {
          prod = '';
        }
        decimal quantity = ql.Quantity__c;
        if(quantity == null)
        {
          quantity = 0;
        }
        decimal discountamount = ql.Discount_Amount__c;
        string unitmeasure = ql.Unit_of_Measure__c;
        if(quantity == null)
        {
          quantity = 0;
        }
        decimal custprice = ql.Customer_Price__c;
        decimal priceoverride = ql.Price_Override__c;
        string curr = ql.CurrencyIsoCode;
        decimal rebatebuyout = ql.Rebate_Buyout_Adjustment__c;
        
        decimal margin = ql.Margin__c;
        string parloc = ql.Par_Location__c;
        if(parloc == null)
        {
          parloc = '';
        }
        boolean extconfig = ql.External_Config__c;
        string picurl = ql.Picture_URL__c;
        //date reqdeliverydate = ql.Requested_Delivery_Date__c;
        
        
        string reqdeliverydate='';
        Date reqdte = ql.Requested_Delivery_Date__c;
        if(reqdte!=null){
        reqdeliverydate = Datetime.newInstance(reqdte.year(), reqdte.month(),reqdte.day()).format('YYYYMMdd');
        System.debug(reqdeliverydate); 
        }
        
        if(reqdeliverydate == null)
        {
          reqdeliverydate = '';
        }
        
        decimal highlevelitem = ql.Higher_Level_Item__c;
        if(highlevelitem == null)
        {
          highlevelitem = 0;
        }
        string linestatus = ql.Line_Status__c;
        //datetime crtdate = ql.CreatedDate;
        
        Datetime crdte = ql.CreatedDate;
        string crtdate = Datetime.newInstance(crdte.year(), crdte.month(),crdte.day()).format('YYYYMMdd');
        //String crtdate = dtcrdte.format('YYYYMMDD');
        System.debug(crtdate);
        
        
        
        decimal saplinenumber = ql.SAP_Line_Number__c;
        if(saplinenumber == null)
        {
          saplinenumber = 0;
        }
        string pricerefmodel = ql.Pricing_Reference_Model__r.ProductCode;
        if(pricerefmodel == null)
        {
          pricerefmodel = '';
        }
        
        string pricerefdescription = ql.Pricing_Reference_Description__c;
        decimal prodcost = ql.Product_Cost__c;
        decimal overheadcost = ql.Overhead_Cost__c;
        if(overheadcost == null)
        {
          overheadcost = 0;
        }
        decimal laborcost = ql.Labor_Cost__c;
        decimal leasebuyout = ql.Lease_Buyout_Price__c;
        if(leasebuyout == null)
        {
          leasebuyout = 0;
        }
        string pricing = ql.Pricing__c;
        if(pricing == null)
        {
          pricing = '';
        }
        decimal priceamt = ql.Pricing_Amount__c;
        if(priceamt == null)
        {
          priceamt = 0;
        }
        
        string saplineitemguid = ql.SAP_Line_Item_GUID__c;
        if(saplineitemguid == null)
        {
          saplineitemguid = '';
        }
        
         if(ql.Quote__r.Quote_Number__c!=null)
            {
                try
                {
                    //String EndPoint1 = endPoint+'?_HttpMethod=PATCH';
                    String EndPoint1 = endPoint;
                    //String jsonstrupdate='{"QuoteNumber" :"'+quotenumber+'","Created By" :"'+createdby+'", "Discount %" : "'+discountpercent+'" ,"Last Modified By" : "'+lastmodifiedby+'","Last modified date": "'+lastmoddate+'","Line Item Description" : "'+description+'", "List Price" : "'+listprice+'" ,"Product" : "'+prod+'", "Quantity" : "'+quantity+'","Discount Amount" : "'+discountamount+'", "Unit of Measure" : "'+unitmeasure+'", "Customer Price" :"'+custprice+'","Price Override" : "'+priceoverride+'","Currency" :"'+curr+'","Rebate/Buyout Adjustment" : "'+rebatebuyout+'","Total Cost" :"'+totalcost+'","Margin" : "'+margin+'","Par Location" : "'+parloc+'","External Config":"'+extconfig+'","Picture URL" : "'+picurl+'","Requested Delivery Date" : "'+reqdeliverydate+'","Higher Level Item" : "'+highlevelitem+'","Line Status" : "'+linestatus+'","Create date":"'+crtdate+'","SAP Line Number" : "'+saplinenumber+'","Pricing Reference ID" : "'+pricerefmodel+'","Pricing Reference Description" : "'+pricerefdescription+'","Product Cost" :"'+prodcost+'","Overhead Cost" : "'+overheadcost+'","Labor Cost":"'+laborcost+'" }'; 
                    //Commented below line by Rajat to fix SF-BUG-393
                    //String jsonstrdelete='{"SF Quote Header ID" :"'+ quote + '","SAP Quote ID" :"'+quotenumber+'","Product" : "'+prod+'", "Quantity" : "'+quantity+'","Unit of Measure" : "'+unitmeasure+'","Par Location" : "'+parloc+'","Requested Delivery Date" : "'+reqdeliverydate+'","Higher Level Item" : "'+highlevelitem+'","SAP Line Number" : "'+saplinenumber+'","Pricing Reference ID" : "'+pricerefmodel+'","Pricing" : "'+pricing+'","Pricing Amount":"'+priceamt+'","SAP Line Item GUID":"'+saplineitemguid+'","SF ID":"'+ql.id+'","Change Status":"D"}';       
                    //Added below code by Rajat to fix SF-BUG-393
                    Map<String, Object> jsondata = new Map<String, Object> {
                      'SF Quote Header ID' => quote,
                      'SAP Quote ID' => quotenumber,
                      'Product' => prod,
                      'Quantity' => quantity,
                      'Unit of Measure' => unitmeasure,
                      'Par Location' => parloc,
                      'Requested Delivery Date' => reqdeliverydate,
                      'Higher Level Item' => highlevelitem,
                      'SAP Line Number' => saplinenumber,
                      'Pricing Reference ID' => pricerefmodel,
                      'Pricing' => pricing,
                      'Pricing Amount' => priceamt,
                      'SAP Line Item GUID' => saplineitemguid,
                      'SF ID' => ql.id,
                      'Change Status' => 'D'
                    };
                    //Added below code by Rajat to fix SF-BUG-393
                    String jsonstrdelete = JSON.serialize(jsondata);
                    system.debug('jsonstrdelete...'+jsonstrdelete);
                    Http h2= new Http();
                    HttpRequest req2= new HttpRequest();
                    //req2.setClientCertificateName('CastIronIntegration');
                    req2.setHeader('Content-Type','application/json');
                    req2.setHeader('accept','application/json');
                    req2.setHeader('X-HTTP-METHOD-Override','PATCH');
                    req2.setBody(jsonstrdelete);
                    req2.setMethod('POST');
                    req2.setEndpoint(EndPoint1);
                    req2.setTimeout(120000); 
                    HttpResponse res2=h2.send(req2);
                    System.debug(res2+'###123createresp');
                     if(res2.getStatusCode() == 200){
                      System.debug(res2+'###123createresp');
                      system.debug('res2.getBody()..'+res2.getBody());
                   } 
                   if(res2.getstatusCode() != 200){
                     system.debug('errorbody..'+res2.getBody());
                     system.debug('errorstatus..'+res2.getStatus());
                    
                       errormsg = res2.getStatus();
                       system.debug('errormsg..'+errormsg);
                       if(errormsg!=null){
                        system.debug('callingclass..');
                       ErrorLogging.IntegrationLog(errormsg, 'callOutMethodDelete','App');
                     }
                      
                  }     
                }
                catch(Exception e){
                  System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
                  ErrorLogging.Log(e, 'callOutMethodDelete','App');
            } 
            }
       }   */
  
    //Updated delete method created to send delete json in array by Pavan Palla-Jan Release  
  @future(callout=true)
  public static void callOutMethodDelete(set<Id> qliId){
      /*System.debug('QLID : '+qliId);
      system.debug('in method 3...');
      List<Quote_Line__c> q = [select id,quote__c from Quote_Line__c where id=:qliId];
      System.debug('Q : '+q);*/
      List<String> jsonStrings = new List<String>();
      CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
      String endpoint = csValue1.QuoteLineUpdateEndpoint__c; 
      system.debug('endpoint...'+endpoint);
      system.debug('qliId...'+qliId);
      
      String quotelinename='';
      String jsonstr ='';
      String quotelineid ='';
      String SapQuoteNumber = '';
      string errormsg ='';
      
      Quote_Line__c [] quotelineList = [SELECT Id,Quote__c,Quote__r.Id,Quote__r.Quote_Number__c,CreatedBy.Omnicell_Employee_Number__c,LastModifiedBy.Omnicell_Employee_Number__c,Name,Lease_Buyout_Price__c,CreatedById,Discount_Percent__c,LastModifiedById,LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c,Line_Duration__c FROM Quote_Line__c WHERE Id IN :qliId ALL ROWS];
      system.debug('quoteList...'+quotelineList);
      
      if(quotelineList.size()>0)
      {
          for( Quote_Line__c qli : quotelineList) 
          {
              quotelinename = qli.Name;
              quotelineid = qli.Id;
              system.debug('quotelinename...'+quotelinename);
              system.debug('quotelineid...'+quotelineid);
                  jsonStrings.add(prepareDataForQuoteLineDelete(qli));
          }  
      }
      
      /*Quote_Line__c ql = [SELECT Id,Name,Quote__r.Id,Quote__c,Lease_Buyout_Price__c,Quote__r.Quote_Number__c,CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c FROM Quote_Line__c WHERE Id =:quotelineid ALL ROWS];
      system.debug('ql..'+ql);*/
      
      
      
      if(quotelineList[0].Quote__r.Quote_Number__c!=null)
      {
          try
          {
              //String EndPoint1 = endPoint+'?_HttpMethod=PATCH';
              String EndPoint1 = endPoint;
              system.debug('EndPoint1---  '+EndPoint1);
              //String jsonstrupdate='{"QuoteNumber" :"'+quotenumber+'","Created By" :"'+createdby+'", "Discount %" : "'+discountpercent+'" ,"Last Modified By" : "'+lastmodifiedby+'","Last modified date": "'+lastmoddate+'","Line Item Description" : "'+description+'", "List Price" : "'+listprice+'" ,"Product" : "'+prod+'", "Quantity" : "'+quantity+'","Discount Amount" : "'+discountamount+'", "Unit of Measure" : "'+unitmeasure+'", "Customer Price" :"'+custprice+'","Price Override" : "'+priceoverride+'","Currency" :"'+curr+'","Rebate/Buyout Adjustment" : "'+rebatebuyout+'","Total Cost" :"'+totalcost+'","Margin" : "'+margin+'","Par Location" : "'+parloc+'","External Config":"'+extconfig+'","Picture URL" : "'+picurl+'","Requested Delivery Date" : "'+reqdeliverydate+'","Higher Level Item" : "'+highlevelitem+'","Line Status" : "'+linestatus+'","Create date":"'+crtdate+'","SAP Line Number" : "'+saplinenumber+'","Pricing Reference ID" : "'+pricerefmodel+'","Pricing Reference Description" : "'+pricerefdescription+'","Product Cost" :"'+prodcost+'","Overhead Cost" : "'+overheadcost+'","Labor Cost":"'+laborcost+'" }'; 
              //Commented below line by Rajat to fix SF-BUG-393
              //String jsonstrdelete='{"SF Quote Header ID" :"'+ quote + '","SAP Quote ID" :"'+quotenumber+'","Product" : "'+prod+'", "Quantity" : "'+quantity+'","Unit of Measure" : "'+unitmeasure+'","Par Location" : "'+parloc+'","Requested Delivery Date" : "'+reqdeliverydate+'","Higher Level Item" : "'+highlevelitem+'","SAP Line Number" : "'+saplinenumber+'","Pricing Reference ID" : "'+pricerefmodel+'","Pricing" : "'+pricing+'","Pricing Amount":"'+priceamt+'","SAP Line Item GUID":"'+saplineitemguid+'","SF ID":"'+ql.id+'","Change Status":"D"}';       
              //Added below code by Rajat to fix SF-BUG-393
              string jsonStringFinal = JSON.serialize(jsonStrings);            
              jsonStringFinal = jsonStringFinal.replace('\\"', '"');
              jsonStringFinal = jsonStringFinal.replace('"{', '{');
              jsonStringFinal = jsonStringFinal.replace('}"', '}');
              system.debug('jsonStringFinal Delete-- '+jsonStringFinal);
              Http h2= new Http();
              HttpRequest req2= new HttpRequest();
              //req2.setClientCertificateName('CastIronIntegration');
              req2.setHeader('Content-Type','application/json');
              req2.setHeader('accept','application/json');
              req2.setHeader('X-HTTP-METHOD-Override','PATCH');
              req2.setBody(jsonStringFinal);
              req2.setMethod('POST');
              req2.setEndpoint(EndPoint1);
              req2.setTimeout(120000); 
              HttpResponse res2=h2.send(req2);
              System.debug(res2+'###123createresp');
              if(res2.getStatusCode() == 200){
                  System.debug(res2+'###123createresp');
                  system.debug('res2.getBody()..'+res2.getBody());
              } 
              if(res2.getstatusCode() != 200){
                  system.debug('errorbody..'+res2.getBody());
                  system.debug('errorstatus..'+res2.getStatus());
                  
                  errormsg = res2.getStatus();
                  system.debug('errormsg..'+errormsg);
                  if(errormsg!=null){
                      system.debug('callingclass..');
                      ErrorLogging.IntegrationLog(errormsg, 'callOutMethodDelete','App');
                  }
                  
              }     
          }
          catch(Exception e){
              System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
              ErrorLogging.Log(e, 'callOutMethodDelete','App');
          } 
      }
  }
      @future(callout=true)
  public static void callOutMethodInsertUpdate(set<Id> qliId){
      
      List<String> jsonStrings = new List<String>();
      
      CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
      String endpoint = csValue1.QuoteLineInsertEndpoint__c; 
      system.debug('endpoint...'+endpoint);
      
      String quotelinename='';
      String jsonstr ='';
      String quotelineid ='';
      String SapQuoteNumber = '';
      string errormsg =''; 
      
      
      Quote_Line__c [] quotelineList = [SELECT Id,Name,Lease_Buyout_Price__c,Quote__c,Quote__r.Id,Quote__r.Quote_Number__c,CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c,Line_Duration__c FROM Quote_Line__c WHERE Id IN :qliId];
      system.debug('quoteList...'+quotelineList);
      
      //changes done by Jay related with demo Start Point
      if(quotelineList.size()>0)
      {
          for( Quote_Line__c qli : quotelineList) 
          {
              quotelinename = qli.Name;
              quotelineid = qli.Id;
              system.debug('quotelinename...'+quotelinename);
              system.debug('quotelineid...'+quotelineid);
              jsonStrings.add(prepareDataForQuoteLineInsert(quotelineid,quotelinename,qli));
          }  
      }
      if(quotelineList[0].Quote__r.Quote_Number__c!=null)
      {
          try
          {
              String EndPoint1 = (endPoint); 
              Http h2= new Http();
              HttpRequest req2= new HttpRequest();
              //req2.setClientCertificateName('CastIronIntegration');
              req2.setHeader('Content-Type','application/json');
              req2.setHeader('accept','application/json');
              //  system.debug('sending json for creating quote line: ' + jsonstrinsert); 
              string jsonStringFinal = JSON.serialize(jsonStrings);            
              jsonStringFinal = jsonStringFinal.replace('\\"', '"');
              jsonStringFinal = jsonStringFinal.replace('"{', '{');
              jsonStringFinal = jsonStringFinal.replace('}"', '}');
              system.debug('INSERT JSON-- '+jsonStringFinal);
              req2.setBody(jsonStringFinal);
              req2.setMethod('POST');
              req2.setEndpoint(EndPoint1);
              req2.setTimeout(120000); 
              HttpResponse res2=h2.send(req2);
              
              System.debug(res2+'###123createresp');
              if(res2.getStatusCode() == 200){
                  System.debug(res2+'###123createresp');
                  system.debug('res2.getBody()..'+res2.getBody());
                  List<String> jsonStringsU = new List<String>();
                  
                  CastIronIntegration__c csValue1U = CastIronIntegration__c.getInstance('CastIronIntegration');
                  String endpointU = csValue1U.QuoteLineUpdateEndpoint__c; 
                  system.debug('endpoint...'+endpointU);
                  
                  String quotelinenameU='';
                  String jsonstrU ='';
                  String quotelineidU ='';
                  String SapQuoteNumberU = '';
                  string errormsgU ='';
                  
                  Quote_Line__c [] quotelineListU = [SELECT Id,Name,Quote__r.Id,Quote__c,Lease_Buyout_Price__c,Quote__r.Quote_Number__c,
                                                     CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,
                                                     LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,
                                                     Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,
                                                     Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,
                                                     Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,
                                                     Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,
                                                     Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c,Line_Duration__c FROM Quote_Line__c WHERE Id IN :qliId];
                  system.debug('quoteListU...'+quotelineListU);
                  
                  if(quotelineListU.size()>0)
                  {
                      for( Quote_Line__c qli : quotelineListU) 
                      {
                          quotelinenameU = qli.Name;
                          quotelineidU = qli.Id;
                          jsonStringsU.add(prepareDataForQuoteLineUpdate(quotelineidU,quotelinenameU,qli));
                          system.debug('quotelinename...'+quotelinenameU);
                          system.debug('quotelineid...'+quotelineidU);
                      }  
                  }
                  
                  
                  if(quotelineListU[0].Quote__r.Quote_Number__c!=null)
                  {
                      
                      String EndPoint1U = endPoint;
                      string jsonStringFinalU = JSON.serialize(jsonStrings);            
                      jsonStringFinalU = jsonStringFinal.replace('\\"', '"');
                      jsonStringFinalU = jsonStringFinal.replace('"{', '{');
                      jsonStringFinalU = jsonStringFinal.replace('}"', '}');                    
                      
                      Http h3= new Http();
                      HttpRequest req3= new HttpRequest();
                      //req2.setClientCertificateName('CastIronIntegration');
                      req3.setHeader('Content-Type','application/json');
                      req3.setHeader('accept','application/json');
                      req3.setHeader('X-HTTP-METHOD-Override','PATCH');
                      system.debug('update JSON-- '+jsonStringFinalU);
                      req3.setBody(jsonStringFinalU);
                      req3.setMethod('POST');
                      req3.setEndpoint(EndPoint1U);
                      req3.setTimeout(120000); 
                      HttpResponse res3=h3.send(req3);
                      System.debug(res3+'###123createresp');
                      if(res3.getStatusCode() == 200){
                          System.debug(res3+'###1233createresp');
                          system.debug('res3.getBody()..'+res3.getBody());
                      } 
                      if(res3.getstatusCode() != 200){
                          system.debug('errorbody..'+res3.getBody());
                          system.debug('errorstatus..'+res3.getStatus());
                          
                          errormsgU = res3.getStatus();
                          system.debug('errormsgU..'+errormsgU);
                          if(errormsgU != null){
                              system.debug('callingclass..');
                              ErrorLogging.IntegrationLog(errormsgU, 'callOutMethodUpdate','App');
                          }
                          
                      }     
                      
                  }
              }
              if(res2.getstatusCode() != 200){
                  system.debug('errorbody..'+res2.getBody());
                  system.debug('errorstatus..'+res2.getStatus());
                  
                  errormsg = res2.getStatus();
                  system.debug('errormsg..'+errormsg);
                  if(errormsg!=null){
                      system.debug('callingclass..');
                      ErrorLogging.IntegrationLog(errormsg, 'callOutMethodInsert','App');
                  }
                  
              }     
          }
          catch(Exception e){
              System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
              ErrorLogging.Log(e, 'callOutMethodInsert','App');
          }
          
      }
      //changes done by Jay related with demo End Point
      //}
  }
  
    
      //Bharath : To handle Add to Cart Quote Lines Delete/Update call 
  @future(callout=true)
  public static void callOutMethodDeleteUpdate(set<Id> qliId){
      
      List<String> jsonStrings = new List<String>();
      
      CastIronIntegration__c csValue1 = CastIronIntegration__c.getInstance('CastIronIntegration');
      String endpoint = csValue1.QuoteLineInsertEndpoint__c; 
      system.debug('endpoint...'+endpoint);
      
      String quotelinename='';
      String jsonstr ='';
      String quotelineid ='';
      String SapQuoteNumber = '';
      string errormsg =''; 
      
      
      
          try
          {
              List<String> jsonStringsU = new List<String>();
              
              CastIronIntegration__c csValue1U = CastIronIntegration__c.getInstance('CastIronIntegration');
              String endpointU = csValue1U.QuoteLineUpdateEndpoint__c; 
              system.debug('endpoint...'+endpointU);
              
              String quotelinenameU='';
              String jsonstrU ='';
              String quotelineidU ='';
              String SapQuoteNumberU = '';
              string errormsgU ='';
              
              Quote_Line__c [] quotelineListU = [SELECT Id,Name,Quote__r.Id,Quote__c,Lease_Buyout_Price__c,Quote__r.Quote_Number__c,
                                                 CreatedBy.Omnicell_Employee_Number__c,Discount_Percent__c,LastModifiedBy.Omnicell_Employee_Number__c,
                                                 LastModifiedDate,Line_Item_Description__c,List_Price__c,Product__c,Product__r.ProductCode,Quantity__c,
                                                 Discount_Amount__c,Unit_of_Measure__c,Customer_Price__c,Price_Override__c,CurrencyIsoCode,
                                                 Rebate_Buyout_Adjustment__c,Margin__c,Par_Location__c,External_Config__c,Picture_URL__c,Requested_Delivery_Date__c,
                                                 Higher_Level_Item__c,Line_Status__c,CreatedDate,SAP_Line_Number__c,Line_Duration__c,
                                                 Pricing_Reference_Model__r.ProductCode,Pricing_Reference_Description__c,Product_Cost__c,Overhead_Cost__c,
                                                 Labor_Cost__c,Pricing__c,Pricing_Amount__c,SAP_Line_Item_GUID__c,Cart_Item_to_Delete__c FROM Quote_Line__c WHERE Id IN :qliId];
              system.debug('quoteListU...'+quotelineListU);
              
              if(quotelineListU.size()>0)
              {
                  for( Quote_Line__c qli : quotelineListU) 
                  {
                      quotelinenameU = qli.Name;
                      quotelineidU = qli.Id;
                      if(qli.Cart_Item_to_Delete__c)
                      {
                          jsonStringsU.add(prepareDataForQuoteLineDelete(qli));
                      }else{
                          jsonStringsU.add(prepareDataForQuoteLineUpdate(quotelineidU,quotelinenameU,qli));
                      }
                      
                      system.debug('quotelinename...'+quotelinenameU);
                      system.debug('quotelineid...'+quotelineidU);
                  }  
              }
              
              
              if(quotelineListU[0].Quote__r.Quote_Number__c!=null)
              {
                  
                  String EndPoint1U = endPoint;
                  string jsonStringFinalU = JSON.serialize(jsonStringsU);            
                  jsonStringFinalU = jsonStringFinalU.replace('\\"', '"');
                  jsonStringFinalU = jsonStringFinalU.replace('"{', '{');
                  jsonStringFinalU = jsonStringFinalU.replace('}"', '}');                    
                  
                  Http h3= new Http();
                  HttpRequest req3= new HttpRequest();
                  //req2.setClientCertificateName('CastIronIntegration');
                  req3.setHeader('Content-Type','application/json');
                  req3.setHeader('accept','application/json');
                  req3.setHeader('X-HTTP-METHOD-Override','PATCH');
                  system.debug('update JSON-- '+jsonStringFinalU);
                  req3.setBody(jsonStringFinalU);
                  req3.setMethod('POST');
                  req3.setEndpoint(EndPoint1U);
                  req3.setTimeout(120000); 
                  HttpResponse res3=h3.send(req3);
                  System.debug(res3+'###123createresp');
                  if(res3.getStatusCode() == 200){
                      System.debug(res3+'###Add To Cart Update-delete');
                      system.debug('res3.getBody()..'+res3.getBody());
                  } 
                  if(res3.getstatusCode() != 200){
                      system.debug('errorbody..'+res3.getBody());
                      system.debug('errorstatus..'+res3.getStatus());
                      
                      errormsgU = res3.getStatus();
                      system.debug('errormsgU..'+errormsgU);
                      if(errormsgU != null){
                          ErrorLogging.IntegrationLog(errormsgU, 'callOutMethodDeleteUpdate','App');
                      }
                  }     
                  
              }
          }
          catch(Exception e){
              System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
              ErrorLogging.Log(e, 'callOutMethodDeleteUpdate','App');
          }
          
      
  }
}