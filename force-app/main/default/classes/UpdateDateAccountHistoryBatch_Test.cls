/**********************************************************************
Name:  UpdateDateAccountHistoryBatch_Test
======================================================
======================================================                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1      	 Pritha Nandi            05/05/2022       INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class UpdateDateAccountHistoryBatch_Test {
@testSetup
    static void setup() {
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
         insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
	 	Account a = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a.Annual_Bill_Date__c = System.today()+100;
        a.Service_Escalator__c = 10;
        a.PO_BOX__c = '90202';
        //a.Youreka_Mobile__c = true;
    //    a.current_Date_sys__c = System.now();    IBA-4149
        insert a; 
        String oldValues = '{"id": "'+a.Id+'","SAP_Account_ID__c": "3100000275"}';  
        
        SAP_Sales_Org__c sp = new SAP_Sales_Org__c(Account__c = a.id);
        sp.Sales_Office__c='OMNE';
        sp.Incoterms_2__c = 'San Francisco';
        sp.Incoterms_1__c = 'CPT';
        insert sp;
       
        List<Account_History__c> acch = [SELECT id,Edited_Time__c,Date__c from Account_History__c where Edited_Time__c!= null and Account__c =: a.id];
       	system.debug('acch.Date__c'+ acch[0].Edited_Time__c);
        for(Account_History__c h : acch){
           	h.Edited_Time__c = '5/5/2022 3:38 AM';
            h.Date__c = null;
        }
        update acch;
     
    }
    @isTest static void test() {
        Test.startTest();
        UpdateDateAccountHistoryBatch uah = new UpdateDateAccountHistoryBatch();
        Id batchId = Database.executeBatch(uah);
        Test.stopTest();
    }
}