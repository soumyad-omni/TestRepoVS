@isTest
public class QuoteApprovalTriggerHandlet_Test {
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
    
    public testmethod static void checkboxAutomation1(){
        AccountCreateController.isFirstRun= false;
        Test.startTest();
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        insert qta;  
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
        RecordType qaRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote'];
        qta.RecordTypeId = qaRecordType1.id;
    update qta;
        
        /*qta.Status__c='Approved';
        qta.Discounting__c=false;
        update qta;*/
        
        Test.stopTest();
    } 
    public testmethod static void checkboxAutomation2(){
        AccountCreateController.isFirstRun= false;
        Test.startTest();
        Quote qt = TestDataFactory.createTestQuote_Integration();
        
        Product2 pr = TestDataFactory.createTestProduct();
        //Product2 pr1 = TestDataFactory.createTest2Product();
            
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = qt.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Product__c=pr.Id;
        insert ql;
        
        /*Quote_Line__c ql2 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        ql2.Quote__c = qt.Id;
        ql2.Higher_Level_Item__c = 1;
        ql2.Quantity__c = 1;
        ql2.Product__c=pr1.Id;
        insert ql2;*/
                
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        insert qta;  
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        update qta;
        Test.stopTest();
    }
    
    public testmethod static void checkboxAutomation3(){
        AccountCreateController.isFirstRun= false;
        Test.startTest();
        Quote qt = TestDataFactory.createTestQuote_Integration();
       
        Product2 pr2 = TestDataFactory.createTest3Product();
                
        Quote_Line__c ql3 = new Quote_Line__c();
        RecordType qlNonConfigRecordType2 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql3.RecordTypeId = qlNonConfigRecordType2.id;
        ql3.Quote__c = qt.Id;
        ql3.Higher_Level_Item__c = 1;
        ql3.Quantity__c = 1;
        ql3.Product__c=pr2.Id;
        insert ql3;
        
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        insert qta;  
         
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        qta.Only_Pricing_Changes_Made__c=TRUE;
        update qta; 
        //update qta;
        Test.stopTest();
    }
    
    public testmethod static void checkboxAutomation4(){
        AccountCreateController.isFirstRun= false;
        Test.startTest();
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();
        qta.Quote__c=qt.Id;
        insert qta;  
        
        qta.Status__c='Approved';
        qta.Discounting__c=false;
        RecordType qtrecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Approval__c' AND Name = 'International ADC/VBM Quote'];
        qta.RecordTypeId = qtrecordtype.id;
        update qta;
        
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
}