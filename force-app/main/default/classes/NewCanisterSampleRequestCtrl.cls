public class NewCanisterSampleRequestCtrl {
    public Id OrderId {get;set;}
    
    public List<ccrz__E_Order__c> getOrderList()
    {
        List<ccrz__E_Order__c> ordList;
        ordList= [SELECT id,Name,Owner.Name,ccrz__BillTo__r.ccrz__CompanyName__c,ccrz__BillTo__r.ccrz__FirstName__c,ccrz__BillTo__r.ccrz__LastName__c,ccrz__ShipTo__r.ccrz__FirstName__c,ccrz__ShipTo__r.ccrz__LastName__c,ccrz__BillTo__r.ccrz__AddressFirstline__c,ccrz__BillTo__r.ccrz__AddressSecondline__c,ccrz__BillTo__r.ccrz__AddressThirdline__c,ccrz__BillTo__r.ccrz__City__c,ccrz__BillTo__r.ccrz__State__c,
        ccrz__BillTo__r.ccrz__StateISOCode__c,ccrz__BillTo__r.ccrz__Country__c,ccrz__BillTo__r.ccrz__CountryISOCode__c,ccrz__BillTo__r.ccrz__PostalCode__c,ccrz__BuyerPhone__c,
        ccrz__ShipTo__r.ccrz__AddressFirstline__c,ccrz__ShipTo__r.ccrz__AddressSecondline__c,ccrz__ShipTo__r.ccrz__AddressThirdline__c,ccrz__ShipTo__r.ccrz__City__c,ccrz__ShipTo__r.ccrz__State__c,
        ccrz__ShipTo__r.ccrz__StateISOCode__c,ccrz__ShipTo__r.ccrz__CompanyName__c,ccrz__ShipTo__r.ccrz__Country__c,ccrz__ShipTo__r.ccrz__CountryISOCode__c,ccrz__ShipTo__r.ccrz__PostalCode__c,
        ccrz__SubtotalAmount__c,ccrz__ShipAmount__c,ccrz__TaxAmount__c,ccrz__TotalAmount__c,ccrz__PaymentMethod__c,ccrz__RequestDate__c,SAP_Order_Number__c,ccrz__OrderStatus__c,ccrz__Order__c 
        from ccrz__E_Order__c WHERE Id =: OrderId];
        return ordList;
        //test
    }
    
    public List<ccrz__E_OrderItem__c> getOrderItemsList()
    {
        List<ccrz__E_OrderItem__c> oredrltemList;
        oredrltemList = [SELECT DrugCodes__r.DrugCodes__c,
                         DrugCodes__r.Long_Generic_Name__c,
                         DrugCodes__r.Brand_Name__c,
                         DrugCodes__r.Drug_Strength__c,
                         DrugCodes__r.Manufacturer_Name__c,
                         DrugCodes__r.Dose_Unit__c,
                         DrugCodes__r.Drug_Forms__c,
                         //DrugCodes__r.Width1__c,
                         //DrugCodes__r.Thickness1__c,
                         //DrugCodes__r.Width2__c,
                         //DrugCodes__r.Length__c,
                         //DrugCodes__r.Thickness2__c,
                         ccrz__Quantity__c
                         FROM ccrz__E_OrderItem__c
                         WHERE ccrz__Order__c=: OrderId
                         AND Drug_Code_Exists_in_SAP__c != TRUE
                         AND ccrz__OrderLineType__c = 'Minor'
                         AND Material__c = 'CANISTER_VC'];
        return oredrltemList;
    }
}