@isTest
public class IsNACAccountFieldSchedulerApex_Test {
    public static testmethod void test(){
      	Test.startTest();
        IsNACAccountFieldUpdateSchedulerApex IsNACFieldUpdate= new IsNACAccountFieldUpdateSchedulerApex();
        String sch = '0 0 23 * * ?';
        String jobID = System.schedule('Is NAC Account Field Update - ScheduleIsNACFieldUpdate', sch, IsNACFieldUpdate);
        Test.stopTest();        
     }
}