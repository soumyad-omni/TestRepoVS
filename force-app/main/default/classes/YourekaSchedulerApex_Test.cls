@isTest
public class YourekaSchedulerApex_Test {
    public static testmethod void test(){
      Test.startTest();
		YourekaSchedulerApex batch = new YourekaSchedulerApex();
		String sch = '0 0 0,4 * * ? *';
		System.schedule('schedule Job',sch,batch);
          Test.stopTest();        
     }
}