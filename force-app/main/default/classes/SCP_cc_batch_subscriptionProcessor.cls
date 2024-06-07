global class SCP_cc_batch_subscriptionProcessor implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select id,CurrentDateTime__c from ccrz__E_Subscription__c limit 1');
    }
    
    global void execute(Database.BatchableContext BC, List<ccrz__E_Subscription__c> scope) {
        
        
        List<ccrz__E_Subscription__c> subslst = [select id,ccrz__CCOrderItem__c,ccrz__SubscriptionStatus__c,ccrz__CCOrder__c,ccrz__SPTInstallmentFrequencyUOM__c,ccrz__InstallmentCountRemaining__c,ccrz__OrderCountRemaining__c,ccrz__InstallmentNextDate__c,ccrz__OrderNextDate__c from ccrz__E_Subscription__c
                                                 WHERE
                                                 ccrz__SubscriptionStatus__c = 'Active' AND ccrz__OrderNextDate__c
                                                 <=: scope[0].CurrentDateTime__c
                                                 AND ccrz__OrderCountRemaining__c > 0
                                                 AND ccrz__InstallmentCountRemaining__c > 0
                                                 AND ccrz__ParentSubscription__c = NULL order by ccrz__CCOrder__c,ccrz__SPTInstallmentFrequencyUOM__c];
        if(subslst.size() > 0){
        Map<String,List<ccrz__E_Subscription__c>> ordSubsMap= new Map<String,List<ccrz__E_Subscription__c>>();
        Map<String,List<string>> ordSubstypeMap= new Map<String,List<string>>();
        map<string,string> ordItemmapping = new map<string,string>();
        
        for(ccrz__E_Subscription__c s : subslst){
            ordItemmapping.put(s.ccrz__CCOrderItem__c,s.ccrz__CCOrder__c);
            if(ordSubsMap.containsKey(s.ccrz__CCOrder__c)){
                List<ccrz__E_Subscription__c> sList=ordSubsMap.get(s.ccrz__CCOrder__c);
                sList.add(s);
                ordSubsMap.put(s.ccrz__CCOrder__c, sList);
            }
            else{
                ordSubsMap.put(s.ccrz__CCOrder__c, new List<ccrz__E_Subscription__c>{s});
                }
        }
    
        system.debug('maps ');
        list<string> ords = new list<string>();
        
        for(String key : ordSubsMap.keySet()){
            ords.add(key);
        }
        
        list<ccrz__E_Subscription__c> substoupdatelist = new list<ccrz__E_Subscription__c>();
        list<string> ordertocreate = new list<string>();
        list<string> orderItemcreate = new list<string>();
        for(Integer i=0;i<ords.size();i++){
            list<ccrz__E_Subscription__c> subs = ordSubsMap.get(ords[i]);
            string order = '';
            if(subs.size() > 1){
                system.debug('>1');
                string stype ='';
                //boolean isfirst = true;
                
                list<ccrz__E_Subscription__c> substoupdate = new list<ccrz__E_Subscription__c>();
                
                
                for(ccrz__E_Subscription__c s:subs){
                    
                    //if(isfirst != true && stype == s.ccrz__SPTInstallmentFrequencyUOM__c){
                        order = s.ccrz__CCOrder__c;     
                    /*}else{
                        substoupdate.clear();
                        orderItemcreate.clear();
                    }
                    stype = s.ccrz__SPTInstallmentFrequencyUOM__c;*/
                    substoupdate.add(s);
                    orderItemcreate.add(s.ccrz__CCOrderItem__c);
                    //isfirst = false;
                }
                if(substoupdate.size() >1){
                    substoupdatelist.addAll(substoupdate);
                    ordertocreate.add(order);
                }
                
            }
            
        }
        system.debug('** '+substoupdatelist.size());
        system.debug('** '+ordertocreate.size());
        
        map<string,string> ordmapping = new map<string,string>();
        list<ccrz__E_Order__c> ordList = [SELECT id,ccrz__Order__c,Account_City__c,Account_CSN__c,Account_State__c,Attachment_id__c,Cancelled_Order_Items__c,ccrz__Account__c,
                                          ccrz__AdjustmentAmount__c,ccrz__AdjustmentReason__c,ccrz__BillTo__c,ccrz__BuyerCompanyName__c,ccrz__BuyerEmail__c,ccrz__BuyerFirstName__c,
                                          ccrz__BuyerLastName__c,ccrz__BuyerMobilePhone__c,ccrz__BuyerPhone__c,ccrz__CCEmailAddress__c,ccrz__CCSubscription__c,ccrz__Contact__c,
                                          ccrz__ContractId__c,ccrz__CurrencyISOCode__c,ccrz__EffectiveAccountID__c,ccrz__ExtCarrier__c,ccrz__ExtShipTo__c,ccrz__ExtShipTrackNo__c,
                                          ccrz__IsAnonymous__c,ccrz__Name__c,ccrz__Note__c,ccrz__OrderSeller__c,ccrz__OrderSource__c,ccrz__OriginatedCart__c,ccrz__PaymentMethod__c,
                                          ccrz__PONumber__c,ccrz__ShipAmount__c,ccrz__ShipDiscountAmount__c,ccrz__ShipMethod__c,ccrz__ShipStructure__c,ccrz__ShipTo__c,
                                          ccrz__SkipTax__c,ccrz__SplitParentOrder__c,ccrz__SplitProcessed__c,ccrz__Storefront__c,ccrz__SubtotalAmount__c,ccrz__OrderDate__c,
                                          ccrz__TotalAmount__c,ccrz__TotalDiscount__c,ccrz__TotalSurcharge__c,ccrz__User__c,ccrz__VerifyExemptionFlag__c,
                                          CurrencyIsoCode,IsDeleted,Name,Order_Items__c,Order_Shipment__c,OrdItmExt__c,OwnerId,PO_Number__c,Process_OrderSimulate__c,Process_OrderSubmit__c,
                                          Reference_Number__c,SAP_CONTACT_ID__c,SAP_Shipping_Customer_Number__c,SAP_SOLD_TO__c,Send_Email__c,SHIP_COND__c,ccrz__OrderStatus__c FROM 
                                          ccrz__E_Order__c where id =: ordertocreate];
        for(ccrz__E_Order__c o:ordList){
            ccrz__E_Order__c ordrclone  = o.clone(false, true, false, false);
            ordrclone.ccrz__Order__c =  o.id;
            ordrclone.Process_OrderSimulate__c = true;
            ordrclone.ccrz__OrderStatus__c = 'Order Submitted';
            list<ccrz__E_Subscription__c> subsl = ordSubsMap.get(o.id);
            ordrclone.ccrz__CCSubscription__c = subsl[0].id;
            ordrclone.ccrz__OrderDate__c = date.today();
            insert ordrclone;
            
            ordmapping.put(o.id,ordrclone.id);
        }
        
        list<ccrz__E_OrderItem__c> orditem = [SELECT id,name,Category_ID__c,Category_Name__c,ccrz__AbsoluteDiscount__c,ccrz__AdjustmentAmount__c,ccrz__AvailabilityMessage__c,
                                              ccrz__Category__c,ccrz__Comments__c,ccrz__Coupon__c,ccrz__DisplayProduct__c,ccrz__ExtName__c,ccrz__ExtSKU__c,ccrz__Is_Subscription__c,
                                              ccrz__ItemLabel__c,ccrz__ItemStatus__c,ccrz__ItemTotal__c,ccrz__Next_Subscription_Date__c,ccrz__OrderItemGroup__c,ccrz__OrderItemId__c,
                                              ccrz__OrderItemStatus__c,ccrz__OrderLineType__c,ccrz__Order__c,ccrz__OriginalItemPrice__c,ccrz__OriginalQuantity__c,ccrz__ParentOrderItem__c,
                                              ccrz__ParentProduct__c,ccrz__PercentDiscount__c,ccrz__Price__c,ccrz__PricingModifierTypes__c,ccrz__PricingType__c,ccrz__PrimaryAttr__c,
                                              ccrz__ProductType__c,ccrz__Product_Name__c,ccrz__Product__c,ccrz__Quantity__c,ccrz__RecurringPriceSubAmt__c,ccrz__RecurringPrice__c,
                                              ccrz__SecondaryAttr__c,ccrz__SelectedAttr__c,ccrz__Seller__c,ccrz__SplitSource__c,ccrz__StoreId__c,ccrz__SubAmount__c,
                                              ccrz__SubProdTerm__c,ccrz__SubscriptionId__c,ccrz__Subscription_Auto_Renewal__c,ccrz__Subscription_Duration__c,ccrz__Subscription_End_Date__c,
                                              ccrz__Subscription_Frequency__c,ccrz__Subscription_Start_Date__c,ccrz__Subscription_Status__c,ccrz__TertiaryAttr__c,ccrz__UnitOfMeasure__c,
                                              CurrencyIsoCode,Discounted_Quantity__c,Email__c,IsDeleted FROM ccrz__E_OrderItem__c where id =: orderItemcreate];
        for(ccrz__E_OrderItem__c o:orditem){
            ccrz__E_OrderItem__c ordriclone  = o.clone(false, true, false, false);
            string oid = ordItemmapping.get(o.id);
            ordriclone.ccrz__Order__c =  ordmapping.get(oid);
            insert ordriclone;
            
        }
        
        
        for(ccrz__E_Subscription__c s:substoupdatelist){
            s.ccrz__InstallmentCountRemaining__c = s.ccrz__InstallmentCountRemaining__c - 1;
            s.ccrz__OrderCountRemaining__c = s.ccrz__OrderCountRemaining__c - 1;
            if(s.ccrz__OrderCountRemaining__c >=1){
                if(s.ccrz__SPTInstallmentFrequencyUOM__c == 'Weekly'){
                    datetime d = s.ccrz__InstallmentNextDate__c;
                    s.ccrz__InstallmentNextDate__c = d.addDays(7);
                    s.ccrz__OrderNextDate__c = d.addDays(7);
                }
                if(s.ccrz__SPTInstallmentFrequencyUOM__c == 'Monthly'){
                    datetime d = s.ccrz__InstallmentNextDate__c;
                    s.ccrz__InstallmentNextDate__c = d.addMonths(1);
                    s.ccrz__OrderNextDate__c = d.addMonths(1);
                }
            }else{
                s.ccrz__SubscriptionStatus__c = 'Expired';
            }
            
            
        }
        
        update substoupdatelist;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        ccrz.cc_batch_SubscriptionProcessor s = new ccrz.cc_batch_SubscriptionProcessor('OmnicellB2BStore','recurrOrder',True);
        DataBase.executeBatch(s);
    }    
    
}