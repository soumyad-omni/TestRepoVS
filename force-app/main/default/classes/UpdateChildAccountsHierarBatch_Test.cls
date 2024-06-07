/*
*Name       : UpdateChildAccountsHierarBatchTest
*Author     : Venu Kukkapalli
*Description: Modifed code from Aesynt Org Test class for UpdateChildAccountsHiearchy
*CreatedDate: 22-June-2018
*Verion     : 1.0
*/

@isTest
public class UpdateChildAccountsHierarBatch_Test{
    
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
        
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
    }
    
    public testmethod static void UpdateChildAccountsHierarchyBatchtest(){ 
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled=true;
        
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
        pacc.RecordTypeId=recTypeAccount;
        update pacc;
        
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.RecordTypeId=recTypeAccount;
        acc.ParentId= pacc.Id;
        update acc;
        
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        acc2.RecordTypeId=recTypeAccount;
        acc2.ParentId= pacc.Id;
        update acc2;        
        
        Account acc3 = TestDataFactory.createTestAccountQuotePrint();
        acc3.RecordTypeId=recTypeAccount;
        acc3.ParentId= pacc.Id;
        update acc3;        
        
        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        //  tarIni.Name          = 'Top 200 Customers';
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        insert tarIni;
        
        //Insert Target Initiative Account
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
        
        test.StartTest();
        //Execute the Batch
        UpdateChildAccountsHierarchyBatch bat = new UpdateChildAccountsHierarchyBatch();
        Id batchId = Database.executeBatch(bat);
        test.StopTest();
    }
    
    /*static testmethod void UpdateChildAccountsHierarchyBatch () {

//Insert Account
Account pacc = new Account();
pacc.Name    = 'My Test Account';
pacc.Account_role__c='ZCSN';
pacc.Account_Territory__c='AZ';
insert pacc;

//Insert Child Account
Account acc = new Account();
acc.Name    = 'My Test Child Account';
acc.ParentId= pacc.Id;
acc.Account_role__c='ZCSN';
acc.Account_Territory__c='AZ';
insert acc;

//Insert Child Account
Account acc2 = new Account();
acc2.Name    = 'My Test Child Account1';
acc2.ParentId= pacc.Id;
acc2.Account_role__c='ZCSN';
acc2.Account_Territory__c='AZ';
insert acc2;

//Insert Child Account
Account acc3 = new Account();
acc3.Name    = 'My Test Child Account2';
acc3.ParentId= pacc.Id;
acc3.Account_role__c='ZCSN';
acc3.Account_Territory__c='AZ';
insert acc3;

//Insert Target Initiative
Target_Initiative__c tarIni = new Target_Initiative__c ();
tarIni.Name          = 'Top 200 Customers';
tarIni.Start_Date__c = System.today();
tarIni.End_Date__c   = System.today()+60;
insert tarIni;

//Insert Target Initiative Account
Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
tarAcc.Account__c           = pacc.Id;
tarAcc.Target_Initiative__c = tarIni.Id;
insert tarAcc;

test.StartTest();
//Execute the Batch
UpdateChildAccountsHierarchyBatch bat = new UpdateChildAccountsHierarchyBatch();
Id batchId = Database.executeBatch(bat);
test.StopTest();
}
*/
    
    public static testmethod void UpdateChildAccountsHiearchyBatch_2 () {
        //Insert Account
        /* Account pacc = new Account();
pacc.Name    = 'My Test Account';
pacc.Account_role__c='ZCSN';
pacc.Account_Territory__c='AZ';
insert pacc;*/
        AccountTriggerHandler.TriggerDisabled=true;
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
        
        pacc.RecordTypeId=recTypeAccount;
        update pacc;
        
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.RecordTypeId=recTypeAccount;
        acc.ParentId= pacc.Id;
        update acc;
        
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        acc2.RecordTypeId=recTypeAccount;
        acc2.ParentId= pacc.Id;
        update acc2;        
        
        //Account acc3 = TestDataFactory.createTestAccountQuotePrint();
        
        Account acc3 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                   BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
                 acc3.Facility_Type__c = 'Pharmacy';
         //acc3.Account_role__c='ZGPO';
        insert acc3; 
        System.debug('acc : '+acc);
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc3.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        acc3.RecordTypeId=recTypeAccount;
        acc3.ParentId= pacc.Id;
        //IBA-4149  acc3.Is_Top_200__c = TRUE;
        update acc3;
        
        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        insert tarIni;
        
        //Insert Target Initiative Account
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
        
        /* //Insert Child Account
Account acc = new Account();
acc.Name    = 'My Test Child Account';
acc.ParentId= pacc.Id;
acc.Account_role__c='ZCSN';
acc.Account_Territory__c='AZ';
insert acc;

//Insert Child Account
Account acc2 = new Account();
acc2.Name    = 'My Test Child Account1';
acc2.ParentId= pacc.Id;
acc2.Account_role__c='ZCSN';
acc2.Account_Territory__c='AZ';
insert acc2;

//Insert Child Account
Account acc3 = new Account();
acc3.Name    = 'My Test Child Account2';
acc3.ParentId= acc2.Id;
acc3.Account_role__c='ZCSN';
acc3.Account_Territory__c='AZ';
insert acc3;*/
        
        test.StartTest();
        delete tarAcc;
        //Execute the Batch
        UpdateChildAccountsHierarchyBatch bat = new UpdateChildAccountsHierarchyBatch();
        Id batchId = Database.executeBatch(bat);
        test.StopTest();
    }
    
}