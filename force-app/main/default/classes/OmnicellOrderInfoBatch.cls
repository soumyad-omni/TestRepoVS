/*Description: Batch class to capture CC category details onto OrderItems
  Author: Aravind 
*/
global class OmnicellOrderInfoBatch implements Database.Batchable<sObject> {

public Database.QueryLocator start(Database.BatchableContext BC){   
      return Database.getQueryLocator([SELECT Id, ccrz__Product__c, ccrz__Category__c, ccrz__Category__r.Name, ccrz__Category__r.ccrz__CategoryID__c FROM ccrz__E_ProductCategory__c WHERE ccrz__Category__r.ccrz__ParentCategory__r.Name = 'All Products' ]);
   }
   public void execute(Database.BatchableContext BC, List<ccrz__E_ProductCategory__c> scope){
       List<ccrz__E_OrderItem__c> orderItemsToUpdate = new List<ccrz__E_OrderItem__c>();
       Set<Id> omniPrdId = new Set<Id>();
       Map<Id, Id> mapOCITEM = new Map<Id, ID>();
       Map<Id, ccrz__E_ProductCategory__c> mapCCCat = new Map<Id,ccrz__E_ProductCategory__c> ();


     for(ccrz__E_ProductCategory__c s : scope){ 
         mapCCCat.put(s.ccrz__Product__c, s); // Category and cc Product category 
         omniPrdId.add(s.ccrz__Product__c);
     }

     for(ccrz__E_OrderItem__c ccItem : [SELECT Id, ccrz__Product__c FROM ccrz__E_OrderItem__c WHERE ccrz__Product__c =: omniPrdId ]) {
         ccItem.Category_Name__c = mapCCCat.get(ccItem.ccrz__Product__c).ccrz__Category__r.Name;
         ccItem.Category_ID__c = mapCCCat.get(ccItem.ccrz__Product__c).ccrz__Category__r.ccrz__CategoryID__c;
         ccItem.ccrz__Category__c = mapCCCat.get(ccItem.ccrz__Product__c).ccrz__Category__c;
        orderItemsToUpdate.add(ccItem);
     }
     if(!orderItemsToUpdate.isEmpty()){
         update orderItemsToUpdate;
         System.debug('Order Items : ' +orderItemsToUpdate );
     }
    }
       public void finish(Database.BatchableContext BC){
   }

}