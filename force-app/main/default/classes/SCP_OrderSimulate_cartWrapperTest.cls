@isTest
public class SCP_OrderSimulate_cartWrapperTest {
    public static String CRON_EXP = '0 11 15 29 5 ? 2022';
	@testSetup 
    public static void dataSetup(){
        
        Account acc;
        Account acc2;
        Contact con;
        User thisUser = [select Id from User where Profile.Name =: 'System Administrator' and IsActive = True and UserRoleId != null LIMIT 1];

        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;


        System.runAs(thisUser){
            acc = new Account(Name = 'Test Account'+math.random(), Account_Name2__c = 'Test Acc Name',Facility_Type__c= 'Hospice',Validation_Status__c = 'Validated',IsDeleted__c = false,BillingStreet='test123',Account_Role__c='ZCSN',Transport_Zone__c='US00000001',Transportation_Zone_Country__c='US');
            insert acc;
            acc2 = new Account(Name = 'Test Account2'+math.random(), Account_Name2__c = 'Test Acc Name2',Facility_Type__c= 'Hospice',Validation_Status__c = 'Validated',IsDeleted__c = false,BillingStreet='test1234',Account_Role__c='ZCSN',Transport_Zone__c='US00000001',Transportation_Zone_Country__c='US');
            insert acc2;
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
        rel.Secondary_Account__c = acc2.id;
        rel.Primary_Account_Sales_Org__c = salOrg.id;
        insert rel;
		
        id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;
       
        ccrz__E_CartItem__c cartitem2 = new ccrz__E_CartItem__c(ccrz__Quantity__c=5.0, Discounted_Quantity__c=0.0,ccrz__Cart__c=cartObjid,ccrz__Price__c=50.00,ccrz__PricingType__c='auto');
        insert cartitem2;
        
        ccrz__E_Product__c Product1 = SCP_TestDataFactory.createProducts(1)[0];
        Product1.ccrz__SKU__c = 'NEW-CALIB';
        insert Product1;
        
        ccrz__E_Attribute__c attrp1 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='NDC', ccrz__DisplayName__c='Drug Code', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__Sequence__c=11111);
        insert attrp1;
        ccrz__E_Attribute__c attr1 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='00005555', ccrz__DisplayName__c='00005555', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp1.id, ccrz__Sequence__c=12222);
        insert attr1;
        ccrz__E_Attribute__c attrp2 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='MACHINE', ccrz__DisplayName__c='MACHINE', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__Sequence__c=13333);
        insert attrp2;
        ccrz__E_Attribute__c attr2 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='11115555', ccrz__DisplayName__c='11115555', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp2.id, ccrz__Sequence__c=14444);
        insert attr2;
        ccrz__E_Attribute__c attrp3 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='TYPE', ccrz__DisplayName__c='TYPE', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__Sequence__c=15555);
        insert attrp3;
        ccrz__E_Attribute__c attr3 = new ccrz__E_Attribute__c(ccrz__AttributeID__c='CANISTER', ccrz__DisplayName__c='Canister', ccrz__EffectiveEnd__c=Date.today().addDays(100), ccrz__EffectiveStart__c=Date.today(), ccrz__ParentAttribute__c=attrp3.id, ccrz__Sequence__c=16666);
        insert attr3;
        DrugCode__c drCode = new DrugCode__c(DrugCodes__c='8888888888888', Generic_Drug_Name__c='Test Drug 555', Brand_Name__c='Test Drug 555', Manufacturer_Name__c='Test Drug 555', Drug_Strength__c='555mg', Drug_Type__c='UPC', Dose_Unit__c='cell', Drug_Forms__c='AEROSOL (ML)-AEROSOL-AA');
		insert drCode;
		Machine__c mcCode = new Machine__c(Account_CSN__c=acc.Id, Machine_Type_Mapping__c='PACMED', Machine_Type_Category__c='Canister', Machine_Name__c='PACMED9988', Machine_Id__c=9988, New_Calibration_Allotment__c=100, Purchased__c=0, Recalibration_Allotment__c=100, Recalibrations_Purchased__c=0, Agreement_sign_date__c=Date.today());      
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c(ccrz__TargetQty__c=1.0, ccrz__TargetProduct__c=Product1.id,ccrz__CouponCode__c='test', ccrz__CouponName__c='test', ccrz__MaxUse__c=10, ccrz__TotalUsed__c=1);
        insert coupon;
        ccrz__E_CartItem__c cartitem = new ccrz__E_CartItem__c(Availability_Date__c=Date.today().addDays(30), ccrz__Quantity__c=2.0, Discounted_Quantity__c=2,ccrz__Cart__c=cartObjid,ccrz__Price__c=10.00,ccrz__Product__c =Product1.id,ccrz__Coupon__c =coupon.id,ccrz__PricingType__c='auto',ccrz__PrimaryAttr__c=attr2.id,ccrz__SecondaryAttr__c=attr3.id,ccrz__TertiaryAttr__c=attr1.id,Machines__c=mcCode.id,Machine_Type__c='Canister', DrugCodes__c=drCode.id);
        insert cartitem;
        
    }
    @isTest
    public static void test1(){
        
        id cartObjid = [Select Id from ccrz__E_Cart__c Limit 1].id;

        List<ccrz__E_Cart__c> cartrec = new List<ccrz__E_Cart__c>([SELECT id, ccrz__Note__c, Name, ccrz__TaxAmount__c, ccrz__Account__r.SAP_Account_ID__c,ccrz__EffectiveAccountID__c,SAP_SOLD_TO__c  
                                                                        , ccrz__BillTo__r.SAP_Customer_Number__c
                                                                        , ccrz__ShipTo__r.SAP_Customer_Number__c
                                                                        , ccrz__Contact__r.SAP_Contact_ID__c, SAP_CONTACT_ID__c, SAP_Shipping_Customer_Number__c,SAP_Billing_Customer_Number__c 
                                                                        , WS_Credit_Block__c
                                                                        , WS_ErrorMessages__c
                                                                        , WS_Exception__c
                                                                        , ccrz__ShipMethod__c
                                                                        , (SELECT id,ccrz__Enabled__c,ccrz__Coupon__r.ccrz__CouponCode__c,ccrz__Coupon__r.ccrz__RuleType__c FROM ccrz__E_CartCoupons__r )
                                                                        //, (SELECT Id,Name,ccrz__Product__r.ccrz__SKU__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c,Discounted_Quantity__c,ccrz__PricingType__c FROM ccrz__E_CartItems__r)
                                                                   		, (SELECT Id,Name,ccrz__Product__r.ccrz__SKU__c,Material__c,ccrz__Quantity__c,ccrz__UnitOfMeasure__c,ccrz__AvailabilityMessage__c,Availability_Date__c,ccrz__AbsoluteDiscount__c,ccrz__PercentDiscount__c,Discounted_Quantity__c,ccrz__PrimaryAttr__r.ccrz__DisplayName__c,ccrz__SecondaryAttr__r.ccrz__DisplayName__c,ccrz__TertiaryAttr__r.ccrz__DisplayName__c,Machines__c,Machine_Type__c, DrugCodes__c, DrugCodes__r.DrugCodes__c,DrugCodes__r.Drug_Type__c,ccrz__Price__c,ccrz__SubAmount__c,ccrz__PricingType__c FROM ccrz__E_CartItems__r WHERE ccrz__PricingType__c != 'attrGroup')
                                                                        FROM ccrz__E_Cart__c Where id =: cartObjid
                                                                        LIMIT 1]);
         
         String str = '{"row": {"EV_SALES_ORDER": "1234","TAX_AMOUNT_HD": "1234","EX_EXCEPTION": "","ET_MESSAGES": "","": "Customer Credit Blocked","ET_FREIGHT_OPTIONSLIST": [{"SHIP_DESC": "Standard Ground","FREIGHT_VAL": "10","REQ_DATE": "2020-09-09"},{"SHIP_DESC": "Priority Overnight","FREIGHT_VAL": "55","REQ_DATE": "2020-07-07"},{"SHIP_DESC": "2nd Day Priority","FREIGHT_VAL": "20","REQ_DATE": "2020-08-07"}],"ET_ITEMLIST": [{"ITM_NUMBER": "000143","MATERIAL": "1123","REQ_QTY": "33","AVL_QTY": "22"},{"ITM_NUMBER": "000144","MATERIAL": "1153","REQ_QTY": "12","AVL_QTY": "88"},{"ITM_NUMBER": "000030","MATERIAL": "1193","REQ_QTY": "33","AVL_QTY": "2"}]}}';
         SCP_OrderSimulate_Res_Parser responseMule = (SCP_OrderSimulate_Res_Parser)System.JSON.deserialize(str, SCP_OrderSimulate_Res_Parser.class);        
         
         Test.StartTest();   
         /*Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
         Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(3));         
         String jobId = System.schedule('SCP_SubscriptionOrderSimSub_TestMethod1' +System.now(),CRON_EXP, new SCP_SubscriptionOrderSimSub());
         Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(2));
         jobId = System.schedule('SCP_SubscriptionOrderSimSub_TestMethod2'+System.now(),CRON_EXP, new SCP_SubscriptionOrderSimSub());
         Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(1));
         jobId = System.schedule('SCP_SubscriptionOrderSimSub_TestMethod3'+System.now(),CRON_EXP, new SCP_SubscriptionOrderSimSub());
         */
         SCP_OrderSimulate_cartWrapper ords = new SCP_OrderSimulate_cartWrapper();
         String st = SCP_OrderSimulate_cartWrapper.orderSimulateGenerateReqBody(cartrec);
         Test.StopTest();
     } 
}