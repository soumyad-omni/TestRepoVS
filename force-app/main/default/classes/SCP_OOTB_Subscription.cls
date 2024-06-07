/*** 
Class to scheduler the Batch class - SCP_OOTB_Subscription
Developer - Subramanyam Gopinath  
***/

global class SCP_OOTB_Subscription implements Schedulable
{
    global void execute(SchedulableContext sc){
        //ccrz.cc_batch_SubscriptionProcessor s = new ccrz.cc_batch_SubscriptionProcessor('OmnicellB2BStore','recurrOrder',True);
        SCP_cc_batch_subscriptionProcessor  s = new SCP_cc_batch_subscriptionProcessor();
        DataBase.executeBatch(s);      
    }
}