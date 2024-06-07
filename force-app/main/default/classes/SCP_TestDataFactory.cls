/* Class Name      :SCP_TestDataFactory
* Description      :This placeholder will be used to contain common codes for test data generation
* Created By       :Sanjana K.R
* Created On       :10/3/2021

* Modification Log:
* ----------------------------------------------------------------------------------------------------------------
* Developer                Date                   Description
* ----------------------------------------------------------------------------------------------------------------
* */
@isTest
public  class SCP_TestDataFactory{
    
    public static final String STOREFRONT_NAME = 'OmnicellB2BStore';
    
    public static List<Account> createAccounts(Integer noOfAccounts) {
        
        List<Account> accounts = new List<Account>();
        for( Integer i = 0 ; i < noOfAccounts ; i++ ){                    
            Account account = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                          Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                          Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                          BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                          Account_Status__c = 'Active',IsDeleted__c = false,  
                                          Transport_Zone__c='US00000001',Partner_Type__c= '0015');
            account.SAP_Account_ID__c = '500300';
            account.Validation_Status__c = 'Validated';
            account.Facility_Type__c = 'Pharmacy';
            account.BILLINGSTREET = '41 Moss';
            account.BillingPostalCode = '77777';
            accounts.add( account);
        }
        return accounts;
    }
    public static ccrz__E_AccountGroup__c createAccountGroup(String accGrpName){
        ccrz__E_AccountGroup__c accGrp = new ccrz__E_AccountGroup__c();
        accGrp.ccrz__AccountGroupID__c = accGrpName;
        accGrp.Name = accGrpName;
        accGrp.ccrz__PriceListSelectionMethod__c = 'Sequence Order';
        insert accGrp;
        ccrz__E_PriceList__c listPrice = createListPriceList();
        createAccountGroupPriceList(listPrice,accGrp);
        ccrz__E_Product__c recalibProd = createCassetteCanisterProduct('RECALIB');
        List<ccrz__E_PriceListItem__c> priceListItem = createPriceListItem(recalibProd,listPrice,null,1);
        priceListItem[0].ccrz__AttributePricing__c = '{ "aT":"sparseAbsolute", "aL":{ "MACHINE^Default":{ "aL":{"TYPE^CANISTER":{ "aL":{ "NDC^DEFAULT":{ "pr": 33.00 }}},"TYPE^CASSETTE":{ "aL":{ "NDC^DEFAULT":{ "pr": 80.00 }}}}}}}';
        insert priceListItem[0];
        return accGrp;
    }
    public static ccrz__E_AccountGroup__c createAccountGroup(String accGrpName,String sku){
        ccrz__E_AccountGroup__c accGrp = new ccrz__E_AccountGroup__c();
        accGrp.ccrz__AccountGroupID__c = accGrpName;
        accGrp.Name = accGrpName;
        accGrp.ccrz__PriceListSelectionMethod__c = 'Sequence Order';
        insert accGrp;
        ccrz__E_PriceList__c listPrice = createListPriceList();
        createAccountGroupPriceList(listPrice,accGrp);
        ccrz__E_Product__c Prod = createCassetteCanisterProduct(sku);
        List<ccrz__E_PriceListItem__c> priceListItem = createPriceListItem(Prod,listPrice,null,1);
        priceListItem[0].ccrz__AttributePricing__c = '{ "aT":"sparseAbsolute", "aL":{ "MACHINE^Default":{ "aL":{"TYPE^CANISTER":{ "aL":{ "NDC^DEFAULT":{ "pr": 33.00 }}},"TYPE^CASSETTE":{ "aL":{ "NDC^DEFAULT":{ "pr": 80.00 }}}}}}}';
        insert priceListItem[0];
        
        ccrz__E_Product__c Prod2 = createCassetteCanisterProduct('RECALIB');
        List<ccrz__E_PriceListItem__c> priceListItem2 = createPriceListItem(Prod2,listPrice,null,1);
        priceListItem2[0].ccrz__AttributePricing__c = '{ "aT":"sparseAbsolute", "aL":{ "MACHINE^Default":{ "aL":{"TYPE^CANISTER":{ "aL":{ "NDC^DEFAULT":{ "pr": 33.00 }}},"TYPE^CASSETTE":{ "aL":{ "NDC^DEFAULT":{ "pr": 80.00 }}}}}}}';
        insert priceListItem2[0];
        
        return accGrp;
    }    
    public static List<Contact> createContacts(Id accId,Integer noOfContacts) {
        
        List<Contact> conList = new List<Contact>();
        Contact con;
        for( Integer i = 0 ; i < noOfContacts; i++ ){ 
            con= new Contact();
            con.AccountId = accId;
            con.Title = 'Mr.';
            con.LastName = 'Contact'+i;
            con.SAP_Contact_ID__c='abc';
            conList.add(con);
        }
        return conList;
    }    
    public static ccrz__E_ContactAddr__c getContactAddress() {
        
        return new ccrz__E_ContactAddr__c(
            ccrz__AddressFirstline__c = '100 Pine Street',
            ccrz__City__c             = 'SmallTown',
            ccrz__DaytimePhone__c     = '(847) 555-1212',
            ccrz__FirstName__c        = 'Test',
            ccrz__HomePhone__c        = '(847) 555-1212',
            ccrz__LastName__c         = 'Class',
            ccrz__PostalCode__c       = '60601',
            ccrz__State__c            = 'Idaho',
            ccrz__StateISOCode__c     = 'ID',
            ccrz__CountryISOCode__c   = 'USA',
            SAP_Customer_Number__c = '1234',
            ccrz__ShippingComments__c = 'Safe'
        );
    }
    public static ccrz__E_Product__c createCassetteCanisterProduct(String SKU){
        ccrz__E_Product__c pd = new ccrz__E_Product__c();
        pd.Name = SKU;
        pd.ccrz__SKU__c = SKU;
        pd.ccrz__ProductId__c = SKU;
        pd.ccrz__Storefront__c = 'OmnicellB2BStore';
        pd.ccrz__Quantityperunit__c = 1;
        pd.ccrz__ProductStatus__c = 'Released';
        pd.ccrz__ProductType__c = 'Product';
        pd.ccrz__LeadTime__c = 1;
        pd.ccrz__UnitOfMeasure__c = 'EA';
        pd.ccrz__StartDate__c = System.today();
        pd.ccrz__EndDate__c = System.today()+90;
        pd.ccrz__ProductWeight__c = 100;
        pd.Minimum_Quantity__c = 10;
        List<ccrz__E_Product__c> pdlist = [Select Id,Name,ccrz__SKU__c,ccrz__ProductId__c,ccrz__Storefront__c,ccrz__Quantityperunit__c,
                                          ccrz__ProductStatus__c,ccrz__ProductType__c,ccrz__LeadTime__c,ccrz__UnitOfMeasure__c,
                                          ccrz__StartDate__c,ccrz__EndDate__c,ccrz__ProductWeight__c,Minimum_Quantity__c From ccrz__E_Product__c 
                                          Where ccrz__ProductId__c = :SKU Limit 1];
        if(pdlist.size()>0){
            return pdlist[0];
        }
        else{
            insert pd;
            return pd;
        }        
    }
    public static ccrz__E_Attribute__c parentccAttribute(String attributeID,Integer seq){
        ccrz__E_Attribute__c ccAtr = new ccrz__E_Attribute__c();
        ccAtr.ccrz__AttributeID__c = attributeID;
        ccAtr.ccrz__DisplayName__c = attributeID;
        ccAtr.Name = attributeID;
        ccAtr.ccrz__EffectiveStart__c = System.today();
        ccAtr.ccrz__EffectiveEnd__c = System.today()+90;
        ccAtr.ccrz__Sequence__c = seq;
        insert ccAtr;
        return ccAtr;
    }
    public static ccrz__E_Attribute__c childccAttribute(String attributeID,String pId,Integer seq){
        ccrz__E_Attribute__c ccAtr = new ccrz__E_Attribute__c();
        ccAtr.ccrz__AttributeID__c = attributeID;
        ccAtr.ccrz__DisplayName__c = attributeID;
        ccAtr.Name = attributeID;
        ccAtr.ccrz__EffectiveStart__c = System.today();
        ccAtr.ccrz__EffectiveEnd__c = System.today()+90;
        ccAtr.ccrz__Sequence__c = seq;
        ccAtr.ccrz__ParentAttribute__c = pId;
        insert ccAtr;
        return ccAtr;
    }
    public static String createMajorCartItems(ccrz__E_Cart__c carts,String prdId) {
        ccrz__E_CartItem__c majorItem = new ccrz__E_CartItem__c(ccrz__Cart__c = carts.Id,ccrz__cartItemType__c = 'Major',
                                                                ccrz__ProductType__c = 'Product',ccrz__UnitOfMeasure__c='EA',ccrz__StoreID__c='OmnicellB2BStore',
                                                                ccrz__PricingType__c='attrGroup');
        majorItem.ccrz__RequestDate__c = System.today();
        majorItem.ccrz__Price__c = 0;
        majorItem.ccrz__Quantity__c = 1;
        majorItem.ccrz__SubAmount__c = majorItem.ccrz__Quantity__c*majorItem.ccrz__Price__c;
        majorItem.ccrz__OriginalQuantity__c = majorItem.ccrz__Quantity__c;
        majorItem.ccrz__OriginalItemPrice__c = majorItem.ccrz__Price__c;
        majorItem.ccrz__Product__c = prdId;
        insert majorItem;
        return majorItem.Id;
    }
    public static ccrz__E_PriceList__c createListPriceList() {         
        ccrz__E_PriceList__c PriceList = new ccrz__E_PriceList__c();
        PriceList.Name = 'LIST PRICE';
        PriceList.ccrz__Enabled__c = True;
        PriceList.ccrz__Storefront__c = 'OmnicellB2BStore';
        PriceList.ccrz__StartDate__c = Date.today();
        PriceList.ccrz__EndDate__c = Date.today();
        PriceList.ccrz__PricelistId__c = 'LIST PRICE';
        List<ccrz__E_PriceList__c> listPrice = [Select id,Name,ccrz__Enabled__c,ccrz__Storefront__c,ccrz__StartDate__c,ccrz__EndDate__c,
                                               ccrz__PricelistId__c From ccrz__E_PriceList__c Where ccrz__PricelistId__c = 'LIST PRICE' Limit 1];
        if(listPrice.size()>0){
            return listPrice[0];
        }
        else{
            insert PriceList;
            return PriceList;
        }        
    }
    public static void createAccountGroupPriceList(ccrz__E_PriceList__c plist,ccrz__E_AccountGroup__c accGrp){
        ccrz__E_AccountGroupPriceList__c accGrpPL = new ccrz__E_AccountGroupPriceList__c();
        accGrpPL.ccrz__AccountGroup__c = accGrp.Id;
        accGrpPL.ccrz__AccountGroupPriceListID__c = accGrp.ccrz__AccountGroupID__c+'_'+plist.ccrz__PricelistId__c;
        accGrpPL.ccrz__Pricelist__c = plist.Id;
        accGrpPL.ccrz__EndDate__c = Date.parse('12/15/40');
        accGrpPL.ccrz__Enable__c = True;
        accGrpPL.ccrz__Sequence__c = 100;
        accGrpPL.ccrz__StartDate__c = Date.parse('04/26/21');
        insert accGrpPL;
    }
    public static DrugCode__c createDrugCode(String drgCode){
        DrugCode__c drg = new DrugCode__c();
        drg.DrugCodes__c = drgCode;
        drg.Brand_Name__c = 'Test';
        drg.Generic_Drug_Name__c = 'Test';
        drg.Drug_Forms__c = 'GAS-GA';
        drg.Dose_Unit__c = 'cell';
        drg.Drug_Strength__c = '10 mg';
        drg.Manufacturer_Name__c='Test';
        drg.Drug_Type__c = 'NDC';
        insert drg;
        return drg;
    }
    public static Machine__c createMachine(Account acc,String machineName,String machineType,String machineCat,String machineStyle){
        Machine__c mach = new Machine__c();
        mach.Machine_Name__c = machineName;
        mach.Machine_Type_Mapping__c = machineType;
        mach.Machine_Id__c = system.now().millisecond()+math.round(math.random()*10000);
        mach.New_Calibration_Allotment__c = 300;
        mach.Recalibration_Allotment__c = 100;
        mach.Recalibrations_Purchased__c = 50;
        mach.Purchased__c = 50;
        mach.Agreement_sign_date__c = System.today()-50;
        mach.Account_CSN__c = acc.Id;
        mach.Machine_Style__c = machineStyle;
        mach.Machine_Type_Category__c = machineCat;
        insert mach;
        return mach;
    }
    public static void createMinorOrderItems(Integer noOfOrderItems,ccrz__E_Order__c order,String parentItemId,String productId) {
        
        final List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c >();
        ccrz__E_OrderItem__c orderItem;
        for (Integer i = 0; i < noOfOrderItems; i++) {
            orderItem = new ccrz__E_OrderItem__c();
            orderItem.ccrz__Order__c =order.id;
            orderItem.ccrz__Price__c=100;
            orderItem.ccrz__Quantity__c=2;
            orderItem.ccrz__SubAmount__c=orderItem.ccrz__Price__c*orderItem.ccrz__Quantity__c; 
            orderItem.ccrz__OrderLineType__c='Major';  
            orderItem.ccrz__ParentOrderItem__c = parentItemId;
            orderItem.ccrz__Product__c = productId;
            testOrderItems.add(orderItem);
        }
        System.assertEquals(testOrderItems.size(), noOfOrderItems); 
        insert testOrderItems;
    }    
    public static List<ccrz__E_Cart__c> createCarts(Integer noOfCarts,Account testAccount,Contact cont,ccrz__E_ContactAddr__c contAddress) {
        
        final List<ccrz__E_Cart__c> testCarts = new List<ccrz__E_Cart__c>();        
        ccrz__E_Cart__c crt;
        for (Integer i = 0; i < noOfCarts; i++) {
            
            crt = new ccrz__E_Cart__c();
            crt.ccrz__Account__c         = testAccount.Id;
            //crt.ccrz__EffectiveAccountID__c = testAccount.Id;
            crt.ccrz__CartType__c        = 'Cart';
            crt.ccrz__CartStatus__c      = 'Open';
            //crt.ccrz__User__c            = testUser.Id;
            //crt.ccrz__Contact__c         = cont.Id;
            crt.ccrz__Name__c            = 'Test Cart';
            //crt.OwnerId                  = testUser.Id;
            crt.ccrz__AnonymousID__c     = false;                           
            crt.ccrz__ActiveCart__c      = true;
            crt.ccrz__SessionId__c       = 'testing';
            crt.ccrz__CurrencyISOCode__c = 'USD';
            crt.ccrz__Storefront__c      = STOREFRONT_NAME;
            crt.ccrz__EncryptedId__c     = 'encid' + String.valueOf(Crypto.getRandomInteger());//i
            if(contAddress!=null){
                crt.ccrz__BillTo__c          = contAddress.Id;
                crt.ccrz__ShipTo__c          = contAddress.Id; 
            }                         
            crt.ccrz__RequestDate__c     = Date.Today();
            
            
            testCarts.add(crt);
        }
        System.assertEquals(testCarts.size(), noOfCarts);    
        return testCarts;
    }    
    public static List<ccrz__E_CartItem__c> createCartItems(Integer noOfCartItems,ccrz__E_Cart__c carts) {
        
        final List<ccrz__E_CartItem__c> testCartItems = new List<ccrz__E_CartItem__c >();
        ccrz__E_CartItem__c cartItem;
        for (Integer i = 0; i < noOfCartItems; i++) {
            cartItem = new ccrz__E_CartItem__c();
            cartItem.ccrz__Cart__c =carts.id;
            cartItem.ccrz__Price__c=100;
            cartItem.ccrz__Quantity__c=2;
            cartItem.ccrz__SubAmount__c=200;
            cartItem.Discounted_Quantity__c=0;
            //cartItem.ccrz__CartLineType__c='Major';            
            
            testCartItems.add(cartItem);
        }
        System.assertEquals(testCartItems.size(), noOfCartItems); 
        return testCartItems;
    }
    public static List<ccrz__E_Order__c> createOrders(Integer noOfOrders,ccrz__E_Cart__c cart,Account testAccount,Contact cont,ccrz__E_ContactAddr__c contAddress) {
        
        final List<ccrz__E_Order__c> testOrders = new List<ccrz__E_Order__c>();
        ccrz__E_Order__c ord;
        for (Integer i = 0; i < noOfOrders; i++) {
            
            ord = new ccrz__E_Order__c();
            ord.ccrz__Account__c         = testAccount.Id;
            //ord.ccrz__Contact__c         = cont.Id;
            ord.ccrz__Name__c = 'Test Order';
            //ord.OwnerId                  = testUser.Id;
            ord.ccrz__OrderNumber__c     = i;
            ord.ccrz__OrderStatus__c ='Pending';
            ord.SHIP_COND__c  = 'Test';
            ord.ccrz__ShipAmount__c = 12.222;
            ord.ccrz__Storefront__c      = STOREFRONT_NAME;
            if(contAddress!=null){
                ord.ccrz__BillTo__c          = contAddress.Id;
                ord.ccrz__ShipTo__c          = contAddress.Id;
            }
            ord.ccrz__OrderDate__c       = Date.Today();
            //ccrz__User__c           = testUser.Id;
            
            ord.ccrz__OriginatedCart__c  = cart.Id;
            ord.ccrz__EncryptedId__c    = 'testEncryptedId'+ i.format();
            ord.ccrz__Note__c           = 'test class';
            ord.ccrz__ShipComplete__c   = false;
            ord.ccrz__ShipMethod__c     = 'test method';
            ord.ccrz__RequestDate__c    = system.today()+3;
            
            testOrders.add(ord);
        }
        System.assertEquals(testOrders.size(), noOfOrders); 
        return testOrders;
    }
    public static List<ccrz__E_OrderItem__c> createOrderItems(Integer noOfOrderItems,ccrz__E_Order__c orders) {
        
        final List<ccrz__E_OrderItem__c> testOrderItems = new List<ccrz__E_OrderItem__c >();
        ccrz__E_OrderItem__c orderItem;
        for (Integer i = 0; i < noOfOrderItems; i++) {
            orderItem = new ccrz__E_OrderItem__c();
            orderItem.ccrz__Order__c =orders.id;
            orderItem.ccrz__Price__c=100;
            orderItem.ccrz__Quantity__c=2;
            orderItem.ccrz__SubAmount__c=200; 
            orderItem.ccrz__OrderLineType__c='Major';            
            
            testOrderItems.add(orderItem);
        }
        System.assertEquals(testOrderItems.size(), noOfOrderItems); 
        return testOrderItems;
    }
    public static List<ccrz__E_Invoice__c> createInvoices(Integer noOfInvoices,Account testAccount,Contact cont,ccrz__E_ContactAddr__c contAddress) {
        
        final List<ccrz__E_Invoice__c> testInvoices = new List<ccrz__E_Invoice__c>();
        ccrz__E_Invoice__c inv;
        for (Integer i = 0; i < noOfInvoices; i++) {
            
            inv = new ccrz__E_Invoice__c();
            
            inv.ccrz__Contact__c         = cont.Id;
            //inv.ccrz__Name__c = 'Test Order';
            
            inv.CurrencyIsoCode = 'USD';
            inv.ccrz__OriginalAmount__c = 10.00;
            inv.ccrz__RemainingAmount__c = 10.00;
            inv.ccrz__Status__c = 'Open';
            inv.ccrz__Type__c = 'Debit';
            inv.ccrz__DateIssued__c = System.Today();
            inv.ccrz__Storefront__c      = STOREFRONT_NAME;
            if(testAccount!=null){
                inv.ccrz__BillTo__c      = testAccount.Id;
                inv.ccrz__SoldTo__c      = testAccount.Id;
            }
            if(contAddress!=null){
                inv.ccrz__SoldAddress__c   = contAddress.Id;
                inv.ccrz__BillAddress__c   = contAddress.Id;
            }
            
            
            testInvoices.add(inv);
        }
        System.assertEquals(testInvoices.size(), noOfInvoices); 
        return testInvoices;
    }
    public static void createCastIron(){
        CastIronIntegration__c csValue1 = new CastIronIntegration__c(Name = 'CastIronIntegration',ContactUpdateEndpoint__c='https://appconndatadev.omnicell.com/',ContactInsertEndpoint__c='https://appconndatadev.omnicell.com/ContactSFToCRM');
        insert csValue1;
    }
    public static void createIntDetails(){
        SCP_Integration_Details__c intValue = new SCP_Integration_Details__c(Name = 'SCP_Order_Submit',SCP_Method_Type__c='POST',SCP_Timeout__c=120.00,SCP_End_Point__c='http://sfdc-sap-prc-api.us-w1.cloudhub.io/api/orders/simulate');
        insert intValue ;
    } 
    public static void createIntDetails_Auth(){
        SCP_Integration_Details__c intValue = new SCP_Integration_Details__c(Name = 'SCP_Mulesoft_Authorization',SCP_Method_Type__c='POST',SCP_Timeout__c=120.00,SCP_End_Point__c='https://dev-sfdc-sap-prc-api.us-w1.cloudhub.io/token',SCP_Key_Client_Id__c='4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1',SCP_Password_Client_Secret__c='3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVT',SCP_Grant_Type__c='CLIENT_CREDENTIALS');
        insert intValue ;
    }    
    public static void createContact_Customsetting(){
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_ContactSFToCRM';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM';
        insert setting;
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        SCP_Integration_Details__c  setting2 = new SCP_Integration_Details__c ();
        setting2.Name = 'SCP_ContactSFToCRM_Update';
        setting2.SCP_Method_Type__c = 'POST';
        setting2.SCP_Timeout__c = 120000;
        setting2.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update';
        insert setting2;
    }    
    public static void createIntDetails_order_simulate(){
        SCP_Integration_Details__c intValue = new SCP_Integration_Details__c(Name = 'SCP_Order_Simulate',SCP_Method_Type__c='POST',SCP_Timeout__c=120.00,SCP_End_Point__c='http://sfdc-sap-prc-api.us-w1.cloudhub.io/api/orders/simulate');
        insert intValue ;    
    }    
    public static Void createTransactionPayment(){
        ccrz__E_TransactionPayment__c transactionPayment = new ccrz__E_TransactionPayment__c(ccrz__Storefront__c='ABC');
        insert transactionPayment;
    }
    public static SCP_Apex_Debug_Logs__c  createApexDebugLogs(boolean isInsert){
        SCP_Apex_Debug_Logs__c apexDebuglog = new SCP_Apex_Debug_Logs__c(SCP_Type__c = 'test error',SCP_Apex_Class__c   = 'Test Data Factory',SCP_Method__c = 'createApexDebugLogs',SCP_Record_Id__c = 'abc',SCP_Message__c = 'Just logged',SCP_Stack_Trace__c  = 'test stack',SCP_Response__c ='test response',SCP_Request__c = 'test request',SCP_Status_Code__c  = 'test status');
        if(isInsert)
            insert apexDebuglog;
        return apexDebuglog;
    }    //SCP-535
    public static List<ccrz__E_PriceList__c> createPriceList(Integer noOfPriceList) {
        
        List<ccrz__E_PriceList__c> priceLists = new List<ccrz__E_PriceList__c>();
        for( Integer i = 0 ; i < noOfPriceList; i++ ){                    
            ccrz__E_PriceList__c PriceList = new ccrz__E_PriceList__c();
            PriceList.Name = 'Test PriceList' + Math.random();
            PriceList.ccrz__Enabled__c = True;
            PriceList.ccrz__Storefront__c = 'OmnicellB2BStore';
            PriceList.ccrz__StartDate__c = Date.parse('04/26/21');
            PriceList.ccrz__EndDate__c = Date.parse('12/15/40');
            PriceLists.add(PriceList);
        }
        return priceLists;
    }
    public static List<ccrz__E_Product__c> createProducts(Integer noOfProducts) {
        
        List<ccrz__E_Product__c> products = new List<ccrz__E_Product__c>();
        for( Integer i = 0 ; i < noOfProducts ; i++ ){                    
            ccrz__E_Product__c product = new ccrz__E_Product__c();
            product.Name = 'Test Product' + Math.random();
            product.ccrz__SKU__c = 'RECUR' + Math.random();
            product.ccrz__StartDate__c = Date.parse('04/26/21');
            product.ccrz__EndDate__c = Date.parse('12/15/40');
            products.add( product);
        }
        return products;
    }
    public static List<ccrz__E_SubProdTerm__c> createSPT(ccrz__E_Product__c product, Integer noOfSPTS) {
        
        List<ccrz__E_SubProdTerm__c> spts = new List<ccrz__E_SubProdTerm__c>();
        for( Integer i = 0 ; i < noOfSPTS; i++ ){                    
            ccrz__E_SubProdTerm__c spt = new ccrz__E_SubProdTerm__c();
            spt.Name = 'Test spt' + Math.random();
            spt.ccrz__CCProduct__c = product.id;
            spt.ccrz__Enabled__c = True;
            spt.ccrz__EffectiveStart__c = Date.parse('04/26/21');
            spt.ccrz__EffectiveEnd__c = Date.parse('12/15/40');
            spts.add(spt);
        }
        return spts;
    }
    public static List<ccrz__E_PriceListItem__c> createPriceListItem(ccrz__E_Product__c product,ccrz__E_PriceList__c pricelist, ccrz__E_SubProdTerm__c spt, Integer noOfpricelistitems) {
        
        List<ccrz__E_PriceListItem__c> pricelistitems = new List<ccrz__E_PriceListItem__c>();
        for( Integer i = 0 ; i < noOfpricelistitems; i++ ){                    
            ccrz__E_PriceListItem__c pricelistitem = new ccrz__E_PriceListItem__c();
            pricelistitem.ccrz__Pricelist__c = pricelist.id;
            if(spt!=null)
                pricelistitem.ccrz__SubProdTerm__c = spt.id;
            pricelistitem.ccrz__Product__c = product.id;
            pricelistitem.ccrz__StartDate__c = Date.parse('04/26/21');
            pricelistitem.ccrz__EndDate__c = Date.parse('12/15/40');
            pricelistitems.add(pricelistitem);
        }
        return pricelistitems;
    }
    public static List<ccrz__E_PriceListItem__c> createPriceListItemwithTier(ccrz__E_Product__c product,ccrz__E_PriceList__c pricelist, ccrz__E_SubProdTerm__c spt, Integer noOfpricelistitems,String pTier) {
        
        List<ccrz__E_PriceListItem__c> pricelistitems = new List<ccrz__E_PriceListItem__c>();
        for( Integer i = 0 ; i < noOfpricelistitems; i++ ){                    
            ccrz__E_PriceListItem__c pricelistitem = new ccrz__E_PriceListItem__c();
            pricelistitem.ccrz__Pricelist__c = pricelist.id;
            pricelistitem.ccrz__SubProdTerm__c = spt.id;
            pricelistitem.ccrz__Product__c = product.id;
            pricelistitem.ccrz__ItemType__c = 'tiered';
            pricelistitem.ccrz__StartDate__c = Date.parse('04/26/21');
            pricelistitem.ccrz__EndDate__c = Date.parse('12/15/40');
            pricelistitem.ccrz__PricingTiers__c = pTier;
            pricelistitems.add(pricelistitem);
        }
        return pricelistitems;
    }
    public static ccrz__E_Coupon__c createValidCoupon(String productId, String couponCode){
        ccrz__E_Coupon__c coupon = new ccrz__E_Coupon__c();
        coupon.ccrz__CouponName__c = 'Test'+String.valueOf(Datetime.now());
        coupon.ccrz__StartDate__c = System.today();
        coupon.ccrz__EndDate__c = System.today()+90;
        coupon.Free_Shipping_Applied__c = false;
        coupon.ccrz__MaxUse__c = 1;
        coupon.ccrz__MinQty__c = 1;
        coupon.ccrz__Storefront__c = STOREFRONT_NAME;
        coupon.ccrz__TargetProduct__c = productId;
        coupon.ccrz__TargetQty__c = 10;
        coupon.ccrz__TotalUsed__c = 0;
        coupon.ccrz__CouponCode__c = couponCode;
        insert coupon;
        return coupon;
    }
    public static void createCartCoupon(ccrz__E_Coupon__c coupon, ccrz__E_Cart__c cart){
        ccrz__E_CartCoupon__c cartcoup = new ccrz__E_CartCoupon__c();    
        cartcoup.ccrz__Cart__c = cart.Id;
        cartcoup.ccrz__Coupon__c = coupon.Id;
        insert cartcoup;        
    }
    public static void createESpec(ccrz__E_Product__c product){
        List<ccrz__E_Spec__c> prodSpecList = new List<ccrz__E_Spec__c>();
        ccrz__E_Spec__c prodSpec = new ccrz__E_Spec__c();
        prodSpec.Name = 'Product Type';
        prodSpec.ccrz__SpecID__c = 'PRODUCT_TYPE';
        prodSpec.ccrz__Sequence__c = 2;
        insert prodSpec ;
        createProductSpec(prodSpec,product);
        ccrz__E_Spec__c prodSpec2 = new ccrz__E_Spec__c();
        prodSpec2.Name = 'Custom Stock';
        prodSpec2.ccrz__SpecID__c = 'CUSTOM_STOCK';
        prodSpec2.ccrz__Sequence__c = 3;
        insert prodSpec2;
        createProductSpec(prodSpec2,product);
        
    }
    public static void createProductSpec(ccrz__E_Spec__c productType, ccrz__E_Product__c product){
        ccrz__E_ProductSpec__c  prodSpec = new ccrz__E_ProductSpec__c ();
        prodSpec.ccrz__SpecValue__c = 'Heat Seal';
        prodSpec.ccrz__Spec__c = productType.Id;
        prodSpec.ccrz__Product__c = product.Id;
        insert prodSpec;
    }
    public static void fullProdDataSetup(){
        
        ccrz__E_AccountGroup__c accGrp = new ccrz__E_AccountGroup__c();
        accGrp.ccrz__AccountGroupID__c = 'IDN-BA/GPO-N0';
        accGrp.Name = 'IDN-BA/GPO-N0';
        accGrp.ccrz__PriceListSelectionMethod__c = 'Sequence Order';
        insert accGrp;
        
        ccrz__E_PriceList__c listPrice = createListPriceList();
        createAccountGroupPriceList(listPrice,accGrp);
        ccrz__E_Product__c Prod = createCassetteCanisterProduct('314-51');
        createESpec(Prod);
        ccrz__E_Coupon__c coupon = SCP_TestDataFactory.createValidCoupon(Prod.Id, 'TestF32');
        List<ccrz__E_PriceListItem__c> priceListItem = createPriceListItem(Prod,listPrice,null,1);
        insert priceListItem;
        
        Account account = new Account(name='Full Account Setup',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                      Account_Status__c = 'Active',IsDeleted__c = false,  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');
        account.SAP_Account_ID__c = '9500300123';
        account.Validation_Status__c = 'Validated';
        account.Facility_Type__c = 'Pharmacy';
        account.BILLINGSTREET = '41 Moss';
        account.BillingPostalCode = '77777';
        account.ccrz__E_AccountGroup__c = accGrp.Id;
        
        AccountTriggerHandler.TriggerDisabled = True;
        insert account;
        
        ccrz__E_Cart__c crt = new ccrz__E_Cart__c();
        crt.ccrz__Account__c         = account.Id;
        crt.ccrz__CartType__c        = 'Cart';
        crt.ccrz__CartStatus__c      = 'Open';
        crt.ccrz__Name__c            = 'Full Cart Setup';
        crt.ccrz__AnonymousID__c     = false;                           
        crt.ccrz__ActiveCart__c      = true;
        crt.ccrz__SessionId__c       = 'testing';
        crt.ccrz__CurrencyISOCode__c = 'USD';
        crt.ccrz__Storefront__c      = STOREFRONT_NAME;
        crt.ccrz__EncryptedId__c     = 'encid' + String.valueOf(Crypto.getRandomInteger());
        crt.ccrz__RequestDate__c     = Date.Today();
        insert crt;
        
        ccrz__E_CartItem__c cartItem = new ccrz__E_CartItem__c();
        cartItem = new ccrz__E_CartItem__c();
        cartItem.ccrz__Cart__c =crt.id;
        cartItem.ccrz__Price__c=100;
        cartItem.ccrz__Quantity__c=2;
        cartItem.ccrz__SubAmount__c=200;
        cartItem.Discounted_Quantity__c=0;
        cartItem.ccrz__Product__c = Prod.Id;
        cartItem.ccrz__Coupon__c = coupon.Id;
        insert cartItem;
        
        fullOrderDataSetup(account,crt);
    }    
    public static void fullOrderDataSetup(Account account, ccrz__E_Cart__c cart){
        List<ccrz__E_ContactAddr__c> aaAddressList = new List<ccrz__E_ContactAddr__c>();
        ccrz__E_ContactAddr__c shipTo = getContactAddress();
        shipTo.SAP_Customer_Number__c = account.SAP_Account_ID__c;
        aaAddressList.add(shipTo);
        ccrz__E_ContactAddr__c billTo = getContactAddress();
        billTo.SAP_Customer_Number__c = account.SAP_Account_ID__c;
        aaAddressList.add(billTo);
        insert aaAddressList;
        ccrz__E_Order__c ord = new ccrz__E_Order__c();
        ord.ccrz__Account__c         = account.Id;
        ord.ccrz__Name__c = 'Test Order';
        ord.ccrz__OrderNumber__c     = 1234320000;
        ord.SAP_Order_Number__c     = '1234320000';
        ord.SHIP_COND__c  = 'Test';
        ord.ccrz__ShipAmount__c = 12.222;
        ord.ccrz__Storefront__c      = STOREFRONT_NAME;
        ord.ccrz__BillTo__c          = shipTo.Id;
        ord.ccrz__ShipTo__c          = billTo.Id;
        ord.ccrz__OrderDate__c       = Date.Today();        
        ord.ccrz__OriginatedCart__c  = cart.Id;
        ord.ccrz__EncryptedId__c    = 'testEncryptedId';
        ord.ccrz__Note__c           = 'test class';
        ord.ccrz__ShipComplete__c   = false;
        ord.ccrz__ShipMethod__c     = 'test method';
        ord.ccrz__RequestDate__c    = system.today()+3;
        ord.ccrz__PaymentMethod__c = 'card';
        ord.ccrz__PONumber__c ='1234';
        insert ord;
        Test.setCreatedDate(ord.Id, DateTime.newInstance(2022,12,12));
        List<ccrz__E_OrderItem__c> orderItemList = new List<ccrz__E_OrderItem__c>();
        List<ccrz__E_CartItem__c> cartItemList = [Select Id,ccrz__Price__c,ccrz__SubAmount__c,ccrz__Quantity__c,ccrz__Coupon__c,
                                                  ccrz__OriginalQuantity__c,ccrz__OriginalItemPrice__c,ccrz__Product__c,ccrz__cartItemType__c,
                                                  ccrz__PricingType__c,ccrz__UnitOfMeasure__c,ccrz__StoreID__c,ccrz__RequestDate__c,
                                                  ccrz__ItemStatus__c
                                                  From ccrz__E_CartItem__c Where ccrz__Cart__c =:cart.Id];
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
            ot.ccrz__Order__c = ord.Id;
            ot.ccrz__Coupon__c = ct.ccrz__Coupon__c;
            orderItemList.add(ot);
        }
        insert orderItemList;
        System.debug('****'+orderItemList[0].Material__c);
        
    }
    public static ccrz__E_Cart__c createActiveCart(Account testAccount,Contact cont,ccrz__E_ContactAddr__c contAddress) {        
        ccrz__E_Cart__c crt = new ccrz__E_Cart__c();
        crt.ccrz__Account__c         = testAccount.Id;
        crt.ccrz__EffectiveAccountID__c = testAccount.Id;
        crt.ccrz__CartType__c        = 'Cart';
        crt.ccrz__CartStatus__c      = 'Open';
        crt.ccrz__Name__c            = 'Test Cart';
        crt.ccrz__AnonymousID__c     = false;                           
        crt.ccrz__ActiveCart__c      = true;
        crt.ccrz__SessionId__c       = 'testing';
        crt.ccrz__CurrencyISOCode__c = 'USD';
        crt.ccrz__Storefront__c      = STOREFRONT_NAME;
        crt.ccrz__EncryptedId__c     = 'encid' + String.valueOf(Crypto.getRandomInteger());//i
        if(contAddress!=null){
            crt.ccrz__BillTo__c          = contAddress.Id;
            crt.ccrz__ShipTo__c          = contAddress.Id; 
        }                         
        crt.ccrz__RequestDate__c     = Date.Today();   
        return crt;
    }  
}