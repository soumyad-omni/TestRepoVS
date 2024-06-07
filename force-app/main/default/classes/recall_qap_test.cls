@isTest(seeAllData=false)
public class recall_qap_test {
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
        
         recall_acc_roll__c testsetting = new recall_acc_roll__c(Name = 'Bookings Team');
        insert testsetting;
        
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
        
        SCP_Integration_Details__c  setting8 = new SCP_Integration_Details__c ();
        setting8.Name = 'SCP_Mulesoft_Authorization';
        setting8.SCP_Method_Type__c = 'POST';
        setting8.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting8.SCP_Timeout__c = 120000;
        setting8.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting8.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting8.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting8.SCP_Is_Active__c = true;
        insert setting8;
        
    } 
    
    public testmethod static void test1(){
       
        
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.quoteUpdated = true;
        OpportunityTriggerHandler.opportunityChanged = true;
        
        Quote qt = TestDataFactory.createPrimaryTestQuote();
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        insert qta; 
        Test.startTest();
    	qta.Status__c = 'Waiting Approval';
        qta.Requires_Deal_Desk_Approval__c=TRUE;
        qta.Requires_Legal_Approval__c=true;
        qta.Requires_RX_Config_Approval__c=true;
        qta.Requires_Sales_Finance_Approval__c=true;
        qta.Requires_Tech_Svcs_Approval__c=true;
        qta.Need_CSC_Approval__c=true;
        qta.Need_Finance_Team_Approval__c=true;
        qta.Need_Operations_Team_Approval__c=true;
        qta.Discounting__c=true;
        qta.Comment__c='Test comment';
        RecordType qaRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote'];
        qta.RecordTypeId = qaRecordType1.id;
    	
        update qta;
        
        recall_qap.isrendered(qta.id);
        
        Test.stopTest();
        
    }
    
    public testmethod static void test2(){
                
        AccountCreateController.isFirstRun= false;
        QuoteTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
       	QuoteApprovalTriggerHandler.TriggerDisabled=true;
        
        Quote qt = TestDataFactory.createTestQuote_Integration();
       
        Product2 pr2 = TestDataFactory.createTest3Product();
          Test.startTest();       
        Quote_Line__c ql3 = new Quote_Line__c();
        RecordType qlNonConfigRecordType2 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql3.RecordTypeId = qlNonConfigRecordType2.id;
        ql3.Quote__c = qt.Id;
        ql3.Higher_Level_Item__c = 1;
        ql3.Quantity__c = 1;
        ql3.Product__c=pr2.Id;
        ql3.Pricing_Amount__c= 10000;
        ql3.Contract_List_Price__c= 20000;
        insert ql3;
         
        
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        qta.Comment__c='Test comment';
        insert qta;  
         
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        qta.Only_Pricing_Changes_Made__c=TRUE;
        qta.Status__c='Approved';
        update qta; 

        Quote_approval__c qta1 = TestDataFactory.createQuoteApprovalRec();
        qta1.Quote__c=qt.Id;
        qta1.RecordTypeId = qtrecordtype.id;
        qta1.Only_Pricing_Changes_Made__c=TRUE;
        qta1.Status__c='Waiting Approval';
         qta1.Comment__c=null;
        insert qta1;
        
        List<Quote_Approval__c> qaList = new List<Quote_Approval__c>();
        qaList.add(qta);
        qaList.add(qta1);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(qta.id);
        req1.setSubmitterId(userinfo.getUserId()); 
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        string cmt = 'test';
        recall_qap.update1(qta.id, cmt);
 
        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval.');
        req2.setObjectId(qta1.id);
        req2.setSubmitterId(userinfo.getUserId()); 
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setSkipEntryCriteria(true);
        Approval.ProcessResult result1 = Approval.process(req2);
        string cmt1 = 'test';
 
        recall_qap.update1(qta1.id, cmt);   
        Test.stopTest();
    }
    
    public testmethod static void test3(){
        recall_permission__c testsetting = new recall_permission__c(Name = 'Bookings Team', id__c = '0PS4F000000E0mgWAC');
        insert testsetting;
               
        Test.startTest();
        recall_qap.update2();   
        //recall_qap.updateCheck();
        Test.stopTest();
        
    }
   
    
    
}