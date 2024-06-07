@isTest
public class SCP_reCheckCanisterCassette_Test {
    
    @testSetup 
    private static void dataSetup(){
        
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        
        List<Account> accList = new List<Account>();
        Account acc = new Account(name='AccountForNEWCALIB',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',
                                  Validation_Status__c = 'Validated',BillingCountryCode = 'US',SAP_Account_ID__c = '0000012345');
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        accList.add(acc);
        Account acc2 = new Account(name='AccountForRECALIB',Account_role__c='ZCSN',
                                   RecordtypeId = TestDataFactory.recTypeAccount,
                                   Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Pharmacy',
                                   Validation_Status__c = 'Validated',BillingCountryCode = 'US',SAP_Account_ID__c = '0000021345');
        //acc2.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N1','RECALIB').Id;
        accList.add(acc2);
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = True;
        insert accList;
        ccrz__E_Attribute__c drugparent = SCP_TestDataFactory.parentccAttribute('NDC',3);
        ccrz__E_Attribute__c machineparent = SCP_TestDataFactory.parentccAttribute('MACHINE',1);
        ccrz__E_Attribute__c typeparent = SCP_TestDataFactory.parentccAttribute('TYPE',2);        
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',machineparent.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',typeparent.Id,21);
        ccrz__E_Attribute__c cassette = SCP_TestDataFactory.childccAttribute('CASSETTE',typeparent.Id,22);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',drugparent.Id,31);
        
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Machine__c machineData2 = SCP_TestDataFactory.createMachine(acc,'OD400','OD400','RFID','E2 Gen 2');
        List<Contact> contactList = new List<Contact>();
        Contact con = new Contact(LastName = 'Test Contact NEW_CALIB',AccountId = acc.id);
        contactList.add(con);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        //Contact con2 = new Contact(LastName = 'Test Contact RECALIB',AccountId = acc2.id);
        //contactList.add(con);
        
        //insert con2;
        List<ccrz__E_ContactAddr__c> ccConAdd = new List<ccrz__E_ContactAddr__c>();
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        contAdd.AccountId__c = acc.Id;
        ccConAdd.add(contAdd);
        //ccrz__E_ContactAddr__c contAdd2 = SCP_TestDataFactory.getContactAddress();
        //contAdd2.AccountId__c = acc2.Id;
        //ccConAdd.add(contAdd2);
        insert ccConAdd;
        
        List<ccrz__E_Cart__c> activeCarts = new List<ccrz__E_Cart__c>();
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createActiveCart(acc,con,contAdd);
        activeCarts.add(cart);
        //ccrz__E_Cart__c cart2 = SCP_TestDataFactory.createActiveCart(acc2,con2,contAdd2);
        //activeCarts.add(cart2);        
        insert activeCarts;
        for(ccrz__E_Cart__c ct:activeCarts){
            ct.ccrz__EncryptedId__c = ct.Id;
            ct.ccrz__EffectiveAccountID__c = ct.ccrz__Account__c;
        }
        update activeCarts;
    }
    
    @isTest
    private static void testMethod1(){
        
        Account acc = [Select Id From Account Where Name = 'AccountForNEWCALIB' Limit 1];   
        Account acc2 = [Select Id From Account Where Name = 'AccountForRECALIB' Limit 1];  
        Map<String,object> attributeDataMap = new Map<String,object>();
        attributeDataMap.put('SKU', 'NEW-CALIB');
        attributeDataMap.put('machine', 'PACMED34349');
        attributeDataMap.put('type', 'CANISTER');
        attributeDataMap.put('drugCode', '0000123456788');
        attributeDataMap.put('quantity', '150');
        attributeDataMap.put('currEffacc', acc.Id);
        ccrz__E_Cart__c cart = [Select Id,ccrz__EffectiveAccountID__c,ccrz__EncryptedId__c,Order_attempt__c,ccrz__BillTo__c,ccrz__ShipTo__c,
                               SAP_Billing_Customer_Number__c,SAP_Shipping_Customer_Number__c From ccrz__E_Cart__c Where 
                                ccrz__Account__c = :acc.Id limit 1];
        String status = OmnicellProductDetailController.createMajorCartItem(cart.Id,attributeDataMap);
        List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                     ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                     From ccrz__E_CartItem__c Where ccrz__Cart__c =:cart.Id 
                                                     AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'NEW-CALIB'];
        String status2 = OmnicellProductDetailController.createMinorCartItem('NEW-CALIB',newcartItemList[0],attributeDataMap);        
        Test.startTest(); 
        	AccountCreateController.isFirstRun= false;
            AccountTriggerHandler.TriggerDisabled = True;
            RelationshipCreateController.isFirstRun = true;
            RelationshipCreateController.isTriggerExecuting = true;
        	SAP_Sales_OrgTriggerHandler.TriggerDisabled = True;
            SAP_Sales_Org__c sso1 = TestDataFactory.createSAPSAlesOrgForAccount(acc.Id);
            List<Relationship__c> relList = new List<Relationship__c>();
            Relationship__c rel = new Relationship__c();
            rel.Primary_Account__c = acc.Id;
            rel.Secondary_Account__c = acc2.Id;
            rel.Relationship__c ='RE';
            rel.Primary_Account_Sales_Org__c = sso1.Id;
            rel.Default_Partner_Flag__c = True;
            relList.add(rel);
        	insert rel;
            Relationship__c rel2 = new Relationship__c();
            rel2.Primary_Account__c = acc.Id;
            rel2.Secondary_Account__c = acc2.Id;
            rel2.Relationship__c ='WE';
            rel2.Primary_Account_Sales_Org__c = sso1.Id;
            rel2.Default_Partner_Flag__c = True;
            relList.add(rel2);
            insert rel2;
        	List<ccrz__E_PriceListItem__c> pricelistItems = [Select Id,ccrz__AttributePricing__c From ccrz__E_PriceListItem__c Where ccrz__Product__r.ccrz__SKU__c ='RECALIB' 
                              AND ccrz__Pricelist__r.ccrz__PricelistId__c = 'LIST PRICE' AND ccrz__StartDate__c <= TODAY AND ccrz__EndDate__c >= TODAY];
        	System.debug('***'+pricelistItems.size());
        	Boolean proceedflag = SCP_reCheckCanisterCassetteItemsPrice.reCheckBillability(cart,false);
        	Machine__c pacmedMachine  = [Select Id,Purchased__c From Machine__c Where Machine_Name__c = 'PACMED34349' Limit 1];
        	pacmedMachine.Purchased__c = 200;
        	update pacmedMachine;
        	proceedflag = SCP_reCheckCanisterCassetteItemsPrice.reCheckBillability(cart,false);
        	pacmedMachine.Purchased__c = 300;
        	update pacmedMachine;
        	proceedflag = SCP_reCheckCanisterCassetteItemsPrice.reCheckBillability(cart,true);
        Test.stopTest();
    }
    
}