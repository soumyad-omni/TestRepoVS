public without sharing class SCP_CartItemTriggerHandler {
    
    public void beforeInsertMethod(List <ccrz__E_CartItem__c> cartItemList){

		discountItem(cartItemList);

	}

    public void beforeUpdateMethod(List <ccrz__E_CartItem__c> cartItemList){

		discountItem(cartItemList);

	}

    public void discountItem(List <ccrz__E_CartItem__c> cartItemList){
        //IBA-3839
        Set<Id> productIds=new Set<Id>(); 
        for(ccrz__E_CartItem__c cartItem : cartItemList){
        
           productIds.add(cartItem.ccrz__Product__c);
        }
        Map<Id,List<ccrz__E_Coupon__c>> prodCouponsMap=new Map<Id,List<ccrz__E_Coupon__c>>();
        List<ccrz__E_Coupon__c> coupons= [SELECT id,ccrz__TargetProduct__c,ccrz__TargetQty__c
                	    FROM ccrz__E_Coupon__c
                    	WHERE ccrz__TargetProduct__c IN :productIds];
        
        for(ccrz__E_Coupon__c coupon:coupons){
            if(prodCouponsMap.containsKey(coupon.ccrz__TargetProduct__c)){
            	List<ccrz__E_Coupon__c> cups =prodCouponsMap.get(coupon.ccrz__TargetProduct__c);
                cups.add(coupon);
                prodCouponsMap.put(coupon.ccrz__TargetProduct__c,cups);
            }
            else{
                prodCouponsMap.put(coupon.ccrz__TargetProduct__c,new List<ccrz__E_Coupon__c>{coupon});
            }
        } //IBA-3839

        for(ccrz__E_CartItem__c cartItem : cartItemList){
        
    	    Id prod = cartItem.ccrz__Product__c;
        	Id cupn = cartItem.ccrz__Coupon__c;
        
        	try {
                               
            	/*Decimal discountQty = [SELECT ccrz__TargetQty__c
                	    FROM ccrz__E_Coupon__c
                    	WHERE ccrz__TargetProduct__c = :prod
                    	AND id = :cupn
         				LIMIT 1].ccrz__TargetQty__c;
				*/
            	//IBA-3839
                Decimal discountQty;
                if(prodCouponsMap.containsKey(prod)){
                List<ccrz__E_Coupon__c> couponList= prodCouponsMap.get(prod);
                for (ccrz__E_Coupon__c coupon:couponList){
                    if(coupon.id==cupn){
                        discountQty=coupon.ccrz__TargetQty__c;
                    } 
                }
              }//IBA-3839
               
                if (cartItem.ccrz__Coupon__c == NULL)
                	cartItem.Discounted_Quantity__c = 0;
            	else {
                	if (discountQty > cartItem.ccrz__Quantity__c)
                    	cartItem.Discounted_Quantity__c = cartItem.ccrz__Quantity__c;
                	else
                    	cartItem.Discounted_Quantity__c = discountQty;
            	}
        	}
        	catch (Exception e){
            		cartItem.Discounted_Quantity__c = 0;
        	}
    	}
        
    }
}