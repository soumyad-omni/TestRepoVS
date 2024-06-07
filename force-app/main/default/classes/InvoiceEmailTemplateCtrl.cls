public class InvoiceEmailTemplateCtrl {
    public Id Invoice {get;set;}
    
    public List<ccrz__E_Invoice__c> getOrderList()
    {
        List<ccrz__E_Invoice__c> ordList;
        ordList = [Select id,Name,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__FirstName__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__LastName__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__FirstName__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__LastName__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__AddressSecondline__c,
           ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__AddressThirdline__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__City__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__State__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__Country__c,
           ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__CountryISOCode__c,ccrz__CCOrder__r.ccrz__BillTo__r.ccrz__PostalCode__c,
           ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__AddressFirstline__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__AddressSecondline__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__AddressThirdline__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__City__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__State__c,
           ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__Country__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__CountryISOCode__c,ccrz__CCOrder__r.ccrz__ShipTo__r.ccrz__PostalCode__c,ccrz__CCOrder__r.SAP_Order_Number__c from ccrz__E_Invoice__c where id =: Invoice];
           return ordList ;
           }
           
     public List<ccrz__E_InvoiceItem__c> getInvoiceItem()
         
      {
        List<ccrz__E_InvoiceItem__c> InvoiceItemList;
        InvoiceItemList = [SELECT id,Name, ccrz__CCOrder__c,ccrz__Invoice__c,Product_Name__c,Invoice_Item_Quantity__c,ccrz__Status__c,ccrz__Type__c, ccrz__CCOrderItem__r.ccrz__OrderLineType__c,ccrz__CCOrderItem__r.ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__CCOrderItem__r.ccrz__SecondaryAttr__r.ccrz__DisplayName__c,ccrz__CCOrderItem__r.ccrz__TertiaryAttr__r.ccrz__DisplayName__c,ccrz__CCOrderItem__r.DrugCodes__r.Brand_Name__c,ccrz__CCOrderItem__r.DrugCodes__r.Drug_Strength__c from ccrz__E_InvoiceItem__c where ccrz__Type__c = 'Item' AND ccrz__Invoice__c =: Invoice];
        return InvoiceItemList;
      }  
    
    public boolean getCart(){//IBA-4361
        List<ccrz__E_Invoice__c> ordList = [Select id,Name,ccrz__CCOrder__r.ccrz__OriginatedCart__c from ccrz__E_Invoice__c where id =: Invoice];
        boolean cart = true;
        for(ccrz__E_Invoice__c inv:ordList){
            if(inv.ccrz__CCOrder__r.ccrz__OriginatedCart__c == null){
                cart = false;
            }
        }
        return cart ;
    }
    
    public List<ccrz__E_OrderItem__c> getCCOrdItem(){//IBA-4361
        /*List<ccrz__E_Invoice__c> ordList = [Select id,Name,ccrz__CCOrder__c from ccrz__E_Invoice__c where id =: Invoice];
        List<ccrz__E_OrderItem__c> oItemList = [SELECT ccrz__Product_Name__c,ccrz__Quantity__c,ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__SecondaryAttr__r.ccrz__DisplayName__c,
                     ccrz__TertiaryAttr__r.ccrz__DisplayName__c,DrugCodes__r.Brand_Name__c,DrugCodes__r.Drug_Strength__c,ccrz__OrderLineType__c
                     from ccrz__E_OrderItem__c where ccrz__Order__c =: ordList[0].ccrz__CCOrder__c];*/
        List<ccrz__E_InvoiceItem__c> InvoiceItemList = [SELECT id,ccrz__CCOrderItem__c from ccrz__E_InvoiceItem__c where ccrz__Type__c = 'Item' AND ccrz__Invoice__c =: Invoice];
        list<string> oItemId = new list<string>();
        for(ccrz__E_InvoiceItem__c inv:InvoiceItemList){
            oItemId.add(inv.ccrz__CCOrderItem__c);
        }
        List<ccrz__E_OrderItem__c> oItemList = [SELECT ccrz__Product_Name__c,ccrz__Quantity__c,ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__SecondaryAttr__r.ccrz__DisplayName__c,
                     ccrz__TertiaryAttr__r.ccrz__DisplayName__c,DrugCodes__r.Brand_Name__c,DrugCodes__r.Drug_Strength__c,ccrz__OrderLineType__c
                     from ccrz__E_OrderItem__c where id=:oItemId];
        
        return oItemList;
    } 
    
    }