/**********************************************************************
Name:  QuoteLineAssetTriggerHandlerTest
======================================================
======================================================   
Purpose: 
This is the test class for QuoteLineAssetTriggerHandler 
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sahid Hussain            5/16/2022       INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class QuoteLineAssetTriggerHandlerTest {
      @testsetup
      static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();    
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
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
    
    public static testmethod void QuoteLineAssetTriggerHandlerTest(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        
        //Opportunity opp = TestDataFactory.createOpportunity();
        //Account acc = TestDataFactory.createUSTestAccount();
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = '0121N000001M5AGQA0'; //qlNonConfigRecordType.id;
        Quote q = TestDataFactory.createPrimaryTestQuote();
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id =: q.OpportunityId];
        Account acc = [SELECT Id FROM Account WHERE Id =: opp.AccountId];
        
        
        
        //q.Status = 'E0009';
        //update q;
        ql.Quote__c = q.Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        //Added by Sravan
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Line_Status__c = 'E0006';
        //ql.Conga_Supplement_Version__c = 1;
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
        //System.debug('Prod : '+ql.product__r.productcode);
        insert ql;
        ql.Customer_Price__c = 400;
        QuoteLineTriggerHandler.fromprint = false;
        QuoteLineTriggerHandler.isinsert = false;
        
        update ql;        
        
        C4C_Assets__c asset = New C4C_Assets__c();
        asset.Account__c = acc.Id;
        asset.Product__c = prod.Id;
        asset.Unique_ID__c = '987654';
        insert asset;
        
        test.startTest();
        Quote_Line_Assests__c a1 = new Quote_Line_Assests__c();
        a1.Quote_Line__c = ql.Id;
        a1.Assets__c = asset.Id;
        insert a1;
        
        Quote_Line_Assests__c a2 = new Quote_Line_Assests__c();
        a2.Quote_Line__c = ql.Id;
        a2.Assets__c = asset.Id;
        
        Try{
            insert a2;
        }catch(Exception e){
            
        }
        test.stopTest();
    }    
}