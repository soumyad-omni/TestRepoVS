/**
 * Developer     Sanjana K.R
 * Date          8 Apr 2021
 * Description   Class to schedule the Category Indexing class
 */

global class SCP_CategoryIndexingScheduler implements Schedulable
{
    global void execute(SchedulableContext sc){
            
        //category
        try{
            (new ccrz.ccCategoryCacheBuilder()).build(new Map<String,Object>{ccrz.ccCategoryCacheBuilder.STOREFRONT => 'OmnicellB2BStore'});
        }
        catch(Exception e){
        }            
        
    }
}