/***********************************************************************************************************
Name:  AcctSendAllContactsToCastIron_Batch_Test
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
Test class for AcctSendAllContactsToCastIron_Batch
============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Capgemini Dev Team          12/13/2018                             INITIAL DEVELOPMENT
*************************************************************************************************************/
@isTest
public class AcctSendAllContactsToCastIron_Batch_Test {

      @testsetup
      static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.ContactInsertEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRM';
        setting.ContactUpdateEndpoint__c= 'https://castirondatadev.omnicell.com/ContactSFToCRMUpdate';
        setting.AccountRole_SoldTo__c='ZCSN';
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
          
  
    public testmethod static void acctconrelBatchTest(){
       Job_execution__c je = JobMonitor_testDataFactory.getJob_execution(); 
       AccountCreateController.isFirstRun= false; 
        accountTriggerHandler.TriggerDisabled = true;
       test.startTest();
		Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
        //   Contact con = TestDataFactory.ContactWithoutSAPContactId_Integration();

        // castIronCSetting();//Haripriya
		CastIronIntegration__c contact_setting = new CastIronIntegration__c();
        contact_setting.Name= 'CastIronIntegration';
        contact_setting.AccountRole_SoldTo__c = 'ZCSN';
        insert contact_setting;
        
      //  dCurrencyCCodeCSetting();//Haripriya
        Default_Currency_by_Country_Code__c dccc_setting1 = new Default_Currency_by_Country_Code__c();
        dccc_setting1.Name = 'AZ';
        dccc_setting1.Currency_Code__c = 'USD';
        insert dccc_setting1;
        
        Default_Currency_by_Country_Code__c dccc_setting2 = new Default_Currency_by_Country_Code__c();
        dccc_setting2.Name = 'US';
        dccc_setting2.Currency_Code__c = 'USD';
        insert dccc_setting2;
        contactTriggerHandler.TriggerDisabled = true;
        Contact con = new Contact();
        con.LastName='Smith';
        con.Is_Active__c ='Y';
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Transportation_Zone_Country__c='AD',Partner_Type__c='0001',Transport_Zone__c='IN00000002',Account_Territory__c='CT',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Validated__c = 'Validated',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated');
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),IsValidated__c=true,Account_role__c='ZCSN',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated',Facility_Type__c = 'Short-term Acute Care Hospital');
        acc.BillingCountryCode = 'AZ';
        insert acc;
        
        acc.SAP_Account_ID__c ='1234';
        update acc;
        
        SAP_Sales_Org__c sso= new SAP_Sales_Org__c(Sales_Org__c = 'OM01',Incoterms_2__c = 'San Francisco',CurrencyIsoCode = 'USD',Customer_Pricing_Procedure__c='1',Default_GPO_Price_List__c='A0',Default_IDN_Price_List__c='A1',Distribution_Channel__c='01',Sales_Office__c = 'OMNE',Shipping_Conditions__c = 'AW',Terms_of_Payment__c = 'NT30',Account__c = acc.Id,Incoterms_1__c = 'ALT',Service_Level__c='AN');
        insert sso;
        //acc.Validation_Status__c = 'Validated';
        //update acc;
        con.AccountId = acc.id;
        insert con;
        //con.SAP_Contact_ID__c='1234';
        //update con;        
        
           AcctSendAllContactsToCastIron_Batch ac = new AcctSendAllContactsToCastIron_Batch(je);
           Database.executeBatch(ac);
        test.stopTest();
    }
}