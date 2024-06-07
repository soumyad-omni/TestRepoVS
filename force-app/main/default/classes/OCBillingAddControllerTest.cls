/*** 
Test Class For - OmniCellBillingAddressController
Developer - Sanjana K.R 
***/
@isTest
public class OCBillingAddControllerTest{
    public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @testSetup 
    public static void dataSetup(){
        AccountTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = True;
        SCP_TestDataFactory.createIntDetails();
        SCP_TestDataFactory.createCastIron();
        SCP_TestDataFactory.createIntDetails_Auth();
        
        SCP_TestDataFactory.createIntDetails_order_simulate();
        SCP_Integration_Details__c  setting11 = new SCP_Integration_Details__c ();
        setting11.Name = 'SCP_ContactSFToCRM';
        setting11.SCP_Method_Type__c = 'POST';
        setting11.SCP_Timeout__c = 120000;
        setting11.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM';
        insert setting11;
        
        SCP_Integration_Details__c  setting2 = new SCP_Integration_Details__c ();
        setting2.Name = 'SCP_ContactSFToCRM_Update';
        setting2.SCP_Method_Type__c = 'POST';
        setting2.SCP_Timeout__c = 120000;
        setting2.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update';
        insert setting2;
        
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        
        CreditCardDisable__c  setting11112 = new CreditCardDisable__c ();
        setting11112.name = 'Credit';
        setting11112.IsDisabled__c = false;
        insert setting11112;
        
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        
        Account acc;
        Account acc1;
        Contact con;
        User thisUser = [select Id from User where Profile.Name =: 'System Administrator' and IsActive = True and UserRoleId != null LIMIT 1];
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        ccrz__E_ConfigurationModule__c conmod = new ccrz__E_ConfigurationModule__c(Name ='Cybersource', ccrz__APIName__c='pgcs');
        insert conmod;
        ccrz__E_ConfigurationMeta__c conmeta = new ccrz__E_ConfigurationMeta__c(Name ='Payment Types', ccrz__APIName__c='paymenttypes',ccrz__ConfigurationModule__c=conmod.id);
        insert conmeta;
		ccrz__E_Configuration__c ecg = new ccrz__E_Configuration__c(ccrz__TextValue__c='po, cc',ccrz__Storefront__c = 'OmnicellB2BStore',ccrz__ConfigurationMeta__c = conmeta.id,Name = 'Payment Types');
		insert ecg;
        System.runAs(thisUser){
            acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000)+'Test Account',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000113903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
           	acc.Facility_Type__c = 'Pharmacy';
           	acc.BILLINGSTREET = '41 Moss';
            acc.BillingPostalCode = 'DY6 9HP';
            insert acc;
            con = new Contact(LastName = 'Test Contact',AccountId = acc.id);
            insert con;
            acc1 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013904',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
           	acc1.Facility_Type__c = 'Pharmacy';
           	acc1.BILLINGSTREET = '41 Moss';
            acc1.BillingPostalCode = 'DY6 9HP';
            insert acc1;
            ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc, con, contAdd)[0];
            insert ec;
            ec.ccrz__EncryptedId__c = ec.Id;
            ec.ccrz__EffectiveAccountID__c=acc.Id;
            update ec;
        
            //UserRole ur = [Select id From UserRole where Name =:'Community Health Systems Customer User' limit 1];
            Profile profileId = [select Id,name from Profile where Name ='Omnicell B2B Storefront Profile' limit 1];
                  
            
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
            //CommUser.UserRoleId = ur.Id;  
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
        rel.Relationship__c ='WE';
        rel.Secondary_Account__c = acc1.id;
        rel.Primary_Account_Sales_Org__c = salOrg.id;
        insert rel;
        
        Relationship__c rel1 = new Relationship__c();
        rel1.Primary_Account__c = acc.id;
        rel1.Relationship__c ='RE';
        rel1.Secondary_Account__c = acc1.id;
        rel1.Primary_Account_Sales_Org__c = salOrg.id;
        insert rel1;
                
