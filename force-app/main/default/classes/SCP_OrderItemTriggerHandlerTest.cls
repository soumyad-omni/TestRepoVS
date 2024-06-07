@isTest
public class SCP_OrderItemTriggerHandlerTest {
    	public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    	
		@isTest
        public static void testMethod1(){
            List<ccrz__E_Attribute__c> attrList = new List<ccrz__E_Attribute__c>();
            ccrz__E_Attribute__c drugparent = new ccrz__E_Attribute__c(Name = 'NDC',ccrz__AttributeID__c = 'NDC',ccrz__DisplayName__c = 'NDC',
                                                            ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                          ccrz__Sequence__c = 1);
            attrList.add(drugparent);
            ccrz__E_Attribute__c machineparent = new ccrz__E_Attribute__c(Name = 'MACHINE',ccrz__AttributeID__c = 'MACHINE',ccrz__DisplayName__c = 'MACHINE',
                                                            ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                          ccrz__Sequence__c = 2);
            attrList.add(machineparent);
            ccrz__E_Attribute__c machineTypeparent = new ccrz__E_Attribute__c(Name = 'TYPE',ccrz__AttributeID__c = 'TYPE',ccrz__DisplayName__c = 'TYPE',
                                                            ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                          ccrz__Sequence__c = 3);
            attrList.add(machineTypeparent);
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
            	OmnicellProductDetailController controller = new OmnicellProductDetailController() ;
                Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                          RecordtypeId = TestDataFactory.recTypeAccount,
                                          Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
                acc.BillingCountryCode = 'US';
            	acc.BillingStreet = '10 Street';
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
            	
            	Map<String,object> attributeDataMap1 = new Map<String,object>();
                attributeDataMap1.put('SKU', 'NEW-CALIB');
                attributeDataMap1.put('machine', 'AccuFlex34349');
                attributeDataMap1.put('type', 'CASSETTE');
                attributeDataMap1.put('drugCode', '0000123456788');
                attributeDataMap1.put('quantity', '10');
                attributeDataMap1.put('currEffacc', acc.Id);
            
            	List<ccrz__E_Attribute__c> machineAttr = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
                String machineId;
                if(machineAttr.size()>0){
                machineId = machineAttr[0].Id;
                }
                else{
                machineId = SCP_TestDataFactory.parentccAttribute('MACHINE',1).Id;
                }
                List<ccrz__E_Attribute__c> machineTypeAttr = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'TYPE'];
                String machineTypeId;
                if(machineTypeAttr.size()>0){
                machineTypeId = machineTypeAttr[0].Id;
                }
                else{
                machineTypeId = SCP_TestDataFactory.parentccAttribute('TYPE',1).Id;
                }
                List<ccrz__E_Attribute__c> NDCAttr = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
                String NDCId;
                if(NDCAttr.size()>0){
                NDCId = NDCAttr[0].Id;
                }
                else{
                NDCId = SCP_TestDataFactory.parentccAttribute('NDC',1).Id;
                }    
                ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',machineId,11);
                ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',machineTypeId,21);
                ccrz__E_Attribute__c cassette = SCP_TestDataFactory.childccAttribute('CASSETTE',machineTypeId,22);
                ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDCId,31);
            
            
            	PageReference myVfPage = Page.OmniCellProductDetail;
                Test.setCurrentPage(myVfPage);
                ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
                ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
                ApexPages.currentPage().getParameters().put('sku','NEW-CALIB');
            	ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            	
                string jsonstring1 = JSON.serialize(attributeDataMap1);
            	OmnicellProductDetailController.upsertCartItem(ctx, jsonstring1);
            	ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,activeCart[0],acc,con,contAdd)[0];
                order.ccrz__PaymentMethod__c = 'card';
                order.ccrz__OrderStatus__c =  'Completed';
                order.ccrz__PONumber__c ='1234';
            	order.ccrz__OriginatedCart__c = activeCart[0].Id;
            	order.ccrz__EffectiveAccountID__c = acc.Id;
                insert order;
            	List<ccrz__E_OrderItem__c> orderItemList = new List<ccrz__E_OrderItem__c>();
            	List<ccrz__E_CartItem__c> cartItemList = [Select Id,ccrz__Price__c,ccrz__SubAmount__c,ccrz__Quantity__c,
                                                          ccrz__OriginalQuantity__c,ccrz__OriginalItemPrice__c,ccrz__Product__c,ccrz__cartItemType__c,
                                                          ccrz__PricingType__c,ccrz__UnitOfMeasure__c,ccrz__StoreID__c,ccrz__RequestDate__c,
                                                          ccrz__ItemStatus__c
                                                          From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id];
            	ccrz__E_Coupon__c coup = new ccrz__E_Coupon__c(ccrz__CouponName__c='Coupon Name',ccrz__MaxUse__c=10,ccrz__TotalUsed__c=0,ccrz__CouponCode__c='testcoup',ccrz__TargetRelation__c='Product',ccrz__TargetProduct__c=cartItemList[0].ccrz__Product__c,ccrz__TargetQty__c=10,ccrz__CouponType__c='Percentage');
        		insert coup;
            	
                for(ccrz__E_CartItem__c ct:cartItemList){
                    ccrz__E_OrderItem__c ot = new ccrz__E_OrderItem__c();
                    ot.ccrz__OrderItemId__c = ct.Id;
                    ot.ccrz__ItemStatus__c = ct.ccrz__ItemStatus__c;
                    ot.ccrz__Price__c = ct.ccrz__Price__c;
                    ot.ccrz__SubAmount__c = ct.ccrz__SubAmount__c;
                    ot.ccrz__Quantity__c = ct.ccrz__Quantity__c;
                    ot.ccrz__OriginalQuantity__c = ct.ccrz__OriginalQuantity__c;
                    ot.ccrz__OriginalItemPrice__c = ct.ccrz__OriginalItemPrice__c;
                    ot.ccrz__Product__c = ct.ccrz__Product__c;
                    ot.ccrz__OrderLineType__c = ct.ccrz__cartItemType__c;
                    ot.ccrz__PricingType__c = ct.ccrz__PricingType__c;
                    ot.ccrz__UnitOfMeasure__c = ct.ccrz__UnitOfMeasure__c;
                    ot.ccrz__StoreID__c = ct.ccrz__StoreID__c;
                    ot.ccrz__RequestDate__c = ct.ccrz__RequestDate__c;
                    ot.ccrz__Order__c = order.Id;
                    ot.ccrz__Coupon__c = coup.Id;
                    orderItemList.add(ot);
                }
            Test.startTest();
            	insert orderItemList; 
            Test.stopTest(); 
        }
}