@isTest
public class UpdateChildAccountsHiearchyBatch_2_Test {

    public static testmethod void UpdateChildAccountsHiearchyBatch_2 () {
                
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
        
        pacc.RecordTypeId=recTypeAccount;
        update pacc;
        
        Account acc3 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                          BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        //IBA-4149 acc3.Is_Top_200__c = TRUE;
        acc3.Facility_Type__c = 'Pharmacy';
        acc3.RecordTypeId=recTypeAccount;
        acc3.ParentId= pacc.Id;
        insert acc3; 
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc3.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        
        Account acc4 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                          BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        //IBA-4149 acc4.Is_Top_200__c = TRUE;
        acc4.Facility_Type__c = 'Pharmacy';
        acc4.RecordTypeId=recTypeAccount;
        acc4.ParentId= pacc.Id;
        insert acc4; 
        SAP_Sales_Org__c ssoc1 = new SAP_Sales_Org__c(Account__c=acc4.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc1;
        
        Account acc5 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                          BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
       //IBA-4149    acc5.Is_Top_200__c = TRUE;
        acc5.Facility_Type__c = 'Pharmacy';
        acc5.RecordTypeId=recTypeAccount;
        acc5.ParentId= pacc.Id;
        insert acc5; 
        SAP_Sales_Org__c ssoc2 = new SAP_Sales_Org__c(Account__c=acc5.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc2;
        
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

        test.StartTest();
        delete tarAcc;
        //Execute the Batch
        UpdateChildAccountsHiearchyBatch_2 bat = new UpdateChildAccountsHiearchyBatch_2();
        Id batchId = Database.executeBatch(bat);
        test.StopTest();
    }
}