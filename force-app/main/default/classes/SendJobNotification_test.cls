@isTest
public class SendJobNotification_test {
    @isTest static void checkTimeAndSendMail_test(){
        System.debug('Job Execution >>> 1 ');
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution('xyz');
        System.debug('Job Execution >>> 2 ');
        List<Job_log_distribution__c> jldLst = JobMonitor_testDataFactory.getJob_log_distribution(je);
        System.debug('Job Execution >>> 3 ');
        List<Job_log__c> testJlLst = JobMonitor_testDataFactory.getJob_log(je);
        System.debug('Job Execution >>> 4 ');
        
		Test.startTest();
        SendJobNotification s = new SendJobNotification('xyz', 1440);
        System.debug('Job Execution >>> 5 ');
        Integer invocationsBefore = Limits.getEmailInvocations();
        s.checkTimeAndSendMail();
        System.debug('Job Execution >>> 6 ');
     //   Integer invocations = Limits.getEmailInvocations();
        
       
        System.debug('Job Execution Status :: ' + je.status__c + 'Notification Status :: ' + je.notificationStatus__c);
        
        SendJobNotification s2 = new SendJobNotification('xyz', 1440);
        System.debug('Job Execution >>> 5 ');
     //   Integer invocationsBefore2 = Limits.getEmailInvocations();
        s.checkTimeAndSendMail(true);
        System.debug('Job Execution >>> 6 ');
 		Integer invocations2 = Limits.getEmailInvocations();
        
        
        
        System.debug('Job Execution Status :: ' + je.status__c + 'Notification Status :: ' + je.notificationStatus__c);
        
        Test.stopTest();
        
        System.debug('Job Execution invocationsBefore :: ' + invocationsBefore );
     //   System.debug('Job Execution invocations :: ' + invocations );
     //   System.debug('Job Execution invocationsBefore2 :: ' + invocationsBefore2 );
        System.debug('Job Execution invocations2 :: ' + invocations2 );
        
    }

}