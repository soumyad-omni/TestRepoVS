@isTest
public class LookUpPageController_Test {

    public static testmethod void lookUpPageControllerTest(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'shipto');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest1(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'billto');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest2(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'payer');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest3(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'gpo');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest4(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'idn');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest5(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'sapsalesorg');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }public static testmethod void lookUpPageControllerTest6(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'dealdesk');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest7(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'clinicalconsultant');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest8(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'salesconsultant');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            lpc.render4 = true;
            lpc.render5 = true;
            List<Account> accList = lpc.getRecords();
            List<List<Contact>> contList = lpc.getContacts();
            List<AccountTeamMember> actmList = lpc.getACTMRecords();
            List<Quote> quoteList = lpc.getQuotes();
            List<SAP_Sales_Org__c> salesList = lpc.getSAPSalesOrgRecords();
        test.stopTest();
    }
    public static testmethod void lookUpPageControllerTest9(){
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        Relationship__c rel = TestDataFactory.createRelationshipForAccount(opp.AccountId);
        rel.Relationship__c = 'SH';
        Test.startTest();
            PageReference pageRef = Page.LookUpPage;
            pageRef.getParameters().put('lookuptype', 'contacts');
            pageRef.getParameters().put('accid', String.valueOf(opp.accountId));
            Test.setCurrentPage(pageRef);
            //ApexPages.StandardController sc = new ApexPages.StandardController();
            LookUpPageController lpc = new LookUpPageController();
            
        test.stopTest();
    }
}