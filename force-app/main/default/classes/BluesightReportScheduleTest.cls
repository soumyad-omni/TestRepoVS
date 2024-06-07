@isTest
private class BluesightReportScheduleTest {
    private class RestMockSuccess implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMockFail implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(400);
            return res;
        }
    }
    

    static testmethod void schedulerTestSuccess() 
    {
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_Bluesight';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'http://uat-aloha-bluesight-saptosfdc.us-w1.cloudhub.io/api/bluesight';
        insert setting;
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '1035732629892-i986n3744vbm8nfgaffc25g5p849r0ml';
        setting1.SCP_Password_Client_Secret__c = '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';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        
        String CRON_EXP = '0 0 0 15 3 ? *';      
       
        Test.setMock(HttpCalloutMock.class, new RestMockSuccess());
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BluesightReportSchedule());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        // Add assert here to validate result
    }
    
    static testmethod void schedulerTestFail() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';      
        CastIronIntegration__c setting = new CastIronIntegration__c();
        setting.Name = 'CastIronIntegration';
        setting.BluesightReport_AppConnect_EndPoint__c = 'http://sit-aloha-bluesight-saptosfdc.us-w1.cloudhub.io/api/bluesight';
        insert setting;
        Test.setMock(HttpCalloutMock.class, new RestMockFail());
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BluesightReportSchedule());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        // Add assert here to validate result
    }
}