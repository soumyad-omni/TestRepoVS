/***********************************************************************************************************
Name:  SCP_OrderSimulate_cartWrapper
Copyright © 2019
============================================================================================================
============================================================================================================
Purpose: 
This class can be called to make a create request body to perform order simulate

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION       AUTHOR                      DATE                   Description
1.0        Karthik Raj Golakaram        01/27/2021             INITIAL DEVELOPMENT
*************************************************************************************************************/
Public with Sharing class SCP_OrderSimulate_cartWrapper {
    
    

    Public static string orderSimulateGenerateReqBody(List<ccrz__E_Cart__c> cartInformationToWrapList){
        String requestBodyString='';
        Boolean isShippingCouponEnabled=FALSE;
        System.debug('Printing the coupon applied or not'+cartInformationToWrapList[0].ccrz__E_CartCoupons__r);
        if(!cartInformationToWrapList[0].ccrz__E_CartCoupons__r.isEmpty()){
            for(ccrz__E_CartCoupon__c coupon: cartInformationToWrapList[0].ccrz__E_CartCoupons__r){
                System.debug('Printing the value shipping value'+coupon.ccrz__Coupon__r.ccrz__RuleType__c);
                if(coupon.ccrz__Coupon__r.ccrz__RuleType__c=='Shipping'){
                   isShippingCouponEnabled=TRUE; 
                }
            }
        }
        
         List<cartWrap> wrappedCartInfo= new List<cartWrap>();
         wrappedCartInfo.add(new cartWrap(cartInformationToWrapList[0], isShippingCouponEnabled));
         requestBodyString = JSON.serialize(wrappedCartInfo);
         System.debug('Printing JSON Request Body to send to Mule Soft'+requestBodyString);                                                
         return requestBodyString;   
    }    
    
    Public class cartWrap{
        public String IV_ORDER_TYPE;
        public String IV_SOLD_TO;
        public String IV_SHIP_TO;
        public String IV_CONTACT;
        public String IV_BILL_TO;
        public String IV_CURRENCY;
        public String IV_NOTE;
        public String IV_NAME;
        public String IV_SALES_ORG;
        public String IV_DISTR_CHAN;
        public String IV_DIVISION;
        public String IV_SHIP_COND;
        public String IV_COUPON;
        public ITEMS ITEMS;
    
        Public cartWrap(ccrz__E_Cart__c cartInfo,Boolean isShippingCouponEnabled){
            this.IV_ORDER_TYPE='ZORB'; // Need to Create Custom Label. 
            
            account acc = [select id,SAP_Account_ID__c from account where id = : cartinfo.ccrz__EffectiveAccountID__c ]; 
            
            this.IV_SOLD_TO=cartInfo.SAP_SOLD_TO__c; 
            
          //  this.IV_BILL_TO= '0000036773';
         //  this.IV_SHIP_TO= '0000036773'; 
            
            this.IV_BILL_TO= cartInfo.SAP_Billing_Customer_Number__c ; 
           this.IV_SHIP_TO= cartInfo.SAP_Shipping_Customer_Number__c;  
              
            this.IV_CURRENCY='USD'; // Need to Create Custom Label
            this.IV_NOTE=cartInfo.ccrz__Note__c;
            this.IV_NAME=cartInfo.Name.right(6);
            this.IV_SALES_ORG='OM01';// Need to create a Custom Label.
            this.IV_DISTR_CHAN='01';
            this.IV_DIVISION='00'; 
            this.IV_SHIP_COND='Priority Overnight';
            if(isShippingCouponEnabled){
                this.IV_COUPON='X';
            }else{
                this.IV_COUPON='';
            }
            this.ITEMS=new ITEMS(cartInfo);

        }
      }
      
      Public class ITEMS{
          Public List<ITEM> ITEM;
          
          public ITEMS(ccrz__E_Cart__c cartInfoItems){
            ITEM=new List<ITEM>();
            for(ccrz__E_CartItem__c cz:cartInfoItems.ccrz__E_CartItems__r){
            if (cz.ccrz__PricingType__c == 'attrGroup')
                continue;
                this.ITEM.add(new ITEM(cz, cartInfoItems));
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
          
        public ITEM(ccrz__E_CartItem__c cartInfoItem, ccrz__E_Cart__c cart){
            this.ITEM_NUMBER=cartInfoItem.Name.right(6);
            //this.ITEM_MATERIAL=cartInfoItem.ccrz__Product__r.ccrz__SKU__c; **** Moved to Canisters and Cassettes project coding section
            this.ITEM_TARGET_QTY=cartInfoItem.ccrz__Quantity__c;
            this.ITEM_TARGET_QU=cartInfoItem.ccrz__UnitOfMeasure__c;
        	this.ITEM_ABS_DISCOUNT = cartInfoItem.ccrz__AbsoluteDiscount__c; //SCP-842 begins
        	this.ITEM_PER_DISCOUNT = cartInfoItem.ccrz__PercentDiscount__c;
        	this.ITEM_DISC_QTY = cartInfoItem.Discounted_Quantity__c;
            if (cartInfoItem.Discounted_Quantity__c > 0){
                try {
                    ccrz__E_Coupon__c coupon = [SELECT ccrz__CouponCode__c, Free_Shipping_Applied__c
                	    						FROM ccrz__E_Coupon__c
                    							WHERE ccrz__TargetProduct__c = :cartInfoItem.ccrz__Product__c
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
            if (cartInfoItem.DrugCodes__c != NULL){  //Coding for Canister and Cassette project starts
            	this.ITEM_CAS_NDC_UPC = cartInfoItem.DrugCodes__r.DrugCodes__c;
                if (cartInfoItem.DrugCodes__r.Drug_Type__c == 'NDC')
                	this.ITEM_CAS_NDC_UPC = this.ITEM_CAS_NDC_UPC.left(this.ITEM_CAS_NDC_UPC.length() - 2) + 'XX';
                if (cartInfoItem.ccrz__SubAmount__c <= 0)
                	this.ITEM_CAS_IS_FREE = 'X';
            	else
                	this.ITEM_CAS_IS_FREE = NULL;
            
                switch on cartInfoItem.ccrz__SecondaryAttr__r.ccrz__DisplayName__c.toUppercase() {
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
            
            switch on cartInfoItem.ccrz__Product__r.ccrz__SKU__c {
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
            this.ITEM_CAS_PRICE = cartInfoItem.ccrz__Price__c;
			this.ITEM_MATERIAL=cartInfoItem.Material__c;            
		// Coding for Canister and Cassette project ends
        }
    }
    
}