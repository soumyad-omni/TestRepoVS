/**********************************************************************
Name:  OmnicellSendAllContactToCastIronTest
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for OmnicellSendAllContactToCastIron_Class
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              12/14/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class OmnicellSendAllContactToCastIronTest
{
         @testsetup
      static void testdatasetup(){
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_ContactSFToCRM';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM';
        insert setting;
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
          SCP_Integration_Details__c  setting2 = new SCP_Integration_Details__c ();
        setting2.Name = 'SCP_ContactSFToCRM_Update';
        setting2.SCP_Method_Type__c = 'POST';
        setting2.SCP_Timeout__c = 120000;
        setting2.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update';
        insert setting2;
       /*
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.ContactInsertEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRM';
        setting.ContactUpdateEndpoint__c= 'https://castirondatadev.omnicell.com/ContactSFToCRMUpdate';
        setting.AccountRole_SoldTo__c='ZCSN';
        insert setting;*/
        
        ECC_Sales_Org_to_CRM__c  eccsetting1 = new ECC_Sales_Org_to_CRM__c ();
        eccsetting1.Name = 'AU SalesOrg Omnicell';
        eccsetting1.CRM_Code__c = 'O 50008662';
        insert eccsetting1;
        ECC_Sales_Org_to_CRM__c  eccsetting2 = new ECC_Sales_Org_to_CRM__c ();
        eccsetting2.Name = 'MACH4 - GmbH';
        eccsetting2.CRM_Code__c = 'O 50008654';
        insert eccsetting2;
       
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
        private static testmethod void testContact() {
        accountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        
        test.starttest();
        
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration();
        Contact con = TestDataFactory.createContactWithAccount_Integration();
        ID conid = con.Id;
        set<Id> newconid = new set<Id>();
        newconid.add(conid);
        
        OmnicellSendAllContactToCastIron_Class.callOutMethodInsert(newconid);
        
        test.stoptest();

   } 

}