@isTest
public class OmnicellProductDetailControllerTest {
    public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    
    @testSetup 
    public static void dataSetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        setting.Accountendpoint__c = 'https://printcastirondev.omnicell.com';
        insert setting;
        Account acc;
        Account acc2;
        Contact con;
        User thisUser = [select Id from User where Profile.Name =: 'System Administrator' and IsActive = True and UserRoleId != null LIMIT 1];
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Attribute__c> attrList = new List<ccrz__E_Attribute__c>();
        ccrz__E_Attribute__c drugparent = new ccrz__E_Attribute__c(Name = 'NDC',ccrz__AttributeID__c = 'NDC',ccrz__DisplayName__c = 'NDC',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 1);
        attrList.add(drugparent);
        ccrz__E_Attribute__c machineparent = new ccrz__E_Attribute__c(Name = 'MACHINE',ccrz__AttributeID__c = 'MACHINE',ccrz__DisplayName__c = 'MACHINE',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 2);
        attrList.add(machineparent);
        insert attrList;
        List<ccrz__E_Attribute__c> attrChList = new List<ccrz__E_Attribute__c>();
        ccrz__E_Attribute__c drugChild = new ccrz__E_Attribute__c(Name = 'NDC2',ccrz__AttributeID__c = 'NDC2',ccrz__DisplayName__c = 'NDC2',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 12, ccrz__ParentAttribute__c = drugparent.Id);
        attrChList.add(drugChild);
        ccrz__E_Attribute__c machineChild = new ccrz__E_Attribute__c(Name = 'machine2',ccrz__AttributeID__c = 'MACHINE2',ccrz__DisplayName__c = 'Machine2',
                                                       ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                      ccrz__Sequence__c = 22, ccrz__ParentAttribute__c = machineparent.Id);
        attrChList.add(machineChild);
        insert attrChList;
        System.runAs(thisUser){
            AccountTriggerHandler.TriggerDisabled = True;
            acc = new Account(name='AccountForPacMed',Account_role__c='ZCSN',
                              RecordtypeId = TestDataFactory.recTypeAccount,
                              Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
            acc.BillingCountryCode = 'AZ';
            insert acc;
            
            
            acc2 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                               RecordtypeId = TestDataFactory.recTypeAccount,
                               Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
            acc2.BillingCountryCode = 'US';
            insert acc2;
            
            con = new Contact(LastName = 'Test Contact',AccountId = acc.id);
            ContactTriggerHandler.TriggerDisabled = True;
            insert con;
            
            ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc, con, contAdd)[0];
            insert ec;
            ec.ccrz__EncryptedId__c = ec.Id;
            ec.ccrz__EffectiveAccountID__c=acc.Id;
            update ec;
            
            String ProfileName = System.Label.OCB_RegisterUserProfile;
            Profile profileId = [select Id,name from Profile where Name =:ProfileName limit 1];
            
            
            User CommUser = new User();
            CommUser.FirstName = 'TestUserfirstName';
            CommUser.LastName = 'TestUserlastName';
            CommUser.UserName = CommUser.FirstName + '.' + CommUser.LastName + '@unitTest.com';        
            CommUser.Email = 'testusermail@omnicell.com';
            CommUser.Alias = CommUser.FirstName.substring(0, 1) + CommUser.LastName.left(7);
            CommUser.CommunityNickname = CommUser.FirstName + ' ' + CommUser.LastName;
            CommUser.TimeZoneSidKey = 'America/New_York';
            CommUser.LocaleSidKey = 'en_US';
            CommUser.EmailEncodingKey = 'UTF-8';
            CommUser.LanguageLocaleKey = 'en_US';
            CommUser.IsActive= True;
            CommUser.ContactId=con.id;
            CommUser.ProfileId = profileId.id;
            insert CommUser;
        }
        SAP_Sales_Org__c salOrg = new SAP_Sales_Org__c();
        salOrg.Account__c = acc.id;
        salOrg.CurrencyIsoCode = 'USD';
        salOrg.Sales_Office__c = 'OMDD';
        salOrg.Distribution_Channel__c = '01';
        salOrg.Incoterms_1__c = 'DDP';
        salOrg.Incoterms_2__c = 'Newyork'; 
        salOrg.Tax_Classification__c = '1';
        insert salOrg;
        System.assert(salOrg.id != null);
        Relationship__c rel = new Relationship__c();
        rel.Primary_Account__c = acc.id;
        rel.Relationship__c ='RE';
        rel.Secondary_Account__c = acc2.id;
        rel.Primary_Account_Sales_Org__c = salOrg.id;
        insert rel; 
    }
    
    @isTest
    public static void testMethod1(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        
        Map<String,object> attributeDataMap = new Map<String,object>();
        attributeDataMap.put('SKU', 'RECALIB');
        attributeDataMap.put('machine', 'PACMED34349');
        attributeDataMap.put('type', 'CANISTER');
        attributeDataMap.put('drugCode', '0000123456788');
        attributeDataMap.put('quantity', '50');
        attributeDataMap.put('currEffacc', acc.Id);
        
        
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> attributeList = new Map<String, Object>();
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        String status = OmnicellProductDetailController.createMajorCartItem(activeCart[0].Id,attributeDataMap);
        
        List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                     ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                     From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                     AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'RECALIB'];
        
        Test.startTest();
        String status2 = OmnicellProductDetailController.createMinorCartItem('RECALIB',newcartItemList[0],attributeDataMap);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod2(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        
        Map<String,object> attributeDataMap = new Map<String,object>();
        attributeDataMap.put('SKU', 'RECALIB');
        attributeDataMap.put('machine', 'PACMED34349');
        attributeDataMap.put('type', 'CANISTER');
        attributeDataMap.put('drugCode', '0000123456788');
        attributeDataMap.put('quantity', '101');
        attributeDataMap.put('currEffacc', acc.Id);
        
        
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> attributeList = new Map<String, Object>();
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        String status = OmnicellProductDetailController.createMajorCartItem(activeCart[0].Id,attributeDataMap);
        
        List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                     ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                     From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                     AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'RECALIB'];
        
        Test.startTest();
        String status2 = OmnicellProductDetailController.createMinorCartItem('RECALIB',newcartItemList[0],attributeDataMap);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod3(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        
        Map<String,object> attributeDataMap = new Map<String,object>();
        attributeDataMap.put('SKU', 'NEW-CALIB');
        attributeDataMap.put('machine', 'PACMED34349');
        attributeDataMap.put('type', 'CANISTER');
        attributeDataMap.put('drugCode', '0000123456788');
        attributeDataMap.put('quantity', '50');
        attributeDataMap.put('currEffacc', acc.Id);
        
        
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> attributeList = new Map<String, Object>();
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        String status = OmnicellProductDetailController.createMajorCartItem(activeCart[0].Id,attributeDataMap);
        
        List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                     ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                     From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                     AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'NEW-CALIB'];
        
        Test.startTest();
        String status2 = OmnicellProductDetailController.createMinorCartItem('NEW-CALIB',newcartItemList[0],attributeDataMap);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod4(){
        OmnicellProductDetailController controller = new OmnicellProductDetailController() ;
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        
        Map<String,object> attributeDataMap = new Map<String,object>();
        attributeDataMap.put('SKU', 'NEW-CALIB');
        attributeDataMap.put('machine', 'PACMED34349');
        attributeDataMap.put('type', 'CANISTER');
        attributeDataMap.put('drugCode', '0000123456788');
        attributeDataMap.put('quantity', '150');
        attributeDataMap.put('currEffacc', acc.Id);
        
        
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> attributeList = new Map<String, Object>();
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        String status = OmnicellProductDetailController.createMajorCartItem(activeCart[0].Id,attributeDataMap);
        
        List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                     ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                     From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                     AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'NEW-CALIB'];
        
        Test.startTest();
        String status2 = OmnicellProductDetailController.createMinorCartItem('NEW-CALIB',newcartItemList[0],attributeDataMap);
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','NEW-CALIB');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        OmnicellProductDetailController.getAttributes(ctx);
        OmnicellProductDetailController.getCartCount(ctx);
        string jsonstring = JSON.serialize(attributeDataMap);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod5(){
        String ProfileName = 'System Administrator';
        Profile profileId = [select Id,name from Profile where Name =:ProfileName limit 1];
        User CommUser = new User();
        CommUser.FirstName = 'TestUserfirstName59';
        CommUser.LastName = 'TestUserlastName59';
        CommUser.UserName = CommUser.FirstName + '59.' + CommUser.LastName + '@unitTest.com';        
        CommUser.Email = 'testusermail59@omnicell.com';
        CommUser.Alias = CommUser.FirstName.substring(0, 1) + CommUser.LastName.left(7);
        CommUser.CommunityNickname = CommUser.FirstName + ' ' + CommUser.LastName;
        CommUser.TimeZoneSidKey = 'America/New_York';
        CommUser.LocaleSidKey = 'en_US';
        CommUser.EmailEncodingKey = 'UTF-8';
        CommUser.LanguageLocaleKey = 'en_US';
        CommUser.IsActive= True;
        CommUser.Read_Only_User__c = True;
        CommUser.ProfileId = profileId.id;
        UserTriggerHandler.TriggerDisabled = True;
        insert CommUser;
        System.runAs(CommUser){
            Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                       Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                       BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                       Account_Status__c = 'Active',IsDeleted__c = false,
                                       Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
            acct.Facility_Type__c = 'Pharmacy';
            acct.BILLINGSTREET = '41 Moss';
            acct.BillingPostalCode = 'DY6 9HP';
            AccountTriggerHandler.TriggerDisabled = True;
            insert acct;
            OmnicellProductDetailController controller = new OmnicellProductDetailController() ;
        }
    }
    
    @isTest
    public static void testMethod6(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineDataCassette = SCP_TestDataFactory.createMachine(acc,'AccuFlex34349','Acuflex','Base','Acuflex II');
        Machine__c machineDataCassette2 = SCP_TestDataFactory.createMachine(acc,'AccuFlex34350','Acuflex','Base','Acuflex II');
        machineDataCassette2.Agreement_sign_date__c = System.today()-100;
        update machineDataCassette2;
        //Machine__c machineDataCanister = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Map<String,object> attributeDataMap1 = new Map<String,object>();
        attributeDataMap1.put('SKU', 'NEW-CALIB');
        attributeDataMap1.put('machine', 'AccuFlex34349');
        attributeDataMap1.put('type', 'CASSETEE');
        attributeDataMap1.put('drugCode', '0000123456788');
        attributeDataMap1.put('quantity', '50');
        attributeDataMap1.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap2 = new Map<String,object>();
        attributeDataMap2.put('SKU', 'RECALIB');
        attributeDataMap2.put('machine', 'AccuFlex34349');
        attributeDataMap2.put('type', 'CASSETEE');
        attributeDataMap2.put('drugCode', '0000123456788');
        attributeDataMap2.put('quantity', '50');
        attributeDataMap2.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap21 = new Map<String,object>();
        attributeDataMap21.put('SKU', 'RECALIB');
        attributeDataMap21.put('machine', 'AccuFlex34350');
        attributeDataMap21.put('type', 'CASSETEE');
        attributeDataMap21.put('drugCode', '0000123456788');
        attributeDataMap21.put('quantity', '50');
        attributeDataMap21.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap3 = new Map<String,object>();
        attributeDataMap3.put('SKU', 'REPAIR');
        attributeDataMap3.put('machine', 'AccuFlex34349');
        attributeDataMap3.put('type', 'CASSETEE');
        attributeDataMap3.put('drugCode', '0000123456788');
        attributeDataMap3.put('quantity', '50');
        attributeDataMap3.put('currEffacc', acc.Id);
        
        
        
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c Casssette = SCP_TestDataFactory.childccAttribute('CASSETTE',Type.Id,22);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        
        Test.startTest();
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','RECALIB');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        OmnicellProductDetailController.getAttributes(ctx);
        string jsonstring1 = JSON.serialize(attributeDataMap1);
        string jsonstring2 = JSON.serialize(attributeDataMap2);
        string jsonstring3 = JSON.serialize(attributeDataMap3);
        string jsonstring21 = JSON.serialize(attributeDataMap21);
        
        //OmnicellProductDetailController.upsertCartItem(ctx, jsonstring1);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring21);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        //OmnicellProductDetailController.upsertCartItem(ctx, jsonstring1);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod7(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineDataCassette = SCP_TestDataFactory.createMachine(acc,'AccuFlex34349','Acuflex','Base','Acuflex II');
        Machine__c machineDataCassette2 = SCP_TestDataFactory.createMachine(acc,'AccuFlex34350','Acuflex','Base','Acuflex II');
        machineDataCassette2.Agreement_sign_date__c = System.today()-100;
        update machineDataCassette2;
        Machine__c machineDataCanister = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Map<String,object> attributeDataMap1 = new Map<String,object>();
        
        
        
        
        Map<String,object> attributeDataMap3 = new Map<String,object>();
        attributeDataMap3.put('SKU', 'RECALIB');
        attributeDataMap3.put('machine', 'PACMED34349');
        attributeDataMap3.put('type', 'Canister');
        attributeDataMap3.put('drugCode', '0000123456788');
        attributeDataMap3.put('quantity', '50');
        attributeDataMap3.put('currEffacc', acc.Id);
        
        Map<String,object> drugData = new Map<String,object>();
        drugData.put('name', 'TestDrug');
        drugData.put('number', '000123XX45678');
        drugData.put('strength', '20 mg');
        drugData.put('manufacturer', 'ABC Inc');
        drugData.put('drugBrand', 'ABC');
        drugData.put('unit', 'cell');
        drugData.put('pillform', 'GAS-GA');
        drugData.put('width1', '0.1');
        drugData.put('thickness1', '0.1');
        drugData.put('width2', '0.1');
        drugData.put('length', '0.1');
        drugData.put('thickness2', '0.1');
        
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c Casssette = SCP_TestDataFactory.childccAttribute('CASSETTE',Type.Id,22);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        
        Test.startTest();
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','NEW-CALIB');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        string jsonstring3 = JSON.serialize(attributeDataMap3);
        string jsonstringdrugData = JSON.serialize(drugData);
        System.debug(jsonstringdrugData);
        
        
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.deleteCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.deleteCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.deleteCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.insertDrug(ctx, jsonstringdrugData);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod8(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','REPAIR').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineDataCassette = SCP_TestDataFactory.createMachine(acc,'AccuFlex34349','Acuflex','Base','Acuflex II');
        Machine__c machineDataCassette2 = SCP_TestDataFactory.createMachine(acc,'AccuFlex34350','Acuflex','Base','Acuflex II');
        machineDataCassette2.Agreement_sign_date__c = System.today()-100;
        update machineDataCassette2;
        Machine__c machineDataCanister = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        
        Map<String,object> attributeDataMap1 = new Map<String,object>();
        attributeDataMap1.put('SKU', 'RECALIB');
        attributeDataMap1.put('machine', 'PACMED34349');
        attributeDataMap1.put('type', 'Canister');
        attributeDataMap1.put('drugCode', '0000123456788');
        attributeDataMap1.put('quantity', '51');
        attributeDataMap1.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap2 = new Map<String,object>();
        attributeDataMap2.put('SKU', 'REPAIR');
        attributeDataMap2.put('machine', 'AccuFlex34350');
        attributeDataMap2.put('type', 'CASSETEE');
        attributeDataMap2.put('drugCode', '0000123456788');
        attributeDataMap2.put('quantity', '51');
        attributeDataMap2.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap3 = new Map<String,object>();
        attributeDataMap3.put('SKU', 'RECALIB');
        attributeDataMap3.put('machine', 'AccuFlex34350');
        attributeDataMap3.put('type', 'CASSETEE');
        attributeDataMap3.put('drugCode', '0000123456788');
        attributeDataMap3.put('quantity', '51');
        attributeDataMap3.put('currEffacc', acc.Id);
        
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c Casssette = SCP_TestDataFactory.childccAttribute('CASSETTE',Type.Id,22);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        
        Test.startTest();
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','REPAIR');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        string jsonstring1 = JSON.serialize(attributeDataMap1);
        string jsonstring2 = JSON.serialize(attributeDataMap2);
        string jsonstring3 = JSON.serialize(attributeDataMap3);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod9(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','REPAIR').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        DrugCode__c drgCode2 = SCP_TestDataFactory.createDrugCode('0000123456799');
        Machine__c machineDataCassette = SCP_TestDataFactory.createMachine(acc,'AccuFlex34349','Acuflex','Base','Acuflex II');
        Machine__c machineDataCassette2 = SCP_TestDataFactory.createMachine(acc,'AccuFlex34350','Acuflex','Base','Acuflex II');
        machineDataCassette2.Agreement_sign_date__c = System.today()-100;
        update machineDataCassette2;
        Machine__c machineDataCanister = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        
        Map<String,object> attributeDataMap1 = new Map<String,object>();
        attributeDataMap1.put('SKU', 'RECALIB');
        attributeDataMap1.put('machine', 'PACMED34349');
        attributeDataMap1.put('type', 'Canister');
        attributeDataMap1.put('drugCode', '0000123456788');
        attributeDataMap1.put('quantity', '151');
        attributeDataMap1.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap2 = new Map<String,object>();
        attributeDataMap2.put('SKU', 'RECALIB');
        attributeDataMap2.put('machine', 'PACMED34349');
        attributeDataMap2.put('type', 'Canister');
        attributeDataMap2.put('drugCode', '0000123456799');
        attributeDataMap2.put('quantity', '30');
        attributeDataMap2.put('currEffacc', acc.Id);
        
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c Casssette = SCP_TestDataFactory.childccAttribute('CASSETTE',Type.Id,22);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        
        Test.startTest();
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','RECALIB');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        string jsonstring1 = JSON.serialize(attributeDataMap1);
        string jsonstring2 = JSON.serialize(attributeDataMap2);
        
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring1);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod10(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        DrugCode__c drgCode2 = SCP_TestDataFactory.createDrugCode('0000123456799');
        DrugCode__c drgCode3 = SCP_TestDataFactory.createDrugCode('0000123456711');
        Machine__c machineDataCassette = SCP_TestDataFactory.createMachine(acc,'AccuFlex34349','Acuflex','Base','Acuflex II');
        Machine__c machineDataCassette2 = SCP_TestDataFactory.createMachine(acc,'AccuFlex34350','Acuflex','Base','Acuflex II');
        machineDataCassette2.Agreement_sign_date__c = System.today()-100;
        update machineDataCassette2;
        Machine__c machineDataCanister = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        
        Map<String,object> attributeDataMap1 = new Map<String,object>();
        attributeDataMap1.put('SKU', 'NEW-CALIB');
        attributeDataMap1.put('machine', 'PACMED34349');
        attributeDataMap1.put('type', 'Canister');
        attributeDataMap1.put('drugCode', '0000123456788');
        attributeDataMap1.put('quantity', '301');
        attributeDataMap1.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap2 = new Map<String,object>();
        attributeDataMap2.put('SKU', 'NEW-CALIB');
        attributeDataMap2.put('machine', 'PACMED34349');
        attributeDataMap2.put('type', 'Canister');
        attributeDataMap2.put('drugCode', '0000123456799');
        attributeDataMap2.put('quantity', '30');
        attributeDataMap2.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap3 = new Map<String,object>();
        attributeDataMap3.put('SKU', 'NEW-CALIB');
        attributeDataMap3.put('machine', 'PACMED34349');
        attributeDataMap3.put('type', 'Canister');
        attributeDataMap3.put('drugCode', '0000123456711');
        attributeDataMap3.put('quantity', '1');
        attributeDataMap3.put('currEffacc', acc.Id);
        
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c Casssette = SCP_TestDataFactory.childccAttribute('CASSETTE',Type.Id,22);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        
        Test.startTest();
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','NEW-CALIB');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        
        string jsonstring1 = JSON.serialize(attributeDataMap1);
        string jsonstring2 = JSON.serialize(attributeDataMap2);
        string jsonstring3 = JSON.serialize(attributeDataMap3);
        
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring1);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod11(){
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineDataCassette = SCP_TestDataFactory.createMachine(acc,'AccuFlex34349','Acuflex','Base','Acuflex II');
        Machine__c machineDataCassette2 = SCP_TestDataFactory.createMachine(acc,'AccuFlex34350','Acuflex','Base','Acuflex II');
        machineDataCassette2.Agreement_sign_date__c = System.today()-100;
        update machineDataCassette2;
        //Machine__c machineDataCanister = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Map<String,object> attributeDataMap1 = new Map<String,object>();
        attributeDataMap1.put('SKU', 'NEW-CALIB');
        attributeDataMap1.put('machine', 'AccuFlex34349');
        attributeDataMap1.put('type', 'CASSETEE');
        attributeDataMap1.put('drugCode', '0000123456788');
        attributeDataMap1.put('quantity', '50');
        attributeDataMap1.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap2 = new Map<String,object>();
        attributeDataMap2.put('SKU', 'RECALIB');
        attributeDataMap2.put('machine', 'AccuFlex34349');
        attributeDataMap2.put('type', 'CASSETEE');
        attributeDataMap2.put('drugCode', '0000123456788');
        attributeDataMap2.put('quantity', '50');
        attributeDataMap2.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap21 = new Map<String,object>();
        attributeDataMap21.put('SKU', 'RECALIB');
        attributeDataMap21.put('machine', 'AccuFlex34350');
        attributeDataMap21.put('type', 'CASSETEE');
        attributeDataMap21.put('drugCode', '0000123456788');
        attributeDataMap21.put('quantity', '50');
        attributeDataMap21.put('currEffacc', acc.Id);
        
        Map<String,object> attributeDataMap3 = new Map<String,object>();
        attributeDataMap3.put('SKU', 'REPAIR');
        attributeDataMap3.put('machine', 'AccuFlex34349');
        attributeDataMap3.put('type', 'CASSETEE');
        attributeDataMap3.put('drugCode', '0000123456788');
        attributeDataMap3.put('quantity', '50');
        attributeDataMap3.put('currEffacc', acc.Id);
        
        
        
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c Casssette = SCP_TestDataFactory.childccAttribute('CASSETEE',Type.Id,22);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        
        Test.startTest();
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','RECALIB');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        OmnicellProductDetailController.getAttributes(ctx);
        string jsonstring1 = JSON.serialize(attributeDataMap1);
        string jsonstring2 = JSON.serialize(attributeDataMap2);
        string jsonstring3 = JSON.serialize(attributeDataMap3);
        string jsonstring21 = JSON.serialize(attributeDataMap21);
        
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring1);
        //OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        //OmnicellProductDetailController.upsertCartItem(ctx, jsonstring21);
        //OmnicellProductDetailController.upsertCartItem(ctx, jsonstring3);
        OmnicellProductDetailController.upsertCartItem(ctx, jsonstring1);
        //OmnicellProductDetailController.upsertCartItem(ctx, jsonstring2);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod12(){
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Boolean check = OmnicellProductDetailController.drugCheckInSystem('000012345XX8');
        List<String> testDrug = new List<String>{'0000123456788','000012345XX8'};
            String jsonstring1 = JSON.serialize(testDrug);  
        OmnicellProductDetailController.bulkdrugCodeCheck(ctx,jsonstring1);
        
    }
    
    @isTest
    public static void testMethod13(){
        SCP_TestDataFactory.fullProdDataSetup();
        Account acc = [Select Id From Account Where Name = 'Full Account Setup' Limit 1];
        Test.startTest();
        PageReference myVfPage = Page.cc_HomeBeta;
        Test.setCurrentPage(myVfPage);
        ccrz__E_Cart__c ec = [Select id,ccrz__EncryptedId__c From ccrz__E_Cart__c Where ccrz__Name__c = 'Full Cart Setup' Limit 1];
        ccrz__E_PriceList__c Pricelist = SCP_TestDataFactory.createPriceList(1)[0];
        insert Pricelist;
        ccrz__E_Product__c Product = SCP_TestDataFactory.createProducts(1)[0];
        insert Product;
        ccrz__E_SubProdTerm__c spt = SCP_TestDataFactory.createSPT(Product,1)[0];
        insert spt;
        String pTier = '{"pT":"tAbsPrice","tiers":[{"q":1.000,"p":91.50},{"q":2.000,"p":82.36},{"q":4.000,"p":73.20},{"q":8.000,"p":64.05}] }';
        List<ccrz__E_PriceListItem__c> pricelistitem = SCP_TestDataFactory.createPriceListItemwithTier(Product,Pricelist,spt,1,pTier);
        insert pricelistitem;
        ApexPages.currentPage().getParameters().put('cartID',ec.ccrz__EncryptedId__c);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        OmnicellProductDetailController.couponApply(ctx,'TestF32');
        OmnicellProductDetailController.getProductList(ctx);
        OmnicellProductDetailController.getProductDetails(ctx,'314-51');
        OmnicellProductDetailController.shipNotesCart(ctx,'test');
        OmnicellProductDetailController.getPrice(1,pricelistitem[0]);
        OmnicellProductDetailController.myCart(ctx);
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createCassetteCanisterProduct('314-61');
        Product1.Minimum_Quantity__c = 1;
        update Product1;
        
        ccrz__E_PriceList__c listPrice = [Select id From ccrz__E_PriceList__c Where Name = 'LIST PRICE' Limit 1];
        List<ccrz__E_PriceListItem__c> priceListItem2 = SCP_TestDataFactory.createPriceListItem(Product1,listPrice,null,1);
        insert priceListItem2;
        string currentCartI= '{\"SKU\": \"'+Product1.ccrz__SKU__c+'\",\"Qty\": \"2\"}';
        OmnicellProductDetailController.homeUpserCarttItem(ctx,currentCartI);
        string currentCartI2= '{\"SKU\": \"314-51\",\"Qty\": \"2\"}';
        string currentCartI3= '{\"SKU\": \"314-61\",\"Qty\": \"5\"}';
        OmnicellProductDetailController.homeUpserCarttItem(ctx,currentCartI2);
        priceListItem2[0].ccrz__PricingTiers__c = pTier;
        priceListItem2[0].ccrz__ItemType__c = 'tiered';
        update priceListItem2;
        OmnicellProductDetailController.homeUpserCarttItem(ctx,currentCartI);
        OmnicellProductDetailController.homeUpserCarttItem(ctx,currentCartI3);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod14(){
        SCP_TestDataFactory.fullProdDataSetup();
        contacttriggerhandler.triggerdisabled = true;
        Account acc = [Select Id From Account Where Name = 'Full Account Setup' Limit 1];
        Test.startTest();
        PageReference myVfPage = Page.cc_HomeBeta;
        Test.setCurrentPage(myVfPage);        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();        
        ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert ec;
        ec.ccrz__EncryptedId__c = ec.Id;
        ec.ccrz__EffectiveAccountID__c=acc.Id;
        update ec;
        ApexPages.currentPage().getParameters().put('cartID',ec.ccrz__EncryptedId__c);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();   
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        insert Product1;
        Product1.ccrz__ProductWeight__c=0.5;
        update Product1;        
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1,ccrz__StartDate__c = System.Today(),ccrz__EndDate__c = System.Today(),ccrz__Enabled__c = True, ccrz__Storefront__c = 'OmnicellB2BStore');
        insert coupon;        
        ccrz__E_CartItem__c cartitem2 = new ccrz__E_CartItem__c(ccrz__Product__c=Product1.id,ccrz__Quantity__c=5.0, Discounted_Quantity__c=0.0,ccrz__Cart__c=ec.id,ccrz__Price__c=50.00,ccrz__Coupon__c=coupon.id);
        insert cartitem2;        
        string currentCartI= '{\"SKU\": \"'+Product1.ccrz__SKU__c+'\",\"Qty\": \"1\"}';
        ccrz__E_CartCoupon__c cartcou = new ccrz__E_CartCoupon__c();
        cartcou.ccrz__Cart__c = ec.id;
        cartcou.ccrz__Coupon__c = coupon.id;
        insert cartcou;
        OmnicellProductDetailController.removeCoupon(ctx,'test');
        OmnicellProductDetailController.homeUpserCarttItem(ctx,currentCartI);
        OmnicellProductDetailController.homeDeleteCarttItem(ctx,currentCartI);
        OmnicellProductDetailController.selectAccount(ctx,'9500300123','shipTo');
        OmnicellProductDetailController.selectAccount(ctx,'9500300123','billTo');
		OmnicellProductDetailController.prodMinQty(ctx,Product1.ccrz__SKU__c);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod15(){
        SCP_TestDataFactory.fullProdDataSetup();
        contacttriggerhandler.triggerdisabled = true;
        Account acc = [Select Id From Account Where Name = 'Full Account Setup' Limit 1];
        Test.startTest();
        PageReference myVfPage = Page.cc_HomeBeta;
        Test.setCurrentPage(myVfPage);        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();        
        ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert ec;
        ec.ccrz__EncryptedId__c = ec.Id;
        ec.ccrz__EffectiveAccountID__c=acc.Id;
        update ec;
        ApexPages.currentPage().getParameters().put('cartID',ec.ccrz__EncryptedId__c);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        insert Product1;
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1,ccrz__StartDate__c = System.Today(),ccrz__EndDate__c = System.Today(),ccrz__Enabled__c = True, ccrz__Storefront__c = 'OmnicellB2BStore');
        insert coupon;
        ccrz__E_CartItem__c cartitem2 = new ccrz__E_CartItem__c(ccrz__Product__c=Product1.id,ccrz__Quantity__c=5.0, Discounted_Quantity__c=0.0,ccrz__Cart__c=ec.id,ccrz__Price__c=50.00);
        insert cartitem2;
        string cou = coupon.id;
        OmnicellProductDetailController.couponApply(ctx,'test');
        OmnicellProductDetailController.deleteCartCoupon(ec.id,cou);
        Test.stopTest();    
    }
    
    @isTest
    public static void testMethod16(){
        OmnicellProductDetailController controller = new OmnicellProductDetailController() ;
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Machine__c machineData2 = SCP_TestDataFactory.createMachine(acc,'OD400','OD400','RFID','E2 Gen 2');
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        
        Map<String,object> attributeDataMap = new Map<String,object>();
        attributeDataMap.put('SKU', 'NEW-CALIB');
        attributeDataMap.put('machine', 'PACMED34349');
        attributeDataMap.put('type', 'CANISTER');
        attributeDataMap.put('drugCode', '0000123456788');
        attributeDataMap.put('quantity', '150');
        attributeDataMap.put('currEffacc', acc.Id);
        
        
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> attributeList = new Map<String, Object>();
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        String status = OmnicellProductDetailController.createMajorCartItem(activeCart[0].Id,attributeDataMap);
        
        List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                     ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                     From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                     AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'NEW-CALIB'];
        
        Test.startTest();
        String status2 = OmnicellProductDetailController.createMinorCartItem('NEW-CALIB',newcartItemList[0],attributeDataMap);
        PageReference myVfPage = Page.OmniCellProductDetail;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
        ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
        ApexPages.currentPage().getParameters().put('sku','NEW-CALIB');
        ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        String attributePrice = OmnicellProductDetailController.getAttPrice(acc.Id,'NEW-CALIB');
        Map<String, Object> attributeJson = (Map<String, Object>) JSON.deserializeUntyped(attributePrice);
        Map<String, Object> machineJson = (Map<String, Object>) attributeJson.get('aL');
        Map<String,Object> typeaLJson = (Map<String, Object>)machineJson.get('MACHINE^Default');
        Map<String,Object> typej = new Map<String,Object>();
        String machineStyle = 'Canister';
        //Map<String,Object> typeGenerator = OmnicellProductDetailController.typeGenerator(typej,machineStyle,typeaLJson);
        Map<String,Decimal> esitingType = new Map<String,Decimal> ();
        esitingType = OmnicellProductDetailController.typeAlltmentPurchase(esitingType,machineStyle,5);
        Map<String,object> cartData = new Map<String,object>();
        cartData.put('Machine', 'Pacmed');
        cartData.put('MachineType', 'Canister');
        cartData.put('DrugCode', '000123XX45678');
        cartData.put('Quantity', '1');
        string jsonstringcartData = JSON.serialize(cartData);
        //OmnicellProductDetailController.bulkUpload(ctx, jsonstringcartData);
        ApexPages.currentPage().getParameters().put('currCartId',activeCart[0].Id);
        OmnicellProductDetailController.reCheck(ctx);
        Test.stopTest();    
    }

    @isTest
    public static void testMethod17(){
        OmnicellProductDetailController controller = new OmnicellProductDetailController() ;
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        Account acc2 = new Account(name='Full Account Setup',Account_role__c='ZCSN',
                Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                BillingCountryCode = 'US',BillingStateCode  = 'IL',
                Account_Status__c = 'Active',IsDeleted__c = false,  
                Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        acc2.SAP_Account_ID__c = '9500300123';
        acc2.Validation_Status__c = 'Validated';
        acc2.Facility_Type__c = 'Pharmacy';
        acc2.BILLINGSTREET = '41 Moss';
        acc2.BillingPostalCode = '77777';
        insert acc2;
        SAP_Sales_Org__c salOrg = new SAP_Sales_Org__c();
        salOrg.Account__c = acc.id;
        salOrg.CurrencyIsoCode = 'USD';
        salOrg.Sales_Office__c = 'OMDD';
        salOrg.Distribution_Channel__c = '01';
        salOrg.Incoterms_1__c = 'DDP';
        salOrg.Incoterms_2__c = 'Newyork'; 
        salOrg.Tax_Classification__c = '1';
        insert salOrg;
        RelationshipTriggerHandler.TriggerDisabled = True;
        Relationship__c rel = new Relationship__c(Relationship__c = 'RE',Primary_Account__c = acc.Id,Secondary_Account__c = acc2.Id,
                                            Primary_Account_Sales_Org__c = salOrg.Id,Default_Partner_Flag__c = True);
        insert rel;
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Machine__c machineData2 = SCP_TestDataFactory.createMachine(acc,'OD400','OD400','RFID','E2 Gen 2');
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);        
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        
        Map<String,object> attributeDataMap = new Map<String,object>();
        attributeDataMap.put('SKU', 'NEW-CALIB');
        attributeDataMap.put('machine', 'PACMED34349');
        attributeDataMap.put('type', 'CANISTER');
        attributeDataMap.put('drugCode', '0000123456788');
        attributeDataMap.put('quantity', '150');
        attributeDataMap.put('currEffacc', acc.Id);
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> attributeList = new Map<String, Object>();
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        
        String status = OmnicellProductDetailController.createMajorCartItem(activeCart[0].Id,attributeDataMap);
        
        List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                     ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                     From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                     AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'NEW-CALIB'];
        
        String status2 = OmnicellProductDetailController.createMinorCartItem('NEW-CALIB',newcartItemList[0],attributeDataMap);
        Test.startTest();
            PageReference myVfPage = Page.OmniCellProductDetail;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
            ApexPages.currentPage().getParameters().put('sku','NEW-CALIB');
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();           
            ApexPages.currentPage().getParameters().put('currCartId',activeCart[0].Id);
            OmnicellProductDetailController.reCheck(ctx);
            ccrz__E_CartItem__c minorItem = [Select Id,ccrz__Quantity__c,Machines__r.Id From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id
                                            AND ccrz__ParentCartItem__c = :newcartItemList[0].Id];            
            minorItem.ccrz__Quantity__c = 251;
            update minorItem;
            OmnicellProductDetailController.reCheck(ctx);
            Machine__c  cartmachineData =[Select Id,Purchased__c From Machine__c Where Id = :minorItem.Machines__r.Id];
            cartmachineData.Purchased__c = 301;
            update cartmachineData;
            OmnicellProductDetailController.reCheck(ctx);
        Test.stopTest();    
    }
}