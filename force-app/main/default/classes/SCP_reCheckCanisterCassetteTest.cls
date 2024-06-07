@isTest
public class SCP_reCheckCanisterCassetteTest {
    
    	@isTest
        public static void testMethod1(){
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
            ccrz__E_Attribute__c Machine = SCP_TestDataFactory.parentccAttribute('MACHINE',1);
            ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
            ccrz__E_Attribute__c NDC = SCP_TestDataFactory.parentccAttribute('NDC',3);
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
            	OmnicellProductDetailController.reCheck(ctx);
            Test.stopTest();    
        }
    
    	@isTest
        public static void testMethod2(){
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
            attributeDataMap.put('SKU', 'RECALIB');
            attributeDataMap.put('machine', 'PACMED34349');
            attributeDataMap.put('type', 'CANISTER');
            attributeDataMap.put('drugCode', '0000123456788');
            attributeDataMap.put('quantity', '150');
            attributeDataMap.put('currEffacc', acc.Id);
    
    
            Map<String, Object> inputData = new Map<String, Object>();
            Map<String, Object> attributeList = new Map<String, Object>();
            ccrz__E_Attribute__c Machine = SCP_TestDataFactory.parentccAttribute('MACHINE',1);
            ccrz__E_Attribute__c Type = SCP_TestDataFactory.parentccAttribute('TYPE',2);
            ccrz__E_Attribute__c NDC = SCP_TestDataFactory.parentccAttribute('NDC',3);
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
            	PageReference myVfPage = Page.OmniCellProductDetail;
                Test.setCurrentPage(myVfPage);
                ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
                ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
                ApexPages.currentPage().getParameters().put('sku','RECALIB');
            	ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
                OmnicellProductDetailController.getAttributes(ctx);
            	OmnicellProductDetailController.getCartCount(ctx);
            	string jsonstring = JSON.serialize(attributeDataMap);
            	OmnicellProductDetailController.upsertCartItem(ctx, jsonstring);
            	OmnicellProductDetailController.upsertCartItem(ctx, jsonstring);
            	OmnicellProductDetailController.reCheck(ctx);
            Test.stopTest();    
        }

}