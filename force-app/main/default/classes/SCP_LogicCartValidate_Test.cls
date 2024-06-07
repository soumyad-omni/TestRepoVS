@istest
public class SCP_LogicCartValidate_Test {

    @testSetup 
    public static void dataSetup(){
        
        Account acc;
        Contact con;
        User thisUser = [select Id from User where Profile.Name =: 'System Administrator' and IsActive = True and UserRoleId != null LIMIT 1];
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;


        System.runAs(thisUser){
            acc = new Account(Name = 'Test Account'+math.random(), Account_Name2__c = 'Test Acc Name',Facility_Type__c= 'Pharmacy',Validation_Status__c = 'Validated',IsDeleted__c = false,BillingStreet='test123',Account_Role__c='ZCSN',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000004');
            insert acc;
            con = new Contact(LastName = 'Test Contact',AccountId = acc.id);
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
    
    @istest
    public static void processValidate_test(){
        id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
        ccrz__E_CartItem__c cartitem2 = new ccrz__E_CartItem__c(ccrz__Quantity__c=5.0, Discounted_Quantity__c=0.0,ccrz__Cart__c=cartObjid,ccrz__Price__c=50.00);
        insert cartitem2;
        
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        insert Product1;
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
        insert coupon;
        ccrz__E_CartItem__c cartitem = new ccrz__E_CartItem__c(ccrz__Quantity__c=2.0, Discounted_Quantity__c=2,ccrz__Cart__c=cartObjid,ccrz__Price__c=10.00,ccrz__Product__c =Product1.id,ccrz__Coupon__c =coupon.id);
        insert cartitem;
        
        /*ccrz__E_Product__c product = new ccrz__E_Product__c();
            product.Name = 'Test Product' + Math.random();
            product.ccrz__SKU__c = 'RECUR' + Math.random();
            product.ccrz__StartDate__c = Date.parse('04/26/21');
            product.ccrz__EndDate__c = Date.parse('12/15/40');
        insert product;
        ccrz__E_Coupon__c coupon1 = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product.id,ccrz__CouponCode__c='test1', ccrz__CouponName__c='test1', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
        insert coupon1;*/
        
        system.debug('** '+cartitem);
      	Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        
        //inputdata.put(ccrz.cc_CallContext.currCartId,cartObj.id);
        Test.startTest();
          SCP_LogicCartValidate cartValidateObj = new SCP_LogicCartValidate();
          cartValidateObj.processValidate(inputdata);
        Test.stopTest();    
    }
    @istest
    public static void processValidate_test1(){
        id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
        
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        insert Product1;
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
        insert coupon;
        ccrz__E_CartItem__c cartitem = new ccrz__E_CartItem__c(ccrz__Quantity__c=2.0, Discounted_Quantity__c=2,ccrz__Cart__c=cartObjid,ccrz__Price__c=10.00,ccrz__Product__c =Product1.id,ccrz__Coupon__c =coupon.id);
        insert cartitem;
        
      	Map<String, Object> inputdata = new Map<String, Object>();
        inputdata.put(ccrz.ccService.OBJECTFIELDS,'test');
        
        Test.startTest();
          SCP_LogicCartValidate cartValidateObj = new SCP_LogicCartValidate();
          cartValidateObj.processValidate(inputdata);
        Test.stopTest();    
    }
}