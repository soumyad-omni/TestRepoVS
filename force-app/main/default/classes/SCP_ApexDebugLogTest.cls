@isTest
public class SCP_ApexDebugLogTest{
    testMethod
    static void createErrorLog(){
        try{
            Integer result = 1 / 0;
        }
        catch(Exception ex){
            /*new SCP_ApexDebugLog().createLog(
                new SCP_ApexDebugLog.Error(
                    'ApexDebugLog_Test',
                    'createErrorLog',
                    NULL,
                    ex
                )
            );

            List<SCP_Apex_Debug_Logs__c> lstLogsCreated = [
                SELECT  Id, SCP_Type__c, SCP_Apex_Class__c, SCP_Method__c
                FROM    SCP_Apex_Debug_Logs__c
                WHERE   SCP_Method__c = 'createErrorLog'
            ];

            System.assertEquals(1, lstLogsCreated.size());
            System.assertEquals('Error', lstLogsCreated.get(0).SCP_Type__c);
            System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).SCP_Apex_Class__c);*/
        }
    }

    testMethod
    static void createInformationLog(){
        /*new SCP_ApexDebugLog().createLog(
            new SCP_ApexDebugLog.Information(
                'ApexDebugLog_Test',
                'createInformationLog',
                NULL,
                'Logging Information from an Apex Class - ApexDebugLog_Test'
            )
        );

        List<SCP_Apex_Debug_Logs__c> lstLogsCreated = [
            SELECT  Id, SCP_Type__c, SCP_Apex_Class__c, SCP_Method__c, SCP_Message__c
                FROM  SCP_Apex_Debug_Logs__c
            WHERE   SCP_Method__c = 'createInformationLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('Information', lstLogsCreated.get(0).SCP_Type__c);
        System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).SCP_Apex_Class__c);
        System.assertEquals('Logging Information from an Apex Class - ApexDebugLog_Test', lstLogsCreated.get(0).SCP_Message__c);
    */
    }

    testMethod
    static void ws_createErrorLog(){
        try{
            Integer result = 1 / 0;
        }
        catch(Exception ex){
            SCP_ApexDebugLog.createLog(
                '{"Type" : "Error","ApexClass" : "ApexDebugLog_Test","Method" : "createErrorLog","RecordId" : "","Message" : "System.MathException: Divide by 0","StackTrace" : "Line: 1, Column: 1 System.MathException: Divide by 0"}'
            );

            List<SCP_Apex_Debug_Logs__c> lstLogsCreated = [
                SELECT  Id, SCP_Type__c, SCP_Apex_Class__c, SCP_Method__c
                FROM    SCP_Apex_Debug_Logs__c
                WHERE   SCP_Method__c = 'createErrorLog'
            ];

            System.assertEquals(1, lstLogsCreated.size());
            System.assertEquals('Error', lstLogsCreated.get(0).SCP_Type__c);
            System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).SCP_Apex_Class__c);
        }
    }

    testMethod
    static void ws_createInformationLog(){
        SCP_ApexDebugLog.createLog(
            '{"Type" : "Information","ApexClass" : "ApexDebugLog_Test","Method" : "createInformationLog","RecordId" : "","Message" : "Logging Information from an Apex Class - ApexDebugLog_Test"}'
        );

        List<SCP_Apex_Debug_Logs__c> lstLogsCreated = [
            SELECT  Id, SCP_Type__c, SCP_Apex_Class__c, SCP_Method__c, SCP_Message__c
            FROM    SCP_Apex_Debug_Logs__c
            WHERE   SCP_Method__c = 'createInformationLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('Information', lstLogsCreated.get(0).SCP_Type__c);
        System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).SCP_Apex_Class__c);
        System.assertEquals('Logging Information from an Apex Class - ApexDebugLog_Test', lstLogsCreated.get(0).SCP_Message__c);
    }
}