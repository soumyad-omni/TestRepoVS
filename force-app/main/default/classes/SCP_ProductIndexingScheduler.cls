/**
 * Developer     Sanjana K.R
 * Date          15 Mar 2021
 * Description   Class to schedule the SCP_IndexingBatch class
 */

global class SCP_ProductIndexingScheduler implements Schedulable
{
    global void execute(SchedulableContext sc){      
       
        //product index 
        ccrz.ccProductIndexBuilder.build(new Map<String, Object> {
                ccrz.ccApiProductIndex.LOCALES => new Set<String>{'en_US','en'},
                ccrz.ccApiProductIndex.CLEAN_ONLY => TRUE
            });     
        
    }
}