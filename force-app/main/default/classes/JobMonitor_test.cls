@isTest
public class JobMonitor_test {
    @isTest static void logJobStart_Test() { 
        Datetime startTime = Datetime.now(); 
        Job_list__c jl = JobMonitor_testDataFactory.getJobList('xyz');
	//	Job_list__c jl = new Job_list__c(Name='xyz');
     //   insert jl;
        
        // reset governor limits for the actual test of the trigger
        Test.startTest();
        Job_execution__c tje = JobMonitor.logJobStart(jl.Name, startTime);
        // exit the testing context
        Test.stopTest();
        
		system.assertEquals(startTime,tje.startTime__c);
     }
    
	 @isTest static void logMessage_Test() {
      /*
       *   Message_type__c mt = new Message_type__c();
        mt.Name = 'Log';
        mt.msgType__c ='l';
        insert mt;
        
        Job_list__c jl = new Job_list__c(Name='xyz', msgTypes__c='l');
        insert jl;
        
        Job_execution__c je = new Job_execution__c(); 
        je.Job_id__c = jl.id;  
        je.startTime__c = Datetime.now();
        insert je; 
         */
         
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        
        // reset governor limits for the actual test of the trigger
        Test.startTest();
        Boolean res = JobMonitor.logMessage(je, 'test', 'l');
        Boolean res2 = JobMonitor.logMessage(null, 'test', 'l');
        // exit the testing context
        Test.stopTest();
        
		system.assertEquals(true,res);
        system.assertEquals(false,res2);
     }
    
	@isTest static void logJobFinish_Test() { 
        // logJobFinish(Job_execution__c jobExec, Datetime endTime, String status)
        Datetime startTime = Datetime.now(); 
	/*	Job_list__c jl = new Job_list__c(Name='xyz');
        insert jl;
        
        Job_execution__c je = new Job_execution__c(); 
        je.Job_id__c = jl.id;  
        insert je; 
*/
        
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        
        // reset governor limits for the actual test of the trigger
        Test.startTest();
        Boolean res = JobMonitor.logJobFinish(je, startTime, 'Successful');
        Boolean res2 = JobMonitor.logJobFinish(null, startTime, 'Successful');
        // exit the testing context
        Test.stopTest();
       
		system.assertEquals(true,res);
        system.assertEquals(false,res2);
     }
    
	@isTest static void logJobNextRunTime_Test() { 
        Datetime startTime = Datetime.now(); 
		/*
		 * Job_list__c jl = new Job_list__c(Name='xyz');
        insert jl;
        
        Job_execution__c je = new Job_execution__c(); 
        je.Job_id__c = jl.id;  
        insert je; 
        */
        
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        
        // reset governor limits for the actual test of the trigger
        Test.startTest();
        Boolean res = JobMonitor.logJobNextRunTime(je, startTime);
        Boolean res2 = JobMonitor.logJobNextRunTime(null, startTime);
        // exit the testing context
        Test.stopTest();
       
		system.assertEquals(true,res);
        system.assertEquals(false,res2);
     }
    
}