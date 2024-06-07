public without sharing class SCP_OrderItemTriggerHandler {
    
    public void beforeInsertMethod(List <ccrz__E_OrderItem__c> orderItemList){
        List<String> cartItemIds = new List<String>();
        for(ccrz__E_OrderItem__c ordItem :orderItemList){
            // if(ordItem.ccrz__OrderLineType__c == 'Minor'){ //IBA-3736
            System.debug('***'+ordItem.ccrz__OrderItemId__c);
            cartItemIds.add( ordItem.ccrz__OrderItemId__c);
            //}																		//IBA-3736
        }
        System.debug('***'+cartItemIds);
        Map<String,ccrz__E_CartItem__c> cartItemMap = new Map<String,ccrz__E_CartItem__c>([Select Id,Machines__c,Machine_Type__c,DrugCodes__c,
                                                                                           Drug_Code_Exists_in_SAP__c, 
                                                                                           DrugCodes__r.DrugCodes__c, Machines__r.Machine_Name__c,Estimated_Delivery_Date__c,
                                                                                           Estimated_Delivery_DateText__c,ccrz__Product__r.ccrz__SKU__c
                                                                                           From ccrz__E_CartItem__c Where  Id In :cartItemIds]);//IBA-3736 //IBA-4223 Sourav
        
        List<ccrz__E_CartItem__c> crtitemList = [Select Id,Machine_Type__c,DrugCodes__c,DrugCodes__r.DrugCodes__c, Machines__r.Machine_Name__c,
                                                 ccrz__Product__r.ccrz__SKU__c 
                                                 From ccrz__E_CartItem__c Where ccrz__cartItemType__c = 'Minor' AND Id In :cartItemIds];//IBA-4223 Sourav
        System.debug('***'+cartItemMap);
        List<String> machineAttList = new List<String>();
        List<String> machineTypeAttList = new List<String>();
        List<String> drugCodeAttList = new List<String>();
        for(ccrz__E_CartItem__c crItem :crtitemList ){
            machineAttList.add(crItem.Machines__r.Machine_Name__c);
            machineAttList.add(crItem.Machine_Type__c);
            if(crItem.ccrz__Product__r.ccrz__SKU__c == 'NEW-CALIB' && crItem.Machine_Type__c == 'BRAKE'){//IBA-4223 Sourav
                machineAttList.add('CB');
            }
            machineAttList.add(String.valueOf(crItem.DrugCodes__r.DrugCodes__c));
        }
        System.debug('***'+machineAttList);
        List<ccrz__E_Attribute__c> attList = [Select Id,ccrz__AttributeID__c From ccrz__E_Attribute__c Where ccrz__AttributeID__c IN :machineAttList];
        Map<String,String> attMap = new Map<String,String>();
        for(ccrz__E_Attribute__c att :attList ){
            attMap.put(att.ccrz__AttributeID__c, att.id);
        }
        System.debug('***'+attMap);
        for(ccrz__E_OrderItem__c odrItem :orderItemList ){
            ccrz__E_CartItem__c crtItem = cartItemMap.get(odrItem.ccrz__OrderItemId__c);//IBA-3736
            if(crtItem != null){   //IBA-3736
                if(crtItem.Estimated_Delivery_Date__c != null)
                    odrItem.Estimated_Delivery_Date__c = crtItem.Estimated_Delivery_Date__c;
                odrItem.Estimated_Delivery_DateText__c = crtItem.Estimated_Delivery_DateText__c;
            }
            
            if(odrItem.ccrz__OrderLineType__c == 'Minor'){
                
                
                
                // odrItem.Machine__c = crtItem.Machine__c;
                odrItem.Machines__c = crtItem.Machines__c;
                odrItem.Machine_Type__c = crtItem.Machine_Type__c;
                odrItem.DrugCodes__c = crtItem.DrugCodes__c;
                
                
                odrItem.Drug_Code_Exists_in_SAP__c = crtItem.Drug_Code_Exists_in_SAP__c;
                String machine =crtItem.Machines__r.Machine_Name__c;
                String machineType = odrItem.Machine_Type__c;
                String drugCode = crtItem.DrugCodes__r.DrugCodes__c;
                if(attMap.get(crtItem.Machines__r.Machine_Name__c) == Null){
                    machine = machine.toUpperCase();
                }
                odrItem.ccrz__PrimaryAttr__c = attMap.get(machine);
                System.debug(attMap.get(machine));
                if(attMap.get(odrItem.Machine_Type__c) == Null){
                    machineType = machineType.toUpperCase();
                }
                if(crtItem.ccrz__Product__r.ccrz__SKU__c == 'NEW-CALIB' && machineType == 'BRAKE'){//IBA-4223 Sourav
                    machineType = 'CB';
                }
                odrItem.ccrz__SecondaryAttr__c = attMap.get(machineType);
                System.debug(attMap.get(machineType));
                if(attMap.get(odrItem.DrugCodes__c) == Null){
                    drugCode = drugCode.toUpperCase();
                }
                odrItem.ccrz__TertiaryAttr__c = attMap.get(drugCode);
                System.debug(attMap.get(drugCode));
                odrItem.ccrz__SelectedAttr__c = '';
            }
        }
        discountItem(orderItemList);
        
    }
    
    public void beforeUpdateMethod(List <ccrz__E_OrderItem__c> orderItemList){
        
        discountItem(orderItemList);
        
    }
    
    public void afterInsertMethod(Map<Id, ccrz__E_OrderItem__c> newMap){
        System.debug('***After Insert Order Item Trigger');
        getOrderIdupdateMachinePurchasedCount(newMap);
    }
    
    public void discountItem(List <ccrz__E_OrderItem__c> orderItemList){
        //IBA-3839
        Set<Id> productIds=new Set<Id>(); 
        for(ccrz__E_OrderItem__c orderItem : orderItemList){
            
            productIds.add(orderItem.ccrz__Product__c);
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
        
        for(ccrz__E_OrderItem__c orderItem : orderItemList){
            
            String prod = orderItem.ccrz__Product__c;
            String cupn = orderItem.ccrz__Coupon__c;
            
            try {
                /*Decimal discountQty = [SELECT ccrz__TargetQty__c
FROM ccrz__E_Coupon__c
WHERE ccrz__TargetProduct__c = :prod
AND id = :cupn
LIMIT 1].ccrz__TargetQty__c;*/
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
                if (orderItem.ccrz__Coupon__c == NULL)
                    orderItem.Discounted_Quantity__c = 0;
                else {
                    if (discountQty > orderItem.ccrz__Quantity__c)
                        orderItem.Discounted_Quantity__c = orderItem.ccrz__Quantity__c;
                    else
                        orderItem.Discounted_Quantity__c = discountQty;
                }
            }
            catch (Exception e){
                orderItem.Discounted_Quantity__c = 0;
            }
        }
        
    }
    
    public void getOrderIdupdateMachinePurchasedCount(Map<Id, ccrz__E_OrderItem__c> newMap){//, Map<Id, ccrz__E_Order__c> oldMap
        List<ccrz__E_OrderItem__c> newOrderItemList= newMap.values();
        List<ccrz__E_Order__c> sortoutOrders = new List<ccrz__E_Order__c>();
        List<ccrz__E_OrderItem__c> orderItemList = new List<ccrz__E_OrderItem__c>();
        
        Set<String> orderds = new Set<String>();
        for(ccrz__E_OrderItem__c ordIt:newOrderItemList){
            orderds.add(ordIt.ccrz__Order__c);
        }  
        Map<Id,ccrz__E_Order__c> orderMap = new Map<Id,ccrz__E_Order__c>([Select Id,ccrz__EffectiveAccountID__c From ccrz__E_Order__c Where Id IN:orderds]);
        updateMachinePurchasedCount(orderMap);
    }
    
    public void updateMachinePurchasedCount(Map<Id, ccrz__E_Order__c> newMap){//, Map<Id, ccrz__E_Order__c> oldMap
        List<ccrz__E_Order__c> newOrders= newMap.values();
        //List<ccrz__E_Order__c> oldOrders= oldMap.values();
        List<ccrz__E_Order__c> sortoutOrders = new List<ccrz__E_Order__c>();
        for(Id recordId : newMap.keyset()){
            //if((oldMap.get(recordId).SAP_Order_Number__c != newMap.get(recordId).SAP_Order_Number__c)){
            sortoutOrders.add(newMap.get(recordId));
            //}
        }
        if(sortoutOrders.size()>0){
            List<Machine__c> machineListtoUpdate = new List<Machine__c>();
            Set<String> effAccuntIds = new Set<String>();
            Set<String> orderIds = new Set<String>();
            for(ccrz__E_Order__c order :sortoutOrders){
                effAccuntIds.add(order.ccrz__EffectiveAccountID__c);
                orderIds.add(order.Id);
            }
            Map<String,Machine__c> machineMap = new Map<String,Machine__c>();
            List<Machine__c> machineData = [Select Id,Machine_Name__c,Account_CSN__c,Purchased__c,New_Calibration_Allotment__c,Recalibration_Allotment__c,
                                            Recalibrations_Purchased__c From Machine__c Where Account_CSN__c IN :effAccuntIds];
            for(Machine__c mch :machineData){
                machineMap.put(mch.Account_CSN__c+mch.Machine_Name__c, mch);
            }
            List<ccrz__E_OrderItem__c> orderItemList = [Select Id,Machines__c,Machines__r.Machine_Name__c,Machine_Type__c,ccrz__Order__r.ccrz__EffectiveAccountID__c,
                                                        ccrz__Product__r.ccrz__SKU__c,ccrz__Quantity__c From ccrz__E_OrderItem__c Where ccrz__OrderLineType__c = 'Minor' 
                                                        AND ccrz__Order__c IN :orderIds AND ((ccrz__Product__r.ccrz__SKU__c = 'RECALIB' 
                                                                                              AND Machine_Type__c = 'CANISTER') OR ccrz__Product__r.ccrz__SKU__c = 'NEW-CALIB')];
            for(ccrz__E_OrderItem__c orderItem :orderItemList){
                if(orderItem.Machines__c!= Null || orderItem.Machines__c!=''){
                    Machine__c machineToAdd = machineMap.get(orderItem.ccrz__Order__r.ccrz__EffectiveAccountID__c+orderItem.Machines__r.Machine_Name__c); 
                    if(orderItem.ccrz__Product__r.ccrz__SKU__c == 'RECALIB'){
                        machineMap.get(orderItem.ccrz__Order__r.ccrz__EffectiveAccountID__c+orderItem.Machines__r.Machine_Name__c).Recalibrations_Purchased__c = machineToAdd.Recalibrations_Purchased__c + orderItem.ccrz__Quantity__c;
                        //machineListtoUpdate.add(machineToAdd);
                    }
                    if(orderItem.ccrz__Product__r.ccrz__SKU__c == 'NEW-CALIB'){
                        machineMap.get(orderItem.ccrz__Order__r.ccrz__EffectiveAccountID__c+orderItem.Machines__r.Machine_Name__c).Purchased__c = machineToAdd.Purchased__c + orderItem.ccrz__Quantity__c;
                        // machineListtoUpdate.add(machineToAdd);
                    }
                    if(orderItem.ccrz__Product__r.ccrz__SKU__c == 'REPAIR'){
                        
                    }
                }
            }
            try{
                update machineMap.values(); 
            }
            catch(Exception e){
                System.debug(e);
            }
        }
        
        
    }
}