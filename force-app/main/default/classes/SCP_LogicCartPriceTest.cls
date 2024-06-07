@isTest
public class SCP_LogicCartPriceTest {
  @testSetup 
  public static void dataSetup(){

  accounttriggerhandler.triggerdisabled= true;
  Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
  setting1111.Name = 'Account SendEmail Off';
  setting1111.Account_SendEmail_Off__c = false;
  insert setting1111;

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

  System.runAs(thisUser){
      acc = new Account(name='AccountForPacMed',Account_role__c='ZCSN',
                            RecordtypeId = TestDataFactory.recTypeAccount,
                            Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
      acc.BillingCountryCode = 'AZ';
      // acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0').Id;
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
      
      //UserRole ur = [Select id From UserRole where Name =:'Community Health Systems Customer User' limit 1];
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
  public static void test1(){
    id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
    
    ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
    insert Product1;
    ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
    insert coupon;
    ccrz__E_CartItem__c cartitem = new ccrz__E_CartItem__c(ccrz__Quantity__c=2.0,ccrz__OriginalQuantity__c=2.0, Discounted_Quantity__c=2,ccrz__Cart__c=cartObjid,ccrz__Price__c=10.00,ccrz__Product__c =Product1.id,ccrz__Coupon__c =coupon.id);
    insert cartitem;
    ccrz__E_PriceList__c Pricelist = SCP_TestDataFactory.createPriceList(1)[0];
    insert Pricelist;
    
    ccrz__E_Product__c Product = SCP_TestDataFactory.createProducts(1)[0];
    insert Product;
    
    ccrz__E_SubProdTerm__c spt = SCP_TestDataFactory.createSPT(Product,1)[0];
    insert spt;
    cartitem.ccrz__SubProdTerm__c = spt.id;
    String pTier = '{"pT":"tAbsPrice","tiers":[{"q":1.000,"p":91.50},{"q":2.000,"p":82.36},{"q":4.000,"p":73.20},{"q":8.000,"p":64.05}] }';
    
    List<ccrz__E_PriceListItem__c> pricelistitem = SCP_TestDataFactory.createPriceListItemwithTier(Product,Pricelist,spt,1,pTier);
    insert pricelistitem;
    Map<String, Object> inputdata = new Map<String, Object>();
    inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
    inputData.put('cartItem',cartitem);
    System.debug('**'+pricelistitem[0].Id);
        
    //String price = '{"'+cartitem.ccrz__Product__c+'"={"maxSubPrice"=70.00, "minSubPrice"=70.00, "productPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "pricingTiers"={"pT"="tAbsPrice", "tiers"=({"p"=91.50, "q"=1.000, "unitPrice"=91.50}, {"p"=82.36, "q"=2.000, "unitPrice"=82.36}, {"p"=73.20, "q"=4.000, "unitPrice"=73.20}, {"p"=64.05, "q"=8.000, "unitPrice"=64.05})}, "sfid"="a783B000000Cz0IQAS"}, "subProductTerms"={"a7v520000000PzbAAE"={"nonRecurringPrice"={"itemType""=tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "sfid"="a7852000000H2F7AAK", "upfrontPricePercentage"=null}, "recurringPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "recurringPricePercentage"=null, "sfid"="a7852000000H2F8AAK"}}}}}';
    String inoutJson ='{"nonRecurringPrice":{"itemType":"tiered","price":91.50,"priceList":"a793B000000D6NrQAK","sfid":"'+pricelistitem[0].Id+'","upfrontPricePercentage":null},"recurringPrice":{"itemType":"tiered","price":91.50,"priceList":"a793B000000D6NrQAK","recurringPricePercentage":null,"sfid":"'+pricelistitem[0].Id+'"}}';
    Object obj = (Object)JSON.deserializeUntyped(inoutJson);
    Map<String, Object> data = (Map<String, Object>)obj;
    inputData.put('spt4Price',data);
    Test.startTest();
      SCP_LogicCartPrice cartValidateObj = new SCP_LogicCartPrice();
      cartValidateObj.evaluateSubProdtermPricing(inputdata);
      cartValidateObj.priceAttributeItem(inputdata);
      cartValidateObj.priceItem(inputdata);
    Test.stopTest();    
  }

  @isTest
  public static void test2(){
    id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
    
    ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
    insert Product1;
    ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
    insert coupon;
    ccrz__E_CartItem__c cartitem = new ccrz__E_CartItem__c(ccrz__Quantity__c=5.0,ccrz__OriginalQuantity__c=5.0, Discounted_Quantity__c=2,ccrz__Cart__c=cartObjid,ccrz__Price__c=10.00,ccrz__Product__c =Product1.id,ccrz__Coupon__c =coupon.id);
    insert cartitem;
    ccrz__E_PriceList__c Pricelist = SCP_TestDataFactory.createPriceList(1)[0];
    insert Pricelist;
    
    ccrz__E_Product__c Product = SCP_TestDataFactory.createProducts(1)[0];
    insert Product;
    
    ccrz__E_SubProdTerm__c spt = SCP_TestDataFactory.createSPT(Product,1)[0];
    insert spt;
    cartitem.ccrz__SubProdTerm__c = spt.id;
    String pTier = '{"pT":"tAbsPrice","tiers":[{"q":1.000,"p":91.50},{"q":2.000,"p":82.36},{"q":4.000,"p":73.20},{"q":8.000,"p":64.05}] }';
    
    List<ccrz__E_PriceListItem__c> pricelistitem = SCP_TestDataFactory.createPriceListItemwithTier(Product,Pricelist,spt,1,pTier);
    insert pricelistitem;
    Map<String, Object> inputdata = new Map<String, Object>();
    inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
    inputData.put('cartItem',cartitem);
    System.debug('**'+pricelistitem[0].Id);
        
    //String price = '{"'+cartitem.ccrz__Product__c+'"={"maxSubPrice"=70.00, "minSubPrice"=70.00, "productPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "pricingTiers"={"pT"="tAbsPrice", "tiers"=({"p"=91.50, "q"=1.000, "unitPrice"=91.50}, {"p"=82.36, "q"=2.000, "unitPrice"=82.36}, {"p"=73.20, "q"=4.000, "unitPrice"=73.20}, {"p"=64.05, "q"=8.000, "unitPrice"=64.05})}, "sfid"="a783B000000Cz0IQAS"}, "subProductTerms"={"a7v520000000PzbAAE"={"nonRecurringPrice"={"itemType""=tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "sfid"="a7852000000H2F7AAK", "upfrontPricePercentage"=null}, "recurringPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "recurringPricePercentage"=null, "sfid"="a7852000000H2F8AAK"}}}}}';
    String inoutJson ='{"nonRecurringPrice":{"itemType":"tiered","price":91.50,"priceList":"a793B000000D6NrQAK","sfid":"'+pricelistitem[0].Id+'","upfrontPricePercentage":null},"recurringPrice":{"itemType":"tiered","price":91.50,"priceList":"a793B000000D6NrQAK","recurringPricePercentage":null,"sfid":"'+pricelistitem[0].Id+'"}}';
    Object obj = (Object)JSON.deserializeUntyped(inoutJson);
    Map<String, Object> data = (Map<String, Object>)obj;
    inputData.put('spt4Price',data);
    Test.startTest();
      SCP_LogicCartPrice cartValidateObj = new SCP_LogicCartPrice();
      cartValidateObj.evaluateSubProdtermPricing(inputdata);
    Test.stopTest();    
  }

  @isTest
  public static void test3(){
    
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
    ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDCId,31);

    String status = OmnicellProductDetailController.createMajorCartItem(activeCart[0].Id,attributeDataMap);
    
    List<ccrz__E_CartItem__c> newcartItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                        ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c
                                                          From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                          AND ccrz__cartItemType__c = 'Major' AND ccrz__Product__r.ccrz__SKU__c = 'RECALIB'];
    
    Test.startTest();
        String status2 = OmnicellProductDetailController.createMinorCartItem('RECALIB',newcartItemList[0],attributeDataMap);
        attributeList.put(MachineDef.Id, MachineDef);
        attributeList.put(Canister.Id, Canister);
        attributeList.put(NDCDef.Id, NDCDef);
        inputData.put('attributeList',attributeList);
        inputData.put('cartEncId',activeCart[0].Id);
        inputData.put('cartId',activeCart[0].Id);
        List<ccrz__E_CartItem__c> cartItemList = new List<ccrz__E_CartItem__c>();
        cartItemList.add(newcartItemList[0]);
        List<ccrz__E_CartItem__c> newcartMinorItemList = [Select id,ccrz__Cart__c,ccrz__Cart__r.ccrz__EffectiveAccountID__c,ccrz__ExtSKU__c,
                                                              ccrz__cartItemType__c,ccrz__Quantity__c,ccrz__Product__r.ccrz__SKU__c,Machines__c,ccrz__PrimaryAttr__c,
                                                              Machine_Type__c,ccrz__SecondaryAttr__c,Machines__r.Machine_Name__c
                                                              From ccrz__E_CartItem__c Where ccrz__Cart__c =:activeCart[0].Id 
                                                              AND ccrz__cartItemType__c = 'Minor' AND ccrz__Product__r.ccrz__SKU__c = 'RECALIB'];
        cartItemList.addAll(newcartMinorItemList);
        inputData.put('cartItemList',cartItemList);
        inputData.put('cartItemsToPrice',cartItemList);
    
    
    
        SCP_LogicCartPrice apl = new SCP_LogicCartPrice();
        apl.applyPricing(inputData);
      Decimal price = SCP_LogicCartPrice.getAttributePrice2(acc.Id,'RECALIB', newcartMinorItemList[0]);
    Test.stopTest();    
  }  
}