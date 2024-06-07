/* *******************************************************
 * Author : Pavan Kumar
 * Dated: October 09, 2020
 * Description: Apex Controller is used to support lightning component used for adding Offline lines to an Quote.
 * Test Class: OffineBuildRequestControllerTest
 * *******************************************************/
public class OffineBuildRequestController {
    
    @AuraEnabled
    public static List<Quote_Line__c> getQuoteLines(String quoteId){
        return [Select Id,
                Product__c,
                Product__r.Name,
                Quantity__c,
                Par_Location__c,
                Pricing_Reference_Model__c,
                Pricing_Reference_Model__r.Name,
                SAP_Line_Item_GUID__c,
                SAP_Line_Number__c 
                From Quote_Line__c 
                Where Quote__c =:quoteId AND 
                Higher_Level_Item__c = 0 AND
                Product__r.Name != 'FREIGHT' Order By SAP_Line_Number__c];
    }
    
    @AuraEnabled
    public static void createOfflineBuildRequestLines(String recordId,String quoteId,List<Quote_Line__c> quoteLines){
        
        Set<String> higherLevelItemSet = new Set<String>();
        Map<Decimal,Quote_Line__c> highLevelToQuoteLineMap = new Map<Decimal,Quote_Line__c>();
        Map<Decimal,List<Quote_Line__c>> highLevelToChildrenMap = new Map<Decimal,List<Quote_Line__c>>();
        List<OfflineBuildRequestLine__c> newOfflineLines = new List<OfflineBuildRequestLine__c>();
        
        for(Quote_Line__c ql : quoteLines){
            highLevelToQuoteLineMap.put(ql.SAP_Line_Number__c,ql);
        }
        
        for(Quote_Line__c ql : [Select Id,
                                Product__c,                                
                                Quantity__c,
                                Par_Location__c,
                                SAP_Line_Number__c ,
                                Higher_Level_Item__c,
                                SAP_Line_Item_GUID__c,
                                Pricing_Reference_Model__c
                                From Quote_Line__c 
                                Where Quote__c = :quoteId AND
                                Higher_Level_Item__c = :highLevelToQuoteLineMap.keySet() AND
                                Product__r.Name != 'FREIGHT' Order By SAP_Line_Number__c])
        {
            if(highLevelToChildrenMap.containsKey(ql.Higher_Level_Item__c)){
                highLevelToChildrenMap.get(ql.Higher_Level_Item__c).add(ql);
            }else{
                highLevelToChildrenMap.put(ql.Higher_Level_Item__c,new List<Quote_Line__c>{highLevelToQuoteLineMap.get(ql.Higher_Level_Item__c)});
                highLevelToChildrenMap.get(ql.Higher_Level_Item__c).add(ql);
            }
        }
        
        
        for(Decimal highLevelItem : highLevelToQuoteLineMap.keySet()){            
            if(highLevelToChildrenMap.containsKey(highLevelItem)){                
                // iterate and add all children lines
                for(Quote_Line__c ql : highLevelToChildrenMap.get(highLevelItem)){
                    system.debug('ql==>'+ql);
                    newOfflineLines.add(new OfflineBuildRequestLine__c(OfflineBuildRequest__c = recordId,
                                                                       PARLocation__c = ql.Par_Location__c,
                                                                       Product__c = ql.Product__c,
                                                                       Quantity__c = ql.Quantity__c,
                                                                       PricingReferenceModel__c = ql.Pricing_Reference_Model__c,
                                                                       QuoteLineItem__c = ql.Id,
                                                                       SAPLineItemGUID__c = ql.SAP_Line_Item_GUID__c,
                                                                       QuoteLineItemReference__c = ql.Id));
                }
            }else{
                // add parent line
                newOfflineLines.add(new OfflineBuildRequestLine__c(OfflineBuildRequest__c = recordId,
                                                                   PARLocation__c = highLevelToQuoteLineMap.get(highLevelItem).Par_Location__c,
                                                                   Product__c = highLevelToQuoteLineMap.get(highLevelItem).Product__c,
                                                                   Quantity__c = highLevelToQuoteLineMap.get(highLevelItem).Quantity__c,
                                                                   PricingReferenceModel__c = highLevelToQuoteLineMap.get(highLevelItem).Pricing_Reference_Model__c,
                                                                   QuoteLineItem__c = highLevelToQuoteLineMap.get(highLevelItem).Id,
                                                                   SAPLineItemGUID__c = highLevelToQuoteLineMap.get(highLevelItem).SAP_Line_Item_GUID__c,
                                                                   QuoteLineItemReference__c = highLevelToQuoteLineMap.get(highLevelItem).Id));
                
                
            }            
        }
        try{
            insert newOfflineLines;
        }Catch(DMLException ex){
            throw new AuraHandledException(ex.getMessage());
        }        
    }
}