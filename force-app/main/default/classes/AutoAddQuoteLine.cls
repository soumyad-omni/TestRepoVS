public class AutoAddQuoteLine implements Queueable {
    public Set<Id> qtLnIds ; 
    public AutoAddQuoteLine(Set<Id> qtLnIds){
        this.qtLnIds = qtLnIds ;  
    }
    public void execute(QueueableContext context) {
        Set<Id> quoteIds = new Set<Id>();
        Map<String,Quote_Line__c> newQuoteLineMap = new Map<String,Quote_Line__c>();
        List<Quote_Line__c> autoAddQtLn = new List<Quote_Line__c>();
        Map<Id,Quote_Line__c> qtLineOCEMap = new Map<Id,Quote_Line__c>();
        Map<Id,Quote_Line__c> qtLineIVSMap = new Map<Id,Quote_Line__c>();
        for(Quote_Line__c qtLn : [Select Id, Quote__c, Product__r.Portfolio_Segment__c, Product__r.ProductCode 
                                         from Quote_Line__c where Id in : qtLnIds]){
     		quoteIds.add(qtLn.Quote__c);
            autoAddQtLn.add(qtLn);                                 
        }
        for(Quote_Line__c qtLn : [Select Id, Quote__c, Product__r.ProductCode from Quote_Line__c where Quote__c in : quoteIds and
                                  (Product__r.ProductCode =: Label.OCE_Product or Product__r.ProductCode  =: Label.IVS_Product)]){
            if(qtLn.Product__r.ProductCode == Label.OCE_Product){
            	qtLineOCEMap.put(qtLn.Quote__c,qtLn);    
            } else if(qtLn.Product__r.ProductCode == Label.IVS_Product) {
            	qtLineIVSMap.put(qtLn.Quote__c,qtLn);      
            }
        }
        Map<String,Product2> prodMap = new Map<String,Product2>();
        for(Product2 pr : [Select Id,ProductCode,QuantityUnitOfMeasure from Product2 where ProductCode =: Label.OCE_Product or ProductCode =: Label.IVS_Product]){
        	prodMap.put(pr.ProductCode,pr);    
        }
        Map<String,String> ocePrtflSgmntMap = new Map<String,String>();
        Map<String,String> ivsPrtflSgmntMap = new Map<String,String>();
		for (String prt1 : Label.Portfolio_Segment_OCE.split(',')){ocePrtflSgmntMap.put(prt1,Label.OCE_Product);}
		for (String prt2 : Label.Portfolio_Segment_IVS.split(',')){ivsPrtflSgmntMap.put(prt2,Label.IVS_Product);}
        for(Quote_Line__c nQtLn : autoAddQtLn){
        	if((qtLineOCEMap.size() > 0 && qtLineOCEMap.get(nQtLn.Quote__c) == null) || qtLineOCEMap.size() == 0 ||
               (qtLineIVSMap.size() > 0 && qtLineIVSMap.get(nQtLn.Quote__c) == null) || qtLineIVSMap.size() == 0){
                Quote_Line__c ql = new Quote_Line__c();
        		Id devRecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('SAP Quote Line').getRecordTypeId();
        		ql.RecordTypeId = devRecordTypeId;
        		ql.Quote__c = nQtLn.Quote__c;
        		ql.Quantity__c = 1;
                ql.Line_Status__c = 'E0001';
                if(ocePrtflSgmntMap.containsKey(nQtLn.Product__r.Portfolio_Segment__c) 
                   && !newQuoteLineMap.containsKey(nQtLn.Quote__c+'_'+Label.OCE_Product)
                   && ((qtLineOCEMap.size() > 0 && qtLineOCEMap.get(nQtLn.Quote__c) == null) || qtLineOCEMap.size() == 0)) {
                   	ql.Product__c = prodMap.get(Label.OCE_Product).Id;   
        			ql.Unit_of_Measure__c = prodMap.get(Label.OCE_Product).QuantityUnitOfMeasure;
                    newQuoteLineMap.put(nQtLn.Quote__c+'_'+Label.OCE_Product,ql);    
                 } else if (ivsPrtflSgmntMap.containsKey(nQtLn.Product__r.Portfolio_Segment__c)
                   			&& !newQuoteLineMap.containsKey(nQtLn.Quote__c+'_'+Label.IVS_Product) 
                            && ((qtLineIVSMap.size() > 0 && qtLineIVSMap.get(nQtLn.Quote__c) == null) || qtLineIVSMap.size() == 0)) {
                 	ql.Product__c = prodMap.get(Label.IVS_Product).Id;   
        			ql.Unit_of_Measure__c = prodMap.get(Label.IVS_Product).QuantityUnitOfMeasure;
                    newQuoteLineMap.put(nQtLn.Quote__c+'_'+Label.IVS_Product,ql);            
                 }   
                   
            }    
        }
        if(newQuoteLineMap.size() > 0){
        	insert newQuoteLineMap.values();    
        }
    }
    
    // IBA-5747 SH -- Cancel OCE-LIC-002 if the Parent is cancelled
    Public static void CancelOCEProducts(Quote_line__c qli){
        QuoteLineTriggerHandler.TriggerDisabled = true;
        update qli;
        System.debug('@#$CancelOCEProducts '+ qli.Line_Status__c+' Status: '+qli.Product_Code__c);
    }

}