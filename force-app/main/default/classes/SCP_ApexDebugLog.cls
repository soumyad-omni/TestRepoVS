/*Description: This Apex Class exposes method(s) that can be utilized by 
other Apex Classes to create Persistent Logs of type Error or
Information as opposed to native Debug Logs*/ 
global class SCP_ApexDebugLog{
    public virtual class Log{
        public String Type;
        public String ApexClass;
        public String Method;
        public String RecordId;
        public String Message;
        public String StackTrace;
        public String Response;
        public String Request;
        public String StatusCode;
    }
    public class Error extends Log{
        public Error(String cls, String routine, String recId,String response,String request,String StatusCode,Exception ex){
            this.Type = 'Error';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Response=response;
            this.Request=request;
            if(ex!=null){
                this.Message = ex.getMessage();
                this.StackTrace = ex.getStackTraceString();
            }
            this.StatusCode=StatusCode;
        }
    }
    public class Information extends Log{
        public Information(String cls, String routine, String recId, String msg,String Response,String Request,String StatusCode){
            this.Type = 'Information';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = msg;
            this.Response=Response;
            this.Request=Request;
            this.StackTrace = NULL;
            this.StatusCode=StatusCode;
        }
    }
    public void createLog(Log logToCreate){
        try{
            if(
                (Limits.getDMLRows() < Limits.getLimitDMLRows()) && 
                (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
            )
            {
                SCP_Apex_Debug_Logs__c apexDebuglog = new SCP_Apex_Debug_Logs__c(
                    SCP_Type__c         = logToCreate.Type,
                    SCP_Apex_Class__c   = logToCreate.ApexClass,
                    SCP_Method__c       = logToCreate.Method,
                    SCP_Record_Id__c    = logToCreate.RecordId,
                    SCP_Message__c      = logToCreate.Message,
                    SCP_Stack_Trace__c  = logToCreate.StackTrace,
                    SCP_Response__c     = logToCreate.Response,
                    SCP_Request__c      = logToCreate.Request,
                    SCP_Status_Code__c  = logToCreate.StatusCode
                );

                Database.insert(apexDebuglog, FALSE);
                
            }
            else{
                System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
            }
        }
        catch(DMLException ex){
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }
    webService
    static void createLog(String log){
        try{
            SCP_ApexDebugLog.Log logToCreate = (SCP_ApexDebugLog.Log)JSON.deserialize(log, SCP_ApexDebugLog.Log.class);
            
            new SCP_ApexDebugLog().createLog(logToCreate);
        }
        catch(Exception ex){
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }
}