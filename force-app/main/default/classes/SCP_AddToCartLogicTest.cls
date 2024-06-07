@isTest
public class SCP_AddToCartLogicTest {
    
    @testSetup 
    public static void dataSetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        setting.Accountendpoint__c = 'https://printcastirondev.omnicell.com';
        insert setting;
        Account acc;
        Contact con;
        User thisUser = [select Id from User where Profile.Name =: 'System Administrator' and IsActive = True and UserRoleId != null LIMIT 1];
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
		

        System.runAs(thisUser){
            acc = new Account(Name = 'Test Account'+math.random(), Account_Name2__c = 'Test Acc Name',Facility_Type__c= 'Hospice',Validation_Status__c = 'Validated',IsDeleted__c = false,BillingStreet='test123',Account_Role__c='ZCSN');
            insert acc;
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
        rel.Secondary_Account__c = acc.id;
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
        inputData.put('currItem',cartitem);
        //String price = '{"'+cartitem.ccrz__Product__c+'"={"maxSubPrice"=70.00, "minSubPrice"=70.00, "productPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "pricingTiers"={"pT"="tAbsPrice", "tiers"=({"p"=91.50, "q"=1.000, "unitPrice"=91.50}, {"p"=82.36, "q"=2.000, "unitPrice"=82.36}, {"p"=73.20, "q"=4.000, "unitPrice"=73.20}, {"p"=64.05, "q"=8.000, "unitPrice"=64.05})}, "sfid"="a783B000000Cz0IQAS"}, "subProductTerms"={"a7v520000000PzbAAE"={"nonRecurringPrice"={"itemType""=tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "sfid"="a7852000000H2F7AAK", "upfrontPricePercentage"=null}, "recurringPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "recurringPricePercentage"=null, "sfid"="a7852000000H2F8AAK"}}}}}';
        String price ='{\n' +
            '"'+cartitem.ccrz__Product__c+'":'+
            '{\n' +
            '"productPrice":'+
                '{"itemType":"tiered",'+
               '"price":70.00,'+
               '"priceList":"a793B000000D6NrQAK",'+
               '"pricingTiers":'+
                  '{"pT":"tAbsPrice",'+
                  '"tiers":[{'+
                     '"p":91.5,'+
                     '"q":1.0,'+
                     '"unitPrice":91.50},'+
                  '{'+
                     '"p":82.3,'+
                     '"q":2.0,'+
                     '"unitPrice":82.36},'+
                  '{'+
                     '"p":73.2,'+
                     '"q":4,'+
                     '"unitPrice":73.2},'+
                  '{'+
                     '"p":64,'+
                     '"q":8,'+
                     '"unitPrice":64.05}]},'+
                '"sfid":"'+pricelistitem[0].Id+'"},"subProductTerms":{"'+spt.Id+'":{"nonRecurringPrice":{"itemType":"tiered", "price":70.00, "priceList":"a793B000000D6NrQAK", "sfid":"a7852000000H2F7AAK", "upfrontPricePercentage":null}, "recurringPrice":{"itemType":"tiered", "price":70.00, "priceList":"a793B000000D6NrQAK", "recurringPricePercentage":null, "sfid":"a7852000000H2F8AAK"}}}'+
                    '}'+
        '}';
        Object obj = (Object)JSON.deserializeUntyped(price);
        Map<String, Object> data = (Map<String, Object>)obj;
        inputData.put('productPricingData',data);
        Test.startTest();
          SCP_AddToCartLogic cartValidateObj = new SCP_AddToCartLogic();
          cartValidateObj.setSubAmount(inputdata);
          cartValidateObj.priceBasicProductItem(inputdata);
          cartValidateObj.applyTieredPricing(inputdata);
        Test.stopTest();    
    }
    
