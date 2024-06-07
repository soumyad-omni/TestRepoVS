/**********************************************************************
Name:  ErrorLogging
Copyright © 2018
======================================================
======================================================
Purpose: 
Class to store the Exceptions raised in the application to the Error object
                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                  Description
0.1          Haripriya Maturi          6/12/2018    Developed by CG Team       INITIAL DEVELOPMENT
***********************************************************************/
public class ErrorLogging {
    public static void Log(Exception ex, String ClassName, String typeoferror)
    {
        Error__c newError = new Error__c();  
        
        newError.Error_Message__c = ex.getMessage();
        if (newError.Error_Message__c.length() > 32000)
            newError.Error_Message__c = newError.Error_Message__c.substring(0, 32000);
        newError.Class__c = ClassName;
        newError.Type__c = typeoferror;
        
        Database.insert(newError);
    } 
    
    public static void IntegrationLog(String errormsg, String ClassName, String typeoferror)
    {
        system.debug('integrationlog..');
        Error__c newError = new Error__c();  
        
        newError.Error_Message__c = errormsg;
        if (newError.Error_Message__c.length() > 32000)
            newError.Error_Message__c = newError.Error_Message__c.substring(0, 32000);
        newError.Class__c = ClassName;
        newError.Type__c = typeoferror;
        
        Database.insert(newError);
    }

    public static Error__c RestResourceLog(String errormsg, String ClassName, String typeoferror, String JSON)
    {
        system.debug('RestResourceLog..');
        Error__c newError = new Error__c();  
        newError.Class__c = ClassName;
        newError.Type__c = typeoferror;
        newError.Re_Attempt__c = 0;
        
        if (errormsg.length() > 32000)
            newError.Error_Message__c = errormsg.substring(0, 32000);
        else
            newError.Error_Message__c = errormsg;
        
        if (JSON.length() > 131072)
            newError.JSON__c = JSON.substring(0, 131072);
        else
            newError.JSON__c = JSON;
        
        return newError;
    }    
}