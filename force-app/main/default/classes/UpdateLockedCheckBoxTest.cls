/**********************************************************************
Name:  UpdateLockedCheckBoxTest
Copyright © 2018
======================================================
======================================================
Purpose: 
This is the test class for lightning controller - updateLockedCheckBox                                                            
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Amruta Dhumal              8/13/2018      Developed by CG Team        INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class UpdateLockedCheckBoxTest
{
        @testsetup
        static void testdatasetup(){
            CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
            ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008662';
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
        
        Default_Currency_by_Country_Code__c   setting7 = new Default_Currency_by_Country_Code__c ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
         Configurator__c c = new Configurator__c();
         c.Name = 'Configurator';
         c.CincomBaseURL__c = 'HTTP://CINCOM-DEV.OMNICELL.COM/CINCOMCONFIGURATORCR2/CONFIGURATIONTOOL.ASPX?'; 
         insert c;
         
         Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
        Conga_Print_Output__c output3 = new Conga_Print_Output__c();
        output3.Name = 'Deal Desk';
        output3.Profile_Name__c = 'Deal Desk';
        insert output3;
        Conga_Print_Output__c output4 = new Conga_Print_Output__c();
        output4.Name = 'Booking Team';
        output4.Profile_Name__c = 'Booking Team';
        insert output4;
        
        }
        private static testmethod void testcheckbox() {
        QuoteLineTriggerHandler.TriggerDisabled = true;
        accountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        quoteTriggerHandler.TriggerDisabled = true;
        contactTriggerHandler.TriggerDisabled = true;
        test.startTest();
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration();
        Quote quote = TestDataFactory.createTestQuote_Integration();
        Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(quote.Id);
        
        ID quoteid = quote.Id;
        //UpdateLockedCheckBox_Class.updateCheck(quoteid);
        UpdateLockedCheckBox_Class.fetchQuoteLine(quoteid);
        UpdateLockedCheckBox_Class.baseURL(quoteid);
        UpdateLockedCheckBox_Class.legacycreateddate(quoteid);
        UpdateLockedCheckBox_Class.getNextAvailableQuoteLineSAPNumber(quoteid);
        UpdateLockedCheckBox_Class.getUser123();
        //UpdateLockedCheckBox_Class.qstat(quoteid);
        test.stopTest();
   } 

}