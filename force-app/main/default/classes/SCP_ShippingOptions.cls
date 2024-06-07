global class SCP_ShippingOptions extends ccrz.cc_api_ShippingAndHandling {

    global virtual override List<ccrz.cc_ctrl_hlpr_ShippingOption> getShippingOptions(String zipCode, String stateCode, String countryCode, Id cartId, String storeName){

        List<ccrz.cc_ctrl_hlpr_ShippingOption> shipList = new List<ccrz.cc_ctrl_hlpr_ShippingOption>(); 

            try{
            List<String> statCodes = System.Label.SCP_OrderSimulateDownCode.Split(',');
            System.debug('Calling SCP_OrderSimulate from SCP_ShippingOptions ## Printing cart id that is being sent to order simulate'+cartId);

            SCP_OrderSimulate_Res_Parser  responseParserObj = new SCP_OrderSimulate().SendOrderInfoToSAP(String.valueOf(cartId),false); //iba-4378

            system.debug('## shiping responseParserObj --'+ responseParserObj ); 

            SCP_OrderSimulate_Res_Parser.Row rowObj = responseParserObj.row;
            List<SCP_OrderSimulate_Res_Parser.ET_FREIGHT_OPTIONLIST> etOptionList = rowObj.ET_FREIGHT_OPTIONLIST;

            system.debug('## shiping etOptionList --'+ etOptionList );    
            String exCRBlock = rowObj.EX_CR_BLOCK;

            system.debug('## shiping rowObj.EX_CR_BLOCK--'+ rowObj.EX_CR_BLOCK); 
            system.debug('## shiping rowObj.EX_EXCEPTION--'+ rowObj.EX_EXCEPTION); 

            List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST> etItemList = rowObj.ET_ITEMLIST;
            // rowObj.EX_CR_BLOCK = 'X' ;  // TEST  
            if( rowObj.EX_CR_BLOCK == null || rowObj.EX_CR_BLOCK == '') {

                if(rowObj.EX_EXCEPTION != 'X'){ 
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG,'exCRBlock ',exCRBlock );

                    system.debug('## shiping exCRBlock --'+ exCRBlock ); 
                    system.debug('## shiping etOptionList --'+ etOptionList );
                    //system.debug('## shiping exCRBlock SIZE  --'+ exCRBlock.length() );

                    //caculate cart weight    
                    Decimal shipweight = 0.0;
                    for( ccrz__E_CartItem__c cit : [select ccrz__Product__r.ccrz__ShippingWeight__c   ,ccrz__Product__r.ccrz__ProductWeight__c from ccrz__E_CartItem__c where  ccrz__Cart__c = :cartId ]){
                        if(cit.ccrz__Product__r.ccrz__ShippingWeight__c!=null){
                            System.debug('Prinitng product team'+cit.ccrz__Product__r.ccrz__ShippingWeight__c);

                            shipweight = shipweight + cit.ccrz__Product__r.ccrz__ShippingWeight__c ; 
                        }
                    }
                    system.debug('## shipweight--'+shipweight); 
                    system.debug('## etOptionList--'+etOptionList); 
                    system.debug('## etOptionList size s--'+etOptionList.size());  

                    if(etOptionList != NULL && etOptionList.size()>0 ){

                       
                        for(SCP_OrderSimulate_Res_Parser.ET_FREIGHT_OPTIONLIST optionObj : etOptionList){
                            String shippingDescription = optionObj.SHIP_DESC + '----'+optionObj.REQ_DATE;
                            system.debug('## optionObj.SHIP_COND--'+optionObj.SHIP_COND);   
                            ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption( 'SHIP',optionObj.REQ_DATE,optionObj.SHIP_DESC,Decimal.valueOf(optionObj.FREIGHT_VAL),0);

                            if(shipweight >150  &&  optionObj.SHIP_DESC.contains('STANDARD')) {
                                shipList.clear(); 
                                shipList.add(tempObj);
                                break; 
                            }
                            shipList.add(tempObj);
                        } 
                    }else{  
                        // list null--complete exception 
                        ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','DefaultSHIP','Standard Ground',null,0);
                        shipList.add(tempObj);  
                    }    
                }else if(etOptionList == NULL && (exCRBlock == null || exCRBlock=='') && statCodes.contains(rowObj.Status_Code)){
                    //when SAP is down or Endpoint wrong
                    ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','SAP_Down','Standard Ground',null,0);
                    shipList.add(tempObj); 
                }else{        
                    system.debug('## shiping rowObj.EX_EXCEPTION  dispp--'+ rowObj.EX_EXCEPTION);
                    ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','DefaultSHIP','Standard Ground',null,0);
                    shipList.add(tempObj);
                }
            }else{
                 //condition for Hard Blocking Error
                ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','HardBlock','Standard Ground',null,0);
                shipList.add(tempObj); 
            }
            ccrz.ccLog.log(System.LoggingLevel.DEBUG,'optionList',shipList);
            SYSTEM.DEBUG('## shipList FIN--' + shipList) ; 

        }catch( exception e ) {
            system.debug('## exce shipList--'+ e.getmessage()); 
            system.debug('## exe stack trace shiplist--'+e.getStackTraceString());
            ccrz.cc_ctrl_hlpr_ShippingOption tempObj = new ccrz.cc_ctrl_hlpr_ShippingOption('SHIP','ERROR','Standard Ground',null,0);
            shipList.add(tempObj);
        }

        system.debug('## shiping shipList-main  -'+ shipList);  
        return shipList;
    }

    public void processETItemList(List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST> etItemList,String cartId  ){
        ccrz__E_Cart__c cartObj = [SELECT id, (SELECT Id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c FROM ccrz__E_CartItems__r) FROM ccrz__E_Cart__c WHERE id=:cartId LIMIT 1];
        List<ccrz__E_CartItem__c> cartItemList = new List<ccrz__E_CartItem__c>();
        ccrz.ccLog.log(System.LoggingLevel.DEBUG,'processETItemList',etItemList);

        //UPDATE CART


        if(etItemList != null){
            for(SCP_OrderSimulate_Res_Parser.ET_ITEMLIST etObj : etItemList){
                for(ccrz__E_CartItem__c cartItemObj : cartObj.ccrz__E_CartItems__r){
                    if(cartItemObj.Name == etObj.ITM_NUMBER){
                        if(etObj.REQ_QTY <= etObj.AVL_QTY){
                            cartItemObj.ccrz__AvailabilityMessage__c ='Available';
                        }else{
                            cartItemObj.ccrz__AvailabilityMessage__c = 'Backorder';
                        }
                    }
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG,'cartItemObj',cartItemObj);
                    cartItemObj.ccrz__AvailabilityMessage__c ='Available'; //for testing..
                    cartItemList.add(cartItemObj);
                }
            }
            if(cartItemList.size() > 0){
            //   update cartItemList; //  TESTING 
            }
        }
    } 
}