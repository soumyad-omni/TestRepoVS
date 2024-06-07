/*** 
Batch to delete the delete old price list items at the end of the year, as subscriptions are all set to expire on 12/31. 
The job will delete all pricelist items that are linked to subprodterms with start and end dates of the current year.
Developer - Subramanyam Gopinath  
***/


global class SCP_DeletePriceListItemBatch implements Database.Batchable<sObject>{

    global Database.querylocator start(Database.BatchableContext BC)
    {
        string query  = 'Select Id,ccrz__SubProdTerm__r.ccrz__EffectiveEnd__c, ccrz__SubProdTerm__r.ccrz__EffectiveStart__c from ccrz__E_PriceListItem__c where  ccrz__SubProdTerm__r.ccrz__EffectiveEnd__c = This_year and ccrz__SubProdTerm__r.ccrz__EffectiveStart__c = This_year and ccrz__SubProdTerm__c !=\'\'';
        //string query  = 'Select Id,ccrz__SubProdTerm__r.ccrz__EffectiveEnd__c, ccrz__SubProdTerm__r.ccrz__EffectiveStart__c from ccrz__E_PriceListItem__c where  ccrz__SubProdTerm__r.ccrz__EffectiveEnd__c = This_year and ccrz__SubProdTerm__r.ccrz__EffectiveStart__c = This_year and ccrz__SubProdTerm__c !=\'\' and id=\'a6a03000000AJVX\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ccrz__E_PriceListItem__c> pricelistltem){
          if(pricelistltem.size()>0){
        delete pricelistltem;
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}