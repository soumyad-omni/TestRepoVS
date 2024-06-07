/*** 
batch and QUERY SUBSCRIPTION ORDERS WHERE Process_OrderSubmit = true and send to SAP 
Developer - Subramanyam Gopinath  
***/


global class SCP_SubscriptionOrderSubmitBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    global Database.querylocator start(Database.BatchableContext BC)
    { 
        String query;
        if(!Test.isRunningTest())
            query = 'SELECT id,Name,Process_OrderSubmit__c,ccrz__CCSubscription__c,ccrz__CCSubscription__r.ccrz__InstallmentCountRemaining__c,ccrz__OrderId__c,ccrz__Account__r.SAP_Account_ID__c,ccrz__Contact__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Customer_Number__c,ccrz__ShipTo__r.ccrz__ShippingComments__c,ccrz__BillTo__r.SAP_Customer_Number__c,ccrz__BillTo__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Contact_ID__c,ccrz__Note__c,ccrz__ShipAmount__c,SAP_Order_Number__c,SHIP_COND__c,ccrz__PONumber__c,ccrz__OriginatedCart__c,ccrz__TotalDiscount__c FROM ccrz__E_Order__c where Process_OrderSubmit__c=True and SAP_Order_Number__c = NULL and ccrz__CCSubscription__c!=\'\' limit 100';
        else
            query = 'SELECT id,Name,Process_OrderSubmit__c,ccrz__CCSubscription__c,ccrz__CCSubscription__r.ccrz__InstallmentCountRemaining__c,ccrz__OrderId__c,ccrz__Account__r.SAP_Account_ID__c,ccrz__Contact__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Customer_Number__c,ccrz__ShipTo__r.ccrz__ShippingComments__c,ccrz__BillTo__r.SAP_Customer_Number__c,ccrz__BillTo__r.SAP_Contact_ID__c,ccrz__ShipTo__r.SAP_Contact_ID__c,ccrz__Note__c,ccrz__ShipAmount__c,SAP_Order_Number__c,SHIP_COND__c,ccrz__PONumber__c,ccrz__OriginatedCart__c,ccrz__TotalDiscount__c,(SELECT id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__OrderItemStatus__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c FROM ccrz__E_OrderItems__r) FROM ccrz__E_Order__c where Process_OrderSubmit__c=True and SAP_Order_Number__c = NULL and ccrz__CCSubscription__c!=\'\' limit 100';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ccrz__E_Order__c> suborders){
       List<ccrz__E_Order__c> orderLst = new List<ccrz__E_Order__c>();
         if(!suborders.isEmpty()){
            for(ccrz__E_Order__c order:suborders){
           orderLst.add(order);
            }
             SCP_SubsOrderSubmitUpdate orderSubAPI = new SCP_SubsOrderSubmitUpdate();
            orderSubAPI.OrderSubmitUpdateCall(orderLst);
         }              
    }

    global void finish(Database.BatchableContext BC){
    }
}