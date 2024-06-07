/*
Name       : ParentToChildFieldUpdate_Test
Description: Test Class for ParentToChildFieldUpdate
Author     : Sahid Hussain
CreatedDate: 05-18-2021
*/
@isTest
public class ParentToChildFieldUpdate_Test {
    @isTest private static void checkParentToChildFieldUpdateTest() {
        Set<Id> pId = new Set<Id>();
        Set<Id> parentId = new Set<Id>();
        Set<Id> aId = new Set<Id>();
        List<Account> allChildAccount = new List<Account>();
        Account acct2 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                            Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                            Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                            BillingCountryCode = 'US',
                                            Account_Status__c = 'Active',IsDeleted__c = false,  
                                            Transport_Zone__c='US00000001',Partner_Type__c= '0015',Likelihood_to_Convert__c = 'Yes',Validation_Status__c='Validated'); 
               // need sap account id to satisfy sales org workflow
               acct2.SAP_Account_ID__c = '500300';
               acct2.Facility_Type__c = 'Pharmacy';
               acct2.BILLINGSTREET = '41 Moss';
               acct2.BillingPostalCode = '77777';
        insert acct2;
        List<Account> accList = new List<Account>();
        Account a1 = new Account(name='t2'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California', 
                                      ParentId = acct2.Id,BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a1.Annual_Bill_Date__c = System.today()+100;
        a1.Service_Escalator__c = 10;
        a1.PO_BOX__c = '90202';
        a1.Likelihood_to_Convert__c = 'No';
        accList.add(a1);
        
        /*Account a2 = new Account(name='test_3'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a2.Annual_Bill_Date__c = System.today()+100;
        a2.Service_Escalator__c = 10;
        a2.PO_BOX__c = '90202';
        accList.add(a2);
        
        Account a3 = new Account(name='tesingAccount_4'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a3.Annual_Bill_Date__c = System.today()+100;
        a3.Service_Escalator__c = 10;
        a3.PO_BOX__c = '90202';
        accList.add(a3);
        
        Account a4 = new Account(name='t2'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California', 
                                      BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a1.Annual_Bill_Date__c = System.today()+100;
        a1.Service_Escalator__c = 10;
        a1.PO_BOX__c = '90202';
        accList.add(a4);
        insert accList;
        
        //create target initiaitve
        Target_Initiative__c ti01 = new Target_Initiative__c();
        ti01.Name          = 'Test';
        ti01.Start_Date__c = System.today();
        ti01.End_Date__c   = System.today()+60;
        ti01.Use_for_segmentation__c = true;
        ti01.Type_of_account_propagation__c = 'Apply to account and all child accounts';    
        insert ti01;

        Target_Initiative__c ti02 = new Target_Initiative__c();
        ti02.Name          = 'Test_2';
        ti02.Start_Date__c = System.today();
        ti02.End_Date__c   = System.today()+60;
        ti02.Use_for_segmentation__c = true;
        ti02.Type_of_account_propagation__c = 'Apply to individual accounts only';    
        insert ti02;
            
        // add an account to target initiative
        Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
        tia1.Target_Initiative__c = ti01.id;
        tia1.Account__c = a3.Id; //0011N00001pYpTbQAK for fulldev2
        insert tia1;
        
        Target_Initiative_Account__c tia2 = new Target_Initiative_Account__c();
        tia2.Target_Initiative__c = ti02.id;
        tia2.Account__c = a1.Id;
        insert tia2;

        Target_Initiative_Account__c tia3 = new Target_Initiative_Account__c();
        tia3.Target_Initiative__c = ti02.id;
        tia3.Account__c = a2.Id;
        insert tia3;*/
        insert accList;
        Target_Initiative__c ti02 = new Target_Initiative__c();
        ti02.Name          = 'Test_2';
        ti02.Start_Date__c = System.today();
        ti02.End_Date__c   = System.today()+60;
        ti02.Use_for_segmentation__c = true;
        ti02.Type_of_account_propagation__c = 'Apply to individual accounts only';    
        insert ti02;
        Target_Initiative_Account__c tia2 = new Target_Initiative_Account__c();
        tia2.Target_Initiative__c = ti02.id;
        tia2.Account__c = a1.Id;
        insert tia2;
        parentId.add(acct2.Id);
        ParentToChildFieldUpdate.parentId = parentId;
        allChildAccount.add(a1);
        aId.add(acct2.Id);
        ParentToChildFieldUpdate.allChildAccount  = allChildAccount;
        ParentToChildFieldUpdate.AllChilAccountsReturnVal(parentId);
        ParentToChildFieldUpdate.AllChilAccounts(aId);
    }
}