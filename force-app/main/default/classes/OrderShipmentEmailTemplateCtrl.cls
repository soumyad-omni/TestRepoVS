public class OrderShipmentEmailTemplateCtrl {
    public Id OrderShipmentId {get;set;}
    public string shipDate {get;set;}   
    
    public List<ccrz__E_OrderShipment__c> getOrderList()
    {
        List<ccrz__E_OrderShipment__c> ordList;
        
        ordList= [SELECT id,ccrz__Order__r.ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__FirstName__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__LastName__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__FirstName__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__LastName__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__AddressSecondline__c,
           ccrz__Order__r.ccrz__BillTo__r.ccrz__AddressThirdline__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__City__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__State__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__Country__c,
           ccrz__Order__r.ccrz__BillTo__r.ccrz__CountryISOCode__c,ccrz__Order__r.ccrz__BillTo__r.ccrz__PostalCode__c,
           ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__CompanyName__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressSecondline__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__AddressThirdline__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__City__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__State__c,
           ccrz__Order__r.ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__Country__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__CountryISOCode__c,ccrz__Order__r.ccrz__ShipTo__r.ccrz__PostalCode__c,
           ccrz__Order__r.ccrz__SubtotalAmount__c,ccrz__Order__r.ccrz__ShipAmount__c,ccrz__Order__r.ccrz__TaxAmount__c,ccrz__Order__r.ccrz__TotalAmount__c,ccrz__Order__r.ccrz__PaymentMethod__c,ccrz__Order__r.ccrz__RequestDate__c,ccrz__Order__r.SAP_Order_Number__c,
           ccrz__TrackingNo__c,ccrz__Carrier__c,ccrz__ShipmentDate__c,
           ccrz__Order__r.ccrz__OrderStatus__c,Name,ccrz__Order__c  FROM ccrz__E_OrderShipment__c WHERE Id =: OrderShipmentId];
            if(ordList[0].ccrz__ShipmentDate__c!= NULL )
            shipDate = ordList[0].ccrz__ShipmentDate__c.format();
            return ordList;
    }

    
    /*public List<ccrz__E_OrderShipmentItem__c> getOrderShipItem()
         
      {
        List<ccrz__E_OrderShipmentItem__c> OrderShipItemList;
        OrderShipItemList = [SELECT id,ccrz__OrderShipment__c,ccrz__OrderShipmentItemId__c,Product_Name__c,ccrz__Quantity__c,ccrz__SKU__c from ccrz__E_OrderShipmentItem__c where ccrz__OrderShipment__c =: OrderShipmentId];
          
        return OrderShipItemList;
      } */ 
    /* commented as per IBA-5834    
    public List<ccrz__E_TransactionPayment__c> getOrderPO()
         
      {
        String orderId = [select ccrz__Order__c from ccrz__E_OrderShipment__c where Id =: OrderShipmentId limit 1].ccrz__Order__c;
        List<ccrz__E_TransactionPayment__c> OrderPOList;
        OrderPOList = [SELECT id,ccrz__AccountType__c,ccrz__AccountNumber__c from ccrz__E_TransactionPayment__c where ccrz__ccorder__c =:orderId limit 1];
        return OrderPOList;
      }  commented as per IBA-5834 */

    public List<ccrz__E_OrderItem__c> getOrderItem()
         
      {
        List<ccrz__E_OrderItem__c> OrderItemList;
        List<ccrz__E_OrderShipmentItem__c> OrderShipItemList;
        List<String> orderItemIDList = new List<String>();
        List<String> orderItemIDList2 = new List<String>();//IBA-4361
        List<String> orderId = new List<String>();//IBA-4361
        String strID = '';
        String strID2 = '';

          OrderShipItemList = [SELECT id,ccrz__OrderShipment__c,ccrz__OrderShipmentItemId__c,Product_Name__c,ccrz__Quantity__c,ccrz__SKU__c,SAP_Line_Item__c,ccrz__OrderShipment__r.ccrz__Order__c from ccrz__E_OrderShipmentItem__c where ccrz__OrderShipment__c =: OrderShipmentId];//IBA-4361
          for (ccrz__E_OrderShipmentItem__c orderShipItem: OrderShipItemList){
              strID = orderShipItem.ccrz__OrderShipmentItemId__c;
            orderItemIDList.add(strID.right(strID.length()-strID.indexOf('_')-1));
              orderItemIDList2.add(orderShipItem.SAP_Line_Item__c);//IBA-4361
              orderId.add(orderShipItem.ccrz__OrderShipment__r.ccrz__Order__c);//IBA-4361
          }
          OrderItemList = [SELECT Name,
                                       ccrz__Product__r.Name,
                                   ccrz__PricingType__c,
                                   ccrz__OrderLineType__c,
                                       ccrz__PrimaryAttr__r.ccrz__DisplayName__c,
                                       ccrz__SecondaryAttr__r.ccrz__DisplayName__c,
                                       ccrz__TertiaryAttr__r.ccrz__DisplayName__c,
                                   DrugCodes__r.Brand_Name__c,
                                   DrugCodes__r.Drug_Strength__c,OrdItmExt_c__c,
                                       ccrz__Quantity__c FROM ccrz__E_OrderItem__c WHERE (Name in :orderItemIDList or OrdItmExt_c__c in: orderItemIDList2) and ccrz__Order__c =: orderId];//IBA-4361
          for (ccrz__E_OrderItem__c ordItem: OrderItemList){
              for (ccrz__E_OrderShipmentItem__c orderShipItem: OrderShipItemList){
                  strID = orderShipItem.ccrz__OrderShipmentItemId__c;
                  strID2 = strID.right(strID.length()-strID.indexOf('_')-1);
                  if (strID2 == ordItem.Name){
                      ordItem.ccrz__Quantity__c = orderShipItem.ccrz__Quantity__c;
                  }
              		if (orderShipItem.SAP_Line_Item__c == ordItem.OrdItmExt_c__c){//IBA-4361
                          ordItem.ccrz__Quantity__c = orderShipItem.ccrz__Quantity__c;
                      }                  
                  }
          }
          
        return OrderItemList;
      }
   
    public boolean getCart(){//IBA-4361
        List<ccrz__E_OrderShipment__c> ordList = [Select id,Name,ccrz__Order__r.ccrz__OriginatedCart__c FROM ccrz__E_OrderShipment__c WHERE Id =: OrderShipmentId];
        boolean cart = true;
        for(ccrz__E_OrderShipment__c shi:ordList){
            if(shi.ccrz__Order__r.ccrz__OriginatedCart__c == null){
                cart = false;
            }
        }
        return cart ;
    }
}