    @isTest
    public static void test2(){
        id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
        
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        insert Product1;
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
        insert coupon;
        ccrz__E_CartItem__c cartitem = new ccrz__E_CartItem__c(ccrz__Quantity__c=7.0,ccrz__OriginalQuantity__c=7.0, Discounted_Quantity__c=2,ccrz__Cart__c=cartObjid,ccrz__Price__c=10.00,ccrz__Product__c =Product1.id,ccrz__Coupon__c =coupon.id);
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
        inputData.put('currItem',cartitem);
        //String price = '{"'+cartitem.ccrz__Product__c+'"={"maxSubPrice"=70.00, "minSubPrice"=70.00, "productPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "pricingTiers"={"pT"="tAbsPrice", "tiers"=({"p"=91.50, "q"=1.000, "unitPrice"=91.50}, {"p"=82.36, "q"=2.000, "unitPrice"=82.36}, {"p"=73.20, "q"=4.000, "unitPrice"=73.20}, {"p"=64.05, "q"=8.000, "unitPrice"=64.05})}, "sfid"="a783B000000Cz0IQAS"}, "subProductTerms"={"a7v520000000PzbAAE"={"nonRecurringPrice"={"itemType""=tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "sfid"="a7852000000H2F7AAK", "upfrontPricePercentage"=null}, "recurringPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "recurringPricePercentage"=null, "sfid"="a7852000000H2F8AAK"}}}}}';
        String price ='{\n' +
            '"'+cartitem.ccrz__Product__c+'":'+
            '{\n' +
            '"productPrice":'+
                '{"itemType":"tiered",'+
               '"price":70.00,'+
               '"priceList":"a793B000000D6NrQAK",'+
               '"pricingTiers":'+
                  '{"pT":"tAbsPrice",'+
                  '"tiers":[{'+
                     '"p":91.5,'+
                     '"q":1.0,'+
                     '"unitPrice":91.50},'+
                  '{'+
                     '"p":82.3,'+
                     '"q":2.0,'+
                     '"unitPrice":82.36},'+
                  '{'+
                     '"p":73.2,'+
                     '"q":4,'+
                     '"unitPrice":73.2},'+
                  '{'+
                     '"p":64,'+
                     '"q":8,'+
                     '"unitPrice":64.05}]},'+
                '"sfid":"'+pricelistitem[0].Id+'"},"subProductTerms":{"'+spt.Id+'":{"nonRecurringPrice":{"itemType":"tiered", "price":70.00, "priceList":"a793B000000D6NrQAK", "sfid":"a7852000000H2F7AAK", "upfrontPricePercentage":null}, "recurringPrice":{"itemType":"tiered", "price":70.00, "priceList":"a793B000000D6NrQAK", "recurringPricePercentage":null, "sfid":"a7852000000H2F8AAK"}}}'+
                    '}'+
        '}';
        Object obj = (Object)JSON.deserializeUntyped(price);
        Map<String, Object> data = (Map<String, Object>)obj;
        inputData.put('productPricingData',data);
        Test.startTest();
          SCP_AddToCartLogic cartValidateObj = new SCP_AddToCartLogic();
          cartValidateObj.setSubAmount(inputdata);
        cartValidateObj.priceBasicProductItem(inputdata);
        Test.stopTest();    
    }
    
    @isTest
    public static void test3(){
        id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
        
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        insert Product1;
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
        insert coupon;
        ccrz__E_CartItem__c cartitem = new ccrz__E_CartItem__c(ccrz__Quantity__c=0.0,ccrz__OriginalQuantity__c=0.0, Discounted_Quantity__c=2,ccrz__Cart__c=cartObjid,ccrz__Price__c=10.00,ccrz__Product__c =Product1.id,ccrz__Coupon__c =coupon.id);
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
        inputData.put('currItem',cartitem);
        //String price = '{"'+cartitem.ccrz__Product__c+'"={"maxSubPrice"=70.00, "minSubPrice"=70.00, "productPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "pricingTiers"={"pT"="tAbsPrice", "tiers"=({"p"=91.50, "q"=1.000, "unitPrice"=91.50}, {"p"=82.36, "q"=2.000, "unitPrice"=82.36}, {"p"=73.20, "q"=4.000, "unitPrice"=73.20}, {"p"=64.05, "q"=8.000, "unitPrice"=64.05})}, "sfid"="a783B000000Cz0IQAS"}, "subProductTerms"={"a7v520000000PzbAAE"={"nonRecurringPrice"={"itemType""=tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "sfid"="a7852000000H2F7AAK", "upfrontPricePercentage"=null}, "recurringPrice"={"itemType"="tiered", "price"=70.00, "priceList"="a793B000000D6NrQAK", "recurringPricePercentage"=null, "sfid"="a7852000000H2F8AAK"}}}}}';
        String price ='{\n' +
            '"'+cartitem.ccrz__Product__c+'":'+
            '{\n' +
            '"productPrice":'+
                '{"itemType":"tiered",'+
               '"price":70.00,'+
               '"priceList":"a793B000000D6NrQAK",'+
               '"pricingTiers":'+
                  '{"pT":"tAbsPrice",'+
                  '"tiers":[{'+
                     '"p":91.5,'+
                     '"q":1.0,'+
                     '"unitPrice":91.50},'+
                  '{'+
                     '"p":82.3,'+
                     '"q":2.0,'+
                     '"unitPrice":82.36},'+
                  '{'+
                     '"p":73.2,'+
                     '"q":4,'+
                     '"unitPrice":73.2},'+
                  '{'+
                     '"p":64,'+
                     '"q":8,'+
                     '"unitPrice":64.05}]},'+
                '"sfid":"'+pricelistitem[0].Id+'"},"subProductTerms":{"'+spt.Id+'":{"nonRecurringPrice":{"itemType":"tiered", "price":70.00, "priceList":"a793B000000D6NrQAK", "sfid":"a7852000000H2F7AAK", "upfrontPricePercentage":null}, "recurringPrice":{"itemType":"tiered", "price":70.00, "priceList":"a793B000000D6NrQAK", "recurringPricePercentage":null, "sfid":"a7852000000H2F8AAK"}}}'+
                    '}'+
        '}';
        Object obj = (Object)JSON.deserializeUntyped(price);
        Map<String, Object> data = (Map<String, Object>)obj;
        inputData.put('productPricingData',data);
        Test.startTest();
          SCP_AddToCartLogic cartValidateObj = new SCP_AddToCartLogic();
          cartValidateObj.setSubAmount(inputdata);
        cartValidateObj.priceBasicProductItem(inputdata);
        Test.stopTest();    
    }

}