/*** 
Handler class for the batch SCP_SubscriptionOrderSubmitBatch
Developer - Subramanyam Gopinath  
***/

public class SCP_SubsOrderSubmitUpdate{
    
    public void OrderSubmitUpdateCall(List<ccrz__E_Order__c> orderId){
        Set<Id> subsIdSet = new Set<Id>();
        List<ccrz__E_Subscription__c> updateSubs = new List<ccrz__E_Subscription__c>();
        ccrz__E_Subscription__c orderSubs;
        List<ccrz__E_Order__c> ordersToUpdate = new List<ccrz__E_Order__c>();
        List<sObject> recordsToUpdateList = new List<sObject>();
        List<SCP_Apex_Debug_Logs__c> errorLogList=new List<SCP_Apex_Debug_Logs__c>();
        Map<ccrz__E_Order__c,SCP_OrderSimulate_Res_Parser> orderToMuleResponseMap = new Map<ccrz__E_Order__c,SCP_OrderSimulate_Res_Parser>();// Map to store response from mulesoft for every transaction.
        
        if(!orderId.isEmpty()){
            /*for(ccrz__E_Order__c order : orderId){
                subsIdSet.add(order.ccrz__CCSubscription__c);
            }
            Map<id,ccrz__E_Subscription__c> subsMap = new Map<id,ccrz__E_Subscription__c>([select id,ccrz__InstallmentCountRemaining__c from ccrz__E_Subscription__c where id IN: subsIdSet]);*/
            for(ccrz__E_Order__c order:orderId){
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
                            /*orderSubs = new ccrz__E_Subscription__c(Id=subsMap.get(order.ccrz__CCSubscription__c).id);
                            orderSubs.ccrz__InstallmentCountRemaining__c = subsMap.get(order.ccrz__CCSubscription__c).ccrz__InstallmentCountRemaining__c - 1;
                            updateSubs.add(orderSubs);*/
                            //order.ccrz__CCSubscription__r.ccrz__InstallmentCountRemaining__c = order.ccrz__CCSubscription__r.ccrz__InstallmentCountRemaining__c -1;
                            order.Process_OrderSubmit__c= false;
                            
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
                                            orderItems.ccrz__AbsoluteDiscount__c=Decimal.ValueOf(responseFromMule.row.ET_ITEMLIST.get(i).ABS_DISCOUNT);
                                            orderItems.ccrz__PercentDiscount__c=Decimal.ValueOf(responseFromMule.row.ET_ITEMLIST.get(i).PERC_DISCOUNT);
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
								order.Process_OrderSubmit__c= false;
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
                        order.Process_OrderSubmit__c= false;
                        recordsToUpdateList.add(order);
                        errorLogList.add(errorDetails(order,responseFromMule));    
                    }
                }
            }
        }
        
        System.debug('Printing Size of the map'+recordsToUpdateList.Size());
        
        if(!recordsToUpdateList.isEmpty()){
            Database.saveResult[] srResult=Database.Update(recordsToUpdateList,false);
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
        
        if(!updateSubs.isEmpty())
            update updateSubs;
        
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
    
    Public SCP_Apex_Debug_Logs__c errorDetails(ccrz__E_Order__c order,SCP_OrderSimulate_Res_Parser responseFromMule){
        SCP_Apex_Debug_Logs__c log= new SCP_Apex_Debug_Logs__c();
        log.SCP_Apex_Class__c='SCP_SubscriptionOrderSubmitBatch';
        log.SCP_Method__c='OrderSubmitUpdateCall';
        log.SCP_Record_Id__c=order.id;
        if(responseFromMule!=null){
            log.SCP_Response__c=String.valueof(responseFromMule);
            if(!test.isRunningTest())
            log.SCP_Message__c='Exception message : '+responseFromMule.row.ET_MESSAGES+'.'+'Credit Card Message : '+responseFromMule.row.EX_CR_BLOCK;   
        }else{
            
            log.SCP_Message__c='Error While processing submit API call for this child Order';
        }
        log.SCP_Type__c='error';
        return log;
    }
}