@isTest
public class JobMonitor_testDataFactory {
	    
    public static List<Message_type__c> getMessage_type(){
        
        List<Message_type__c> testMts = new List<Message_type__c>();
        testMts.add(new Message_type__c(Name = 'Log', msgType__c ='l'));
        testMts.add(new Message_type__c(Name = 'Error', msgType__c ='e'));
        testMts.add(new Message_type__c(Name = 'Summary', msgType__c ='s'));
        testMts.add(new Message_type__c(Name = 'Next run error', msgType__c ='n'));
        insert testMts;  
        
        
    //    Message_type__c mt = new Message_type__c();
    //    mt.Name = 'Log';
     //   mt.msgType__c ='l';
     //   insert mt;
        return testMts;
	}
    
    public static Job_list__c getJobList(String name) {
        List<Message_type__c> testMts = getMessage_type();
        
      //  Job_list__c jl = new Job_list__c(Name='xyz', msgTypes__c='l');
        Job_list__c jl = new Job_list__c(Name= name);
        insert jl;
		return jl;
	}
    
    public static Job_execution__c getJob_execution(){
		Job_list__c jl = getJobList('xyz');        
        Job_execution__c je = new Job_execution__c(); 
        
        je.endTime__c = Datetime.now() - (2.5/24);
		je.Job_id__c = jl.id;
		je.notificationStatus__c = 'NotSent';
        je.startTime__c = Datetime.now() - (3/24);
        je.NextRunTime__c = Datetime.now() + (3/24); 
        je.status__c = 'Successful'; 
                
        insert je;
        return je;
	}
    
    public static Job_execution__c getJob_execution(String jobName){
		Job_list__c jl = getJobList(jobName);        
        Job_execution__c je = new Job_execution__c(); 
        
        je.endTime__c = Datetime.now() - (2.5/24);
		je.Job_id__c = jl.id;
		je.notificationStatus__c = 'NotSent';
        je.startTime__c = Datetime.now() - (3/24);
        je.NextRunTime__c = Datetime.now() + (3/24); 
        je.status__c = 'Successful'; 
                
        insert je;
        return je;
	}
    
	public static List<Job_log_distribution__c> getJob_log_distribution(Job_execution__c je){
      //  Job_execution__c je = getJob_execution(jobName);
        
        List<Job_log_distribution__c> testJldLst = new List<Job_log_distribution__c>();
        
        testJldLst.add(new Job_log_distribution__c(emailList__c = 'test@test.com', startDate__c = Date.newInstance(2020, 3, 15),
			Job_id__c = je.Job_id__c, msgTypes__c = 'iudersw', ReportEmail__c = 'AsScheduled'));
        testJldLst.add(new Job_log_distribution__c(emailList__c = 'test@test.com', startDate__c = Date.newInstance(2020, 3, 15),
			Job_id__c = je.Job_id__c, msgTypes__c = 'n', ReportEmail__c = 'WhenFinish'));

        insert testJldLst; 
        return testJldLst;
        
        
    //    Message_type__c mt = new Message_type__c();
    //    mt.Name = 'Log';
     //   mt.msgType__c ='l';
     //   insert mt;
     //   return testMts;
	}
    
    public static List<Job_log__c> getJob_log(Job_execution__c je){
        
        List<Job_log__c> testJlLst = new List<Job_log__c>();
        
        testJlLst.add(new Job_log__c(Job_execution_id__c = je.Id, msgLog__c = 'Test summary',
			msgTypeName__c = 's', timeStamp__c = DateTime.now()));
        testJlLst.add(new Job_log__c(Job_execution_id__c = je.Id, msgLog__c = 'Test log',
			msgTypeName__c = 'l', timeStamp__c = DateTime.now()));
        testJlLst.add(new Job_log__c(Job_execution_id__c = je.Id, msgLog__c = 'Test error',
			msgTypeName__c = 'e', timeStamp__c = DateTime.now()));
        testJlLst.add(new Job_log__c(Job_execution_id__c = je.Id, msgLog__c = 'Test next run error',
			msgTypeName__c = 'n', timeStamp__c = DateTime.now()));

        insert testJlLst; 
		return testJlLst;        
	}


}