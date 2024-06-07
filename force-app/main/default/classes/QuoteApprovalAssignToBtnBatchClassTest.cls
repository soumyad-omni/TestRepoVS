@isTest
private class QuoteApprovalAssignToBtnBatchClassTest {
    @testSetup
    private static void setupTestData(){
        
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
    }
    
    @isTest
    private static void test1(){
        Test.startTest();
        Database.executeBatch(new QuoteApprovalAssignToButtonBatchClass());
        Test.stopTest();
    }
}