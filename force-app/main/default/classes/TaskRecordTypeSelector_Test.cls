@isTest
public class TaskRecordTypeSelector_Test {
  @testsetup
    static void testdatasetup(){
      
}
    Static testmethod void fetchRecordTypeValues_test(){
        TaskRecordTypeSelector.fetchRecordTypeValues('Task');
    }
    Static testmethod void fetchRecordTypeValues_test2(){
        TaskRecordTypeSelector.fetchRecordTypeValues('Account');
    }
}