/**
 * @File Name          : QuoteApprovalTriggerHandler_Test_New.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/6/2020, 6:07:30 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class QuoteApprovalTriggerHandler_Test_New {
    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();
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
    
    public testmethod static void checkboxAutomation2(){
        AccountCreateController.isFirstRun= false;
         QuoteLineTriggerHandler.TriggerDisabled = true;
       
        Quote qt = TestDataFactory.createPrimaryTestQuote();
        
        Product2 pr = TestDataFactory.createTestProduct();
        //Product2 pr1 = TestDataFactory.createTest2Product();
       Test.startTest();    
        Quote_Line__c ql = new Quote_Line__c();
        //RecordType qlNonConfigRecordType = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product');
        //[SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product').getRecordTypeId();
        ql.Quote__c = qt.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Product__c=pr.Id;
        ql.Contract_List_Price__c = 1000;
       // Test.stopTest();
        insert ql;
        
        
       

        //Quote_Line__c ql2 = new Quote_Line__c();
        //RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        //ql2.RecordTypeId = qlNonConfigRecordType1.id;
        //ql2.Quote__c = qt.Id;
        //ql2.Higher_Level_Item__c = 1;
        //ql2.Quantity__c = 1;
        //ql2.Product__c=pr1.Id;
        //insert ql2;
                
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        
        qta.Quote__c=qt.Id;
        insert qta;  
       // RecordType qtrecordtype = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('NAA Supplement Quote');
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        //qta.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('NAA Supplement Quote').getRecordTypeId();
        qta.RecordTypeId = qtrecordtype.id;
        update qta;
        Test.stopTest();
    }
    
    
    
    public testmethod static void checkboxAutomation4(){
        AccountCreateController.isFirstRun= false;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Quote qt = TestDataFactory.createPrimaryTestQuote();
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        Test.startTest();
        insert qta;  
        
        qta.Status__c='Approved';
        qta.Discounting__c=false;
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'International ADC/VBM Supplement'];
        qta.RecordTypeId = qtrecordtype.id;
       // update qta;
        
        delete qta;
        undelete qta;
        Test.stopTest();
    } 
    /*public testmethod static void quoteLock(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
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
    
    
   public testmethod static void Test123() {
        AccountCreateController.isFirstRun= false;
         QuoteLineTriggerHandler.TriggerDisabled = true;
        Quote qt = TestDataFactory.createPrimaryTestQuote();
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
       qta.Requires_Deal_Desk_Approval__c=TRUE ;
       Test.startTest();
        insert qta;  
        
        qta.Status__c='Approved';
        qta.Discounting__c=false;
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        //update qta;
        
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
    public testmethod static void checkboxAutomation6(){
        AccountCreateController.isFirstRun= false;
         QuoteLineTriggerHandler.TriggerDisabled = true;
        Quote qt = TestDataFactory.createPrimaryTestQuote();
        
        Product2 p = new product2(name='Test Product',ProductCode='W0196',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Test Product Line',DW_Product_Segment__c='Robotic IV Insourcing Solution (RIIS)',DW_Business_Segment__c='Test Business Segment', External_ID__c='t'+system.now());
        p.Family = 'License';
        insert p;
        
        Product2 p1 = new product2(name='Test Product1',ProductCode='W0197',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Autobond',Portfolio_Segment__c='Supply',DW_Business_Segment__c='Test Business Segment1', External_ID__c='t'+system.now()+10);
        p1.Family = 'Server';
        insert p1;

        Test.startTest();
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product').getRecordTypeId();
        ql.Quote__c = qt.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Product__c=p.Id;
        ql.Contract_List_Price__c = 1000;
        insert ql;
         Quote_Line__c q2 = new Quote_Line__c();
        q2.RecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product').getRecordTypeId();
        q2.Quote__c = qt.Id;
        q2.Higher_Level_Item__c = 1;
        q2.Quantity__c = 1;
        q2.Product__c=p1.Id;
        q2.Contract_List_Price__c = 1000;
        insert q2;
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        qta.Status__c='New';
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        
        
        
        
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
}