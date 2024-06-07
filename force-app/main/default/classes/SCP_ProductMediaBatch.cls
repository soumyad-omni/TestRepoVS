global class SCP_ProductMediaBatch implements Database.Batchable<sobject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        integer hours = integer.valueof(Label.SCP_Product_Media_Batch_Hours);
        Datetime dt = System.Now().addHours(-hours);
        string query;
        if(Boolean.valueof(Label.SCP_Include_Modified_Date))
        {
            query = 'SELECT id FROM ccrz__E_Product__c WHERE CreatedDate>=:dt  OR LastModifiedDate>=:dt';
        }
        else
        {
            query = 'SELECT id FROM ccrz__E_Product__c WHERE CreatedDate>=:dt';
        }
        return Database.getquerylocator(query);
    }
    global void execute(Database.Batchablecontext BC,List<ccrz__E_Product__c> prodlst)
    {
        Date enddate = Date.newInstance(2099,12,31);
        List<ccrz__E_ProductMedia__c> medialist = new List<ccrz__E_ProductMedia__c>();
        for(ccrz__E_Product__c objprod: prodlst)
        {
            ccrz__E_ProductMedia__c prdmedia = new ccrz__E_ProductMedia__c();
            prdmedia.ccrz__Product__c = objprod.id;
            prdmedia.ccrz__StartDate__c = System.Today().addDays(-1);
            prdmedia.ccrz__EndDate__c = enddate;
            prdmedia.ccrz__Enabled__c = true;
            prdmedia.ccrz__FilePath__c = 'ImageNotAvailable.jpg';
            prdmedia.ccrz__Locale__c = 'en_US';
            prdmedia.ccrz__MediaType__c = 'Product Search Image';
            prdmedia.ccrz__StaticResourceName__c = 'c__ImageNotAvailable';
            prdmedia.ccrz__ProductMediaSource__c = 'Static Resource';
            prdmedia.ccrz__ProductMediaId__c = objprod.id + 'Product Search Image'; 
            medialist.add(prdmedia);
            
        }
        if(!medialist.isEmpty())
        {
            upsert  medialist ccrz__ProductMediaId__c ;
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }

}