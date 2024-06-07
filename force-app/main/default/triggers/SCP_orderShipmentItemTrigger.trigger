trigger SCP_orderShipmentItemTrigger on ccrz__E_OrderShipmentItem__c (before insert,before update) {
    
    System.debug('Printing Order shipment item entered trigger');
    
     list<string> skus = new  list<string>();
    for(ccrz__E_OrderShipmentItem__c shipmentItem :Trigger.New){
        System.debug('Printing shipment id'+shipmentItem.ccrz__OrderShipment__c);
        System.debug('Printing shipment details'+shipmentItem.ccrz__OrderShipment__r);
        ccrz__E_OrderShipment__c shipmentInfo=[Select id,ccrz__Order__r.ccrz__BuyerEmail__c From ccrz__E_OrderShipment__c Where id=:shipmentItem.ccrz__OrderShipment__c];
        System.debug('Printing email field'+shipmentInfo.ccrz__Order__r.ccrz__BuyerEmail__c);  
        shipmentItem.SCP_Email__c=shipmentInfo.ccrz__Order__r.ccrz__BuyerEmail__c;
        
       skus.add(shipmentItem.ccrz__SKU__c );
    }
     
     Map<string, ccrz__E_Product__c> MapOfProd = new Map<string, ccrz__E_Product__c>();
     for(ccrz__E_Product__c pd:[select id,Name,ccrz__SKU__c from ccrz__E_Product__c where ccrz__SKU__c in: skus]){
         MapOfProd.put(pd.ccrz__SKU__c,pd);
     }
       for(ccrz__E_OrderShipmentItem__c shipitem : trigger.new)
       {
           if(MapOfProd.containsKey(shipitem.ccrz__SKU__c)){
                system.debug(MapOfProd.get(shipitem.ccrz__SKU__c).Name);
                shipitem.Product_Name__c = MapOfProd.get(shipitem.ccrz__SKU__c).Name;
            }
       } 
}