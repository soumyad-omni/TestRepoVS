@isTest
public class QuoteApprovalTriggerHandler_Test {
    public static Id recTypeQuoteApproval = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote' LIMIT 1].Id;
    @testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        SCP_TestDataFactory.createContact_Customsetting();
        CastIronIntegration__c  setting00 = new CastIronIntegration__c ();
        setting00.Name = 'CastIronIntegration';
        setting00.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting00.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting00;
        
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
        
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
    } 
    
     public testmethod static void checkboxAutomation1(){
                 AccountTriggerHandler.TriggerDisabled = true;
         ContactTriggerHandler.TriggerDisabled=true;
        Quote qt = createQuote();
         Test.startTest();
         insert qt;
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        insert qta;  
        qta.Status__c = 'Approved';
        qta.Requires_Deal_Desk_Approval__c=TRUE;
        qta.Requires_Legal_Approval__c=true;
        qta.Requires_RX_Config_Approval__c=true;
        qta.Requires_Sales_Finance_Approval__c=true;
        qta.Requires_Tech_Svcs_Approval__c=true;
        qta.Need_CSC_Approval__c=true;
        qta.Need_Finance_Team_Approval__c=true;
        qta.Need_Operations_Team_Approval__c=true;
        qta.Discounting__c=true;
        RecordType qaRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote'];
        qta.RecordTypeId = qaRecordType1.id;
        update qta;
        
        Quote_Approval__c qtApp = new Quote_Approval__c();
        qtApp.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote' LIMIT 1].Id;
        qtApp.Quote__c = qt.Id;
        qtApp.Need_Manual_Approval__c = true;
        insert qtApp;
        
        QuoteApprovalTriggerHandler quoteApproval = new QuoteApprovalTriggerHandler();
        List<Quote_Approval__c> qaList = [Select id, status__c, Quote__c,RecordTypeId,Requires_Deal_Desk_Approval__c from Quote_Approval__c];
        quoteApproval.quoteStatusUpdate(qaList);
         Test.stopTest();
    }   
    
    public testmethod static void checkboxAutomation3(){
                 AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled=true;
        Quote qt = createQuote();
        
        Product2 pr2 = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'Professional Services',SAP_Product_Type__c = 'testsap');
        insert pr2;
         Test.startTest();
         insert qt;       
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
         
        
        Quote_Approval__c qta = new Quote_Approval__c();
        qta.Quote__c=qt.Id;
        insert qta;  
         
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        qta.Only_Pricing_Changes_Made__c=TRUE;
        update qta; 
        Test.stopTest();
        //update qta;
       
    }
    
    public testmethod static void checkboxAutomation4(){
                 AccountTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled=true;
        QuoteTriggerHandler.TriggerDisabled=true;
        Quote quote = createQuote();
        
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'Professional Services',SAP_Product_Type__c = 'testsap');
        insert prod;
        Quote_Line__c ql = createQuoteLine();
       	ql.Product__c = prod.id;
        
       Test.startTest();
       insert quote;
       quote.Quote_Number__c = '1234';
       quote.Create_Sales_Order__c = true;
       update quote;
       ql.Quote__c = quote.Id;
       insert ql;
       Quote_Approval__c qta = new Quote_Approval__c();
        qta.Quote__c=quote.Id;
        insert qta;  
        
        qta.Status__c='Approved';
        qta.Discounting__c=false;
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'International ADC/VBM Supplement'];
        qta.RecordTypeId = qtrecordtype.id;
        update qta;
        
        delete qta;
        undelete qta;
        Test.stopTest();
    } 
        public testmethod static void checkboxAutomation5(){
        AccountCreateController.isFirstRun= false;
         QuoteLineTriggerHandler.TriggerDisabled = true;
        Quote qt = TestDataFactory.createPrimaryTestQuote();
        
        Product2 p = new product2(name='Test Product',ProductCode='W0196',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Test Product Line',DW_Product_Segment__c='Robotic IV Insourcing Solution (RIIS)',DW_Business_Segment__c='Test Business Segment', External_ID__c='t'+system.now());
        p.Family = 'License';
        insert p;
        Test.startTest();
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product').getRecordTypeId();
        ql.Quote__c = qt.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Product__c=p.Id;
        ql.Contract_List_Price__c = 1000;
        insert ql;
        
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        qta.Status__c='New';
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        //qta.RecordTypeId = qtrecordtype.id;
        
        
        
        
        insert qta;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Approve.');
        req1.setNextApproverIds(new id[] {UserInfo.getUserId()});//
        req1.setObjectId(qta.Id);
        //Submit the approval request
        Approval.ProcessResult result1 = Approval.process(req1);
        qta.Status__c='Waiting Approval';
        qta.Only_Pricing_Changes_Made__c = true;
        update qta;
        Test.stopTest();
    }
    /*public testmethod static void quoteLock(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting; 
        Quote qt = TestDataFactory.createTestQuote_Integration();
        qt.Region__c = 'California';
        update qt; 
        Quote_Approval__c qa=new Quote_Approval__c();
        qa.Quote__c=qt.Id;
        
        qa.New_Customer_ContainConfigCabinet_Supply__c = true;
        qa.Contains_IV_XR2_PC_and_Upgrade__c=true;
        qa.LR_Buyout_CO_Rep_Line_It_CRX_IV_RII__c=true;
        qa.Discounting__c = true;
        qa.Additional_Discount_apply_Exist_Customer__c= 'Y';
        qa.Contains_Configurable_Cabinets_Supply__c=true;
        qa.Contains_IV_XR2_PC_and_Upgrade__c=true;
        qa.Contains_IV_PC_Pakplus__c=true;
        qa.Extg_Cust_Non_Discounted_500K_Sales_Vol__c=true;
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('NAA Supplement Quote').getRecordTypeId();
        //qa.Additional_Discount_apply_Exist_Customer__c='Y';
        // qa.Contains_IV_XR2_PC_and_Upgrade__c = true;
        insert qa;
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Approve.');
        req.setObjectId(qa.Id);
        //Submit the approval request
        Approval.ProcessResult result = Approval.process(req);
        qa.status__c='Approved';
        update qa;
        delete qa;
        undelete qa;       
    }*/
    
   public testmethod static void Test1_2() {
       AccountTriggerHandler.TriggerDisabled = true;
       ContactTriggerHandler.TriggerDisabled=true;
       QuoteTriggerHandler.TriggerDisabled=true;
       Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'Professional Services',SAP_Product_Type__c = 'testsap');
        insert prod;
       	ql.Product__c = prod.id;
       Test.startTest();
       insert quote;
       quote.Quote_Number__c = '1234';
       quote.Create_Sales_Order__c = true;
       update quote;
       ql.Quote__c = quote.Id;
       insert ql;
       Quote_Approval__c qa = new Quote_Approval__c();
       qa.RecordTypeId = recTypeQuoteApproval;
       qa.Need_Manual_Approval__c = true;
       qa.Quote__c=quote.Id;
       qa.Only_Pricing_Changes_Made__c = true;
       insert qa;
       qa.Status__c='Rejected';
       update qa;
       Test.stopTest();
   }
    
   public testmethod static void Test123() {
       OpportunityTriggerHandler.TriggerDisabled = true;
         AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
       ContactTriggerHandler.TriggerDisabled=true;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Quote_Line__c ql2 = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        Product2 prod2 = new Product2(Name = 'IVS-LAB-012',Family = 'test2',External_ID__c = '1234596890123',ProductCode = 'IVS-LAB-012',Business_Line__c = 'IV Product Solutions',DW_Product_Line__c = 'Robotic IV Insourcing Solution (RIIS)',SAP_Product_Type__c = 'Labor');
        insert prod2;
        ql.Product__c = prod.id;
        ql2.Product__c = prod2.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        QuoteLineTriggerHandler.TriggerDisabled = true;
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        update quote;
        ql.Quote__c = quote.Id;
       	ql2.Quote__c = quote.id;
        insert ql;
        insert ql2;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.RecordTypeId = recTypeQuoteApproval;
        qa.Need_Manual_Approval__c = true;
        qa.Quote__c=quote.Id;
        qa.Requires_Deal_Desk_Approval__c=TRUE ;
        insert qa;  
        Test.stopTest();

        qa.Status__c='Approved';
        qa.Discounting__c=false;
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qa.RecordTypeId = qtrecordtype.id;
        update qa;
        delete qa;
        undelete qa;
       	
        
    }
    public testmethod static void presignatureEmailNotification(){
        AccountCreateController.isFirstRun= false;
        QuoteLineTriggerHandler.TriggerDisabled = true;
         quotetriggerhandler.TriggerDisabled = true;
        Quote qt = TestDataFactory.createPrimaryTestQuote();
        
        Product2 pr = TestDataFactory.createTestProduct();
		  Test.startTest();    
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product').getRecordTypeId();
        ql.Quote__c = qt.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Product__c=pr.Id;
        ql.Contract_List_Price__c = 1000;
        insert ql;
                
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        qta.Booking_Approval_Request_Type__c='Pre-Signature Process';
        qta.Assigned_To__c='Booking Team';
        insert qta;  
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        qta.Status__c='Approved';
        qta.Assigned_To__c=null;
        update qta;

        Quote_approval__c qta1 = TestDataFactory.createQuoteApprovalRec();
        qta1.Quote__c=qt.Id;
        qta1.Booking_Approval_Request_Type__c='Pre-Signature Process';
        qta1.Assigned_To__c='Booking Team';
        insert qta1; 
         
        RecordType qtrecordtype1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta1.RecordTypeId = qtrecordtype1.id;
        qta1.Status__c='Rejected';
        qta1.Assigned_To__c=null;
        update qta1;

        Test.stopTest();
    }
    //Create Quote
    public static Quote createQuote(){
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = opp.Id;    
        insert pl;
        quote.OpportunityId = opp.Id;
        return quote;
    }
    //Create Quote line
    public static Quote_Line__c createQuoteLine(){
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Line_Status__c = 'E0006';
        return ql;
    }
}