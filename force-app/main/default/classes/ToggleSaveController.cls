public with sharing class ToggleSaveController {
    Quote quote{get;set;}    
    public string accountid{get;set;}
    public String quoteid = ApexPages.currentPage().getParameters().get('Id');
    public String orderType = ApexPages.currentPage().getParameters().get('OT');   
    Quote q = [select SAP_Sales_Org__c,accountid,Shipping_Contact__c,Sales_Operation_Counterpart__c,Consultant__c,Sales_Consultant__c,opportunityid,Ship_to_Account__c,Bill_to_Account__c,Payer__c,GPO_Account__c,IDN_Account__c from Quote where id=:quoteid];
    public String accid = q.AccountId;
    public String oppid = q.OpportunityId;
    

    public ToggleSaveController(ApexPages.StandardController controller){
        
        this.quote = (Quote)controller.getRecord();
        quote.Order_Type__c=orderType; 
       
    }

    public PageReference save(){      
       
            try{
                quote.Order_Type__c=orderType;      
                System.debug('ALH orderType='+orderType);
                System.debug('ALH quote='+quote);    
                update quote;
                
                PageReference pr = new PageReference('/'+quote.id);
                 pr.setRedirect(true);
                return pr;
            }
            catch(DMLException e) { 
                ApexPages.addMessages(e); 
                return null; 
            }
    }


}