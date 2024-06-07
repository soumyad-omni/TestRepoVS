/**********************************************************************
Name:  AccountErrorLog
Copyright © 2018
======================================================
======================================================
Purpose: 
Class to store the Exceptions raised in the Account Integration.
                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL          Description
0.1          Linda Neel         8/9/2018         Adopted from CG Team     INITIAL DEVELOPMENT
***********************************************************************/
public class AccountErrorLog {
    public static void Log(Exception ex,String ClassName, String typeoferror)
    {
        AccountError__c newError = new AccountError__c();  
        
        newError.Error_Message__c = ex.getMessage();
        if (newError.Error_Message__c.length() > 32000)
            newError.Error_Message__c = newError.Error_Message__c.substring(0, 32000);
        newError.Class__c = ClassName;
        newError.Type__c = typeoferror;
        newError.Account_Id__c = null;
        Database.insert(newError);
    }  
    public static void Log(string message, string accountId)
    {
        AccountError__c newError = new AccountError__c();  
        
        newError.Error_Message__c = message;
        if (newError.Error_Message__c.length() > 32000)
            newError.Error_Message__c = newError.Error_Message__c.substring(0, 32000);
        newError.Class__c = 'AccountCreateController';
        newError.Type__c = 'Integration';
        newError.Account_Id__c = accountId;
        Database.insert(newError);
    }
}