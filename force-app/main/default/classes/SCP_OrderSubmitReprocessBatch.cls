Public class SCP_OrderSubmitReprocessBatch implements Database.Batchable<sObject>,DataBase.AllowsCallouts{

    Public Database.querylocator start(Database.BatchableContext bc) {
    
        String ERROR_STATUS='Error';
        String ORDER_STATUS_SUBMITTED='Order Submitted';
        String BLANK_STRING='';
        String queryString='SELECT id,Name,ccrz__OrderId__c,ccrz__Account__r.SAP_Account_ID__c,ccrz__Contact__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Customer_Number__c,ccrz__ShipTo__r.ccrz__ShippingComments__c,ccrz__BillTo__r.SAP_Customer_Number__c,ccrz__BillTo__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Contact_ID__c,ccrz__Note__c,ccrz__ShipAmount__c,SAP_Order_Number__c,SHIP_COND__c,ccrz__PONumber__c,ccrz__OriginatedCart__c,ccrz__TotalDiscount__c,ET_MESSAGES__c,EX_CR_BLOCK__c,EX_EXCEPTION__c,Integration_Status__c,(SELECT id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__OrderItemStatus__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c FROM ccrz__E_OrderItems__r) FROM ccrz__E_Order__c Where Integration_Status__c=:ERROR_STATUS AND SAP_Order_Number__c=:BLANK_STRING';
    
        return Database.getQueryLocator(queryString);
    }
    
    Public void execute(Database.BatchableContext BC, List<ccrz__E_Order__c> unProcessedOrders){
    
        System.debug('Printing numbers of Records for each execute'+unProcessedOrders.Size());
        List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
        set<sObject> recordsToUpdateList = new set<sObject>();
        List<SCP_Apex_Debug_Logs__c> errorLogList=new List<SCP_Apex_Debug_Logs__c>();
        Map<ccrz__E_Order__c,SCP_OrderSimulate_Res_Parser> orderToMuleResponseMap = new Map<ccrz__E_Order__c,SCP_OrderSimulate_Res_Parser>();// Map to store response from mulesoft for every transaction.
        if(!unProcessedOrders.isEmpty()){
            for(ccrz__E_Order__c order:unProcessedOrders){
                //calling order Submit API.
                System.debug('Printing order id #####'+order.id);
                if(Limits.getLimitCallouts()>=Limits.getCallouts()){
                    SCP_OrderSubmitAPI orderAPI = new SCP_OrderSubmitAPI();
                    SCP_OrderSimulate_Res_Parser responseFromMule= orderAPI.sendOrderInformationToSAP(order.id);
                    if(responseFromMule.row!=null){
                        System.debug('Printing SAP OrderID from the response'+responseFromMule);
                        orderToMuleResponseMap.put(order,responseFromMule);
                        if(responseFromMule.row.EX_EXCEPTION==null || (responseFromMule.row.EX_EXCEPTION!='X' && responseFromMule.row.EX_EXCEPTION!='D')){  //scp-794 corrected or to and
                           order.ET_MESSAGES__c=responseFromMule.row.ET_MESSAGES;
                           order.EX_CR_BLOCK__c=responseFromMule.row.EX_CR_BLOCK;
                           order.EX_EXCEPTION__c=responseFromMule.row.EX_EXCEPTION;
                           order.ccrz__OrderId__c=responseFromMule.row.EV_SALES_ORDER;
                           order.Integration_Status__c='Submitted'; 
                           
                           if(String.isNotBlank(responseFromMule.row.EV_SALES_ORDER)){
                               order.SAP_Order_Number__c=responseFromMule.row.EV_SALES_ORDER;
                           }
                           
                           if(order.ccrz__E_OrderItems__r.isEmpty()){
                               for(ccrz__E_OrderItem__c orderItemsToUpdate:order.ccrz__E_OrderItems__r){
                                    orderItemsToUpdate.ccrz__OrderItemStatus__c='Order Submitted'; 
                                    recordsToUpdateList.add(orderItemsToUpdate); 
                                }    
                           }
                           
                           if(responseFromMule.row.ET_ITEMLIST!=null && responseFromMule.row.ET_ITEMLIST.SIZE()>0 ){
                                for(Integer i=0;i<responseFromMule.row.ET_ITEMLIST.size();i++){ 
                                    for(ccrz__E_OrderItem__c orderItems:order.ccrz__E_OrderItems__r){
                                        if(responseFromMule.row.ET_ITEMLIST.get(i).ITM_NUMBER==orderItems.Name.right(6)){
                                            if(responseFromMule.row.ET_ITEMLIST.get(i).REQ_QTY<=responseFromMule.row.ET_ITEMLIST.get(i).AVL_QTY){
                                                orderItems.ccrz__AvailabilityMessage__c='Available'; // Need to use Custom Label.
                                            }else If(responseFromMule.row.ET_ITEMLIST.get(i).AVL_QTY<responseFromMule.row.ET_ITEMLIST.get(i).REQ_QTY){
                                                orderItems.ccrz__AvailabilityMessage__c='Backorder'; // Need to use Custom Label.
                                            } 
                                            if(responseFromMule.row.ET_ITEMLIST.get(i).ABS_DISCOUNT != null){//IBA-3894
                                                orderItems.ccrz__AbsoluteDiscount__c=Decimal.ValueOf(responseFromMule.row.ET_ITEMLIST.get(i).ABS_DISCOUNT);
                                            }
                                            if(responseFromMule.row.ET_ITEMLIST.get(i).PERC_DISCOUNT  != null){//IBA-3894
                                                orderItems.ccrz__PercentDiscount__c=Decimal.ValueOf(responseFromMule.row.ET_ITEMLIST.get(i).PERC_DISCOUNT);
                                            }
                                        }
                                        recordsToUpdateList.add(orderItems);   
                                    }
                                }
                            } 
                            recordsToUpdateList.add(order);    
                        }else{
						        if(responseFromMule.row.EX_EXCEPTION=='D'){
                                order.ET_MESSAGES__c = System.Label.SCP_ApexError;
                                order.EX_EXCEPTION__c = 'X';
                                order.Integration_Status__c='Error';
                                recordsToUpdateList.add(order); 
                                errorLogList.add(errorDetails(order,responseFromMule));
                                
                            }else{

                            //failure scenario.
                            order.ET_MESSAGES__c = responseFromMule.row.ET_MESSAGES;
                            order.EX_CR_BLOCK__c = responseFromMule.row.EX_CR_BLOCK!=null?responseFromMule.row.EX_CR_BLOCK : '';
                            order.EX_EXCEPTION__c = responseFromMule.row.EX_EXCEPTION;
                            if(responseFromMule.row.EV_SALES_ORDER==null || String.isBlank(responseFromMule.row.EV_SALES_ORDER))
                                order.Integration_Status__c='Error';
                                recordsToUpdateList.add(order); 
                                errorLogList.add(errorDetails(order,responseFromMule)); 
                            }     
                        }
                    }else{
                         //failure scenario. Where there is no response from Mulesoft
                            order.ET_MESSAGES__c = 'No Response from Mulesoft';
                            order.EX_CR_BLOCK__c = 'No Response from Mulesoft';
                            order.EX_EXCEPTION__c = 'No Response from Mulesoft';
                            order.Integration_Status__c='Error';
                            recordsToUpdateList.add(order);
                            errorLogList.add(errorDetails(order,responseFromMule));    
                    }
                }
            }
        }
        
        System.debug('Printing Size of the map'+recordsToUpdateList.Size());
        List<sObject> UpdateList = new List<sObject>(recordsToUpdateList);
        if(!recordsToUpdateList.isEmpty()){
            Database.saveResult[] srResult=Database.Update(UpdateList,false);
            List<string> failedRecordID= new List<string>();
            String failedRecordIdString='';
            for(Database.SaveResult sr: srResult){
                if(!sr.isSuccess()){
                    //get record Id;
                    failedRecordID.add(sr.getId());
                }else{
                    System.debug('Printing debug values'+sr.getId());
                }
            }    
        }
        
        if(!errorLogList.isEmpty()){
            Database.saveResult[] srResult=Database.insert(errorLogList,false);
            List<string> failedErrorID= new List<string>();
            String failedErrorIdString='';
            for(Database.SaveResult sr: srResult){
                if(!sr.isSuccess()){
                    //get record Id;
                    failedErrorID.add(sr.getId());
                }else{
                    System.debug('Printing debug values'+sr.getId());
                }
            }    
        }
    }
    
    Public void finish(Database.BatchableContext BC){
        
    }
    
    Public SCP_Apex_Debug_Logs__c errorDetails(ccrz__E_Order__c order,SCP_OrderSimulate_Res_Parser responseFromMule){
        SCP_Apex_Debug_Logs__c log= new SCP_Apex_Debug_Logs__c();
        log.SCP_Apex_Class__c='SCP_OrderSubmitReprocessBatch';
        log.SCP_Method__c='SCP_OrderSubmitReprocessBatch';
        log.SCP_Record_Id__c=order.id;
        if(responseFromMule!=null){
             log.SCP_Response__c=String.valueof(responseFromMule);
            if(!test.isRunningTest())
            log.SCP_Message__c='Exception message : '+responseFromMule.row.ET_MESSAGES+'.'+'Credit Card Message : '+responseFromMule.row.EX_CR_BLOCK;   
        }else{
 
            log.SCP_Message__c='Error While Reprocessing Order';
        }
        log.SCP_Type__c='error';
        return log;
    }

}