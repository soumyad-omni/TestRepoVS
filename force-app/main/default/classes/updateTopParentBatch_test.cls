@isTest
public class updateTopParentBatch_test {
    static id accid;
    static id caccid;
    static Account myacc;
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
    
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
        
        
        Trigger_Configuration__c  setting2 = new Trigger_Configuration__c ();
        setting2.Name = 'TopLevelParentclassDisable';
        setting2.isDisabled__c= true;
        insert setting2;
        
    } 
    static testmethod void test(){
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = true;
        Test.startTest();
         Account acct1 = new Account(name='My New Account1',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c='Children\'s Hospital');
        
       
        
        insert acct1;
        acct1.Top_level_1__c = null;
        update acct1;
        
        account a = [select id, Top_level_1__c, Top_level_2__c from account where name = 'My New Account1'];
        Account acct2 = new Account(name='My New Account2',Account_role__c='ZCSN', ParentId= a.id,
                                      Transportation_Zone_Country__c = 'GB',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'UNASSIGNED',Division_Account__c = 'UNASSIGNED',Region__c = 'UNASSIGNED',Account_Territory__c='UNASSIGNED',
                                      BillingCountryCode = 'GB',RecordtypeId = recTypeAccountItn,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000002',Partner_Type__c= '0014',Facility_Type__c='Children\'s Hospital');
        
        insert acct2;
        
        updateTopParentBatch btlpu=new updateTopParentBatch();
        Id batchId=Database.executeBatch(btlpu);
        Test.stopTest();
    }
}