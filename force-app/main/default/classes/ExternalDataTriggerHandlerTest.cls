/**********************************************************************
Name:  ExternalDataTriggerHandlerTest
======================================================
======================================================
Purpose: 
This is the test class for ExternalDataTriggerHandler                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL                     Description
0.1         Sahid Hussain              1/11/2022                                INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class ExternalDataTriggerHandlerTest {
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static testmethod void ExternalDataTriggerHandlerTest(){
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        accounttriggerhandler.triggerdisabled = true;
        Account acc = TestDataFactory.createUSTestAccount();
        acc.texcellency__DefHC_HospitalID__c = 90;
        AccountTriggerHandler.TriggerDisabled = true;
        update acc;        
        Opportunity op = TestDataFactory.createOppWithAccount();
        External_Data__c ex = new External_Data__c();
        ex.Account_Breakage__c = 5;
        ex.Definitive_ID__c = 97;
        ex.AccountID__c = op.AccountId;
        ex.Opportunity_ID__c = op.Id;        
        ex.DHC_of_licensed_beds__c = 19;
        ex.DHC_340B_ID__c = '1';
        insert ex;
        ex.AccountID__c = acc.Id;
        ex.Opportunity_ID__c = null;
        ex.Definitive_ID__c = 90;
        ex.DHC_of_licensed_beds__c = 20;
        ex.Adoption__c = 2;
        ex.DHC_340B_ID__c = '2';
        ex.Alteryx_TLP_Recency__c = '1';
        ex.Alteryx_TLP_Frequency__c = '1';
        ex.Alteryx_TLP_Monetary__c = '2';
        ex.Alteryx_TLP_RFM_Score__c = '2';
        ex.Alteryx_TLP_RFM_Segment__c = 'se';
        
        update ex;
    }
}