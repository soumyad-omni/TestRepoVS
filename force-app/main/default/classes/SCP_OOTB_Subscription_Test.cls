@isTest
    private class SCP_OOTB_Subscription_Test
    {
        public static String CRON_EXP = '0 0 0 15 3 ? 2022';

        static testmethod void SCP_OOTB_Subscription_TestMethod() 
        {
            Test.startTest();
            String jobId = System.schedule('SCP_OOTB_SubscriptionTestMethod',CRON_EXP, new SCP_OOTB_Subscription());
            Test.StopTest();
         }                              
}