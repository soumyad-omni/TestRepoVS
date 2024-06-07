@isTest
public class accountInvoc_test {

    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
    @testsetup
      static void testdatasetup(){
        Trigger_Configuration__c  setting = new Trigger_Configuration__c ();
        setting.Name = 'TopLevelParentclassDisable';
        setting.isDisabled__c= false;
        insert setting;
  
        }
    
    @isTest
    static void Test1() {

        Account acct1 = new Account(name='My New Account1',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount, BillingPostalCode='95128',
                                      Account_Status__c = 'Active',IsDeleted__c = false, BillingStreet='200 South Bascom Avenue',
                                      Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');//Transport_Zone__c='US00000001'
        
       
        
        insert acct1;
        account a = [select id, Top_level_1__c, Top_level_2__c from account where name = 'My New Account1'];
        Account acct2 = new Account(name='My New Account2',Account_role__c='ZCSN', ParentId= a.id,
                                      Transportation_Zone_Country__c = 'GB',Primary_Language__c = 'EN', BillingStreet='Test South Bascom Avenue1',
                                      Country_Cluster__c = 'UNASSIGNED',Division_Account__c = 'UNASSIGNED',Region__c = 'UNASSIGNED',Account_Territory__c='UNASSIGNED',
                                      BillingCountryCode = 'GB',RecordtypeId = recTypeAccountItn, BillingPostalCode='12548',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Partner_Type__c= '0014',Facility_Type__c='Children\'s Hospital');//Transport_Zone__c='US00000002',
        
        insert acct2;
        list<id> aid = new list<id>();
        aid.add(acct1.id);
        
        Test.startTest();
        accountInvoc.getAccountinfo(aid);

        Test.stopTest();


    }
    
    @isTest
    static void Test2() {

        Account acct1 = new Account(name='My New Account1',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false, BillingStreet='200 South Bascom Avenue', BillingPostalCode='95128',
                                      Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');//Transport_Zone__c='US00000001',
        
       
        
        insert acct1;
        account a1 = [select id, Top_level_1__c, Top_level_2__c from account where name = 'My New Account1'];
        Account acct2 = new Account(name='My New Account2',Account_role__c='ZCSN', ParentId= a1.id,
                                      Transportation_Zone_Country__c = 'GB',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'UNASSIGNED',Division_Account__c = 'UNASSIGNED',Region__c = 'UNASSIGNED',Account_Territory__c='UNASSIGNED',
                                      BillingCountryCode = 'GB',RecordtypeId = recTypeAccountItn, BillingPostalCode='15245',
                                      Account_Status__c = 'Active',IsDeleted__c = false, BillingStreet='test 200 South Bascom Avenue test',
                                      Partner_Type__c= '0014',Facility_Type__c='Children\'s Hospital');//Transport_Zone__c='US00000002',
        
        insert acct2;
        account a = [select id, Top_level_1__c, Top_level_2__c from account where name = 'My New Account2'];
        a.Top_level_1__c = 'a';
        update a;
        
        list<id> aid = new list<id>();
        aid.add(acct1.id);
        
        Test.startTest();
        accountInvoc.getAccountinfo(aid);

        Test.stopTest();


    }
    
    
}