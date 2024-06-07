public class OfflineBuildRequestVFTemplateController {
    
    public Id obrId {get;set;} 
    
    //default constructor
    public OfflineBuildRequestVFTemplateController(){}
    
    // get the offline build request lines information.
    public List<OfflineBuildRequestLine__c> offlineBuildRequestLines{
        get{
            offlineBuildRequestLines = new List<OfflineBuildRequestLine__c>();
            
            offlineBuildRequestLines = [Select Id,
                                        OfflineBuildRequest__c,
                                        PARLocation__c,
                                        Product__c,
                                        Product__r.Name,
                                        Quantity__c,
                                        PricingReferenceModel__c,
                                        QuoteLineItem__c,
                                        SAPLineItemGUID__c,
                                        QuoteLineItemReference__c,
                                        PricingReferenceModel__r.Name
                                        from OfflineBuildRequestLine__c 
                                        where OfflineBuildRequest__c =:obrId Order By Product__r.Name];
            
            return offlineBuildRequestLines;
            
        }
        set;
    }
}