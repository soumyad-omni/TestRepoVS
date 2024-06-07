/**********************************************************************
Name:  fromJSONTest
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for fromJSON                                                          
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              11/13/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class fromJSONTest
{
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
        private static testmethod void testfromJSON() {
        
         AccountCreateController.isFirstRun= false;

            fromJSON obj = new fromJSON();
            String json='{"SAPResponse":{"item":[{"MessageType":"E","MessageId":"CRM_ORGMAN","Number":"038","Message":"Enter an organizational unit (Sales)","LogMessageNo":"000000","ROW":"0"},{"MessageType":"E","MessageId":"CRM_PRICING_MD","Number":"407","Message":"The price group for customer A1 does not exist","LogMessageNo":"000000","MessageV1":"A1","ROW":"0"},{"MessageType":"E","MessageId":"CRM_PRICING_MD","Number":"401","Message":"Customer group A0 does not exist","LogMessageNo":"000000","MessageV1":"A0","ROW":"0"},{"MessageType":"E","MessageId":"COM_PARTNER","Number":"145","Message":"User CASTIRON (Employee Responsible) is not a business partner","LogMessageNo":"000000","MessageV1":"User","MessageV2":"CASTIRON","MessageV3":"Employee Responsible","ROW":"0"},{"MessageType":"S","Number":"000","Message":"Quotation created successfully","Log No":"02","LogMessageNo":"000000","ROW":"0"}]}}'+
            ''+
            ''+
            ''+
            '';
            fromJSON.parse(json);
            System.assert(obj != null);
        
   } 

}