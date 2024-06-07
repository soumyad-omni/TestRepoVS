global with sharing class SCP_LogicCartPrice extends ccrz.ccLogicCartPrice
{
    global virtual override Map<String, Object> evaluateSubProdtermPricing(Map<String, Object> inputData){
        inputData = super.evaluateSubProdtermPricing(inputData);
        System.debug('*******'+inputData);
        ccrz__E_CartItem__c curr_Item = (ccrz__E_CartItem__c)inputData.get('cartItem');
        Map<String,Object> sptPrice = (Map<String,Object>)inputData.get('spt4Price');
        Map<String,Object> recPrice = (Map<String,Object>)sptPrice.get('recurringPrice');
        Map<String,Object> nonrecPrice = (Map<String,Object>)sptPrice.get('nonRecurringPrice');
        String priceListItemId = (String)recPrice.get('sfid');
        String tierJSON = [Select id,ccrz__Price__c,ccrz__Product__c,ccrz__PricingTiers__c From ccrz__E_PriceListItem__c Where id =: priceListItemId Limit 1].ccrz__PricingTiers__c;
        String attributeJSON = [Select id,ccrz__Price__c,ccrz__Product__c,ccrz__PricingTiers__c,ccrz__AttributePricing__c From ccrz__E_PriceListItem__c Where id =: priceListItemId Limit 1].ccrz__AttributePricing__c;
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
            System.debug('*******'+inputData.get('cartItem'));
            for(Integer i=0;i<4;i++){
                System.debug('****'+i);
                
                System.debug('****'+curr_Item.ccrz__Quantity__c+'***'+qty[i]);
                try{
                    if(curr_Item.ccrz__Quantity__c < qty[i]){
                        curr_Item.ccrz__Price__c = absPrice[i-1];
                        break;
                    }
                    
                    if(curr_Item.ccrz__Quantity__c == qty[i]){
                        curr_Item.ccrz__Price__c = absPrice[i];
                        break;
                    }
                    
                }
                catch(Exception e){
                    System.debug(e);
                }  
            }
            curr_Item.ccrz__SubAmount__c = curr_Item.ccrz__Price__c * curr_Item.ccrz__Quantity__c ;
            curr_Item.ccrz__OriginalItemPrice__c = curr_Item.ccrz__Price__c;
            curr_Item.ccrz__RecurringPrice__c = curr_Item.ccrz__Price__c;
            curr_Item.ccrz__RecurringPriceSubAmt__c = curr_Item.ccrz__OriginalItemPrice__c * curr_Item.ccrz__OriginalQuantity__c ;
            inputData.put('cartItem',curr_Item); 
        }
        if(attributeJSON != Null){
            
        }
        return inputData;
        
    }
    
    global virtual override Map<String, Object> priceAttributeItem(Map<String, Object> inputData){
        inputData = super.priceAttributeItem(inputData);
        System.debug('****Hello World');
        return inputData;
        
    }
    global virtual override Map<String, Object> priceItem(Map<String, Object> inputData){
        inputData = super.priceItem(inputData);
        System.debug('****Hello World');
        return inputData;
        
    }
    
    global virtual override Map<String, Object> applyPricing(Map<String, Object> inputData){
        inputData = super.applyPricing(inputData);
        System.debug('****'+inputData);
        System.debug('****'+inputData.get('cartItemsToPrice'));
        String cartEncrypId = (String)inputData.get('cartEncId');
        System.debug('***'+cartEncrypId);
        String currEffaccId = [Select ccrz__EffectiveAccountID__c From ccrz__E_Cart__c Where ccrz__EncryptedId__c=:cartEncrypId Limit 1].ccrz__EffectiveAccountID__c;
        List<ccrz__E_CartItem__c> cartExiatingMinorList = [Select id,Machines__c,Machine_Type__c,DrugCodes__c,ccrz__Quantity__c,
                                                           ccrz__OriginalQuantity__c,
                                                           ccrz__SubAmount__c,ccrz__Price__c From ccrz__E_CartItem__c Where 
                                                           ccrz__Cart__r.ccrz__EncryptedId__c =:cartEncrypId AND ccrz__cartItemType__c = 'Minor'];
        Map<String,ccrz__E_CartItem__c> cartExiatingMinorMap = new Map<String,ccrz__E_CartItem__c>();
        Map<String,Decimal> cartExiatingMinorSubtotal = new Map<String,Decimal>();
        Map<String,Decimal> cartExiatingMinorPrice = new Map<String,Decimal>();
        for(ccrz__E_CartItem__c crItemEx : cartExiatingMinorList){
            cartExiatingMinorMap.put(crItemEx.Id, crItemEx);
            cartExiatingMinorSubtotal.put(crItemEx.Id, crItemEx.ccrz__SubAmount__c);
            cartExiatingMinorPrice.put(crItemEx.Id, crItemEx.ccrz__Price__c);
        }
        System.debug('***'+inputData);
        List<ccrz__E_CartItem__c> cartItemList = (List<ccrz__E_CartItem__c>)inputData.get('cartItemList');
        
        for(ccrz__E_CartItem__c crItem :cartItemList){
            String sku = crItem.ccrz__Product__r.ccrz__SKU__c;
            if(crItem.ccrz__cartItemType__c == 'Minor'){
                System.debug('***'+crItem.ccrz__Quantity__c);                
                System.debug('***'+cartExiatingMinorMap.get(crItem.Id));
                Decimal subtotal = cartExiatingMinorSubtotal.get(crItem.Id);
                System.debug('***'+subtotal);
                crItem.ccrz__Price__c = cartExiatingMinorPrice.get(crItem.Id);
                crItem.ccrz__SubAmount__c = subtotal;                
            }
        }
        inputData.put('cartItemList',cartItemList);
        System.debug('****'+inputData);
        return inputData;
    }
    public static Integer getAttributePrice(String currEffacc, String sku, ccrz__E_CartItem__c cartItem){
        String attributePrice = OmnicellProductDetailController.getAttPrice(currEffacc,sku);
        Integer price = 0;
        String machineName = cartItem.Machines__r.Machine_Name__c ;
        
        String typeName =[Select Id,Name From ccrz__E_Attribute__c Where Id =:cartItem.ccrz__SecondaryAttr__c Limit 1].Name;
        System.debug(machineName+'***'+typeName);
        List<Machine__c> machineTypeMap2 = [Select Id,Machine_Name__c,Machine_Type_Mapping__c,Agreement_sign_date__c,
                                            Recalibration_Allotment__c,Recalibrations_Purchased__c From Machine__c Where Account_CSN__c =:currEffacc];
        
        if(attributePrice != Null){
            Map<String, Object> attributeJson = (Map<String, Object>) JSON.deserializeUntyped(attributePrice);
            Map<String, Object> machineJson = (Map<String, Object>) attributeJson.get('aL');
            Set<string> machineList = new Set<string>(machineJson.keyset());
            Map<String,Object> attributeData = new Map<String,Object>();
            String expectedmachine = [Select ccrz__AttributeID__c From ccrz__E_Attribute__c Where Id = :cartItem.ccrz__PrimaryAttr__c Limit 1].ccrz__AttributeID__c;
            String expectedtype = 'Canister';
            if(sku == 'NEW-CALIB'){ //IBA-4223 Sourav Start
                expectedtype = cartItem.Machine_Type__c;
                if(expectedtype == 'BRAKE'){
                    expectedtype = 'CB';
                }			
            }
            else{
                if(cartItem.Machine_Type__c != 'Canister'){
                    expectedtype = 'Cassette';
                }
            }//IBA-4223 Sourav  - End
            System.debug(expectedtype+'***'+expectedmachine);
            for(String machine : machineList){
                if(removeString(machine) == expectedmachine){
                    System.debug(machine+'***'+expectedmachine);
                    Map<String,Object> typeaLJson = (Map<String, Object>)machineJson.get(machine);
                    System.debug('***'+typeaLJson);
                    price = getAttPrice(typeaLJson,expectedtype);
                }
            }
        }
        
        return price;
    }
    public static Integer getAttPrice(Map<String,Object> typeaLJson,String expectedtype){
        Map<String,String> typeData = new Map<String,String>();
        Map<String, Object> TypeJson = (Map<String, Object>) typeaLJson.get('aL');
        Set<string> typeList = new Set<string>(TypeJson.keyset());
        Integer price ;
        for(String type : typeList){
            if(removeString(type) == expectedtype){
                System.debug(type+'***'+expectedtype);
                Map<String,Object> ndcaLJson = (Map<String, Object>) TypeJson.get(type);
                Map<String, Object> ndcJson = (Map<String, Object>) ndcaLJson.get('aL');
                Map<String, Object> priceJson = (Map<String, Object>) ndcJson.get('NDC^DEFAULT');
                if(priceJson != Null){
                    price = Integer.valueof(priceJson.get('pr'));
                }
            }
        }
        System.debug('***'+price);
        return price;
        
    }
    public static String removeString(String updateString){
        String s1 = updateString.substring(updateString.indexOf('^')+1);
        s1.trim();
        return s1;
    }
    public static Decimal getAttributePrice2(String currEffacc, String sku, ccrz__E_CartItem__c cartItem){
        
        String attributePrice = OmnicellProductDetailController.getAttPrice(currEffacc,sku);
        Decimal price = 0;
        String machineName = cartItem.Machines__r.Machine_Name__c ;
        
        String typeName =[Select Id,Name From ccrz__E_Attribute__c Where Id =:cartItem.ccrz__SecondaryAttr__c Limit 1].Name;
        System.debug(machineName+'***'+typeName);
        List<Machine__c> machineTypeMap2 = [Select Id,Machine_Name__c,Machine_Type_Mapping__c,Agreement_sign_date__c,
                                            Recalibration_Allotment__c,Recalibrations_Purchased__c From Machine__c Where Machine_Name__c =:machineName AND Account_CSN__c =:currEffacc];
        AggregateResult[] argPurchAlloc = [Select Machine_Name__c mch,Sum(Recalibrations_Purchased__c) prch From Machine__c Where 
                                           Account_CSN__c =:currEffacc Group By Machine_Name__c];
        Map<String,Decimal> argPurchAllocMap = new Map<String,Decimal>();
        for(Integer i=0;i<argPurchAlloc.size();i++){
            String mc = (String)argPurchAlloc[i].get('mch');
            Decimal prc = (Decimal)argPurchAlloc[i].get('prch');
            argPurchAllocMap.put((String)argPurchAlloc[i].get('mch'),(Decimal)argPurchAlloc[i].get('prch'));
        }
        Decimal qrtDiff = (cartItem.ccrz__Quantity__c+argPurchAllocMap.get(cartItem.Machines__r.Machine_Name__c))- machineTypeMap2[0].Recalibration_Allotment__c;
        
        if(attributePrice != Null){
            Map<String, Object> attributeJson = (Map<String, Object>) JSON.deserializeUntyped(attributePrice);
            Map<String, Object> machineJson = (Map<String, Object>) attributeJson.get('aL');
            Set<string> machineList = new Set<string>(machineJson.keyset());
            Map<String,Object> attributeData = new Map<String,Object>();
            String expectedmachine = [Select ccrz__AttributeID__c From ccrz__E_Attribute__c Where Id = :cartItem.ccrz__PrimaryAttr__c Limit 1].ccrz__AttributeID__c;
            String expectedtype = 'Canister';
            if(sku == 'NEW-CALIB'){ //IBA-4223 Sourav Start
                expectedtype = cartItem.Machine_Type__c;
                if(expectedtype == 'BRAKE'){
                    expectedtype = 'CB';
                }			
            }
            else{
                if(cartItem.Machine_Type__c != 'Canister'){
                    expectedtype = 'Cassette';
                }
            }//IBA-4223 Sourav  - End
            System.debug(expectedtype+'***'+expectedmachine);
            for(String machine : machineList){
                if(removeString(machine) == expectedmachine){
                    System.debug(machine+'***'+expectedmachine);
                    Map<String,Object> typeaLJson = (Map<String, Object>)machineJson.get(machine);
                    if(qrtDiff > 0){
                        if(cartItem.Machine_Type__c == 'Canister'){
                            if(argPurchAllocMap.get(machine) > machineTypeMap2[0].Recalibration_Allotment__c){
                                price = getAttPrice(typeaLJson,expectedtype)*cartItem.ccrz__Quantity__c;
                            }
                            else{
                                price = getAttPrice(typeaLJson,expectedtype)*qrtDiff;
                            }
                        }
                        else{
                            price = getAttPrice(typeaLJson,expectedtype)*cartItem.ccrz__Quantity__c;
                        }
                    }
                    else{
                        price  = 0;
                    }
                }
            }
        }
        
        return price;
    }
    
    
}