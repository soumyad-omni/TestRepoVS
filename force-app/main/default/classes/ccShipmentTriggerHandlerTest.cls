@istest
public class ccShipmentTriggerHandlerTest {
    
    @testsetup
    public static void ccShipmentTriggerHandlerTest_Setup(){
        
        
    	accounttriggerhandler.triggerdisabled = true;
        SCP_TestDataFactory.createCastIron();
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM');
		insert obj;
        SCP_Integration_Details__c obj1 = new SCP_Integration_Details__c(Name = 'SCP_ContactSFToCRM_Update', SCP_End_Point__c = 'http://uat-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update');
		insert obj1;
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c(Name = 'SCP_Mulesoft_Authorization', SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token',SCP_Key_Client_Id__c='ooooiiii',SCP_Method_Type__c='POST',SCP_Password_Client_Secret__c='xxxxxxxbbbbbbbbbxx',SCP_Grant_Type__c='CLIENT_CREDENTIALS');
		insert obj2;
        
        
        
      
    }
    
    @istest
    public static void test1(){
        usertriggerhandler.triggerdisabled = true;
        Profile pf= [Select Id from profile where Name='API only']; 
        UserRole ur = [Select Id from UserRole where Name='US & CA'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'Manager', 
                         lastName = 'XYZ', 
                         IsActive = true,
                         UserPermissionsInteractionUser =true,
                         UserPermissionsMarketingUser = true,
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23),
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         ProfileId = pf.Id); 
        insert uu;
        
        System.runAs(uu) {
        
        Test.startTest();
        accounttriggerhandler.triggerdisabled = true;
        Account accounts = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                            Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                            Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                            BillingCountryCode = 'US',BillingStateCode  = 'IL',
                                            Account_Status__c = 'Active',IsDeleted__c = false,  
                                            Transport_Zone__c='US00000001',Partner_Type__c= '0015');
            accounts.SAP_Account_ID__c = '1234';
            accounts.Validation_Status__c = 'Validated';
            accounts.Facility_Type__c = 'Pharmacy';
            accounts.BILLINGSTREET = '41 Moss';
            accounts.BillingPostalCode = '77777';
                insert accounts;
            
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        insert acc;
        
        Contact con = SCP_TestDataFactory.createContacts(acc.id,1)[0];
        insert con;
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;

        ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc, con, contAdd)[0];
        insert ec;

        List <ccrz__E_Order__c> eod = createOrders(1,ec, acc, con,contAdd);
        insert  eod;
        
        List<ccrz__E_OrderItem__c> eoditem = SCP_TestDataFactory.createOrderItems(1,eod[0]);
        insert eoditem;
        
        eod[0].SAP_Order_Number__c='test123';
        update eod;
		
        ccrz__E_OrderShipment__c ship = new ccrz__E_OrderShipment__c();
        ship.ccrz__ShipmentDate__c = system.today() ;
        ship.ccrz__Order__c = eod[0].id ;
        insert ship;
        
        ccrz__E_TransactionPayment__c tp = new ccrz__E_TransactionPayment__c();
		tp.ccrz__AccountNumber__c = 'TESTING PO NUMBER';
        insert tp;
         
        ccrz__E_OrderShipmentItem__c shipitem = new ccrz__E_OrderShipmentItem__c();
        shipitem.ccrz__OrderShipment__c = ship.id;
        shipitem.ccrz__Quantity__c =1;
        shipitem.ccrz__SKU__c= '136386';
        shipitem.ccrz__OrderShipmentItemId__c = 'abcd_'+eoditem[0].name;
        insert shipitem;
            
        
        Test.stopTest();
        }
    }
    
    public static List<ccrz__E_Order__c> createOrders(Integer noOfOrders,ccrz__E_Cart__c cart,Account testAccount,Contact cont,ccrz__E_ContactAddr__c contAddress) {
    
        List<ccrz__E_Order__c> testOrders = new List<ccrz__E_Order__c>();
        ccrz__E_Order__c ord;
        for (Integer i = 0; i < noOfOrders; i++) {
            
            ord = new ccrz__E_Order__c();
            ord.ccrz__Account__c         = testAccount.Id;
            ord.ccrz__Name__c = 'Test Order';
            ord.ccrz__OrderNumber__c     = i;
            ord.ccrz__OrderStatus__c ='Pending';
            ord.SHIP_COND__c  = 'Test';
            ord.ccrz__ShipAmount__c = 12.222;
            ord.ccrz__Storefront__c      = 'OmnicellB2BStore';
            if(contAddress!=null){
                ord.ccrz__BillTo__c          = contAddress.Id;
                ord.ccrz__ShipTo__c          = contAddress.Id;
                ord.SAP_Shipping_Customer_Number__c = '1234';
                ord.SAP_Billing_Customer_Number__c = '1234';
            }
            ord.ccrz__OrderDate__c       = Date.Today();
            ord.ccrz__Contact__c = cont.id;
            //ord.ccrz__OriginatedCart__c  = cart.Id;
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

}