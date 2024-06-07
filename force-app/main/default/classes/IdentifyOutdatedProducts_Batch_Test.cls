@isTest
public class IdentifyOutdatedProducts_Batch_Test {

/*
@TestSetup
    public static void testDataSetup() {
          
    CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount();
        opp.OwnerId = TestDataFactory.createUser(true,'TestFname','TestLname').id;
        Quote quote = TestDataFactory.createPrimaryTestQuote();
        quote.Status = 'Open';
        quote.Has_Critical_Errors__c = false;
        TestDataFactory.eccSOrgToCRMCSetting();
        update quote;
        Quote_Line__c ql = TestDataFactory.createQuoteLineItem();
        
        System.debug('quote.Id : '+quote.Id);
        ql.Quote__c = quote.Id;
        insert ql;   
        System.debug('Quote lineitem Id : '+ql);
        Product_Changes__c prodCh = TestDataFactory.createProductChanges();
    
    }*/




    public testmethod static void IdentifyOutdatedProductsBatch_Test(){
        quotetriggerhandler.triggerdisabled = true;
         contacttriggerhandler.triggerdisabled = true;
    CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
        AccountCreateController.isFirstRun= false;
        Quote quote = TestDataFactory.createPrimaryTestQuote();
        quote.Status = 'Open';
        quote.Has_Critical_Errors__c = true;
        TestDataFactory.eccSOrgToCRMCSetting();
        update quote;
        Quote_Line__c ql = TestDataFactory.createTestQuoteLineForQuote(quote.Id);
        System.debug('Quote lineitem Id : '+ql);
        Product_Changes__c pc = TestDataFactory.createProductChangesForQuoteLine(ql.product__c);//sravan 22FEB
      
        //Test.setMock(HTTPCalloutMock.class, new MockCalloutResponse());
        //HTTPResponse res =null;
       	// Contact c = TestDataFactory.createTestContact(true, TestDataFactory.createUSTestAccount().id, 'Testnamett1test',null);
		Quote_Error__c qe = new Quote_Error__c();
        qe.Quote__c = quote.Id;
        qe.Error_Message__c = 'Test';
        insert qe;
        test.startTest();
        
        IdentifyOutdatedProducts_Batch iOPB = new IdentifyOutdatedProducts_Batch();
        Id batchId = Database.executeBatch(iOPB,1);
        
        test.stopTest();
        
    }
}