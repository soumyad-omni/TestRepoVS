/***********************************************************************************************************
Name:  SCP_OrderSubmit_Req_Wrapper
Copyright © 2019
============================================================================================================
============================================================================================================
Purpose: 
This class is the request wrapper class for order submit webservice

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION       AUTHOR                      DATE                   Description
1.0        Karthik Raj Golakaram        01/27/2021             INITIAL DEVELOPMENT
*************************************************************************************************************/
Public With Sharing class SCP_OrderSubmit_Req_Wrapper{

    Public Static String createJSONRequestBody(List<ccrz__E_Order__c> ordertoWrapList,list<ccrz__E_CartCoupon__c> cartCouponList){
        String requestBodyString='';
        Boolean isShippingCouponEnabled=FALSE;
        Boolean isCCPaymentMade=FALSE;
        
       System.debug('Priinting all cart coupons'+cartCouponList+cartCouponList);
       List<orderSubmitWrap> wrappedOrderInfo=new List<orderSubmitWrap>();
        if(!cartCouponList.isEmpty()){
            for(ccrz__E_CartCoupon__c coupon: cartCouponList){
                System.debug('Printing the value shipping value shipping in order submit'+coupon.ccrz__Coupon__r.ccrz__RuleType__c);
                if(coupon.ccrz__Coupon__r.ccrz__RuleType__c=='Shipping'){
                   isShippingCouponEnabled=TRUE; 
                }
            }
        }
       
       wrappedOrderInfo.add(new orderSubmitWrap(ordertoWrapList[0],cartCouponList,isShippingCouponEnabled));                                              
       requestBodyString=JSON.serialize(wrappedOrderInfo);
       System.debug('Printing request body'+requestBodyString);
       return requestBodyString;
        
    }
    
    Public class orderSubmitWrap{
    Public String IV_ORDER_TYPE;
    Public String IV_SOLD_TO;
    Public String IV_SHIP_TO;
    Public String IV_CONTACT;
    Public String IV_BILL_TO;
    Public String IV_CURRENCY;
    Public String IV_NOTE;
    Public String IV_NAME;
    Public String IV_SALES_ORG;
    Public String IV_DISTR_CHAN;
    Public String IV_DIVISION;
    Public String IV_SHIP_COND;//MAy Need to Comment because dependent on order simulate
    Public String IV_PURCH_NO_C;
    Public String IV_CREDIT_CARD;
    Public String IV_COMMIT;
    Public Decimal IV_SHIP_AMOUNT;
    Public String IV_COUPON;
    Public String IV_SHIPPING_CONTACT;
    Public ITEMS ITEMS;
	Public String Ship_Con_FName;//SCP-850
    Public String Ship_Con_LName;//SCP-850
    Public String Ship_Con_Phone;//SCP-850
    Public String IV_AUTH_CODE; // IBA-5834
        
       
        
        Public orderSubmitWrap(ccrz__E_Order__c orderInfo,List<ccrz__E_CartCoupon__c> cartCouponsApplied,Boolean isShippingCouponEnabled){
            this.Ship_Con_FName= orderInfo.ccrz__ShipTo__r.ccrz__FirstName__c;//SCP-850
            this.Ship_Con_LName= orderInfo.ccrz__ShipTo__r.ccrz__LastName__c;//SCP-850
            this.Ship_Con_Phone= orderInfo.ccrz__ShipTo__r.ccrz__HomePhone__c;//SCP-850
            
            this.IV_ORDER_TYPE='ZORB';
            
            this.IV_SOLD_TO= orderinfo.ccrz__OriginatedCart__r.SAP_SOLD_TO__c;   
             
            this.IV_CONTACT= orderInfo.ccrz__Contact__r.SAP_Contact_ID__c ;
           this.IV_BILL_TO=  orderinfo.ccrz__OriginatedCart__r.SAP_Billing_Customer_Number__c;
           this.IV_SHIP_TO= orderinfo.ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c; 
            this.IV_SHIPPING_CONTACT= orderinfo.ccrz__OriginatedCart__r.SAP_CONTACT_ID__c ;  
            
             if(String.isNotEmpty(orderinfo.ccrz__OriginatedCart__r.SAP_CONTACT_ID__c)){
                this.IV_SHIPPING_CONTACT= orderinfo.ccrz__OriginatedCart__r.SAP_CONTACT_ID__c ;
              
            }else{
                this.IV_SHIPPING_CONTACT=orderInfo.ccrz__Contact__r.SAP_Contact_ID__c;
            }
           
            this.IV_CURRENCY='USD';
            //this.IV_NOTE=orderInfo.ccrz__Note__c;
            this.IV_NOTE=orderInfo.ccrz__ShipTo__r.ccrz__ShippingComments__c;
            this.IV_NAME=orderInfo.Name;
            this.IV_SALES_ORG='OM01';
            this.IV_DISTR_CHAN='01';
            this.IV_DIVISION='00'; 
            //this.IV_SHIP_COND= will get this information from order simulate 
            if(!orderInfo.ccrz__TransactionPayments__r.isEmpty()){
                if(orderInfo.ccrz__TransactionPayments__r[0].ccrz__AccountType__c.equalsIgnoreCase('po')){
                
                    this.IV_PURCH_NO_C=orderInfo.ccrz__TransactionPayments__r[0].ccrz__AccountNumber__c;
                }
                // IBA-5834 Start
                if(orderInfo.ccrz__TransactionPayments__r[0].ccrz__AccountType__c.equalsIgnoreCase('sopcc')){
                	String ccNumber = orderInfo.ccrz__TransactionPayments__r[0].ccrz__AccountNumber__c.trim();
                    if(String.isNotBlank(ccNumber)){
                        this.IV_CREDIT_CARD = ccNumber.substring(12, 16);
                    }
                    this.IV_AUTH_CODE = orderInfo.ccrz__TransactionPayments__r[0].ccrz__Token__c;
                }else if(!orderInfo.ccrz__TransactionPayments__r[0].ccrz__AccountType__c.equalsIgnoreCase('po')){
                // IBA-5834 End
                    this.IV_CREDIT_CARD='X';
                } 
            }else if(orderInfo.ccrz__TransactionPayments__r.isEmpty() && orderInfo.ccrz__CCSubscription__c != null ){
                this.IV_CREDIT_CARD='X';
            }
            this.IV_COMMIT='X';
            this.IV_SHIP_COND=orderInfo.SHIP_COND__c;
            this.IV_SHIP_AMOUNT=orderInfo.ccrz__ShipAmount__c;
            if(isShippingCouponEnabled && orderInfo.ccrz__CCSubscription__c == null){  
                this.IV_COUPON='X';
            }else{
                this.IV_COUPON='';
            }
System.debug(this.IV_CREDIT_CARD+' Values: '+this.IV_AUTH_CODE);           
            
            this.ITEMS=new ITEMS(orderInfo);
             
        }
        
    }
    
    Public Class ITEMS{
        Public List<ITEM> ITEM;
        
        Public ITEMS(ccrz__E_Order__c orderInformation){
            ITEM=new List<ITEM>();
            for(ccrz__E_OrderItem__c orderItem:orderInformation.ccrz__E_OrderItems__r){
            if (orderItem.ccrz__PricingType__c == 'attrGroup')
                continue;
                this.ITEM.add(new ITEM(orderItem, orderInformation));
            }
        }
    }
    
    public class ITEM {
        public String ITEM_NUMBER;
        public String ITEM_MATERIAL; 
        public Decimal ITEM_TARGET_QTY;
        public String ITEM_TARGET_QU;
        public String ITEM_COUPON_CODE; //SCP-842 
        public Decimal ITEM_ABS_DISCOUNT; //SCP-842
        public Decimal ITEM_PER_DISCOUNT; //SCP-842
        public Decimal ITEM_DISC_QTY; //SCP-842
        public String  ITEM_FREE_SHIP; //SCP-842
        public String ITEM_CAS_NDC_UPC; //Canister and Cassette project
        public String ITEM_CAS_MACHINE_TYPE; //Canister and Cassette project
        public String ITEM_CAS_OPERATION; //Canister and Cassette project
        public Decimal ITEM_CAS_PRICE; //Canister and Cassette project
        public String ITEM_CAS_IS_FREE; //Canister and Cassette project
        public String ITEM_CAS_REF_SALES_ORDER; //Canister and Cassette project
        public String ITEM_CAS_MACHINE_ID; //Canister and Cassette project
        
        public ITEM(ccrz__E_OrderItem__c orderItemInfo, ccrz__E_Order__c order){
            this.ITEM_NUMBER=orderItemInfo.Name;
            //this.ITEM_MATERIAL=orderItemInfo.ccrz__Product__r.ccrz__SKU__c; **** Moved to Canisters and Cassettes project coding section            
            this.ITEM_TARGET_QTY=orderItemInfo.ccrz__Quantity__c;
            this.ITEM_TARGET_QU=orderItemInfo.ccrz__UnitOfMeasure__c;
        	this.ITEM_ABS_DISCOUNT = orderItemInfo.ccrz__AbsoluteDiscount__c; //SCP-842 begins
        	this.ITEM_PER_DISCOUNT = orderItemInfo.ccrz__PercentDiscount__c;
        	this.ITEM_DISC_QTY = orderItemInfo.Discounted_Quantity__c;
            if (orderItemInfo.Discounted_Quantity__c > 0){
                try {
                    ccrz__E_Coupon__c coupon = [SELECT ccrz__CouponCode__c, Free_Shipping_Applied__c
                	    						FROM ccrz__E_Coupon__c
                    							WHERE ccrz__TargetProduct__c = :orderItemInfo.ccrz__Product__c
                    							AND ccrz__Enabled__c != FALSE
                                                AND ccrz__EndDate__c > TODAY
         										LIMIT 1];
                    this.ITEM_COUPON_CODE = coupon.ccrz__CouponCode__c;
                    if (coupon.Free_Shipping_Applied__c)
                        this.ITEM_FREE_SHIP = 'X';
                    else
                        this.ITEM_FREE_SHIP = '';
                }
                catch (Exception e){
                    this.ITEM_COUPON_CODE = '';
                    this.ITEM_FREE_SHIP = '';
                }
            }//SCP-842 ends
			if (orderItemInfo.DrugCodes__c != NULL){  //Coding for Canister and Cassette project starts
            	this.ITEM_CAS_NDC_UPC = orderItemInfo.DrugCodes__r.DrugCodes__c;
                if (orderItemInfo.DrugCodes__r.Drug_Type__c == 'NDC')
                	this.ITEM_CAS_NDC_UPC = this.ITEM_CAS_NDC_UPC.left(this.ITEM_CAS_NDC_UPC.length() - 2) + 'XX';
                if (orderItemInfo.ccrz__SubAmount__c <= 0)
                	this.ITEM_CAS_IS_FREE = 'X';
            	else
                	this.ITEM_CAS_IS_FREE = NULL;
                switch on orderItemInfo.ccrz__SecondaryAttr__r.ccrz__DisplayName__c.toUppercase() {
                    when 'CANISTER'{
                        this.ITEM_CAS_MACHINE_TYPE = '2';
                    }
                    when 'CASSETTE', 'BRAKE', 'BASE', 'VBM', 'RFID' {
                        this.ITEM_CAS_MACHINE_TYPE = '1';
                    }               
                    when else {
                        this.ITEM_CAS_MACHINE_TYPE = NULL;
                    }
                }
            }
            switch on orderItemInfo.ccrz__Product__r.ccrz__SKU__c {
                when 'NEW-CALIB'{
                	this.ITEM_CAS_OPERATION = 'X';
                }
                when 'RECALIB'{
                	this.ITEM_CAS_OPERATION = 'C';
                }
                when 'REPAIR'{
                	this.ITEM_CAS_OPERATION = 'R';
                }               
                when else {
                	this.ITEM_CAS_OPERATION = NULL;
                }
            }            
            this.ITEM_CAS_PRICE = orderItemInfo.ccrz__Price__c;
	    	this.ITEM_MATERIAL=orderItemInfo.Material__c;
            this.ITEM_CAS_REF_SALES_ORDER = String.valueOf(orderItemInfo.Machines__r.Original_Sales_order_Number__c);
        	this.ITEM_CAS_MACHINE_ID = String.valueOf(orderItemInfo.Machines__r.Machine_Id__c);
		// Coding for Canister and Cassette project ends        
        }
    }
       
}