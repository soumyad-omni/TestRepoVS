public class SCP_reCheckCanisterCassetteItemsPrice {
    public static Boolean reCheckBillability(ccrz__E_Cart__c cart, Boolean processBillToShipTo){//IBA-4266
        Boolean returnFlag = false;
        Map<String,Decimal> canisterCassettePriceMap = new Map<String,Decimal>();
        List<ccrz__E_CartItem__c> paidItemList = new List<ccrz__E_CartItem__c>();
        canisterCassettePriceMap = SCP_getCassetteCanisterPrice.getPrice(cart.ccrz__EffectiveAccountID__c);
        List<ccrz__E_CartItem__c> cartItemList = [Select ID, ccrz__Product__r.ccrz__SKU__c,ccrz__Price__c, ccrz__quantity__c, ccrz__SubAmount__c,
                                                  Machine_Type__c,Machines__c,ccrz__Cart__c,ccrz__PrimaryAttr__c,ccrz__SecondaryAttr__c,ccrz__TertiaryAttr__c,
                                                  ccrz__ProductType__c,ccrz__cartItemType__c,ccrz__ParentCartItem__c,ccrz__RequestDate__c,DrugCodes__c,ccrz__ExtSKU__c
                                                  from ccrz__E_CartItem__c where ccrz__Cart__c = :cart.Id and ccrz__PricingType__c!= 'attrGroup' 
                                                  order by ccrz__SubAmount__c, createddate];
        
        Set<String> machineIDSet = new Set<String>();
        for (ccrz__E_CartItem__c ci :cartItemList ){
            if(ci.ccrz__Product__r.ccrz__SKU__c == 'NEW-CALIB' || ci.ccrz__Product__r.ccrz__SKU__c == 'RECALIB' 
               || ci.ccrz__Product__r.ccrz__SKU__c == 'REPAIR'){
                   machineIDSet.add(ci.Machines__c);
               }
        }
        if(machineIDSet.size()>0){
            List <Machine__c> machineList = [Select Id,Machine_Name__c,Machine_Type_Mapping__c,Agreement_sign_date__c,
                                             Recalibration_Allotment__c,Recalibrations_Purchased__c,New_Calibration_Allotment__c,Purchased__c
                                             From Machine__c Where Account_CSN__c =:cart.ccrz__EffectiveAccountID__c AND Id IN :machineIDSet];
            Decimal remainingFreeNew = 0;
            Decimal remainingFreeRecalib = 0;
            Decimal remainingQty = 0;
            for (Machine__c mL : machineList){
                remainingFreeNew = mL.New_Calibration_Allotment__c - mL.Purchased__c;
                remainingFreeRecalib = mL.Recalibration_Allotment__c - mL.Recalibrations_Purchased__c;
                for (ccrz__E_CartItem__c cItem : cartItemList){
                    if (cItem.Machines__c == mL.Id){
                        switch on cItem.ccrz__Product__r.ccrz__SKU__c{
                            when 'NEW-CALIB' {
                                if (remainingFreeNew >= cItem.ccrz__quantity__c) {
                                    cItem.ccrz__Price__c = 0;
                                    cItem.ccrz__SubAmount__c = 0;
                                    remainingFreeNew = remainingFreeNew - cItem.ccrz__quantity__c;
                                }
                                else if (remainingFreeNew > 0) {
                                    remainingQty = cItem.ccrz__Quantity__c - remainingFreeNew;
                                    cItem.ccrz__Price__c = 0;
                                    cItem.ccrz__SubAmount__c = 0;
                                    cItem.ccrz__Quantity__c = remainingFreeNew;
                                    remainingFreeNew = remainingFreeNew - cItem.ccrz__Quantity__c;
                                    //Paid Item create
                                    ccrz__E_CartItem__c paidItem  = createPaidItem(cItem,remainingQty,canisterCassettePriceMap);
                                    paidItemList.add(paidItem);
                                    
                                }
                                else {
                                    System.debug('**'+cItem.ccrz__Product__r.ccrz__Sku__c+cItem.Machine_Type__c);
                                    String type = cItem.Machine_Type__c;//IBA-4223 Sourav
                                    cItem.ccrz__Price__c = canisterCassettePriceMap.get(cItem.ccrz__Product__r.ccrz__Sku__c+type);
                                    cItem.ccrz__SubAmount__c = cItem.ccrz__Price__c*cItem.ccrz__Quantity__c;
                                    cItem.ccrz__OriginalItemPrice__c = cItem.ccrz__Price__c;
                                }
                            }
                            when 'RECALIB' {
                                if (cItem.Machine_Type__c == 'Canister'){
                                    System.debug('**'+cItem.ccrz__quantity__c);
                                    if (remainingFreeRecalib >= cItem.ccrz__quantity__c) {
                                        cItem.ccrz__Price__c = 0;
                                        cItem.ccrz__SubAmount__c = 0;
                                        remainingFreeRecalib = remainingFreeRecalib - cItem.ccrz__quantity__c;
                                        System.debug('**'+remainingFreeRecalib);
                                    }
                                    else if (remainingFreeRecalib > 0) {
                                        remainingQty = cItem.ccrz__quantity__c - remainingFreeRecalib;
                                        cItem.ccrz__Price__c = 0;
                                        cItem.ccrz__SubAmount__c = 0;
                                        cItem.ccrz__quantity__c = remainingFreeRecalib;
                                        remainingFreeRecalib = remainingFreeRecalib - cItem.ccrz__quantity__c;
                                        
                                        //Cloning the above CartItem to create PaidItem
                                        ccrz__E_CartItem__c paidItem  = createPaidItem(cItem,remainingQty,canisterCassettePriceMap);
                                        
                                        paidItemList.add(paidItem);
                                    } 
                                    else {
                                        cItem.ccrz__Price__c = canisterCassettePriceMap.get(cItem.ccrz__Product__r.ccrz__Sku__c+cItem.Machine_Type__c);
                                        cItem.ccrz__SubAmount__c = cItem.ccrz__Price__c*cItem.ccrz__Quantity__c;
                                        cItem.ccrz__OriginalItemPrice__c = cItem.ccrz__Price__c;
                                    }				
                                    
                                }
                                else {
                                    continue;
                                }
                            }
                            when 'REPAIR' {
                                continue;
                            }
                        }
                    }
                }
            }
            cartItemList.addALL(paidItemList);
            try{
                System.debug('****'+paidItemList.size());
                System.debug('****'+cartItemList.size());
                upsert cartItemList;
                returnFlag = true;
            }
            catch(Exception e){
                System.debug(e);
            }
        }
        else{
            returnFlag = true;
        }
        if(returnFlag == true && processBillToShipTo){//IBA-4266
            selectDefaultRel(cart);
        }
        return returnFlag;
    }
    public static ccrz__E_CartItem__c createPaidItem(ccrz__E_CartItem__c freeItem,Decimal qty,Map<String,Decimal> priceMap){
        ccrz__E_CartItem__c paidItem  = new ccrz__E_CartItem__c();
        paidItem = freeItem.clone(false, true, false, false);
        paidItem.ccrz__Cart__c = freeItem.ccrz__Cart__c;
        String type = ''; //IBA-4223 Sourav Start
        if(freeItem.ccrz__Product__r.ccrz__SKU__c == 'NEW-CALIB'){
            type = freeItem.Machine_Type__c;
        }
        else{
            type = getMachineType(freeItem.Machine_Type__c);
        }					//IBA-4223 Sourav End   
        paidItem.ccrz__Price__c = priceMap.get(freeItem.ccrz__Product__r.ccrz__Sku__c+type);
        paidItem.ccrz__Quantity__c = qty; 
        paidItem.ccrz__SubAmount__c = paidItem.ccrz__Price__c*paidItem.ccrz__Quantity__c;
        paidItem.ccrz__OriginalItemPrice__c = paidItem.ccrz__Price__c;
        paidItem.ccrz__OriginalQuantity__c = paidItem.ccrz__Quantity__c ;
        
        //paidItem.Machine__c = freeItem.Machine__c;
        paidItem.ccrz__ProductType__c = freeItem.ccrz__ProductType__c;
        paidItem.ccrz__PrimaryAttr__c = freeItem.ccrz__PrimaryAttr__c;
        paidItem.ccrz__SecondaryAttr__c = freeItem.ccrz__SecondaryAttr__c;
        paidItem.ccrz__TertiaryAttr__c = freeItem.ccrz__TertiaryAttr__c;
        paidItem.ccrz__cartItemType__c = freeItem.ccrz__cartItemType__c;
        paidItem.ccrz__ParentCartItem__c = freeItem.ccrz__ParentCartItem__c;
        paidItem.ccrz__RequestDate__c = freeItem.ccrz__RequestDate__c;
        paidItem.Machines__c = freeItem.Machines__c;
        paidItem.Machine_Type__c = freeItem.Machine_Type__c;
        paidItem.DrugCodes__c = freeItem.DrugCodes__c;
        paidItem.ccrz__ExtSKU__c = freeItem.ccrz__ExtSKU__c;
        
        return paidItem;
    }
    
    public static String getMachineType(String machineType){
        if(machineType == 'Canister'){
            return 'Canister';
        }
        else{
            return 'CASSETTE';
        }
        
    }
    
    public static void selectDefaultRel(ccrz__E_Cart__c cart){ // IBA-4266
        
        List<Relationship__c> allRelationships = [Select Id,Relationship__c,Secondary_Account__r.SAP_Customer_Number__c,Secondary_Account__c,
                                                  Secondary_Account__r.Name,
                                                  Secondary_Account__r.BillingStreet,Secondary_Account__r.BillingCity,Secondary_Account__r.Transportation_Zone_Country__c,
                                                  Secondary_Account__r.BillingPostalCode,Secondary_Account__r.BillingCountry,Secondary_Account__r.BillingState,
                                                  Secondary_Account__r.BillingStateCode,Secondary_Account__r.PO_BOX__c 
                                                  From Relationship__c Where Primary_Account__c =:cart.ccrz__EffectiveAccountID__c AND Default_Partner_Flag__c = True
                                                  AND (Relationship__c = 'RE' OR Relationship__c = 'WE')];
        Account currAcc = [Select Name,BillingStreet,BillingCity,Transportation_Zone_Country__c,BillingPostalCode,BillingCountry,BillingState,
                           SAP_Customer_Number__c,BillingStateCode,PO_BOX__c,Address_Zip_code__c from Account Where Id =:cart.ccrz__EffectiveAccountID__c];
        
        if(cart.Order_attempt__c != true){
            for(Relationship__c rel:allRelationships){
                if(rel.Relationship__c == 'WE' || rel.Relationship__c == 'RE'){
                    upsertCartCCAddress(cart,rel);
                }                
            }  
            if(allRelationships.size() == 1){
                if(allRelationships[0].Relationship__c != 'RE' && allRelationships[0].Relationship__c == 'WE'){
                    OmnicellProductDetailController.createRelationshiponCart(cart,currAcc,'billTo');
                }
                if(allRelationships[0].Relationship__c == 'RE' && allRelationships[0].Relationship__c != 'WE'){
                    OmnicellProductDetailController.createRelationshiponCart(cart,currAcc,'shipTo');
                }
            }
        }        
    }
    
    public static void upsertCartCCAddress(ccrz__E_Cart__c cartObj, Relationship__c rel){//IBA-4266
        
        ccrz__E_ContactAddr__c accRel = new ccrz__E_ContactAddr__c();
        accRel.ccrz__CompanyName__c = rel.Secondary_Account__r.Name;
        accRel.AccountId__c = rel.Secondary_Account__c;
        accRel.ccrz__AddressFirstline__c = rel.Secondary_Account__r.BillingStreet;
        accRel.ccrz__City__c = rel.Secondary_Account__r.BillingCity;
        accRel.ccrz__CountryISOCode__c = rel.Secondary_Account__r.Transportation_Zone_Country__c;
        accRel.ccrz__PostalCode__c = rel.Secondary_Account__r.BillingPostalCode;
        accRel.ccrz__Country__c = rel.Secondary_Account__r.BillingCountry;
        accRel.ccrz__State__c = rel.Secondary_Account__r.BillingState;
        accRel.SAP_Customer_Number__c = rel.Secondary_Account__r.SAP_Customer_Number__c;   
        accRel.ccrz__StateISOCode__c = rel.Secondary_Account__r.BillingStateCode;
        accRel.ccrz__AddressThirdline__c = rel.Secondary_Account__r.PO_BOX__c;
        if(rel.Relationship__c == 'WE' && cartObj.ccrz__ShipTo__c != null){
            accRel.id = cartObj.ccrz__ShipTo__c;
        }
        if(rel.Relationship__c == 'RE' && cartObj.ccrz__BillTo__c != null){
            accRel.id = cartObj.ccrz__BillTo__c;
        }
        upsert accRel;
        if(rel.Relationship__c == 'WE'){
            cartObj.SAP_Shipping_Customer_Number__c = rel.Secondary_Account__r.SAP_Customer_Number__c;
            cartObj.Order_attempt__c = true;
            cartObj.ccrz__ShipTo__c = accRel.id;
        }
        if(rel.Relationship__c == 'RE'){
            cartObj.SAP_Billing_Customer_Number__c = rel.Secondary_Account__r.SAP_Customer_Number__c;
            cartObj.Order_attempt__c = true;
            cartObj.ccrz__BillTo__c = accRel.id;
        }
        update cartObj;
    }
}