@isTest
public class briefingEdgeToTaskCreate_BatchTest {
    
    public testmethod static void test1(){
        Datetime yesterday = Datetime.now().addDays(-1);
        briefingedge__Briefing_Center_Visit__c testbcv = briefing_center_create();
        opportunity_visit_create(testbcv);
        visit_attendee_create(testbcv);
        visit_details_create(testbcv,'Product Demo (ON-PREMISE)');
		Test.setCreatedDate(testbcv.Id, yesterday);
        test.startTest();
        database.executeBatch(new briefingEdgeToTaskCreate_Batch(), 1);
        test.stopTest();
    }
    public testmethod static void test2(){
        Datetime yesterday = Datetime.now().addDays(-1);
        briefingedge__Briefing_Center_Visit__c testbcv2 = briefing_center_create();
        opportunity_visit_create(testbcv2);
        visit_details_create(testbcv2,'Product Demo (VIRTUAL)');
		Test.setCreatedDate(testbcv2.Id, yesterday);
        test.startTest();
        database.executeBatch(new briefingEdgeToTaskCreate_Batch(), 1);
        test.stopTest();
    }
    public testmethod static void test3(){
        Datetime yesterday = Datetime.now().addDays(-1);
        briefingedge__Briefing_Center_Visit__c testbcv3 = briefing_center_create();
        visit_attendee_create(testbcv3);
        visit_details_create(testbcv3,'Executive Briefing (ON-PREMISE)');
		Test.setCreatedDate(testbcv3.Id, yesterday);
        test.startTest();
        database.executeBatch(new briefingEdgeToTaskCreate_Batch(), 1);
        database.executeBatch(new briefingEdgeToTaskUpdate_Batch(), 1);
        test.stopTest();
    }
    public testmethod static void test4(){
        Datetime yesterday = Datetime.now().addDays(-1);
        briefingedge__Briefing_Center_Visit__c testbcv4 = briefing_center_create();
        opportunity_visit_create(testbcv4);
        visit_attendee_create(testbcv4);
        visit_details_create(testbcv4,'Executive Briefing (VIRTUAL)');
		Test.setCreatedDate(testbcv4.Id, yesterday);
        test.startTest();
        //database.executeBatch(new briefingEdgeToTaskCreate_Batch(), 1);
        briefingEdgeToTaskCreate_BatchSchedule sch1 = new briefingEdgeToTaskCreate_BatchSchedule();
        String cr = '0 0 1 * * ?'; 
        system.schedule('Briefing Edge Task Create', cr, sch1);
        
        briefingEdgeToTaskUpdate_BatchSchedule sch2 = new briefingEdgeToTaskUpdate_BatchSchedule();
        String cr2 = '0 0 2 * * ?'; 
        system.schedule('Briefing Edge Task Update', cr2, sch2);
        test.stopTest();
    }
    public static briefingedge__Briefing_Center_Visit__c briefing_center_create(){
        briefingedge__Briefing_Center_Visit__c bcv = new briefingedge__Briefing_Center_Visit__c();
        bcv.briefingedge__Visit_Staus__c = 'Confirmed';
        bcv.briefingedge__Start_Date__c = datetime.newInstance(2021, 2, 5, 12, 30, 0);
        bcv.briefingedge__End_Date__c = datetime.newInstance(2021, 2, 16, 12, 30, 0);
        insert bcv;
        return bcv;
    }
    public static void opportunity_visit_create(briefingedge__Briefing_Center_Visit__c bv){
        briefingedge__Opportunity_Visit__c ov = new briefingedge__Opportunity_Visit__c();
        ov.briefingedge__Briefing_Center_Visit__c = bv.Id;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        ov.briefingedge__Opportunity__c = opp.id;
        insert ov;
    }
    public static void visit_attendee_create(briefingedge__Briefing_Center_Visit__c bv){
        briefingedge__Visit_Attendee__c va = new briefingedge__Visit_Attendee__c();
        AccountCreateController.isFirstRun= false; 
        Account account=TestDataFactory.createTestAccountQuotePrint();
        va.briefingedge__Account__c = account.id;
        va.briefingedge__Briefing_Center_Visit__c = bv.Id;
        va.briefingedge__Internal_Attendee__c = UserInfo.getUserId();
        va.briefingedge__Email__c = UserInfo.getUserEmail();
        Opportunity opp = TestDataFactory.createOppWithAccount();
        va.briefingedge__Opportunity__c = opp.id;
        Id ia = Schema.SObjectType.briefingedge__Visit_Attendee__c.getRecordTypeInfosByName().get('Internal Attendee').getRecordTypeId();
        va.RecordtypeId= ia;
        insert va;
    }
    public static void visit_details_create(briefingedge__Briefing_Center_Visit__c bv, String pickv){
        briefingedge__Visit_Details__c a = new briefingedge__Visit_Details__c();
        a.briefingedge__Briefing_Center_Visit__c = bv.Id;
        a.briefingedge__Picklist_Value__c = pickv;
        insert a;
    }
}