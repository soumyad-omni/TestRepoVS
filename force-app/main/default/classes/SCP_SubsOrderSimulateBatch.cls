/* 
* Class Name       :SCP_SubsOrderSimulateBatch
* Description      :Batch class to make Order Simulate call for Subscription Orders
* Created By       :Sanjana K.R
* Created On       :Apr 29,2021

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date           Story                                 Description
* ----------------------------------------------------------------------------------------------------------------
* Sanjana K.R             29/4/2021
*/

Public class SCP_SubsOrderSimulateBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    Public Database.querylocator start(Database.BatchableContext bc) {
        
        String queryString='select id,ccrz__Order__c,ccrz__Order__r.ccrz__OriginatedCart__c,ccrz__RequestDate__c ,ccrz__TaxAmount__c,ccrz__ShipMethod__c,ccrz__ShipAmount__c,Process_OrderSimulate__c,Process_OrderSubmit__c,WS_Credit_Block__c,WS_ErrorMessages__c,WS_Exception__c,Integration_Status__c from ccrz__E_Order__c where Process_OrderSimulate__c = TRUE and ccrz__CCSubscription__c!=NULL limit 100';
    
        return Database.getQueryLocator(queryString);   
    } 
    
    Public void execute(Database.BatchableContext BC, List<ccrz__E_Order__c> newSubscriptionOrds){
                
        SCP_OrderSimulate ordSim = new SCP_OrderSimulate();
        ordSim.updateSubscriptionOrder(newSubscriptionOrds);
       
    }
    
    public void finish(Database.BatchableContext BC){
        SCP_SubscriptionOrderSubmitBatch batch = new SCP_SubscriptionOrderSubmitBatch();
        Database.executeBatch(batch);
    
    }

}