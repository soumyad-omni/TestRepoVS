/**
 * Developer     Sanjana K.R
 * Date          8 Apr 2021
 * Description   Class to schedule the indexing for CC Product Spec
 */

global class SCP_ProdSpecIndexingScheduler implements Schedulable
{
    global void execute(SchedulableContext sc){
        
        //spec 
        Database.executeBatch(new ccrz.cc_job_LoadProductSpecIndex('Select Id, ParentProduct__c, FilterData__c from E_Product__c'), 200);  
        
    }
}