/***********************************************************************************************************
Name:  SCP_OrderSimulate
Copyright © 2019
Purpose: 
This class can be called to make a callout to perform order simulate

History                                                            
-------                                                            
VERSION       AUTHOR                      DATE                   Description
1.0        Karthik Raj Golakaram        01/27/2021             INITIAL DEVELOPMENT
2.0        Sanjana K.R                  04/27/2021             Subscription Order Simulate callout
*************************************************************************************************************/
global with sharing class SCP_OrderSimulate{


    Public HttpRequest  request = new HttpRequest();
    Public HttpResponse response= new HttpResponse();
    Public String requestBody='';
    Public String accessToken;

    Public SCP_OrderSimulate_Res_Parser SendOrderInfoToSAP(String cartIdToSendToSap,boolean getPayer){//iba-4378
        //Perform a query and get all needed information and create a Json Request.

        SCP_OrderSimulate_Res_Parser responseFromMS = new SCP_OrderSimulate_Res_Parser();
        String responseFromMSString ; 
        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_Order_Simulate');
        try{
            List<ccrz__E_Cart__c> cartInformationToWrapList=[SELECT id
                                                                        , ccrz__Note__c
                                                                        , Name
                                                                        , ccrz__TaxAmount__c
                                                                        , ccrz__Account__r.SAP_Account_ID__c,ccrz__EffectiveAccountID__c,SAP_SOLD_TO__c  
                                                                        , ccrz__BillTo__r.SAP_Customer_Number__c
                                                                        , ccrz__ShipTo__r.SAP_Customer_Number__c
                                                                        , ccrz__Contact__r.SAP_Contact_ID__c, SAP_CONTACT_ID__c, SAP_Shipping_Customer_Number__c,SAP_Billing_Customer_Number__c 
                                                                        , WS_Credit_Block__c
                                                                        , WS_ErrorMessages__c
                                                                        , WS_Exception__c
                                                                        , ccrz__ShipMethod__c
                                                                        , ccrz__RequestDate__c
                                                                        , (SELECT id,ccrz__Enabled__c,ccrz__Coupon__r.ccrz__CouponCode__c,ccrz__Coupon__r.ccrz__RuleType__c FROM ccrz__E_CartCoupons__r )
                                                                        , (SELECT Id,Name,ccrz__Product__r.ccrz__SKU__c,Material__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,Availability_Date__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c,Discounted_Quantity__c,ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__SecondaryAttr__r.ccrz__DisplayName__c,ccrz__TertiaryAttr__r.ccrz__DisplayName__c,Machine_Type__c, DrugCodes__c, DrugCodes__r.DrugCodes__c,DrugCodes__r.Drug_Type__c,ccrz__Price__c,ccrz__SubAmount__c,ccrz__PricingType__c FROM ccrz__E_CartItems__r WHERE ccrz__PricingType__c != 'attrGroup')
                                                                        FROM ccrz__E_Cart__c
                                                                        WHERE id=:cartIdToSendToSap LIMIT 1];

                if(cartInformationToWrapList[0].SAP_SOLD_TO__c == null && getPayer == True){//iba-4378
                    Account currAcc = [Select SAP_Customer_Number__c from Account Where Id =:cartInformationToWrapList[0].ccrz__EffectiveAccountID__c];
                    cartInformationToWrapList[0].SAP_SOLD_TO__c = currAcc.SAP_Customer_Number__c;
                }
                if(cartInformationToWrapList[0].SAP_Shipping_Customer_Number__c !=null || cartInformationToWrapList[0].SAP_SOLD_TO__c !=null){
                    accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
                    requestBody=SCP_OrderSimulate_cartWrapper.orderSimulateGenerateReqBody(cartInformationToWrapList);
                                requestBody = requestBody.removeStart('[{');//iba-4378
                                requestBody = '[{"getPayer":"'+ getPayer +'",'+requestBody;//iba-4378
                    
                    request.setHeader('Content-Type', 'application/json');
                    request.setHeader('Authorization', 'Bearer '+accessToken);
                    request.setMethod(connectionDetails.SCP_Method_Type__c);  
                    request.setTimeout((Integer)connectionDetails.SCP_Timeout__c);
                    request.setEndpoint(connectionDetails.SCP_End_Point__c);
                    request.setBodyAsBlob(Blob.valueOf(requestBody));
                    http  h= new http();
                    response=h.send(request);
                    system.debug('##   request--'+request );
                    system.debug('##   request--'+request.getBody() );
                    System.debug('##response'+response.getStatus());
                    System.debug('## Printing response body'+response.getBody());
                    if(response.getStatusCode()!=504)
                        orderStimulateParser parsedResponse= (orderStimulateParser) System.JSON.deserialize(response.getBody(),orderStimulateParser.class);
                    responseFromMSString='{"row": {"TAX_AMOUNT_HD": "540","EX_EXCEPTION": "X","ET_MESSAGES": "Message from Mulesoft","EX_CR_BLOCK":"","ET_FREIGHT_OPTIONLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09","TOTAL_TAX":"1000"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07","TOTAL_TAX":"1200"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07","TOTAL_TAX":"1300"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}} ';
                    
                    responseFromMSString = response.getBody();
                    ccrz.ccLog.log(System.LoggingLevel.DEBUG,'Response from mulsoft is--',responseFromMSString);
                    System.debug('##Printing responseFromMSString###### '+responseFromMSString);
                    if(response.getStatusCode()!=504){
                        responseFromMS=SCP_OrderSimulate_Res_Parser.Parse(responseFromMSString);
                    }else{
                        responseFromMS.row= new SCP_OrderSimulate_Res_Parser.Row();                
                        responseFromMS.row.EX_EXCEPTION = 'X';   
                    }            
                    responseFromMS.row.Status_Code = String.valueof(response.getStatusCode());
                    System.debug('##Printing parsed value of response Body'+responseFromMS); 
                    if(!System.isBatch())
                        updateCartAndCartItems(responseFromMS,cartInformationToWrapList);
                    //Need to check with Ravi, If I have to create any record or not for information purpose when exception is x.
                    if(response.getStatusCode()!=201 ){
                        new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_OrderSimulate','SendOrderInfoToSAP',cartIdToSendToSap,response.getBody(),requestBody,string.valueof(response.getStatusCode()),null));
                    }

                }else{
                    if(System.isBatch()){
                        responseFromMS.row= new SCP_OrderSimulate_Res_Parser.Row();                
                        responseFromMS.row.EX_EXCEPTION = 'D'; 
                        //responseFromMS.row.ET_MESSAGES = System.Label.SCP_ApexError;
                    }else{
                        ccrz__E_Cart__c currCart = cartInformationToWrapList[0];
                        currCart.WS_Exception__c = 'X';
                        currCart.WS_ErrorMessages__c = System.Label.SCP_ApexError;
                        //currCart.WS_Credit_Block__c= '';
                        update currCart;
                    }
                }
            }catch(exception ex){
                System.debug('Printing Exception'+ex);
                System.debug('Printing Exception'+ex.getStackTraceString());
                System.debug('Printing Exception Message'+ex.getMessage());
                new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_OrderSimulate','SendOrderInfoToSAP',cartIdToSendToSap,response.getBody(),requestBody,string.valueof(response.getStatusCode()),ex));

            }
            return responseFromMS;
    }
    
    Public class orderStimulateParser{
        Public String id;
        Public String status;
    }

    
    @TestVisible Private void updateCartAndCartItems(SCP_OrderSimulate_Res_Parser responseFromMule,List<ccrz__E_Cart__c> cartInfoToUpdateList){


        cartInfoToUpdateList[0].WS_Exception__c=responseFromMule.row.EX_EXCEPTION;
        cartInfoToUpdateList[0].WS_ErrorMessages__c=responseFromMule.row.ET_MESSAGES;
        cartInfoToUpdateList[0].WS_Credit_Block__c=responseFromMule.row.EX_CR_BLOCK;

        // Update cartInformationToWrapList;
        List<sObject> sObjectList= new List<sObject>();
        sObjectList.add(cartInfoToUpdateList[0]);
        System.debug('##Printing cart item sObjectList'+ sObjectList);

        System.debug('##Printing cart item responseFromMule'+ responseFromMule);
        System.debug('##Printing cart item cartInfoToUpdateList'+ cartInfoToUpdateList);

        if(responseFromMule.row.EX_EXCEPTION!='X'){ 
            if(responseFromMule.row.ET_ITEMLIST!=null){
                System.debug('##Printing cart item sObjectList'+ sObjectList);
                 Date dt;
                for(Integer i=0;i<responseFromMule.row.ET_ITEMLIST.size();i++){
                    for(ccrz__E_CartItem__c cartItems: cartInfoToUpdateList[0].ccrz__E_CartItems__r){

                        System.debug('##Printing cart item 0 mule'+ responseFromMule.row.ET_ITEMLIST.get(i).ITM_NUMBER);
                        System.debug('##Printing cart item 1 cartim'+  cartItems.Name.right(6) );

                        String strPattern = '^0+(?!$)';
                        //string sku = responseFromMule.row.ET_ITEMLIST.get(i).MATERIAL.replaceAll(strPattern, '');
                        string itemNo = responseFromMule.row.ET_ITEMLIST.get(i).ITM_NUMBER;
                        System.debug('##Printing cart item 1 ITM_NUMBER '+  itemNo ); 
                        // System.debug('##Printing cart item 0 cartItems-'+ String.valueOf(Integer.valueOf(responseFromMule.row.ET_ITEMLIST.get(i).MATERIAL)));
                        System.debug('##Printing cart item 1 cartim'+  cartItems.ccrz__Product__r.ccrz__SKU__c + ' ITM_NUMBER '+cartItems.Name.right(6));

                        //if( sku == cartItems.ccrz__Product__r.ccrz__SKU__c ){ // Commented and introduced the line below for Canisters and Cassettes project
                        if ( itemNo == cartItems.Name.right(6) ) {
                            //update the available quantity and requested quantity. Need to ask ravi for exact mapping.
                            System.debug('##Printing cart item matched'+ cartItems);   
                            //Compare the available quantity 
                           /* if(responseFromMule.row.ET_ITEMLIST.get(i).REQ_QTY<=responseFromMule.row.ET_ITEMLIST.get(i).AVL_QTY){
                                cartItems.ccrz__AvailabilityMessage__c='Available'; // Need to use Custom Label.
                            }else If(responseFromMule.row.ET_ITEMLIST.get(i).AVL_QTY<responseFromMule.row.ET_ITEMLIST.get(i).REQ_QTY){
                                cartItems.ccrz__AvailabilityMessage__c='Backorder'; // Need to use Custom Label.
                            }*/
                          dt = Date.newInstance(Integer.valueof(responseFromMule.row.ET_ITEMLIST.get(i).AVL_DATE.substring(0,4)), Integer.valueof(responseFromMule.row.ET_ITEMLIST.get(i).AVL_DATE.substring(5,7)), Integer.valueof(responseFromMule.row.ET_ITEMLIST.get(i).AVL_DATE.substring(8)));   
                           system.debug('AVL_DATE check--->'+dt);
                           cartItems.Availability_Date__c = dt;
                           system.debug('CAS_NOT_SETUP--->  '+responseFromMule.row.ET_ITEMLIST.get(i).CAS_NOT_SETUP);
                           if (responseFromMule.row.ET_ITEMLIST.get(i).CAS_NOT_SETUP == 'X') //Added for Canister and Cassette project
                               cartItems.Drug_Code_Exists_in_SAP__c = FALSE;
                           else
                               cartItems.Drug_Code_Exists_in_SAP__c = TRUE;  //Added for Canister and Cassette project - end
                           system.debug('cartItems.Drug_Code_Exists_in_SAP__c--->  '+cartItems.Drug_Code_Exists_in_SAP__c);
                           sObjectList.add(cartItems);
                            
                        }
                    }   
                }
            }
        }else if(responseFromMule.row.EX_EXCEPTION=='X'){
            new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Information('SCP_OrderSimulate','updateCartAndCartItems',cartInfoToUpdateList[0].id,'Exception message : '+responseFromMule.row.ET_MESSAGES+'.'+'Credit Card Message : '+responseFromMule.row.EX_CR_BLOCK,response.getBody(),requestBody,string.valueof(response.getStatusCode())));
        }   
        system.debug('## sObjectList--'+sObjectList); 
        Database.saveResult[] srResult=Database.Update(sObjectList,false);
        List<string> failedRecordID= new List<string>();
        String failedRecordIdString='';
        for(Database.SaveResult sr: srResult){
            if(!sr.isSuccess()){
                //get record Id;
                failedRecordID.add(sr.getId());
            }
        }

        if(!failedRecordId.isempty()){
            //Inserr record in LOG object.
            failedRecordIdString=String.join(failedrecordId,';');
            MyException customException= new MyException('failedRecords to Update '+failedRecordIdString);
            new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_OrderSimulate','updateCartAndCartItems',cartInfoToUpdateList[0].id,response.getBody(),requestBody,string.valueof(response.getStatusCode()),customException));
        }
    }

    public class MyException extends Exception {}
    
    public void updateSubscriptionOrder(List<ccrz__E_Order__c> newSubscriptionOrds){
        
        SCP_OrderSimulate_Res_Parser muleResp = new SCP_OrderSimulate_Res_Parser();
        SCP_OrderSimulate_Res_Parser.Row muleRespRow = new SCP_OrderSimulate_Res_Parser.Row();
        Id orderId;
        List<ccrz__E_Order__c> updateOrders = new List<ccrz__E_Order__c>();
        try{
            for(ccrz__E_Order__c ord : newSubscriptionOrds){
                orderId = ord.id;
                muleResp = SendOrderInfoToSAP(ord.ccrz__Order__r.ccrz__OriginatedCart__c,False);//iba-4378
                muleRespRow = muleResp.row;
                System.debug('muleResp--->'+muleResp);
                if(muleRespRow.EX_EXCEPTION!= 'X' || muleRespRow.EX_EXCEPTION!= 'D'){
                    Date dt;
                    List<SCP_OrderSimulate_Res_Parser.ET_FREIGHT_OPTIONLIST> etOptionList = muleRespRow.ET_FREIGHT_OPTIONLIST;          
                    for(SCP_OrderSimulate_Res_Parser.ET_FREIGHT_OPTIONLIST optionObj : etOptionList){
                        system.debug('chk ord id'+ord.id);
                        system.debug('chk ord shipmethod'+ord.ccrz__ShipMethod__c.substring(7));
                        system.debug('chk list shipmethod'+optionObj.SHIP_DESC);
                        system.debug('chk equals'+optionObj.SHIP_DESC.equals(ord.ccrz__ShipMethod__c.substring(7)));
                        if(ord.ccrz__ShipMethod__c!= null && optionObj.SHIP_DESC.equals(ord.ccrz__ShipMethod__c.substring(7))){
                            ord.ccrz__TaxAmount__c = Decimal.valueof(optionObj.TOTAL_TAX);
                            ord.ccrz__ShipAmount__c = Decimal.valueof(optionObj.FREIGHT_VAL);  
                            dt = Date.newInstance(Integer.valueof(optionObj.REQ_DATE.substring(0,4)), Integer.valueof(optionObj.REQ_DATE.substring(5,7)), Integer.valueof(optionObj.REQ_DATE.substring(8)));   
                            ord.ccrz__RequestDate__c = dt; 
                        }                
                    }
                    ord.Process_OrderSimulate__c = false;
                    ord.Process_OrderSubmit__c = true;
                }else{
                    if(muleRespRow.EX_EXCEPTION == 'D'){
                        
                        ord.WS_ErrorMessages__c = muleRespRow.ET_MESSAGES != null ? muleRespRow.ET_MESSAGES :'';
                        ord.WS_Exception__c = System.Label.SCP_ApexError; 
                        ord.Integration_Status__c = 'Error';
                        
                    }else{                      
                        ord.WS_Credit_Block__c = muleRespRow.EX_EXCEPTION!=null ? muleRespRow.EX_EXCEPTION :'';
                        ord.WS_ErrorMessages__c = muleRespRow.ET_MESSAGES != null ? muleRespRow.ET_MESSAGES :'';
                        ord.WS_Exception__c = muleRespRow.EX_CR_BLOCK != null ? muleRespRow.EX_CR_BLOCK :''; 
                        ord.Integration_Status__c = 'Error';
                    }
                }
                updateOrders.add(ord);
            }
            update updateOrders;
            }Catch(Exception ex){
            new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_OrderSimulate','updateSubscriptionOrder',orderId,muleRespRow.ET_MESSAGES,String.valueof(muleRespRow),string.valueof(muleResp),ex));
        
        }
    }

}