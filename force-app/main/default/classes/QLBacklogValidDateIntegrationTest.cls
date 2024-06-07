@isTest
public class QLBacklogValidDateIntegrationTest {
    @isTest public static void method1()
    {
        Quote_Line_Backlog__c qlb1 = new Quote_Line_Backlog__c();
        qlb1.expected_booking__c = 20;
        qlb1.SAP_Line_Number__c = 101;
        qlb1.SAP_Quote_Number__c = '5531288';
        qlb1.Higher_Level_Item__c = 100;
        qlb1.Valid_From__c = system.today();
        insert qlb1;
        
        database.executebatch(new marginQLAverage());
        
        RestRequest req = new RestRequest();
        String reqBody = '{"valid_to":"2999-12-31","valid_from":"'+system.today().Year()+'-'+system.today().Month()+'-'+system.today().Day()+'"}';
        req.requestBody=Blob.valueof(reqBody);
        
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/accountgroup'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        test.startTest();
        QLBacklogValidDateIntegration.updateQLBacklogRestMethod();
        test.stopTest();
    }
    
    @isTest public static void method2()
    {
        Quote_Line_Backlog__c qlb1 = new Quote_Line_Backlog__c();
        qlb1.expected_booking__c = 20;
        qlb1.SAP_Line_Number__c = 101;
        qlb1.SAP_Quote_Number__c = '5531288';
        qlb1.Higher_Level_Item__c = 100;
        qlb1.Valid_From__c = system.today();
        insert qlb1;
        
        database.executebatch(new marginQLAverage());
        
        RestRequest req = new RestRequest();
        String reqBody = '';
        req.requestBody=Blob.valueof(reqBody);
        
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/accountgroup'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        test.startTest();
        QLBacklogValidDateIntegration.updateQLBacklogRestMethod();
        test.stopTest();
    }
    
     @isTest public static void method3()
    {
        Quote_Line_Backlog__c qlb1 = new Quote_Line_Backlog__c();
        qlb1.expected_booking__c = 20;
        qlb1.SAP_Line_Number__c = 101;
        qlb1.SAP_Quote_Number__c = '5531288';
        qlb1.Higher_Level_Item__c = 100;
        qlb1.Valid_From__c = system.today();
        insert qlb1;
        
        database.executebatch(new marginQLAverage());
        
        RestRequest req = new RestRequest();
        String reqBody = '{"valid_to":NULL,"valid_from":"'+system.today().Year()+'-'+system.today().Month()+'-'+system.today().Day()+'"}';
        req.requestBody=Blob.valueof(reqBody);
        
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/accountgroup'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        test.startTest();
        QLBacklogValidDateIntegration.updateQLBacklogRestMethod();
        test.stopTest();
    }
}