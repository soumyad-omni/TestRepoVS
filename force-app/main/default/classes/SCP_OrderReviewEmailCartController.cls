/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-24-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-24-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global without sharing class SCP_OrderReviewEmailCartController {
    public List<ccrz__E_CartItem__c> CartListrecords {get; set;} 
 public List<ccrz__E_Product__c> ProductList{get; set;} 
 public ccrz__E_Cart__c Cartrecords{get;set;}
 public String conFirstName{get;set;}
 public String conLastName{get;set;}
 public String effAccountName{get;set;}
 public List<wrapCartItems> wrapcartItemsList {get; set;}
 set<id> Productids = new set<id>();
 public decimal gtotal{get;set;}
 
   global SCP_OrderReviewEmailCartController(){  
         wrapcartItemsList = new List<wrapCartItems>();
         Account acc = new Account();
         String recordId = ApexPages.CurrentPage().getParameters().get('recordId');
          System.debug('recordId --------'+recordId );
         Cartrecords = [select id, Name,ccrz__TotalAmount__c,ccrz__SubtotalAmount__c,ccrz__EffectiveAccountID__c,ccrz__Contact__r.FirstName,ccrz__Contact__r.LastName,ccrz__Account__r.Name,
                        ccrz__EncryptedId__c,ccrz__TaxAmount__c,ccrz__ShipAmount__c from ccrz__E_Cart__c where ccrz__EncryptedId__c=:recordId]; 
         conFirstName = (Cartrecords.ccrz__Contact__r.FirstName!=null || Cartrecords.ccrz__Contact__r.FirstName!= '') ? Cartrecords.ccrz__Contact__r.FirstName : '';
         conLastName = (Cartrecords.ccrz__Contact__r.LastName!=null || Cartrecords.ccrz__Contact__r.LastName!= '') ? Cartrecords.ccrz__Contact__r.LastName: '';
         if(Cartrecords.ccrz__EffectiveAccountID__c!=null || Cartrecords.ccrz__EffectiveAccountID__c!=''){
             acc = [select id,Name from Account where id =: Cartrecords.ccrz__EffectiveAccountID__c];
             effAccountName = acc.Name != null? acc.Name : '';
         }
       
       decimal sub = 0;
       if(Cartrecords.ccrz__SubtotalAmount__c != null){
           sub = Cartrecords.ccrz__SubtotalAmount__c;
       }
       
       decimal tax = 0;
       if(Cartrecords.ccrz__TaxAmount__c != null){
           tax = Cartrecords.ccrz__TaxAmount__c;
       }
       
       decimal ship = 0;
       if(Cartrecords.ccrz__ShipAmount__c != null){
           ship = Cartrecords.ccrz__ShipAmount__c;
       }
       
       gtotal = sub + tax + ship;
       System.debug('tax --------'+Cartrecords.ccrz__TaxAmount__c );
       System.debug('ship --------'+Cartrecords.ccrz__ShipAmount__c );
         CartListrecords  =new list<ccrz__E_CartItem__c>([select id,Name,ccrz__Product__c,ccrz__Cart__c,ccrz__Price__c,ccrz__Quantity__c,ccrz__AbsoluteDiscount__c,
                                                          ccrz__ItemTotal__c,ccrz__Product__r.Name,Material__c,
                                                          ccrz__Product__r.ccrz__UnitOfMeasure__c, Machines__c, Machines__r.Machine_Name__c, DrugCodes__r.DrugCodes__c, DrugCodes__r.Brand_Name__c, DrugCodes__r.Drug_Strength__c, DrugCodes__c from ccrz__E_CartItem__c where
                                                          ccrz__Cart__r.ccrz__EncryptedId__c=:recordId and ccrz__PricingType__c != 'attrGroup']);
	    String mName= '';
    	String dName= '';
       	String bName= '';
       	String sName= '';
       	try{
             for(ccrz__E_CartItem__c cartItem : CartListrecords ){
                 if(cartItem.ccrz__Product__r.ccrz__UnitOfMeasure__c == null){
                     cartItem.ccrz__Product__r.ccrz__UnitOfMeasure__c = '';
                 }
                 if(cartItem.ccrz__AbsoluteDiscount__c == null){
                     cartItem.ccrz__AbsoluteDiscount__c = 0.0;
                 }
                 if(cartItem.Machines__c != null){
                     mName= cartItem.Machines__r.Machine_Name__c;
                 }
                 else {
                     mName= '';
                 }
                 if(cartItem.DrugCodes__c != null){
                     dName= cartItem.DrugCodes__r.DrugCodes__c;
                     bName= cartItem.DrugCodes__r.Brand_Name__c;
                     sName= cartItem.DrugCodes__r.Drug_Strength__c;
                 }
                 else {
                    dName= '';
                    bName= '';
                    sName= '';
                 }
                 wrapcartItemsList.add(new wrapCartItems(cartItem.ccrz__Product__r.Name,String.valueof(cartItem.ccrz__Price__c),String.valueof(cartItem.ccrz__Quantity__c),String.valueof(cartItem.ccrz__AbsoluteDiscount__c),String.valueof(cartItem.ccrz__ItemTotal__c),cartItem.Material__c,cartItem.ccrz__Product__r.ccrz__UnitOfMeasure__c,mName, dName, bName, sName));
                 system.debug('cartItem ---'+cartItem.ccrz__AbsoluteDiscount__c);
             }
         
         }catch(exception e){
             System.debug(e.getMessage());
         }
         system.debug([select id,name from ccrz__E_Product__c where id=:CartListrecords[0].ccrz__Product__c]);
     }
     
    public class wrapCartItems {
        public String productName {get; set;}
        public String price{get; set;}
        public String qty{get; set;}
        public String discount{get; set;}
        public String total{get; set;}
        public String sku{get; set;}
        public String uom{get; set;}
        public String machine{get; set;}
        public String drugcode{get; set;}
        public String brand{get; set;}
        public String strength{get; set;}
 
        public wrapCartItems(String a,String b,String c,String d,String e,String f,String g,String h,String i,String j,String k) {
            productName  = a;
            price= b;
            qty= c;
            discount= d;
            productName  = a;
            total= e;
            sku= f;
            uom= g;
            machine= h;
            drugcode= i;
            brand= j;
            strength= k;

        }
    }

}