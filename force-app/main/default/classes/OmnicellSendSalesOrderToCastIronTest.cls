/**********************************************************************
Name:  OmnicellSendSalesOrderToCastIronTest
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for OmnicellSendSalesOrderToCastIron_Class
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              9/21/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class OmnicellSendSalesOrderToCastIronTest
{
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
        private static testmethod void testQuoteSalesOrder() {
            AccountTriggerHandler.TriggerDisabled = true;
            AccountCreateController.isFirstRun= false;
         Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        
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
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        q.OpportunityId = opp.Id;
            
        test.startTest();
        insert q;
        ID quoteid = q.Id;
        
        //OmnicellSendSalesOrderToCastIron_Class.updateCheck(quoteid);
        OmnicellSendSalesOrderToCastIron_Class.callOutMethod(quoteid);
        OmnicellSendSalesOrderToCastIron_Class.getquotedetails(quoteid);
        test.stopTest();

   } 
}