        ccrz__E_Cart__c cart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd)[0];
        insert cart;
        
        
        ccrz__E_Order__c order = SCP_TestDataFactory.createOrders(1,cart,acc,con,contAdd)[0];
        insert order;
        
        ccrz__E_TransactionPayment__c tPay = new ccrz__E_TransactionPayment__c(ccrz__AccountNumber__c = 'Test PO',ccrz__AccountType__c = 'po',ccrz__CCOrder__c = order.id);
        insert tPay;
    }
    @isTest
    public static void testBillingAddress(){
    
        
        User usr = [select id,ContactId from User where FirstName = 'TestUserfirstName' LIMIT 1];
        System.assert(usr.id != null);
        Account acct = [SELECT Id,Name FROM Account WHERE Name like '%Test Account%' LIMIT 1];
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName like '%Test Contact%' LIMIT 1];
        SAP_Sales_Org__c salOrg = [select id from SAP_Sales_Org__c where Account__c =: acct.id];
        Relationship__c rel= [SELECT Id,Relationship__c ,Secondary_Account__c,Primary_Account__c FROM Relationship__c Where Relationship__c = 'WE' LIMIT 1];
        ccrz__E_Cart__c  cartObj = [Select Id from ccrz__E_Cart__c Limit 1];
        ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123',ccrz__ShippingWeight__c=151);
        insert productObj;
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(ccrz__Cart__c=cartObj.Id,ccrz__Price__c=123,ccrz__Product__c=productObj.Id);
        insert cartItem;
        String cartItemData = '[{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"},{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"},{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"}]';
        //System.runAs(usr){
            Test.startTest();
            PageReference myVfPage = Page.OmniCellBillingAddress;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',cartObj.Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acct.Id);
            OmniCellBillingAddressController billAdd = new OmniCellBillingAddressController();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            OmniCellBillingAddressController.getContactAddressContactList(ctx,cont.Id);
            OmniCellBillingAddressController.updateCartCustomFields(ctx,json.serialize(cont),'test','113903',cartItemData);
            OmniCellBillingAddressController.updateCartCustomFields(ctx,'{"contactId":"'+cont.Id+'","shippingCustomerNumber":"shippingno","billingCustomerNumber":"billingno"}','test','113903',cartItemData);
            OmniCellBillingAddressController.getpo(ctx, 'Test PO');
        	OmniCellBillingAddressController.simulate(ctx);
        	OmniCellBillingAddressController.getPayment(ctx);
        	OmniCellBillingAddressController.createCreditBillTo(ctx, JSON.serialize(acct));
        	OmniCellBillingAddressController.reCheckSingleCheckout(ctx);
            Test.stopTest();
       // }
    }
    
    @isTest
    public static void testBillingAddress1(){
    
        
        User usr = [select id,ContactId from User where FirstName = 'TestUserfirstName' LIMIT 1];
        System.assert(usr.id != null);
        Account acct = [SELECT Id,Name FROM Account WHERE Name like '%Test Account%' LIMIT 1];
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName like '%Test Contact%' LIMIT 1];
        SAP_Sales_Org__c salOrg = [select id from SAP_Sales_Org__c where Account__c =: acct.id];
        Relationship__c rel= [SELECT Id,Relationship__c ,Secondary_Account__c,Primary_Account__c FROM Relationship__c LIMIT 1];
        ccrz__E_Cart__c  cartObj = [Select Id,Order_attempt__c,SAP_Shipping_Customer_Number__c from ccrz__E_Cart__c Limit 1];
        cartObj.Order_attempt__c=true;
        cartObj.SAP_Shipping_Customer_Number__c='80158656';
        update cartObj;
        
        ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123',ccrz__ShippingWeight__c=151);
        insert productObj;
        
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(ccrz__Cart__c=cartObj.Id,ccrz__Price__c=123,ccrz__Product__c=productObj.Id);
        insert cartItem;
        String cartItemData = '[{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"},{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"},{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"}]';
        
        List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST> etItemList = new List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST>();
        SCP_OrderSimulate_Res_Parser.ET_ITEMLIST etList = new SCP_OrderSimulate_Res_Parser.ET_ITEMLIST();
        etList.ITM_NUMBER=cartItem.Name;
        etList.MATERIAL='1120';
        etList.REQ_QTY='1';
        etList.AVL_QTY='2';
        etList.ABS_DISCOUNT='5';
        etList.PERC_DISCOUNT='1';
        etList.CAS_NOT_SETUP='X';
        etItemList.add(etList);
        
        SCP_OrderSimulate_Res_Parser.ET_ITEMLIST etList1 = new SCP_OrderSimulate_Res_Parser.ET_ITEMLIST();
        etList1.ITM_NUMBER=cartItem.Name;
        etList1.MATERIAL='1120';
        etList1.REQ_QTY='1';
        etList1.AVL_QTY='0';
        etList1.ABS_DISCOUNT='5';
        etList1.PERC_DISCOUNT='1';
        etList.CAS_NOT_SETUP=NULL;
        etItemList.add(etList1);
        
        SCP_OrderSimulate_Res_Parser.Row row1 = new SCP_OrderSimulate_Res_Parser.Row();
        row1.ET_ITEMLIST = etItemList;
        row1.EX_CR_BLOCK = NULL;
        row1.EX_EXCEPTION = '';
        
        SCP_OrderSimulate_Res_Parser res = new SCP_OrderSimulate_Res_Parser();
        res.row = row1;
        String datest = '11-11-1111';
            Test.startTest();
            PageReference myVfPage = Page.OmniCellBillingAddress;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',cartObj.Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acct.Id);
            OmniCellBillingAddressController billAdd = new OmniCellBillingAddressController();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        	Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(0));
            OmniCellBillingAddressController.simulate(ctx);
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(1));
        	OmniCellBillingAddressController.simulate(ctx);
        	OmniCellBillingAddressController.changeDateFormat(datest);
            OmniCellBillingAddressController.updateCartCustomFields(ctx,'{"contactId":"'+cont.Id+'","shippingCustomerNumber":"shippingno","billingCustomerNumber":"billingno"}','test','',cartItemData);
            
            Test.stopTest();
       
    }
    
    @isTest
    public static void testBillingAddress2(){
    
        
        User usr = [select id,ContactId from User where FirstName = 'TestUserfirstName' LIMIT 1];
        System.assert(usr.id != null);
        Account acct = [SELECT Id,Name FROM Account WHERE Name like '%Test Account%' LIMIT 1];
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName like '%Test Contact%' LIMIT 1];
        SAP_Sales_Org__c salOrg = [select id from SAP_Sales_Org__c where Account__c =: acct.id];
        Relationship__c rel= [SELECT Id,Relationship__c ,Secondary_Account__c,Primary_Account__c FROM Relationship__c LIMIT 1];
        ccrz__E_Cart__c  cartObj = [Select Id,Order_attempt__c from ccrz__E_Cart__c Limit 1];
        cartObj.Order_attempt__c=true;
        update cartObj;
        
        ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123',ccrz__ShippingWeight__c=151);
        insert productObj;
        
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(ccrz__Cart__c=cartObj.Id,ccrz__Price__c=123,ccrz__Product__c=productObj.Id);
        insert cartItem;
        List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST> etItemList = new List<SCP_OrderSimulate_Res_Parser.ET_ITEMLIST>();
        SCP_OrderSimulate_Res_Parser.ET_ITEMLIST etList = new SCP_OrderSimulate_Res_Parser.ET_ITEMLIST();
        etList.ITM_NUMBER=cartItem.Name;
        etList.MATERIAL='1120';
        etList.REQ_QTY='1';
        etList.AVL_QTY='2';
        etList.ABS_DISCOUNT='5';
        etList.PERC_DISCOUNT='1';
        etList.CAS_NOT_SETUP='X';
        etItemList.add(etList);
              
        SCP_OrderSimulate_Res_Parser.ET_ITEMLIST etList1 = new SCP_OrderSimulate_Res_Parser.ET_ITEMLIST();
        etList1.ITM_NUMBER=cartItem.Name;
        etList1.MATERIAL='1120';
        etList1.REQ_QTY='1';
        etList1.AVL_QTY='0';
        etList1.ABS_DISCOUNT='5';
        etList1.PERC_DISCOUNT='1';
        etList1.CAS_NOT_SETUP='X';
        etItemList.add(etList1);
        
        SCP_OrderSimulate_Res_Parser.Row row1 = new SCP_OrderSimulate_Res_Parser.Row();
        row1.ET_ITEMLIST = etItemList;
        row1.EX_CR_BLOCK = NULL;
        row1.EX_EXCEPTION = 'Y'; 
        
        SCP_OrderSimulate_Res_Parser res = new SCP_OrderSimulate_Res_Parser();
        res.row = row1;
        
        
            Test.startTest();
            PageReference myVfPage = Page.OmniCellBillingAddress;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',cartObj.Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acct.Id);
        	OmniCellBillingAddressController billAdd = new OmniCellBillingAddressController();
        	billAdd.companyattn='test';
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        	Test.setMock(HttpCalloutMock.class, new SCP_MuleAccessTokenMock(1));
            Test.setMock(HttpCalloutMock.class, new SCP_OrderSimulate_Test_MockResponse(2));
            OmniCellBillingAddressController.simulate(ctx);
            OmniCellBillingAddressController.checkCC(ctx);
            Test.stopTest();
       
    }
    
    @isTest
    public static void testBillingAddress4(){
    
        
        User usr = [select id,ContactId from User where FirstName = 'TestUserfirstName' LIMIT 1];
        System.assert(usr.id != null);
        Account acct = [SELECT Id,Name FROM Account WHERE Name like '%Test Account%' LIMIT 1];
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName like '%Test Contact%' LIMIT 1];
        SAP_Sales_Org__c salOrg = [select id from SAP_Sales_Org__c where Account__c =: acct.id];
        Relationship__c rel= [SELECT Id,Relationship__c ,Secondary_Account__c,Primary_Account__c FROM Relationship__c Where Relationship__c = 'RE' LIMIT 1];
        ccrz__E_Cart__c  cartObj = [Select Id from ccrz__E_Cart__c Limit 1];
        ccrz__E_Product__c productObj = new ccrz__E_Product__c(ccrz__SKU__c='1123',ccrz__ShippingWeight__c=151);
        insert productObj;
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c(ccrz__Cart__c=cartObj.Id,ccrz__Price__c=123,ccrz__Product__c=productObj.Id);
        insert cartItem;
        String cartItemData = '[{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"},{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"},{"ItemNumber":"'+cartItem.Name+'","Date":"02/10/2023"}]';
        Test.startTest();
            PageReference myVfPage = Page.OmniCellBillingAddress;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',cartObj.Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acct.Id);
            OmniCellBillingAddressController billAdd = new OmniCellBillingAddressController();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            OmniCellBillingAddressController.getContactAddressContactList(ctx,cont.Id);
            OmniCellBillingAddressController.updateCartCustomFields(ctx,json.serialize(cont),'test','113903',cartItemData);
            OmniCellBillingAddressController.updateCartCustomFields(ctx,'{"contactId":"'+cont.Id+'","shippingCustomerNumber":"shippingno","billingCustomerNumber":"billingno"}','test','113903',cartItemData);
            OmniCellBillingAddressController.getpo(ctx, 'Test PO');
        	OmniCellBillingAddressController.simulate(ctx);
        	OmniCellBillingAddressController.getPayment(ctx);
        	OmniCellBillingAddressController.createCreditBillTo(ctx, JSON.serialize(acct));
        	OmniCellBillingAddressController.reCheckSingleCheckout(ctx);
        Test.stopTest();
    }
}