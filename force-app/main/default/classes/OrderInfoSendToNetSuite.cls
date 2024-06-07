public class OrderInfoSendToNetSuite { //IBA-4831
    @future(callout=true)
    public static void sendToNetSuit(Set<Id> quoteIds){
        String quoteLines = ''; 
        List<Quote> quotes = [Select ID,Name,Order_Type__c,ECC_Sales_Order_Number__c,subscription_Months__c,Freight_Price__c,
                              Resident_Operator_Duration__c,Resident_Operator_Solution_Fee__c,Service_Duration__c,Rebate_Amount__c ,Professional_services_duration__c,  //IBA-5783
                              Conga_Total_Monthly_Product__c,Conga_Total_Monthly_Support_Services__c,CurrencyIsoCode,SAP_NPV__c,
                              Expected_Bookings__c,Booking_Date__c,Expected_Close_Date__c,AccountId,Account_CSN__c,BillTo_CSN__c,
                              ShipTo_CSN__c,Customer_Name__c,Opp_Name__c,OpportunityId,Ship_to_Account__r.name,Ship_to_Account__r.BillingCity,
                              Ship_to_Account__r.BillingCountry,Ship_to_Account__r.BillingCountryCode,Ship_to_Account__r.Address_Line_2__c,
                              Ship_to_Account__r.BillingPostalCode,Ship_to_Account__r.BillingState,Ship_to_Account__r.BillingStateCode,
                              Ship_to_Account__r.BillingStreet,Bill_to_Account__r.name,Bill_to_Account__r.BillingCity,Bill_to_Account__r.BillingCountry,
                              Bill_to_Account__r.BillingCountryCode,Bill_to_Account__r.Address_Line_2__c,Bill_to_Account__r.BillingPostalCode,
                              Bill_to_Account__r.BillingState,Bill_to_Account__r.BillingStateCode,Bill_to_Account__r.BillingStreet,
                              Opportunity.Account.Division_Account__c,Opportunity.Opportunity_Division__c,Opportunity.Opportunity_Number__c,
                              opportunity.Opportunity__c,Account_Name_Text__c,Division__c,Quote_Number__c,Opportunity.Name,Product_PO_Number__c,
                              Quote.Shipping_Contact__r.Name,Quote.Shipping_Contact__r.Email,NetSuite_ID__c,Terms_of_Payment__c  From Quote Where Id IN :quoteIds];        //IBA-5882
        Quote quote = quotes[0];//later need to bulkify as per requirement
        String jsontoSend = '';
        String quoteJson = getQuotejson(quote);
        quoteLines = getRebateLinejson(quote); //IBA-5783 Pabitra
        
        
        
        List<Quote_Line__c> quoteLineList=[SELECT Id,Name,SAP_Line_Number__c,Higher_Level_Item__c,Portfolio_Segment__c,
                                           DW_Product_Line__c,Product_Code__c,Line_Item_Description__c,Quantity__c,Total_Customer_Price__c,SAP_NPV__c,Sales_Text__c,
                                           NetSuite_Line_ID__c,Customer_Price__c,Part_of_a_Bundle__c,Rebate_Buyout_Adjustment__c  //IBA-5783
                                           FROM Quote_Line__c WHERE Quote__c=:quote.Id AND Line_Status__c != 'E0006' ORDER BY SAP_Line_Number__c];            //IBA-5876 AMAN
        Boolean notrrepsflag;        
        List<Resident_Robotic_Expert_Product__c> rreProds = [Select Product_Code__c From Resident_Robotic_Expert_Product__c];
        Set<String> rreProdCodes = new Set<String>();
        for(Resident_Robotic_Expert_Product__c rreprod: rreProds){
            rreprodcodes.add(rreprod.Product_Code__c);
        }
        Map<Decimal,Quote_Line__c> saplineQuoteLineMap = new Map<Decimal,Quote_Line__c>();
        for(Quote_Line__c qt :quoteLineList){
            if(qt.Higher_Level_Item__c == 0){
                saplineQuoteLineMap.put(qt.SAP_Line_Number__c,qt);
            }
        }
        for(Quote_Line__c qt :quoteLineList){
            if(qt.Product_Code__c == 'FREIGHT'){
                if(quoteLines.length()>0){
                    quoteLines += ','+getFreightLinejson(qt,quote);
                }
                else{
                    quoteLines += getFreightLinejson(qt,quote);
                }
            }
            else{
                if(quoteLines.length()>0){
                    quoteLines += ','+getQuoteLinejson(quote,qt,saplineQuoteLineMap,rreProdCodes);
                }
                else{
                    quoteLines += getQuoteLinejson(quote,qt,saplineQuoteLineMap,rreProdCodes);
                }
            }
        }
        if(quote.Order_Type__c == 'ZQRS'){
            if(quoteLines.length()>0){
                quoteLines += ','+getDummyInterestLinejson(quote);
            }
            else{
                quoteLines += getDummyInterestLinejson(quote);                
            }
        }
        if(quoteLines.endsWith(',')){
            quoteLines = quoteLines.substring(0,quoteLines.length()-1);
        }
        quoteLines = '"Quote_Lines__c" : ['+quoteLines.replace('"null"', 'null')+']'; 
        jsontoSend = '[{'+quoteJson+','+quoteLines+'}]';  
        System.debug(jsontoSend);
        callNetSuite(quote,jsontoSend);
    }
    
    public static String getQuotejson(Quote quote){
        String bookingDate = '';
        if(quote.Booking_Date__c != null){
            bookingDate = formatDate(quote.Booking_Date__c);
        }
        Map<String, NS_Terms_Mapping__c> termsMapping = new Map<String, NS_Terms_Mapping__c>();             //IBA-5882 AMAN
        String nsTermId = '';
        String nsTermText = '';
        
        List<NS_Terms_Mapping__c> nsMapping = [SELECT Id, NS_Term_ID__c, NS_Term_Text__c, Quote_Terms_of_Payment__c 
                                               FROM NS_Terms_Mapping__c where Quote_Terms_of_Payment__c = :quote.Terms_of_Payment__c];
        if(nsMapping.size()>0){
            
            nsTermId = nsMapping[0].NS_Term_ID__c;
            nsTermText = nsMapping[0].NS_Term_Text__c;
        }                                                                                                  //IBA-5882 AMAN
        
        String quoteJson = '"AccountId": "'+quote.AccountId+'","Account_CSN__c": "'+quote.Account_CSN__c+'","BillTo_CSN__c": "'+quote.BillTo_CSN__c+'",'+
            +'"ShipTo_CSN__c": "'+quote.ShipTo_CSN__c+'","Customer_Name__c": "'+quote.Account_Name_Text__c+'","Division_Account__c": "'+quote.Division__c+'",'+
            +'"Opportunity_Division__c": "'+quote.Opportunity.Opportunity_Division__c+'","Opportunity_Number__c": "'+quote.Opportunity.Opportunity_Number__c+'",'+
            +'"Supplement_Number__c": "'+quote.Quote_Number__c+'","Opportunity__c": "'+quote.Opportunity.Opportunity__c+'","OpportunityId": "'+quote.OpportunityId+'",'+
            +'"Opp_Name__c": "'+quote.Opportunity.Name+'","Ship_to_Account__r.Name": "'+quote.Ship_to_Account__r.Name+'",'+
            +'"Ship_to_Account__r.City": "'+quote.Ship_to_Account__r.BillingCity+'","Ship_to_Account__r.country": "'+quote.Ship_to_Account__r.Billingcountry+'",'+
            +'"Ship_to_Account__r.countryCode": "'+quote.Ship_to_Account__r.BillingcountryCode+'",'+
            +'"Ship_to_Account__r.Address_Line_2__c": "'+quote.Ship_to_Account__r.Address_Line_2__c+'",'+
            +'"Ship_to_Account__r.postalCode": "'+quote.Ship_to_Account__r.BillingpostalCode+'","Ship_to_Account__r.state": "'+quote.Ship_to_Account__r.Billingstate+'",'+
            +'"Ship_to_Account__r.stateCode": "'+quote.Ship_to_Account__r.BillingstateCode+'","Ship_to_Account__r.street": "'+quote.Ship_to_Account__r.Billingstreet+'",'+
            +'"Bill_to_Account__r.Name": "'+quote.Bill_to_Account__r.Name+'","Bill_to_Account__r.city": "'+quote.Bill_to_Account__r.Billingcity+'",'+
            +'"Bill_to_Account__r.country": "'+quote.Bill_to_Account__r.Billingcountry+'","Bill_to_Account__r.countryCode": "'+quote.Bill_to_Account__r.BillingcountryCode+'",'+
            +'"Bill_to_Account__r.Address_Line_2__c": "'+quote.Bill_to_Account__r.Address_Line_2__c+'",'+
            +'"Bill_to_Account__r.postalCode": "'+quote.Bill_to_Account__r.BillingpostalCode+'","Bill_to_Account__r.state": "'+quote.Bill_to_Account__r.Billingstate+'",'+
            +'"Bill_to_Account__r.stateCode": "'+quote.Bill_to_Account__r.BillingstateCode+'",'+
            +'"Bill_to_Account__r.street": "'+quote.Bill_to_Account__r.BillingStreet+'",'+
            +'"QuoteId": "'+quote.Id+'","Name": "'+quote.Name+'","Order_Type__c": "'+quote.Order_Type__c+'",'+
            +'"ECC_Sales_Order_Number__c": "'+quote.ECC_Sales_Order_Number__c+'",'+
            +'"CurrencyIsoCode": "'+quote.CurrencyIsoCode+'",'+            
            +'"NetSuite_ID__c": "'+quote.NetSuite_ID__c+'",'+'"Product_PO_Number__c": "'+quote.Product_PO_Number__c+'",'+
            +'"Shipping_Contact__r.name": "'+quote.Shipping_Contact__r.Name+'","Shipping_Contact__r.email": "'+quote.Shipping_Contact__r.Email+'",'+
            +'"Booking_Date__c": "'+bookingDate+'","NS_Term_ID__c": "' + nsTermId + '", "NS_Term_Text__c": "' + nsTermText + '"';                    //IBA-5883
        return quoteJson;
    }
    
    public static Boolean getMultisiteflag(Quote_Line__c qtline){
        if(qtline.Sales_Text__c != '' && qtline.Sales_Text__c != null){
            if(qtline.Sales_Text__c.trim().toUpperCase().contains('OMNICELL ONE IMPLEMENTATION') && qtline.Sales_Text__c.trim().contains('1')){
                return false;
            }
            else{
                return true;
            }
        }
        else{
            return true;
        }
    }
    
    public static String getQuoteLinejson(Quote quote, Quote_Line__c qtline, Map<Decimal,Quote_Line__c> saplineQuoteLineMap,Set<String> rreProdCodes){
        Boolean multisiteflag = false;
        Boolean printflag = false;
        Decimal billingterm;
        Decimal initpercentage = null;   
        Decimal subseqpercentage = null;  
        Decimal recurrAmount = null; 
        Decimal totalcustPrice = 0;
        if(qtline.Total_Customer_Price__c != null){
            totalcustPrice = qtline.Total_Customer_Price__c;
        }
        
        //IBA-5783 Starts
        String bookingScheduleStartDate = '';
        if(quote.Booking_Date__c != null){
            bookingScheduleStartDate = formatDate(quote.Booking_Date__c.addMonths(Integer.valueOf(Label.BILLING_DELAY_MONTHS)));
        }
        
        //IBA-5783 Ends
        String invoicingGroup = '';
        if(quote.Order_Type__c == 'ZQR'){                                                                        //IBA-5783
            if(qtline.DW_Product_Line__c == 'Inventory Optimization Service' && qtline.Product_Code__c != 'OC1-LAB-001' && qtline.Product_Code__c != 'OC1-SVC-001'){ // Case #1
                
                multisiteflag = getMultisiteflag(qtline);
                
                billingterm = quote.Service_Duration__c;
                recurrAmount = qtline.Total_Customer_Price__c/quote.Service_Duration__c;
                if(qtline.Higher_Level_Item__c == 0){
                    invoicingGroup = saplineQuoteLineMap.get(qtline.SAP_Line_Number__c).Line_Item_Description__c;
                }
                else{
                    invoicingGroup = saplineQuoteLineMap.get(qtline.Higher_Level_Item__c).Line_Item_Description__c;
                }
            }
            //IBA-5783 Starts
            else if (qtline.DW_Product_Line__c == 'Inventory Optimization Service' && (qtline.Product_Code__c == 'OC1-LAB-001' || qtline.Product_Code__c == 'OC1-SVC-001')) { 
                
                billingterm = 1;
                recurrAmount = qtline.Total_Customer_Price__c;
                
                multisiteflag = getMultisiteflag(qtline);
                
                if (qtline.Higher_Level_Item__c == 0) {
                    invoicingGroup = saplineQuoteLineMap.get(qtline.SAP_Line_Number__c).Line_Item_Description__c;
                } else {
                    invoicingGroup = saplineQuoteLineMap.get(qtline.Higher_Level_Item__c).Line_Item_Description__c;
                }
            }
            
            //IBA-5783 Ends
            
            else if(qtline.DW_Product_Line__c == 'Professional Services'){ // Case #2
                initpercentage = 70;          //IBA-5995
                subseqpercentage = 30;        //IBA-5995
                invoicingGroup = 'Professional Services';
            }
            else if(qtline.Product_Code__c.contains('-SV')){//Case #3
                billingterm = quote.Service_Duration__c;
                recurrAmount = qtline.Total_Customer_Price__c/quote.Service_Duration__c;
                invoicingGroup = qtline.Line_Item_Description__c;
            }
            else{//Case #4
                billingterm = 1;                                       //IBA-5783
                recurrAmount = qtline.Total_Customer_Price__c;
                
                if(qtline.Part_of_a_Bundle__c ){
                    invoicingGroup = saplineQuoteLineMap.get(qtline.Higher_Level_Item__c).Line_Item_Description__c;
                    
                }
                else{
                    invoicingGroup = qtline.Line_Item_Description__c;
                    
                }
            }
        }
        else if(quote.Order_Type__c == 'ZQRS'){
            if(rreProdCodes.contains(qtline.Product_Code__c)){//Case #5
                billingterm = quote.Resident_Operator_Duration__c;
                recurrAmount = quote.Resident_Operator_Solution_Fee__c;
                invoicingGroup = qtline.Line_Item_Description__c;
            }
            else if(qtline.DW_Product_Line__c == 'Professional Services' ){ // Case #2 #6       
                initpercentage = 70;          //IBA-5995
                subseqpercentage = 30;        //IBA-5995
                invoicingGroup = 'Professional Services';
                billingterm = null;                                              //IBA-5783
                recurrAmount = null;                                             //IBA-5783   
            }
            
            else if(qtline.Product_Code__c.startsWith('IVS-SVC-004')){  //IBA-5874 //case #6a       
                initpercentage = 70;         //IBA-5995
                subseqpercentage = 30;       //IBA-5995
                invoicingGroup = 'IVX Workflow Professional Services';
                billingterm = null;                                              
                recurrAmount = null;
            }                                                                                    
            else {          //Case #7 
                if (!qtline.Product_Code__c.startsWith('IVS-SVC-004')){                    //IBA-5874 AMAN
                    billingterm = quote.Service_Duration__c;
                    if(quote.Service_Duration__c != null && qtline.Total_Customer_Price__c != null)
                        recurrAmount = qtline.Total_Customer_Price__c/quote.Service_Duration__c;
                    if(qtline.Higher_Level_Item__c == 0){
                        invoicingGroup = saplineQuoteLineMap.get(qtline.SAP_Line_Number__c).Portfolio_Segment__c;
                    }
                    else{
                        invoicingGroup = saplineQuoteLineMap.get(qtline.Higher_Level_Item__c).Portfolio_Segment__c;
                    }
                }
                
            }
        }
        
        String item_desc = '';
        if(qtline.Line_Item_Description__c != null && qtline.Line_Item_Description__c.length()>0){
            item_desc = replaceDoubleQuotes(qtline.Line_Item_Description__c);
        }
        if(invoicingGroup != null && invoicingGroup.length()>0){
            invoicingGroup = replaceDoubleQuotes(invoicingGroup);
        }
        
        String qtLinejson = '{"Id":"'+qtline.Id+'","Name":"'+qtline.Name+'","SAP_Line_Number__c":'+qtline.SAP_Line_Number__c+','+
            +'"Higher_Level_Item__c":'+qtline.Higher_Level_Item__c+',"Portfolio_Segment__c":"'+qtline.Portfolio_Segment__c+'","DW_Product_Line__c":"'+qtline.DW_Product_Line__c+'",'+
            +'"Product_Code__c":"'+qtline.Product_Code__c+'","Line_Item_Description__c":"'+item_desc+'","Quantity__c":'+qtline.Quantity__c+','+
            +'"Sales_Text__c":"'+replaceDoubleQuotes(qtline.Sales_Text__c)+'","NetSuite_Line_ID__c":"'+qtline.NetSuite_Line_ID__c+'",'+
            +'"MultiSite_Flag__c":'+multisiteflag+',"Initial_Percentage__c":"'+initpercentage+'","Subsequent_Percentage__c":"'+subseqpercentage+'",'+
            +'"Billing_Term__c":"'+billingterm+'","Recurring_Amount__c":"'+recurrAmount+'","Print__c":'+printflag+','+
            +'"Total_Customer_Price__c":'+totalcustPrice+',"Invoicing_Group__c":"'+invoicingGroup+'",'+
            +'"Billing_Schedule_Delay_Months__c":'+Integer.valueOf(Label.BILLING_DELAY_MONTHS)+','+
            +'"Billing_Schedule_Start_Date__c":"'+bookingScheduleStartDate+'",'+
            +'"Rebate_Buyout_Adjustment__c":"'+qtline.Rebate_Buyout_Adjustment__c+'"}';
        
        return qtLinejson;
    } 
    
    public static String getDummyInterestLinejson(Quote quote){
        String item_desc = 'INTEREST';
        item_desc = replaceDoubleQuotes(item_desc);
        String bookingScheduleStartDate = '';
        if(quote.Booking_Date__c != null){
            bookingScheduleStartDate = formatDate(quote.Booking_Date__c.addMonths(Integer.valueOf(Label.BILLING_DELAY_MONTHS)));
        }
        String qtLinejson = '{"Id":null,"Name":null,"SAP_Line_Number__c":'+Label.INTEREST_SAP_Line_Number+','+
            +'"Higher_Level_Item__c":0,"Portfolio_Segment__c":null,"DW_Product_Line__c":null,'+
            +'"Product_Code__c":"INTEREST","Line_Item_Description__c":"'+item_desc+'","Quantity__c":1,'+
            +'"Sales_Text__c":null,"NetSuite_Line_ID__c":null,'+
            +'"MultiSite_Flag__c":null,"Initial_Percentage__c":null,"Subsequent_Percentage__c":null,'+
            +'"Billing_Term__c":"'+quote.Service_Duration__c+'","Recurring_Amount__c":"0","Print__c":null,'+
            +'"Total_Customer_Price__c":0,"Invoicing_Group__c":"Interest",'+                        // IBA-5783
            +'"Billing_Schedule_Delay_Months__c":'+Label.BILLING_DELAY_MONTHS+','+  
            +'"Billing_Schedule_Start_Date__c":"'+bookingScheduleStartDate+'",'+
            +'"Rebate_Buyout_Adjustment__c":"0"}';
        return qtLinejson;
    }
    //IBA-5783 Starts
    public static String getRebateLinejson(Quote quote){
        if (quote.Rebate_Amount__c > 0) {
            String item_desc = 'REBATE';
            item_desc = replaceDoubleQuotes(item_desc);
            String bookingScheduleStartDate = '';
            if(quote.Booking_Date__c != null){
                bookingScheduleStartDate = formatDate(quote.Booking_Date__c.addMonths(Integer.valueOf(Label.BILLING_DELAY_MONTHS)));
            }
            String qtLinejson = '{"Id":null,"Name":null,"SAP_Line_Number__c":'+Label.REBATE_SAP_Line_Number+','+
                +'"Higher_Level_Item__c": 0,"Portfolio_Segment__c":null,"DW_Product_Line__c":null,'+
                +'"Product_Code__c":"REBATE","Line_Item_Description__c":"'+item_desc+'","Quantity__c":1,'+
                +'"Sales_Text__c":null,"NetSuite_Line_ID__c":null,'+
                +'"MultiSite_Flag__c":null,"Initial_Percentage__c":null,"Subsequent_Percentage__c":null,'+
                +'"Billing_Term__c": null,"Recurring_Amount__c":null,"Print__c":null,'+
                +'"Total_Customer_Price__c":0,"Invoicing_Group__c":"Rebate",'+                        
                +'"Billing_Schedule_Delay_Months__c":'+Label.BILLING_DELAY_MONTHS+','+  
                +'"Billing_Schedule_Start_Date__c":"'+bookingScheduleStartDate+'",'+
                +'"Rebate_Buyout_Adjustment__c":"0"}';
            return qtLinejson;
        } 
        else{
            return '';
            
        }
        
    }
    
    //IBA- 5783 ENDS
    public static String formatDate(Date bookingDate){
        Integer day = bookingDate.day();
        Integer month = bookingDate.month();
        Integer year = bookingDate.year();
        String dd;
        String mm;
        String yyyy = String.valueOf(year);
        if(day < 10){
            dd = '0'+String.valueOf(day);
        }
        else{
            dd = String.valueOf(day);
        }
        if(month < 10){
            mm = '0'+String.valueOf(month);
        }
        else{
            mm = String.valueOf(month);
        }    
        return yyyy+'-'+mm+'-'+dd;
    }
    
    public static String getFreightLinejson(Quote_Line__c qtline, Quote quote){
        String item_desc = '';
        //IBA-5783 Starts
        String bookingScheduleStartDate = '';
        if(quote.Booking_Date__c != null){
            bookingScheduleStartDate = formatDate(quote.Booking_Date__c.addMonths(Integer.valueOf(Label.BILLING_DELAY_MONTHS)));
        }
        
        //IBA-5783 Ends
        if(qtline.Line_Item_Description__c.length()>0){
            item_desc = replaceDoubleQuotes(qtline.Line_Item_Description__c);
        }
        String qtLinejson = '{"Id":"'+qtline.Id+'","Name":"'+qtline.Name+'","SAP_Line_Number__c":'+qtline.SAP_Line_Number__c+','+
            +'"Higher_Level_Item__c":0,"Portfolio_Segment__c":"'+qtline.Portfolio_Segment__c+'","DW_Product_Line__c":"'+qtline.DW_Product_Line__c+'",'+
            +'"Product_Code__c":"'+qtline.Product_Code__c+'","Line_Item_Description__c":"'+item_desc+'","Quantity__c":'+qtline.Quantity__c+','+
            +'"Sales_Text__c":"'+qtline.Sales_Text__c+'","NetSuite_Line_ID__c":"'+qtline.NetSuite_Line_ID__c+'",'+
            +'"MultiSite_Flag__c":null,"Initial_Percentage__c":null,"Subsequent_Percentage__c":null,'+
            +'"Billing_Term__c":"1","Recurring_Amount__c":"'+qtline.Customer_Price__c+'","Print__c":null,'+                                //IBA-5875 AMAN                 
            +'"Total_Customer_Price__c":'+qtline.Customer_Price__c+',"Invoicing_Group__c":"Freight",'+                                     //IBA-5875 AMAN
            +'"Billing_Schedule_Delay_Months__c":'+Integer.valueOf(Label.BILLING_DELAY_MONTHS)+','+                                          //IBA-5783 
            +'"Billing_Schedule_Start_Date__c":"'+bookingScheduleStartDate+'",'+
            +'"Rebate_Buyout_Adjustment__c":"'+qtline.Rebate_Buyout_Adjustment__c+'"}';
        return qtLinejson;
    }
    
    public static void callNetSuite(Quote quote, String jsontoSend){
        SCP_Integration_Details__c authMule = SCP_Integration_Details__c.getValues('NetSuite_MuleSoft_Authorization');
        String endpoint = '';
        String accessToken;
        Http h = new Http();
        accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
        HttpRequest request= new HttpRequest();
        request.setMethod(authMule.SCP_Method_Type__c);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+accessToken);
        request.setEndpoint(authMule.SCP_End_Point__c);     
        System.debug(authMule.SCP_End_Point__c);
        request.setBody(jsontoSend);
        request.setTimeout(120000); 
        HttpResponse res = h.send(request);
        NetSuite_Res_Parser responseFromMS = new NetSuite_Res_Parser();
        if(res.getstatusCode() == 201){
            System.debug(res.getBody());
            String response = res.getBody(); 
            System.debug(System.JSON.deserialize(response, NetSuite_Res_Parser.class));    
            responseFromMS = NetSuite_Res_Parser.Parse(response);
            System.debug(responseFromMS);
            System.debug(responseFromMS.SalesOrder_NetsuiteId);
            List<NetSuite_Res_Parser.LineItems_NetsuiteIds> NetsuiteItems = responseFromMS.LineItems_NetsuiteIds;
            System.debug(NetsuiteItems);
            Map<Decimal,String> sapLineItemNetsuiteMap = new Map<Decimal,String>();
            for(NetSuite_Res_Parser.LineItems_NetsuiteIds netsuiteItem:NetsuiteItems){
                sapLineItemNetsuiteMap.put(Decimal.valueOf(netsuiteItem.sap_item_number),netsuiteItem.NetsuiteId);
            }
            Quote quoteToupdate = [Select Id,NetSuite_ID__c,NetSuite_Integration_Message__c From Quote Where Id =:quote.Id];//IBA-5961 Sourav
            quoteToupdate.NetSuite_ID__c = responseFromMS.SalesOrder_NetsuiteId;
            if(quoteToupdate.NetSuite_Integration_Message__c != ''){ //IBA-5961 Sourav
                quoteToupdate.NetSuite_Integration_Message__c = '';
            }
            List<Quote_Line__c> quoteLinesToupdate = [Select Id,NetSuite_Line_ID__c,SAP_Line_Number__c From Quote_Line__c Where Quote__c =: quote.Id];
            for(Quote_Line__c qt:quoteLinesToupdate ){
                qt.NetSuite_Line_ID__c = sapLineItemNetsuiteMap.get(qt.SAP_Line_Number__c);
            }
            QuoteTriggerHandler.TriggerDisabled = True;
            QuoteLineTriggerHandler.TriggerDisabled = True;
            try{
                update quoteToupdate;
                update quoteLinesToupdate;
            }
            catch(DmlException e){
                System.debug(e);
            }
        }
        else{
            System.debug(res);
        }
    }
    
    public static String replaceDoubleQuotes(String str){
        if(str!=null && str.length()>0){
        	str = str.replace('"', '\\"');
        }
        return str;
    }    
}