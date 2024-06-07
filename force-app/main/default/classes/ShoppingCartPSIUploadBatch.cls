global class ShoppingCartPSIUploadBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){     
        String query = '';
        query = 'Select Id,Name,ccrz__SKU__c,(Select Id From ccrz__E_ProductMedias__r Where ccrz__MediaType__c = \'Product Search Image\''+') From ccrz__E_Product__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ccrz__E_Product__c> scope){
        
        Date enddate = Date.newInstance(2099,12,31);
        List<ccrz__E_ProductMedia__c> medialist = new List<ccrz__E_ProductMedia__c>();
        ccrz__E_ProductMedia__c prdmedia;
        for(ccrz__E_Product__c pd : scope){
           if(pd.ccrz__E_ProductMedias__r.Size() == 0){
                prdmedia = new ccrz__E_ProductMedia__c();
                prdmedia.ccrz__Product__c = pd.id;
                prdmedia.ccrz__StartDate__c = System.Today().addDays(-1);
                prdmedia.ccrz__EndDate__c = enddate;
                prdmedia.ccrz__Enabled__c = true;
                prdmedia.ccrz__FilePath__c = 'ImageNotAvailable.jpg';
                prdmedia.ccrz__Locale__c = 'en_US';
                prdmedia.ccrz__MediaType__c = 'Product Search Image';
                prdmedia.ccrz__StaticResourceName__c = 'c__ImageNotAvailable';
                prdmedia.ccrz__ProductMediaSource__c = 'Static Resource';
                prdmedia.ccrz__ProductMediaId__c = pd.id + 'Product Search Image'; 
                medialist.add(prdmedia);   
            }
        }
        
        if(!medialist.isEmpty()){
            upsert  medialist ccrz__ProductMediaId__c ;            
        }  
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}