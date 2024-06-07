public class JobMonitor {
    
    //  (Returns the object of the new inserted record.)
    public static Job_execution__c logJobStart(String jobName, Datetime startTime){
        // Find job id from Job_list object
        List<Job_list__c> jl =[SELECT id, Name FROM Job_list__c WHERE Name =:jobName];
        // Start time = current time.
       // Datetime now = Datetime.now();
        // insert to Job_execution job id and start time.
        Job_execution__c je = new Job_execution__c(); 
        je.Job_id__c = jl[0].id;  
        je.startTime__c = startTime;
        insert je;
        
    	return je;   
    }
    
    public static Boolean logMessage(Job_execution__c jobExec, String msg, String msgType){
		Boolean success = true;
        
        try{
            // insert to Job_execution job id and start time.
            Job_log__c jl = new Job_log__c();
            jl.Job_execution_id__c = jobExec.Id;
            jl.msgTypeName__c = msgType; //logTypeName;
            jl.msgLog__c = msg;
            jl.timeStamp__c = Datetime.now();
            insert jl;
            System.debug('JobMonitor.logMessage :: New job log message id :: ' + jl.Id);
            
        } catch(Exception e){
            success = false;
            System.debug('JobMonitor.logMessage :: Error :: ' + e.getMessage() + ' Line ::' + e.getLineNumber());  
        }
                
        return success;
    }
    
    public static Boolean logJobFinish(Job_execution__c jobExec, Datetime endTime, String status){
        Boolean success = true;
        
        try{
            System.debug('In job finish');
            jobExec.endTime__c = endTime;  
            jobExec.status__c = status;
            jobExec.notificationStatus__c = 'NotSent';
    
            update jobExec;
            System.debug('In job finish: jobExec.endTime__c :: ' + jobExec.endTime__c 
                + '  jobExec.status__c :: ' +  jobExec.status__c);
            
        } catch(Exception e){
            success = false;
            System.debug('JobMonitor.logJobFinish :: Error :: ' + e.getMessage() + ' Line ::' + e.getLineNumber());    
        }
        return success;   
    }
    
    public static Boolean logJobNextRunTime(Job_execution__c jobExec, Datetime nextTime){
        Boolean success = true;
        try{
            System.debug('In job finish');
            jobExec.NextRunTime__c = nextTime;  
            update jobExec;
            System.debug('In job finish: jobExec.NextRunTime__c :: ' + jobExec.NextRunTime__c );
            
        } catch(Exception e){
            success = false;
            System.debug('JobMonitor.logJobNextRunTime :: Error :: ' + e.getMessage() + ' Line ::' + e.getLineNumber());       
        } 
        return success;   
    }

}