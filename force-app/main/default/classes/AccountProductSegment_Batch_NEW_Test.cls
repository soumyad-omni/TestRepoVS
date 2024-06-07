@isTest
public class AccountProductSegment_Batch_NEW_Test {
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008654';
        insert setting2;
        ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
        setting3.Name = 'Omnicell - St.Petes';
        setting3.CRM_Code__c = 'O 50008663';
        insert setting3;
        ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c ();
        setting4.Name = 'Omnicell Inc.';
        setting4.CRM_Code__c = 'O 50000029';
        insert setting4;
        ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c ();
        setting5.Name = 'Omnicell Ltd';
        setting5.CRM_Code__c = 'O 50008655';
        insert setting5;
        ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c ();
        setting6.Name = 'Omnicell SAS';
        setting6.CRM_Code__c = 'O 50011128';
        insert setting6;
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
    }
    public testmethod static void accountProductSegBatchTest(){
        AccountCreateController.isFirstRun= false; 
        //Account acc = TestDataFactory.createTestAccountQuotePrint();
        Account acc = new Account(name='My New Account1',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        insert acc;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opp.AccountId = acc.id;
        insert opp;
        
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        //quote.Quote_Number__c = 'test123';
        //quote.OpportunityId = createOppWithAccount_Integration1().Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Region__c='Northeast';
        q.Pricing_Reference_Date__c=system.today();
        q.Requested_Delivery_Date__c = system.today();
        q.Booking_Date__c=system.today();
        q.ExpirationDate = system.today();
        q.SAP_Last_Line_Number__c = 200;
        q.EOL_Date__c = System.today()+200;
        q.Supplement_Version__c = 2;
        q.Status = 'E0009';
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';	
        q.OpportunityId = opp.Id;
        
        //Product_Segment__c ps = TestDataFactory.createTestProdSegment(acc);
        Product_Segment__c ps = new Product_Segment__c();
        ps.Amount__c = 1000;
        ps.Cost__c = 100;
        ps.Date_Booked__c = System.today()-5;
        ps.Estimate__c = true;
        
        ps.Opportunity__c = opp.Id;
        ps.Quantity__c = 3;
        
        ps.Product_Segment__c='Test';
        
        Quote_Line_Type__c qlt = new Quote_Line_Type__c();
        qlt.Amount__c = 1000;
        qlt.Cost__c = 100;
        qlt.Date_Booked__c = System.today()-5;
        qlt.Estimate__c = true;
        opp.AccountId = acc.id;
        qlt.Opportunity__c = opp.Id;
        qlt.Quantity__c = 3;
        
        
         
        
        test.startTest();
        insert q;
        ps.Quote__c = q.Id;
        insert ps;
        qlt.Quote__c = q.Id;
        insert qlt;
        Job_execution__c je = JobMonitor_testDataFactory.getJob_execution();
        AccountProductSegment_Batch_NEW aplb = new AccountProductSegment_Batch_NEW(je);
        Id batchId = Database.executeBatch(aplb, 1);
        
        AccountProductSegment_Batch_NEW aplb2 = new AccountProductSegment_Batch_NEW();
        test.stopTest();
    }
}