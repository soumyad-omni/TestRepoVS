/* *******************************************************
 * Author : Pavan Kumar
 * Dated:November 17, 2020
 * Description: Test Coverage for the below apex classes
 * 1- OfflineBuildRequestVFTemplateController
 * 2- OffineBuildRequestController
 * 3- OfflineBuildRequestApprovalBatch
 * *******************************************************/
@isTest(seeAllData=false)
public class OffineBuildRequestControllerTest {
    
    @testSetup
    static void setupData(){
        SCP_TestDataFactory.createContact_Customsetting();  
        List<ECC_Sales_Org_to_CRM__c> eccSalesOrgSetting = new List<ECC_Sales_Org_to_CRM__c>();
        
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
        
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        eccSalesOrgSetting.add(setting1);
        
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008662';
        eccSalesOrgSetting.add(setting2);
        
        ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
        setting3.Name = 'Omnicell - St.Petes';
        //setting3.ECC_Code__c = 'OM02'; //IBA-2389 Abhrajitc Removing reference.
        setting3.ECC_Code__c = 'OM01';
        setting3.CRM_Code__c = 'O 50008663';
        eccSalesOrgSetting.add(setting3);
        
        ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c ();
        setting4.Name = 'Omnicell Inc.';
        setting4.CRM_Code__c = 'O 50000029';
        eccSalesOrgSetting.add(setting4);
        
        ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c ();
        setting5.Name = 'Omnicell Ltd';
        setting5.CRM_Code__c = 'O 50008655';        
        eccSalesOrgSetting.add(setting5);
        
        ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c ();
        setting6.Name = 'Omnicell SAS';
        setting6.CRM_Code__c = 'O 50011128';
        eccSalesOrgSetting.add(setting6);
        
        ECC_Sales_Org_to_CRM__c  setting8 = new ECC_Sales_Org_to_CRM__c ();
        setting8.Name = 'GPOPricelist-None';
        setting8.GPOPricelist__c = '--XX--';
        eccSalesOrgSetting.add(setting8);  
        
        insert eccSalesOrgSetting;
            
        Default_Currency_by_Country_Code__c	setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        List<Product2> prdList = new List<Product2>();
        
        Product2 prod1 = new Product2(Name = 'Test 1',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT');
        prdList.add(prod1);
        
        Product2 prod2 = new Product2(Name = 'Test 2',Family = 'test',External_ID__c = '1234567',ProductCode = 'FREIGHT');
        prdList.add(prod2);
        
        Product2 prod3 = new Product2(Name = 'Test 3',Family = 'test',External_ID__c = '1234568',ProductCode = 'FREIGHT');
        prdList.add(prod3);
        
        insert prdList;
                
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = TestDataFactory.createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;        
        ql.Product__c = prdList[0].id;
        qlList.add(ql);
        
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 200;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 201;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        ql2.Product__c = prdList[1].id;
        ql2.Sales_Text__c = 'test';
        qlList.add(ql2);
        
        Quote_Line__c ql3 = new Quote_Line__c();
        ql3.RecordTypeId = qlNonConfigRecordType.id;
        ql3.Quote__c = ql.Quote__c;
        ql3.Higher_Level_Item__c = 200;
        ql3.Quantity__c = 1;
        ql3.SAP_Line_Number__c = 202;
        ql3.SAP_Line_Item_GUID__c = '404';
        ql3.Contract_List_Price__c = 200;
        ql3.Conga_product__c = 'LEASE BUYOUT';
        ql3.Material_Type__c = 'SERVICE';
        ql3.Part_of_a_Bundle__c = FALSE; 
        ql3.Customer_Price__c = 200;
        ql3.Product__c = prdList[2].id;
        ql3.Sales_Text__c = 'test';
        qlList.add(ql3);
                
        Test.startTest();
        insert qlList;
        Test.stopTest();
    }
    
    @isTest static void loadRelatedQuoteLines(){
        
        Quote mainQuote = [Select Id From Quote LIMIT 1];
        
        OffineBuildRequestController.getQuoteLines(mainQuote.Id);
    }
    
    @isTest static void createOfflineBuildLines(){
        // turn of trigger flags 
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        
        Quote mainQuote = [Select Id From Quote LIMIT 1];
                
        // create offline build request
        OfflineBuildRequest__c newOfflineBuildRequest = new OfflineBuildRequest__c(Quote__c = mainQuote.Id,
                                                                                   AAE__c = UserInfo.getUserId(),
                                                                                   Approver__c = UserInfo.getUserId(),
                                                                                   Requestor__c = UserInfo.getUserId(),
                                                                                   ForecastedLiveDate__c = Date.Today().addDays(30),
                                                                                   RequestedLandDate__c = Date.Today().addDays(30));
        insert newOfflineBuildRequest;
        
        // retrieve newly created quotelines 
        List<Quote_Line__c> quoteLines = [Select Id,Product__c,                                
                                          Quantity__c,
                                          Par_Location__c,
                                          SAP_Line_Number__c ,
                                          Higher_Level_Item__c,
                                          SAP_Line_Item_GUID__c,
                                          Pricing_Reference_Model__c From Quote_Line__c Where Quote__c = :mainQuote.Id];

        // create offline build request lines
        OffineBuildRequestController.createOfflineBuildRequestLines(newOfflineBuildRequest.Id,mainQuote.Id,quoteLines);
        
        // generate visualforce email template content
        OfflineBuildRequestVFTemplateController vfEmailTemplate = new OfflineBuildRequestVFTemplateController();
        vfEmailTemplate.obrId = newOfflineBuildRequest.Id;
        List<OfflineBuildRequestLine__c> oppLineItem = vfEmailTemplate.offlineBuildRequestLines;
        
        Test.startTest();
        // call ship before approval process
        OfflineBuildRequestApprovalBatch obrab = new OfflineBuildRequestApprovalBatch();
        
        // execute approval batch
        Database.executeBatch(obrab,50);   
		Test.stopTest();        
    }
    
    @isTest static void testOfflineBuildRequestApprovalBatchSchedule(){
        String cronExpr = '0 0 0 15 3 ? 2022';
        
        // instantiate ship before approval batch
        OfflineBuildRequestApprovalBatch obrab = new OfflineBuildRequestApprovalBatch();
        
        // schedule ship before batch
        String jobId = System.schedule('Offline Build Request Approval Batch', cronExpr, obrab);        
    }
}