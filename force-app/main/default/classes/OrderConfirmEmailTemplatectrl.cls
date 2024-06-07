public class OrderConfirmEmailTemplatectrl
{
    public Id OrderId {get;set;}
    public string ReqDate {get;set;} 
    
    public List<ccrz__E_Order__c> getOrderList()
    {
        List<ccrz__E_Order__c> ordList;
        ordList= [SELECT id,Name,Owner.Name,ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__LastName__c,ccrz__ShipTo__r.ccrz__FirstName__c,ccrz__ShipTo__r.ccrz__LastName__c,ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__AddressSecondline__c,ccrz__BillTo__r.ccrz__AddressThirdline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__State__c,
        ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__BillTo__r.ccrz__Country__c,ccrz__BillTo__r.ccrz__CountryISOCode__c,ccrz__BillTo__r.ccrz__PostalCode__c,
        ccrz__ShipTo__r.ccrz__AddressFirstline__c,ccrz__ShipTo__r.ccrz__AddressSecondline__c,ccrz__ShipTo__r.ccrz__AddressThirdline__c,ccrz__ShipTo__r.ccrz__City__c,ccrz__ShipTo__r.ccrz__State__c,
        ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__ShipTo__r.ccrz__CompanyName__c,ccrz__ShipTo__r.ccrz__Country__c,ccrz__ShipTo__r.ccrz__CountryISOCode__c,ccrz__ShipTo__r.ccrz__PostalCode__c,
        ccrz__SubtotalAmount__c,ccrz__ShipAmount__c,ccrz__TaxAmount__c,ccrz__TotalAmount__c,ccrz__PaymentMethod__c,ccrz__RequestDate__c,SAP_Order_Number__c,ccrz__OrderStatus__c,ccrz__Order__c 
        from ccrz__E_Order__c WHERE Id =: OrderId];
        if(ordList[0].ccrz__RequestDate__c!= NULL )
        ReqDate = ordList[0].ccrz__RequestDate__c.format();
        return ordList;
        
    }
    
    public List<ccrz__E_OrderShipment__c> getOrderShipList()
    {
        List<ccrz__E_OrderShipment__c> oredrshipList;
        oredrshipList= [SELECT id,Name,ccrz__Order__c,ccrz__ShipmentDate__c,ccrz__Carrier__c,ccrz__TrackingNo__c from ccrz__E_OrderShipment__c where ccrz__Order__c=: OrderId];

        return oredrshipList;
    } 
    
    public List<ccrz__E_OrderItem__c> getOrderItemsList()
    {
        List<ccrz__E_OrderItem__c> oredrltemList;
        oredrltemList = [SELECT id,Name,Estimated_Delivery_DateText__c,ccrz__Product__r.Name,ccrz__Product_Name__c,ccrz__Price__c,ccrz__OrderItemStatus__c,ccrz__Quantity__c,ccrz__ItemStatus__c,ccrz__ItemTotal__c,ccrz__PricingType__c,ccrz__OrderLineType__c,ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__SecondaryAttr__r.ccrz__DisplayName__c,ccrz__TertiaryAttr__r.ccrz__DisplayName__c,DrugCodes__r.Brand_Name__c,DrugCodes__r.Drug_Strength__c from ccrz__E_OrderItem__c where ccrz__Order__c=: OrderId];// IBA-3736
        return oredrltemList;
    } 
    
    public List<Integer> getOrderCassetteitem()
    {
        List<Integer> cassetteCountList = new List<Integer>();
        Integer cassetteCount;
        cassetteCount = [SELECT COUNT()
                         FROM ccrz__E_OrderItem__c
                         WHERE ccrz__Order__c=: OrderId
                         AND Material__c IN ('CASS_VC_BASE', 'CASS_VC_CB', 'CASS_VC_VBM', 'CASS_VC_RFID')];
        cassetteCountList.add(cassetteCount);
        return cassetteCountList;
    } 

    public List<Integer> getOrderCanisteritem()
    {
        List<Integer> canisterCountList = new List<Integer>();
        Integer canisterCount;
        canisterCount = [SELECT COUNT()
                         FROM ccrz__E_OrderItem__c
                         WHERE ccrz__Order__c=: OrderId
                         AND Material__c = 'CANISTER_VC'];
        canisterCountList.add(canisterCount);
        return canisterCountList;
    } 
       
    public List<ccrz__E_TransactionPayment__c> getTranscList()
    {
        List<ccrz__E_Order__c> ordList;
        ordList= [SELECT id,Name,Owner.Name,ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__LastName__c,ccrz__ShipTo__r.ccrz__FirstName__c,ccrz__ShipTo__r.ccrz__LastName__c,ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__AddressSecondline__c,ccrz__BillTo__r.ccrz__AddressThirdline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__State__c,
        ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__BillTo__r.ccrz__Country__c,ccrz__BillTo__r.ccrz__CountryISOCode__c,ccrz__BillTo__r.ccrz__PostalCode__c,
        ccrz__ShipTo__r.ccrz__AddressFirstline__c,ccrz__ShipTo__r.ccrz__AddressSecondline__c,ccrz__ShipTo__r.ccrz__AddressThirdline__c,ccrz__ShipTo__r.ccrz__City__c,ccrz__ShipTo__r.ccrz__State__c,
        ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__ShipTo__r.ccrz__Country__c,ccrz__ShipTo__r.ccrz__CountryISOCode__c,ccrz__ShipTo__r.ccrz__PostalCode__c,
        ccrz__SubtotalAmount__c,ccrz__ShipTo__r.ccrz__CompanyName__c,ccrz__ShipAmount__c,ccrz__TaxAmount__c,ccrz__TotalAmount__c,ccrz__PaymentMethod__c,ccrz__RequestDate__c,SAP_Order_Number__c,ccrz__OrderStatus__c,ccrz__Order__c 
        from ccrz__E_Order__c WHERE Id =: OrderId];
        List<ccrz__E_TransactionPayment__c> TranscList;
        TranscList = [SELECT id,Name,ccrz__AccountNumber__c,ccrz__AccountType__c,ccrz__Amount__c,LastModifiedDate,CreatedDate from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c=: OrderId order by CreatedDate desc limit 1];
        if(TranscList.size() ==0){
            TranscList = [SELECT id,Name,ccrz__AccountNumber__c,ccrz__AccountType__c,ccrz__Amount__c,LastModifiedDate,CreatedDate from ccrz__E_TransactionPayment__c where ccrz__CCOrder__c=: ordList[0].ccrz__Order__c order by CreatedDate desc limit 1];
        }
        return TranscList;
    } 
}