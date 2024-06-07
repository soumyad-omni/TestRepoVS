/**********************************************************************
Name:  OmnicellAcctContRelationToCastIron_Test
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for OmnicellAcctContRelationToCastIron_Class                                                          
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              9/21/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class OmnicellAcctContRelationToCastIron_Test
{
         @testsetup
      static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.ContactInsertEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRM';
        setting.ContactUpdateEndpoint__c= 'https://castirondatadev.omnicell.com/ContactSFToCRMUpdate';
        setting.AccountRole_SoldTo__c='ZCSN';
        insert setting;
          
          SCP_Integration_Details__c  setting8 = new SCP_Integration_Details__c ();
          setting8.Name = 'SCP_AccountSFDCTOSAP';
          setting8.SCP_Method_Type__c = 'POST';
          setting8.SCP_Timeout__c = 120000;
          setting8.SCP_End_Point__c = 'http://sit-aloha-accounts.us-w1.cloudhub.io/AccountSFDCToSAP';
          insert setting8;
          
          SCP_Integration_Details__c  setting9 = new SCP_Integration_Details__c ();
          setting9.Name = 'SCP_AccountRelationshipSFDCtoSAP';
          setting9.SCP_Method_Type__c = 'POST';
          setting9.SCP_Timeout__c = 120000;
          setting9.SCP_End_Point__c = 'http://sit-aloha-accounts.us-w1.cloudhub.io/AccountRelationshipsfromSFDC';
          insert setting9;
          
        SCP_Integration_Details__c  setting10 = new SCP_Integration_Details__c ();
        setting10.Name = 'SCP_Mulesoft_Authorization';
        setting10.SCP_Method_Type__c = 'POST';
        setting10.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting10.SCP_Timeout__c = 120000;
        setting10.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting10.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting10.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting10.SCP_Is_Active__c = true;
        insert setting10;
 
        
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
        private static testmethod void testActConRelation() {
        contactTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = true;
        test.startTest();
        AccountContactRelation actcon = TestDataFactory.createAcctConRel_Integration();
        ID actconid = actcon.Id;
        set<Id> newactconid = new set<Id>();
        newactconid.add(actconid);
        OmnicellAcctContRelationToCastIron_Class.callOutMethod(newactconid);
        test.stopTest();
        

   } 

}