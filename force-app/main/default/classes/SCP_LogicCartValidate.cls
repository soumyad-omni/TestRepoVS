global with sharing class SCP_LogicCartValidate extends ccrz.ccLogicCartValidate {
    global virtual override Map<String, Object> processValidate(Map<String, Object> inputData) {
            
		inputData = super.processValidate(inputData);
            String cartID = ccrz.cc_CallContext.currCartId;
            String isB2Bnotdown= System.Label.isB2Bnotdown;
            if(Test.isRunningTest()){
                cartID = [Select Id from ccrz__E_Cart__c Limit 1].id;
            }
            Boolean checkOutAllowed = TRUE;
            Boolean hasDiscount = FALSE;
        	Boolean hasNonDiscount = FALSE;
            String errorMsg = '';
            ccrz.cc_bean_Message msg;
        
        if (isB2Bnotdown == 'FALSE') {
                checkOutAllowed = FALSE;
            	inputData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, checkOutAllowed);
            	return inputData;
        }
        
        try {
            List<ccrz__E_CartItem__c> cartItemList = [SELECT ccrz__Quantity__c, Discounted_Quantity__c FROM ccrz__E_CartItem__c WHERE ccrz__Cart__r.ccrz__EncryptedId__c = :cartId];
            
            for(ccrz__E_CartItem__c cartItem : cartItemList){
                if (cartItem.Discounted_Quantity__c > 0) {
                    hasDiscount = TRUE;
                    if (hasNonDiscount) {
                        errorMsg = 'Products with discount coupon cannot be mixed with other products in the cart. Please either delete the products, where coupon is not applicable from the cart or remove the coupon. Checkout will be enabled after that.';
           	            msg = new ccrz.cc_bean_Message(errorMsg,ccrz.cc_bean_Message.MessageType.CUSTOM);
                        msg.classToAppend = 'panel-heading';
                        msg.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                        checkOutAllowed = FALSE;
                        break;                        
                    }	
                    else {
                    	if (cartItem.Discounted_Quantity__c < cartItem.ccrz__Quantity__c) {
                        	errorMsg = 'Order quantity cannot be greater than discounted quantity. Please either reduce the order quantity and click on the Update link, otherwise remove the coupon. Checkout will be enabled after that.';
                        	msg = new ccrz.cc_bean_Message(errorMsg,ccrz.cc_bean_Message.MessageType.CUSTOM);
                            msg.classToAppend = 'panel-heading';
                            msg.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                            checkOutAllowed = FALSE;
                            break;
                        }
                    }
                }
                else {
                    hasNonDiscount = TRUE;
                    if (hasDiscount) {
                        errorMsg = 'Products with discount coupon cannot be mixed with other products in the cart. Please either delete the products, where coupon is not applicable from the cart or remove the coupon. Checkout will be enabled after that.';
           	            msg = new ccrz.cc_bean_Message(errorMsg,ccrz.cc_bean_Message.MessageType.CUSTOM);
                        msg.classToAppend = 'panel-heading';
                        msg.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
                        checkOutAllowed = FALSE;
                        break;
                    }
                } 
                
            }
            
            if (errorMsg != '')
               inputdata.put(ccrz.ccApi.MESSAGES, new List<ccrz.cc_bean_Message>{
                   msg
                });

        }
        catch (Exception e){
            System.debug('*** Exception ' + e);
        }
        inputData.put(ccrz.ccApiCart.ALLOW_CHECKOUT, checkOutAllowed);
        
        return inputData;
    }
}