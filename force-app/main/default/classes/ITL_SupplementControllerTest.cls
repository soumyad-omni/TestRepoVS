@isTest 
public class ITL_SupplementControllerTest {
       @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        /*SCP_Integration_Details__c scpsettings= new SCP_Integration_Details__c();
        scpsettings.Name = 'SCP Integration Details';
        scpsettings.SCP_End_Point__c =  'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM';
        insert scpsettings;*/
        accounttriggerhandler.triggerdisabled = true;
        SCP_TestDataFactory.createIntDetails();
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;        
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c(Name = 'SCP_Mulesoft_Authorization', SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token',SCP_Key_Client_Id__c='ooooiiii',SCP_Method_Type__c='POST',SCP_Password_Client_Secret__c='xxxxxxxbbbbbbbbbxx',SCP_Grant_Type__c='CLIENT_CREDENTIALS');
		insert obj2;
        
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
        
        Generic_Material_Product__c gmp = new Generic_Material_Product__c();
        gmp.Material__c = 'TEST-TEST1234';
        gmp.MatEntered__c = 'Testprodserv1';
        insert gmp;
        
        gmp = new Generic_Material_Product__c();
        gmp.Material__c = 'TEST-TESTREN1';
        gmp.MatEntered__c = 'Renewal-S1V';
        insert gmp;
        
        
    } 
    
    
    @istest
    public static void testmethod1(){
        AccountCreateController.isFirstRun= false;
        
        Quote qt = createPrimaryTestQuote();
        
        
        Quote_Line__c qtline = TestDataFactory.createTestQuoteLineForQuote(qt.id);
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        String st = contentVersionInsert.id;
        Quote_Approval__c qa = new Quote_Approval__c(
                Comment__c = 'Test',
                Discounting__c = false,
                Only_Pricing_Changes_Made__c = false,
                Discounting_Instruction__c = 'Discount'
           );
        
        QuoteLineTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = true;
        test.startTest();
        	ITL_SupplementController.saveQuoteApp(qa,qt.id,'NAA Budgetary Quote',true,st);
        	qa.id = ITL_SupplementController.saveQuoteApproval(qa,qt.id,'NAA Budgetary Quote',false);
           	ITL_SupplementController.saveChunk(qa,qa.id,'NAA Budgetary Quote',true, 'test', 'TestPDF', 'pdf',0,1) ;
            ITL_SupplementController.isSmallPartDiscounted(qt.Id,'Small Parts');
        test.stopTest();
    }
    
     public static Quote createPrimaryTestQuote(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        quote.Order_Type__c = 'ZHQR';
        quote.OpportunityId = TestDataFactory.createOppWithAccount().Id;
        Opportunity opp = [select accountid from opportunity where id=:quote.opportunityId];
        TestDataFactory.createProductLine(opp.id);
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);
        quote.ContactId= cont.id;
       	quote.Shipping_Contact__c= cont.Id;
        opp.Pre_Approved_Parts__c = true;
        update opp;
        
        quote.Master_Agreement__c = 'qwerty';
        
        quote.Order_Type__c = 'ZQD';
        quote.subscription_Months__c=null;
        
        quote.Discounting__c = false;
        quote.Pre_Approvedpart__c = true;
        quote.Lease_To_Own_Perc__c = 0;
        quote.Bill_to_Account__c = opp.AccountId;//Sravan 22feb
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        return quote;
    }

}