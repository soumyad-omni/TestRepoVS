/**
* @File Name          : DealModelingController.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 8/5/2020, 10:29:28 pm
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    8/5/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class DealModelingController {
    
    public static String quoteOrderType = '';
    public static Decimal quoteSubscriptionTerm = 0;
    public static String quoteFreight = '0';
     //IBA-1476 START
    public static Decimal residentOperatorAmount = 0;
    public static Decimal residentOperatorTerm = 0;
    //IBA-1476 END
    public static Decimal quoteProfessionalServicesValue = 0;
    public static String residentDuration = '0.00'; //Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
    public static boolean eAdopterFlag = false;//Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
    @AuraEnabled public static DealModelWrapper getQuote(String quoteId, String processType, String calc_gsa,String calc_margin, String calc_disc){
     /* List<Quote> lstQuote = [SELECT Id, Quote_Number__c,Order_Type__c,subscription_Months__c,Conga_one_time_Impl_Fee__c,Early_Adopter_Flag__c,
                                Conga_Total_Shipping_and_Handling__c FROM Quote WHERE Id =:quoteId]; */
        //Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
         List<Quote> lstQuote = [SELECT Id, Quote_Number__c,Order_Type__c,subscription_Months__c,Resident_Operator_Duration__c,Resident_Operator_Solution_Fee__c,Conga_one_time_Impl_Fee__c,Early_Adopter_Flag__c,
                                Conga_Total_Shipping_and_Handling__c FROM Quote WHERE Id =:quoteId]; 
        DealCalculator_AppConnect request = new DealCalculator_AppConnect();
        DealCalculator_AppConnect.IS_MARGIN_GSA quotemargin = new DealCalculator_AppConnect.IS_MARGIN_GSA();
        quotemargin.QUOTE_ID = lstQuote.isEmpty() || lstQuote[0].Quote_Number__c == null ? '' : String.valueOf(Integer.valueOf(lstQuote[0].Quote_Number__c)) ;
        String sap_quote_number = quotemargin.QUOTE_ID;
        //quotemargin.QUOTE_ID = '5400168';//5333859
        quotemargin.CALC_GSA = calc_gsa;
        if(lstQuote.isEmpty() == false)
        {
            quoteOrderType = lstQuote[0].Order_Type__c; //added by jay CR-18666
            quoteSubscriptionTerm = lstQuote[0].subscription_Months__c; //added by jay CR-18666   
            quoteFreight = lstQuote[0].Conga_Total_Shipping_and_Handling__c; 
            quoteProfessionalServicesValue = lstQuote[0].Conga_one_time_Impl_Fee__c; 
            
            //Added by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
            eAdopterFlag = lstQuote[0].Early_Adopter_Flag__c;
            String months = lstQuote[0].Resident_Operator_Duration__c != null ? String.valueOf(lstQuote[0].Resident_Operator_Duration__c) : '0';
            residentDuration = lstQuote[0].Resident_Operator_Solution_Fee__c != null ? String.valueOf(lstQuote[0].Resident_Operator_Solution_Fee__c)+' (Term - '+months+' months)' : '0.00';
            //IBA-1476 START
            residentOperatorAmount = lstQuote[0].Resident_Operator_Solution_Fee__c != null ? lstQuote[0].Resident_Operator_Solution_Fee__c : 0.00;
            residentOperatorTerm = lstQuote[0].Resident_Operator_Duration__c != null ? lstQuote[0].Resident_Operator_Duration__c : 0;       
        	//IBA-1476 END
        }
        
        quotemargin.CALC_MARGIN = calc_margin;
        List<DealCalculator_AppConnect.IS_MARGIN_GSA> quotemargins = new List<DealCalculator_AppConnect.IS_MARGIN_GSA>{quotemargin};
            request.IS_MARGIN_GSA.add(quotemargin);
        system.debug('request***********'+request);
        /*try{
ZMARGINGSADISC response  = request.run();    
return new DealModelWrapper(response, false, ''); 
}catch (Exception ex){
System.debug('Error Occurred : ' + ex.getMessage());
return new DealModelWrapper(null, true, ex.getMessage());  
}*/
        try{
            
            ////////////// Added on March 12- replacing overcast with Appconnect START
            String responseString = '';
            String errormsg = '';
            Map<String, Object> jsondata = new Map<String, Object>{
                'QUOTE_ID' => sap_quote_number,
                    'CALC_MARGIN' => calc_margin,
                    'CALC_GSA' => calc_gsa};
                        String jsonstring = JSON.serialize(jsondata);
            CastIronIntegration__c CI = CastIronIntegration__c.getInstance('CastIronIntegration');
            String endpoint =   CI.DealCalculatorAppConnect_Endpoint__c;
            Http h= new Http();
            HttpRequest req= new HttpRequest();
            //req.setClientCertificateName('CastIronIntegration');
            req.setHeader('Content-Type','application/json');
            req.setHeader('accept','application/json');
            req.setBody(jsonstring);
            req.setMethod('POST');
            req.setEndpoint(endpoint);
            req.setTimeout(120000); 
            HttpResponse res=h.send(req);
            responseString = res.getBody();
            if(res.getStatusCode() == 200){
                system.debug('res.getBody()..'+res.getBody());
                DealCalculator_AppConnect response = DealCalculator_AppConnect.deserialize(res.getBody());
                return new DealModelWrapper(response, false, '');
            }
            
            
            //////////////Added on March 12- replacing overcast with Appconnect END
            
            return new DealModelWrapper(null, true, '');
            //DealCalculator_AppConnect response  = request.run();    
            //return new DealModelWrapper(response, false, ''); 
        }catch (Exception ex){
            System.debug('Error Occurred : ' + ex.getMessage());
            return new DealModelWrapper(null, true, ex.getMessage());  
        } 
    }
    //Added getOrderType by Sravan for SF-BUG-590 START
    @AuraEnabled public static String getOrderType(Id qId){
        Quote q = [select id,order_type__c from quote where id=:qId];
        System.debug('order type : '+q.Order_Type__c);
        if(q.order_type__c == 'ZQL3' || q.order_type__c == 'ZQR3' || q.order_type__c == 'ZQRL' || q.order_type__c == 'ZQLI')
            return 'lease';
        else
            return 'purchase';
    }
    //Added getOrderType by Sravan for SF-BUG-590 END
    //Item details which has the "Product Line" as FREIGHT OR SHARED shouldn't be displayed. 
    @AuraEnabled public static List<Product2> getProducts(List<String> setProductId){
        return [SELECT Id, Name, External_ID__c, DW_Product_Line__c FROM Product2 WHERE External_ID__c IN: setProductId AND DW_Product_Line__c != null ];//AND DW_Product_Line__c != 'FREIGHT' AND DW_Product_Line__c != 'Shared'
    }
    @AuraEnabled public static String saveCalculation(String dealModelW, String quoteId){
        Integer count = database.countQuery('SELECT COUNT() FROM Deal_Modeling_PDF__c WHERE Quote__c =:quoteId'); 
        DealModelWrapper objDealModelW = (DealModelWrapper) JSON.deserialize(dealModelW, DealModelWrapper.class);
        Deal_Modeling_PDF__c objDMPDF = new Deal_Modeling_PDF__c(Name = 'Quote #:'+Integer.valueOf(objDealModelW.data.ES_MARGIN_HDR.ORDER_NUM)+' V.' + (count +1),
                                                                 Transaction_No__c = String.valueOf(Integer.valueOf(objDealModelW.data.ES_MARGIN_HDR.ORDER_NUM)),  //Contains quote number
                                                                 Transaction_Type__c = objDealModelW.data.ES_MARGIN_HDR.ORDER_TYPE_DESC, //Transaction Type = Order Type Desc 
                                                                 Description__c = objDealModelW.data.ES_MARGIN_HDR.DESCRIPTION, //Description
                                                                 Business_Partner__c = String.valueOf(objDealModelW.data.ES_MARGIN_HDR.SOLD_TO_PARTY),//Business Partner = Sold to Party
                                                                 Employee_Responsible__c = objDealModelW.data.ES_MARGIN_HDR.EMP_RESP, //Employee Responsible = Emp Resp
                                                                 Status__c = objDealModelW.data.ES_MARGIN_HDR.STATUS,//Status
                                                                 Pricing_Date__c = objDealModelW.data.ES_MARGIN_HDR.PRICING_DATE,//Pricing Date
                                                                 GPO_Price_List__c = objDealModelW.data.ES_MARGIN_HDR.GPO_PRICE_DESC,//GPO Price DESC
                                                                 Service_Level__c = objDealModelW.data.ES_MARGIN_HDR.SERVICE_PRICE_DESC,//Service Price Desc
                                                                 Currency__c = objDealModelW.data.ES_MARGIN_HDR.CURRENCY_x,//Currency
                                                                 Service_Booking__c = objDealModelW.data.ES_MARGIN_HDR.SERVICE_BOOKING,//Service Booking
                                                                 Margin_Service_Percent__c = objDealModelW.data.ES_MARGIN_HDR.MARGIN_SERVICE,//Margin Service% 
                                                                 Service_Cost__c = objDealModelW.data.ES_MARGIN_HDR.SERVICE_COST,//Service Cost
                                                                 Service_Discount__c = objDealModelW.data.ZCRMFM_MARGIN_OVERCAST.SERV_DISC,//Service Discount
                                                                 Additional_Discount__c = objDealModelW.oldAdditionalDiscount,//Additional Discount
                                                                 USA_List_Price__c = objDealModelW.usaListPrice,//USA List Price
                                                                 USA_List_Price_Percentage__c =objDealModelW.USAListPricePercentage, //USA List Price Percentage
                                                                 Non_Discountable_Price__c = objDealModelW.nonDiscountablePrice,//Non Discountable Price
                                                                 Total_Product_Cost__c = objDealModelW.totalMaterial,// Total Product Cost = Total Material
                                                                 Contract_List_Price__c = objDealModelW.contractListPrice, //Contract List Price
                                                                 Contract_List_Price_Percentage__c = objDealModelW.ContractListPricePercentage, //Contract List Price Percentage
                                                                 Discountable_Only_Price__c = objDealModelW.discountable,// Discountable only Price = Discountable
                                                                 Total_Labor__c =objDealModelW.totalLabor, //Total Labor
                                                                 Discount__c = objDealModelW.discount,// Discount 
                                                                 Booking_Price__c = objDealModelW.bookingPrice, //Booking Price
                                                                 Total_Overhead__c= objDealModelW.totalOverhead,//Total Overhead
                                                                 Customer_Value_Price__c = objDealModelW.customerValuePrice,//Customer Value Price
                                                                 Total_Margin__c = objDealModelW.totalMargin,//Total Margin
                                                                 Total_Cost__c = objDealModelW.totalProductCost,//Total Cost = Total Product Cost
                                                                 Comission_Value__c = objDealModelW.commissionValue,// Comission Value
                                                                 Margin_Product_Percentage__c = objDealModelW.marginProduct,//Margin Prodcut %
                                                                 Discount_Amount__c = objDealModelW.oldDiscountAmount, //Discount Amount (Old discount/SAP Discount)
                                                                 Discount_Percentage__c= objDealModelW.oldDiscountPercentage,//Discount % (Old discount %)
                                                                 Order_Net_Price__c = objDealModelW.orderNetPrice, //Order Net Price
                                                                 GSA_Net_Price__c = objDealModelW.gsaNetPrice,//GSA Net Price
                                                                 GSA_Price__c = objDealModelW.gsaPrice, //GSA Price
                                                                 Result__c = objDealModelW.result,//Result
                                                                 IDN_Price_List__c = objDealModelW.data.ES_MARGIN_HDR.IDN_PRICE_DESC, //IDN Price List
                                                                 Quote__c = quoteId, //Quote ID
                                                                 Monthly_Fee__c = objDealModelW.monthly, 
                                                                 Professional_Services__c = objDealModelW.professionalServicesValue, 
                                                                 Freight__c = Decimal.valueOf(objDealModelW.freight), 
                                                                 Discountable_Parts_Total__c = objDealModelW.basediscount,
                                                                 Resident_Operator__c = objDealModelW.residentOperator,//Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
                                                                 Early_Adopter_Flag__c =  objDealModelW.earlyAdopterFlag//Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
                                                                
                                                                );
        System.debug('======objDMPDF======'+objDMPDF); 
        //set monthly, freight , professionalServicesValue
        insert objDMPDF;
        return objDMPDF.Id;
    }
    
    public class DealModelWrapper{
        @AuraEnabled public DealCalculator_AppConnect data;
        /*Start - Product Details*/
        @AuraEnabled public Decimal usaListPrice;
        @AuraEnabled public Decimal nonDiscountablePrice;
        @AuraEnabled public Decimal totalMaterial;
        @AuraEnabled public Decimal contractListPrice;
        @AuraEnabled public Decimal discountable; 
        @AuraEnabled public Decimal totalLabor;
        @AuraEnabled public Decimal discount;
        @AuraEnabled public Decimal bookingPrice;
        @AuraEnabled public Decimal totalOverhead;
        @AuraEnabled public Decimal customerValuePrice;
        @AuraEnabled public Decimal totalMargin;
        @AuraEnabled public Decimal totalProductCost;
        @AuraEnabled public Decimal commissionValue;
        @AuraEnabled public Decimal marginProduct;
        @AuraEnabled public Decimal leaseTerm;//Lease Term
        @AuraEnabled public Decimal freeLeaseTerm;//Free Lease Term
        @AuraEnabled public Decimal ContractListPricePercentage;
        @AuraEnabled public Decimal USAListPricePercentage;
        @AuraEnabled public Decimal basediscount; //soumyad sf-bug-1018
        /*End - Product Details*/
        
        /*Start - Discount Calculation*/
        @AuraEnabled public Boolean additionalDiscount;
        @AuraEnabled public Boolean oldAdditionalDiscount;
        @AuraEnabled public Decimal discountAmount;
        @AuraEnabled public Decimal discountPercentage;
        @AuraEnabled public Decimal oldDiscountAmount;
        @AuraEnabled public Decimal oldDiscountPercentage;
        /*End - Discount Calculation*/
        
        /*Start - GSA Calculation*/
        @AuraEnabled public Decimal orderNetPrice;
        @AuraEnabled public Decimal gsaNetPrice;
        @AuraEnabled public Decimal gsaPrice;
        @AuraEnabled public String result;
        @AuraEnabled public Decimal monthly; //soumyad sf-bug-1018
        @AuraEnabled public String residentOperator; //Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
        @AuraEnabled public boolean earlyAdopterFlag;//Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
        /*End - GSA Calculation*/
        
        /*Start - Error Handling */
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String errMsg;
        /*End - Error Handling */
        
        //Added by JAY - CR-18666
        @AuraEnabled public Boolean isQuoteOmnicellServiceOrderType;
        @AuraEnabled public Decimal subscriptionTerm;
        @AuraEnabled public String freight;
        //IBA-1476 START
        @AuraEnabled public Decimal professionalServicesValue;
        @AuraEnabled public Decimal residentOperatorValue;
        @AuraEnabled public Decimal residentOperatorDuration;
        //IBA-1476 END
        public DealModelWrapper(DealCalculator_AppConnect data, Boolean isError, String errMsg){
            this.data = data;
            this.isError = isError;
            this.errMsg = errMsg;
            if(data != null){
                this.isQuoteOmnicellServiceOrderType = (quoteOrderType == 'ZQRS') ? true : false;
                this.subscriptionTerm = quoteSubscriptionTerm;
                this.freight = quoteFreight;
                this.professionalServicesValue = quoteProfessionalServicesValue;
                this.usaListPrice = data.ES_MARGIN_HDR.USA_LPRICE_EXT;
                this.nonDiscountablePrice = data.ZCRMFM_MARGIN_OVERCAST.NON_DISCOUNTABLE;
                this.totalMaterial = data.ES_MARGIN_HDR.COST_EXT;
                this.contractListPrice = data.ES_MARGIN_HDR.CONT_LPRICE_EXT;
                this.discountable = data.ZCRMFM_MARGIN_OVERCAST.DISCOUNTABLE_ONLY;
                this.totalLabor = data.ES_MARGIN_HDR.LABOR_EXT;
                this.discount = data.ES_MARGIN_HDR.DISCOUNT_EXT;
                this.bookingPrice = data.ES_MARGIN_HDR.BOOKING_EXT;
                this.totalOverhead = data.ES_MARGIN_HDR.OVERHEAD_EXT;
                this.customerValuePrice = data.ES_MARGIN_HDR.VAL_CUST_EXT;
                this.totalMargin = data.ES_MARGIN_HDR.MARGIN_EXT;
                this.totalProductCost = data.ES_MARGIN_HDR.COST_EXT + data.ES_MARGIN_HDR.LABOR_EXT + data.ES_MARGIN_HDR.OVERHEAD_EXT;
                this.commissionValue = data.ES_MARGIN_HDR.COMMISSION_EXT;
                this.marginProduct = data.ES_MARGIN_HDR.MARGIN_PRODUCT;
                this.orderNetPrice = data.ES_GSA_CALC.ORDER_PRICE;
                this.gsaNetPrice = data.ES_GSA_CALC.GSA_PRICE;
                this.gsaPrice = data.ES_GSA_CALC.DIFF_PRICE;
                this.result = data.ES_GSA_CALC.RESULT;
                //IBA-1476 START
                this.residentOperatorValue = residentOperatorAmount;
                this.residentOperatorDuration = residentOperatorTerm;
                //IBA-1476 END
                //this.leaseTerm = data.ES_MARGIN_HDR.LEASE_TERM; //lease term
                //this.freeLeaseTerm = data.ES_MARGIN_HDR.FREE_LEASE; //Free lease term
                this.ContractListPricePercentage = data.ES_MARGIN_HDR.CONT_LPRICE_EXT != null && data.ES_MARGIN_HDR.CONT_LPRICE_EXT != 0 ? (data.ES_MARGIN_HDR.DISCOUNT_EXT/data.ES_MARGIN_HDR.CONT_LPRICE_EXT) * 100 : 0;
                this.USAListPricePercentage = data.ES_MARGIN_HDR.USA_LPRICE_EXT != null && data.ES_MARGIN_HDR.USA_LPRICE_EXT != 0 ? (data.ES_MARGIN_HDR.DISCOUNT_EXT/data.ES_MARGIN_HDR.USA_LPRICE_EXT) * 100 : 0;
                this.basediscount = data.ES_MARGIN_HDR.DISCOUNT_BASE; // soumyad sf-bug-1018
                this.monthly = data.ZCRMFM_MARGIN_OVERCAST.EV_MONTHLY_CHARGE; // soumyad sf-bug-1018
                this.residentOperator = residentDuration != '0' ? residentDuration : '0.00';//Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
                this.earlyAdopterFlag = eAdopterFlag;//Updated by Pavan palla as part of new XR2 & IVX changes IBA-1135 Nov-Release
            
            }
            this.additionalDiscount = true;
            this.oldAdditionalDiscount = true;
            this.discountAmount = oldDiscountAmount = discountPercentage = oldDiscountPercentage = 0.00;
        }
    }
}