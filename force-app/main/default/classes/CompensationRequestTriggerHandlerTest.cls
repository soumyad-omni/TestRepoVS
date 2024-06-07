@isTest
public class CompensationRequestTriggerHandlerTest {

    static testmethod void createrecord() {
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Compensation_Request_Approval__c cr = new Compensation_Request_Approval__c(Compensation_Request_Type__c = 'Opportunity Team Updates', Comment__c = 'Test Request', Opportunity__c = opp.id);
        insert cr;
        Compensation_Request_Approval__c cr1 = [SELECT id, CreatedDate, Status__c FROM Compensation_Request_Approval__c WHERE Id =:  cr.Id];
        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate, Status FROM ProcessInstance WHERE TargetObjectId = :cr.Id];
        //System.assertEquals(cr1.CreatedDate.date,pi.CreatedDate);
    }
}