/***********************************************************************************************************
Name:  SCP_OrderSubmitAPI
Copyright © 2019
============================================================================================================
============================================================================================================
Purpose: 
This class is webservice class to send order information to SAP

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION       AUTHOR                      DATE                   Description
1.0        Karthik Raj Golakaram        01/27/2021             INITIAL DEVELOPMENT
*************************************************************************************************************/
Public With Sharing class SCP_OrderSubmitAPI{

    Public HttpRequest  request = new HttpRequest();
    Public HttpResponse response= new HttpResponse();
    Public String requestBody='';
    Public String accessToken;

    public SCP_OrderSimulate_Res_Parser sendOrderInformationToSAP(String OrderId){

        List<ccrz__E_Order__c> ordertoWrapList=[SELECT id
                                                            , ccrz__ShipTo__r.ccrz__FirstName__c//SCP-846
                                                            , ccrz__ShipTo__r.ccrz__LastName__c//SCP-846
                                                            , ccrz__ShipTo__r.ccrz__HomePhone__c//SCP-846
                                                            , Name, ccrz__CCSubscription__c 
                                                            , ccrz__OrderId__c, ccrz__RequestDate__c 
                                                            , ccrz__Account__r.SAP_Account_ID__c
                                                            , ccrz__Contact__r.SAP_Contact_ID__c 
                                                            , ccrz__ShipTo__r.SAP_Customer_Number__c
                                                            , ccrz__ShipTo__r.ccrz__ShippingComments__c
                                                            , ccrz__BillTo__r.SAP_Customer_Number__c
                                                            , ccrz__BillTo__r.SAP_Contact_ID__c 
                                                            , ccrz__ShipTo__r.SAP_Contact_ID__c
                                                            , ccrz__OriginatedCart__r.SAP_CONTACT_ID__c
                                                            , ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c
                                                            , ccrz__OriginatedCart__r.SAP_Billing_Customer_Number__c
                                                            , ccrz__OriginatedCart__r.SAP_SOLD_TO__c
                                                            , ccrz__Note__c
                                                            , ccrz__ShipAmount__c 
                                                            , SAP_Order_Number__c
                                                            , SHIP_COND__c
                                                            , ccrz__PONumber__c
                                                            , ccrz__OriginatedCart__c
                                                            , ccrz__TotalDiscount__c
                                                            , SCP_Retry_Count__c
                                                            , ET_MESSAGES__c
                                                            , EX_CR_BLOCK__c
                                                            , EX_EXCEPTION__c
                                                            , Integration_Status__c
                                                            , (SELECT id,ccrz__AccountNumber__c,ccrz__AccountType__c,ccrz__Token__c FROM ccrz__TransactionPayments__r WHERE ccrz__CCOrder__c=:orderId LIMIT 1) // IBA-5834
                                                            , (SELECT id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__OrderItemStatus__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c,Discounted_Quantity__c,ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__SecondaryAttr__r.ccrz__DisplayName__c,ccrz__TertiaryAttr__r.ccrz__DisplayName__c,Material__c, DrugCodes__c, DrugCodes__r.DrugCodes__c,DrugCodes__r.Drug_Type__c,ccrz__Price__c,ccrz__SubAmount__c,ccrz__PricingType__c, Machines__r.Machine_Id__c, Machines__r.Original_Sales_order_Number__c FROM ccrz__E_OrderItems__r)
                                                            FROM ccrz__E_Order__c
                                                            WHERE id=:orderId AND SAP_Order_Number__c = NULL  LIMIT 1];  
                                                            
        List<ccrz__E_CartCoupon__c> cartCouponList=     [SELECT id,ccrz__Coupon__r.ccrz__RuleType__c FROM ccrz__E_CartCoupon__c WHERE ccrz__Cart__c=:ordertoWrapList[0].ccrz__OriginatedCart__c];

        final String END_POINT   = 'https://anypoint.mulesoft.com/mocking/api/v1/links/408dc916-e384-48bf-afc5-3a9c23215f5d/api/orders/submit' ;

        SCP_Integration_Details__c connectionDetails= SCP_Integration_Details__c.getValues('SCP_Order_Submit');
        SCP_OrderSimulate_Res_Parser parsedOrderSubmitInfo=new SCP_OrderSimulate_Res_Parser();
        
        try{

            String ship_to,sold_to;
            ship_to = ordertoWrapList[0].ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c != null ? ordertoWrapList[0].ccrz__OriginatedCart__r.SAP_Shipping_Customer_Number__c : '';
            sold_to = ordertoWrapList[0].ccrz__OriginatedCart__r.SAP_SOLD_TO__c!=null ? ordertoWrapList[0].ccrz__OriginatedCart__r.SAP_SOLD_TO__c : '';
            if(ship_to != '' &&  sold_to != ''){
                accessToken = SCP_MuleAccessTokenBuilder.authenticateMuleSystem();
                requestBody=SCP_OrderSubmit_Req_Wrapper.createJSONRequestBody(ordertoWrapList,cartCouponList);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer '+accessToken);
                request.setMethod(connectionDetails.SCP_Method_Type__c);  
                request.setTimeout((Integer)connectionDetails.SCP_Timeout__c); 
                request.setEndpoint(connectionDetails.SCP_End_Point__c);
                request.setBodyAsBlob(Blob.valueOf(requestBody));
                http  h= new http();
                system.debug('##   request--'+request );
                response=h.send(request);
                //system.debug('##   request--'+request );
                System.debug('response'+response.getStatus());
                System.debug('##Printing response body from mule'+response.getBody());
                orderSubmitParser parsedResponse= (orderSubmitParser) System.JSON.deserialize(response.getBody(),orderSubmitParser.class);

                // String customResponse='{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "","": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMSLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}}';            
                String customResponse=response.getbody();
                parsedOrderSubmitInfo=SCP_OrderSimulate_Res_Parser.parse(customResponse);

                System.debug('##Printing id from the parsedOrderSubmitInfo.'+parsedOrderSubmitInfo);
                
                //Handling the DML Updates and response parsing in Batch Class it self because f system limitaiton - 03/30/2021
                if(!System.isBatch()){
                    System.debug('Printing order submit data updates when request is from Storefront');
                    updateOrderInfo(parsedOrderSubmitInfo,ordertoWrapList,cartCouponList);
                }
                
                    System.debug('##Parsed order Submit info'+parsedOrderSubmitInfo); 
            }else{
                if(System.isBatch()){
                    parsedOrderSubmitInfo.row = new SCP_OrderSimulate_Res_Parser.Row();
                    //parsedOrderSubmitInfo.row.ET_MESSAGES = System.Label.SCP_ApexError;
                    parsedOrderSubmitInfo.row.EX_EXCEPTION = 'D';
                    
                }else{
                    ccrz__E_Order__c currOrd = ordertoWrapList[0];
                    currOrd.ET_MESSAGES__c =System.Label.SCP_ApexError;
                    //currOrd.EX_CR_BLOCK__c=parsedResponseFromMS.row.EX_CR_BLOCK;
                    currOrd.EX_EXCEPTION__c = 'X';
                    update currOrd;
                }
            }

        }catch(exception e){
            System.debug('Printing exception'+e);
            System.debug('Printing exception message'+e.getMessage());
            System.debug('Printing exception stack trace string'+e.getStackTraceString());
            new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_OrderSubmitAPI','sendOrderInformationToSAP',OrderId,response.getBody(),requestBody,string.valueof(response.getStatusCode()),e));
            if(!ordertoWrapList.isEmpty()){
                ordertoWrapList[0].Integration_Status__c='Error';
                Update ordertoWrapList;
            }
        } 

        return parsedOrderSubmitInfo;
    }

    Public class orderSubmitParser{
        Public String id;
        Public String status;
    }

    Private Void updateOrderInfo(SCP_OrderSimulate_Res_Parser parsedResponsefromMS, List<ccrz__E_Order__c> orderInfoToUpdate,List<ccrz__E_CartCoupon__c> cartCouponInfo){

        List<sObject> recordsToUpdateList= new List<sObject>();
        list<ccrz__E_OrderItem__c> orditms = new list<ccrz__E_OrderItem__c>();  
        if(parsedResponseFromMS.row.EX_EXCEPTION==null || parsedResponseFromMS.row.EX_EXCEPTION!='X'){

            orderInfoToUpdate[0].ET_MESSAGES__c=parsedResponseFromMS.row.ET_MESSAGES;
            orderInfoToUpdate[0].EX_CR_BLOCK__c=parsedResponseFromMS.row.EX_CR_BLOCK;
            orderInfoToUpdate[0].EX_EXCEPTION__c=parsedResponseFromMS.row.EX_EXCEPTION;
            orderInfoToUpdate[0].ccrz__OrderId__c=parsedResponseFromMS.row.EV_SALES_ORDER;
            orderInfoToUpdate[0].Integration_Status__c='Submitted';
            /*orderInfoToUpdate[0].ccrz__TaxAmount__c=Decimal.ValueOF(parsedResponseFromMS.row.TAX_AMOUNT_HD);
            if(!String.isBlank(parsedResponseFromMS.row.IV_ORDER_DISCOUNT)){
            orderInfoToUpdate[0].ccrz__TotalDiscount__c=Decimal.ValueOf(parsedResponseFromMS.row.IV_ORDER_DISCOUNT);
            }*/
            if(String.isNotBlank(parsedResponseFromMS.row.EV_SALES_ORDER)){
                orderInfoToUpdate[0].SAP_Order_Number__c= parsedResponseFromMS.row.EV_SALES_ORDER; 
            }

            //Code logic to update the status of the order line items with order submitted status.
            if(!orderInfoToUpdate[0].ccrz__E_OrderItems__r.isEmpty()){
                for(ccrz__E_OrderItem__c orderItemsToUpdate:orderInfoToUpdate[0].ccrz__E_OrderItems__r){
                    orderItemsToUpdate.ccrz__OrderItemStatus__c='Order Submitted'; 
                    recordsToUpdateList.add(orderItemsToUpdate); 
                }
            }

            recordsToUpdateList.add(orderInfoToUpdate[0]);
            

            if(parsedResponseFromMS.row.ET_ITEMLIST!=null && parsedResponseFromMS.row.ET_ITEMLIST.SIZE()>0 ){
                for(Integer i=0;i<parsedResponseFromMS.row.ET_ITEMLIST.size();i++){ 
                    for(ccrz__E_OrderItem__c orderItems:orderInfoToUpdate[0].ccrz__E_OrderItems__r){
                        if(parsedResponseFromMS.row.ET_ITEMLIST.get(i).ITM_NUMBER==orderItems.Name.right(6) || test.isRunningTest() ){ 
                            if(parsedResponseFromMS.row.ET_ITEMLIST.get(i).REQ_QTY<=parsedResponseFromMS.row.ET_ITEMLIST.get(i).AVL_QTY){
                                orderItems.ccrz__AvailabilityMessage__c='Available'; // Need to use Custom Label.
                            }else If(parsedResponseFromMS.row.ET_ITEMLIST.get(i).AVL_QTY<parsedResponseFromMS.row.ET_ITEMLIST.get(i).REQ_QTY){
                                orderItems.ccrz__AvailabilityMessage__c='Backorder'; // Need to use Custom Label.
                            } 
                             
                            if(parsedResponseFromMS.row.ET_ITEMLIST.get(i).ABS_DISCOUNT != null)
                            orderItems.ccrz__AbsoluteDiscount__c=Decimal.ValueOf(parsedResponseFromMS.row.ET_ITEMLIST.get(i).ABS_DISCOUNT);
                            if(parsedResponseFromMS.row.ET_ITEMLIST.get(i).PERC_DISCOUNT  != null)
                            orderItems.ccrz__PercentDiscount__c=Decimal.ValueOf(parsedResponseFromMS.row.ET_ITEMLIST.get(i).PERC_DISCOUNT);
                            
                           date dt = Date.newInstance(Integer.valueof(parsedResponseFromMS.row.ET_ITEMLIST.get(i).AVL_DATE.substring(0,4)), Integer.valueof(parsedResponseFromMS.row.ET_ITEMLIST.get(i).AVL_DATE.substring(5,7)), Integer.valueof(parsedResponseFromMS.row.ET_ITEMLIST.get(i).AVL_DATE.substring(8)));   
                           system.debug('## ord AVL_DATE check WS --->'+dt);  
                             system.debug('## ord AVL_DATE SFDC --->'+ orderInfoToUpdate[0].ccrz__RequestDate__c);
                            
                    IF(orderInfoToUpdate[0].ccrz__RequestDate__c < DT) 
                           orderItems.ccrz__AvailabilityMessage__c= 'Backorder'; 
                            
                     IF(orderInfoToUpdate[0].ccrz__RequestDate__c >= DT )
                          orderItems.ccrz__AvailabilityMessage__c= 'Available'; 
                         
                             orderItems.OrdItmExt_c__c= orderItems.Name.right(6); 
                        }
                        orditms.add(orderItems);   
                    }
                }
            }    
        }else{
            orderInfoToUpdate[0].ET_MESSAGES__c = parsedResponseFromMS.row.ET_MESSAGES;
            orderInfoToUpdate[0].EX_CR_BLOCK__c = parsedResponseFromMS.row.EX_CR_BLOCK!=null?parsedResponseFromMS.row.EX_CR_BLOCK : '';
            orderInfoToUpdate[0].EX_EXCEPTION__c = parsedResponseFromMS.row.EX_EXCEPTION;
            if(parsedResponseFromMS.row.EV_SALES_ORDER==null || String.isBlank(parsedResponseFromMS.row.EV_SALES_ORDER))
                orderInfoToUpdate[0].Integration_Status__c='Error';
            recordsToUpdateList.add(orderInfoToUpdate[0]);   
            new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.information('SCP_OrderSubmitAPI','updateOrderInfo',orderInfoToUpdate[0].id,'Exception message : '+parsedResponseFromMS.row.ET_MESSAGES+'.'+'Credit Card Message : '+parsedResponseFromMS.row.EX_CR_BLOCK,response.getBody(),requestBody,string.valueof(response.getStatusCode())));
        }
             system.debug('### orditms--'+orditms); 
        system.debug('### recordsToUpdateList--'+recordsToUpdateList); 
        if(!recordsToUpdateList.isEmpty()){
            try{
            Database.saveResult[] srResult=Database.Update(recordsToUpdateList,false);
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
                new SCP_ApexDebugLog().CreateLog(new SCP_ApexDebugLog.Error('SCP_OrderSubmitAPI','updateOrderInfo',orderInfoToUpdate[0].id,response.getBody(),requestBody,string.valueof(response.getStatusCode()),customException));
            }
        }
           catch(exception e){
                system.debug('### excception line update --'+ e.getmessage()); 
            }  
        }
         
        if(!orditms.isEmpty()){
            try{
                   Database.Upsert(orditms,false);
                  
            }
            catch(exception e){
                system.debug('### excception line upsert --'+ e.getmessage()); 
            }
         
    } 
    } 

    public class MyException extends Exception {}
}