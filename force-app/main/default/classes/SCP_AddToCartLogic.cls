global with sharing class SCP_AddToCartLogic extends ccrz.ccLogicCartAddTo
{
    global virtual override Map<String, Object> applyTieredPricing(Map<String, Object> inputData){
        inputData = super.applyTieredPricing(inputData);
        return inputData;
        
    } 
    global virtual override Map<String, Object> setSubAmount(Map<String, Object> inputData){
        inputData = super.setSubAmount(inputData);  
        ccrz__E_CartItem__c curItem = (ccrz__E_CartItem__c)inputData.get('currItem');
        Map<String,Object> prodPriceJsonToMap = (Map<String,Object>)inputData.get('productPricingData');
        Map<String,Object> prodAllPrice = (Map<String,Object>)prodPriceJsonToMap.get(curItem.ccrz__Product__c);
        Map<String,Object> prodPrice = (Map<String,Object>)prodAllPrice.get('productPrice');
        
        
        String priceListItemId = (String)prodPrice.get('sfid');
        System.debug('***'+curItem.ccrz__Quantity__c);
        System.debug('*******'+curItem.ccrz__SubProdTerm__c);
		if(curItem.ccrz__SubProdTerm__c != null){ 
            String tierJSON = [Select id,ccrz__Price__c,ccrz__Product__c,ccrz__PricingTiers__c From ccrz__E_PriceListItem__c Where id =: priceListItemId Limit 1].ccrz__PricingTiers__c;
            if(tierJSON != Null){
                Map<String,Object> tierList = (Map<String,Object>)System.JSON.deserializeUntyped(tierJSON);
                List<object> tierPrice = (List<object>)tierList.get('tiers');
                List<Decimal> qty = new List<Decimal>();
                List<Decimal> absPrice = new List<Decimal>();
                
                for(object ob: tierPrice){
                    Map<String,Object> data = (Map<String,Object>)ob;
                    qty.add((Decimal)data.get('q'));
                    absPrice.add((Decimal)data.get('p'));
                    System.debug('***'+data.get('p'));
                }
                
                for(Integer i=0;i<4;i++){
                    System.debug('****'+i);
                    
                    System.debug('****'+curItem.ccrz__Quantity__c+'***'+qty[i]);
                    try{
                    if(curItem.ccrz__Quantity__c < qty[i]){
                        curItem.ccrz__Price__c = absPrice[i-1];
                        curItem.ccrz__OriginalItemPrice__c = absPrice[i-1];
                        curItem.ccrz__RecurringPrice__c = absPrice[i-1];
                        break;
                    }
                        
                    if(curItem.ccrz__Quantity__c == qty[i]){
                        curItem.ccrz__Price__c = absPrice[i];
                        curItem.ccrz__OriginalItemPrice__c = absPrice[i];
                        curItem.ccrz__RecurringPrice__c = absPrice[i];
                        break;
                    }
                       
                    }
                    catch(Exception e){System.debug(e);} 
                }
                
                curItem.ccrz__SubAmount__c = curItem.ccrz__Quantity__c * curItem.ccrz__Price__c;
                curItem.ccrz__RecurringPriceSubAmt__c = curItem.ccrz__RecurringPrice__c * curItem.ccrz__OriginalQuantity__c;
                inputData.put('currItem',curItem);
            }
        }
        return inputData;
    }
    global virtual override Map<String, Object> priceBasicProductItem(Map<String, Object> inputData){
        inputData = super.priceBasicProductItem(inputData);
        Map<String, Object> priceBasicMap = new Map<String, Object>(inputData);
        
        ccrz__E_CartItem__c curItem = (ccrz__E_CartItem__c)inputData.get('currItem');
        Id prodId = curItem.ccrz__Product__c;
        Map<String,Object> prodPrice = (Map<String,Object>)inputData.get('productPricingData');
       
        Map<String,Object> prodSub = (Map<String,Object>)prodPrice.get(curItem.ccrz__Product__c);
        
        Map<String,Object> subProdTerm = (Map<String,Object>)prodSub.get('subProductTerms');
        System.debug('*******'+prodSub.get('subProductTerms'));
        if(curItem.ccrz__SubProdTerm__c != null){     
            System.debug('*******'+curItem.ccrz__SubProdTerm__c);
            Map<String,Object> subProdTermPrice = (Map<String,Object>)subProdTerm.get(curItem.ccrz__SubProdTerm__c);
            System.debug('*******'+subProdTerm.get(curItem.ccrz__SubProdTerm__c));
            Map<String,Object> recPrice = (Map<String,Object>)subProdTermPrice.get('recurringPrice');
            Map<String,Object> nonrecPrice = (Map<String,Object>)subProdTermPrice.get('nonRecurringPrice');
            Map<String,Object> ptPrice = (Map<String,Object>)prodSub.get('productPrice');
            
            Decimal pr = (Decimal)70.00;
            recPrice.put('price',pr);
            nonrecPrice.put('price',pr);
            ptPrice.put('price', pr);
            subProdTermPrice.put('recurringPrice',recPrice);
            subProdTermPrice.put('nonRecurringPrice',nonrecPrice);
            subProdTerm.put(curItem.ccrz__SubProdTerm__c,subProdTermPrice);
            prodSub.put('maxSubPrice',pr);
            prodSub.put('minSubPrice',pr);
            prodSub.put('subProductTerms',subProdTerm);
            prodSub.put('productPrice',ptPrice);
            prodPrice.put(curItem.ccrz__Product__c,prodSub);
            inputData.put('productPricingData',prodPrice);
    	}
        return inputData;
    }

}