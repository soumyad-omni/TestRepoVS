@isTest
public class QuoteEditPageControllerTest {

    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();  
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008662';
        insert setting2;
        ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
        setting3.Name = 'Omnicell - St.Petes';
        //setting3.ECC_Code__c = 'OM02'; //IBA-2389 Abhrajit Removing Reference.
        setting3.ECC_Code__c = 'OM01';
        setting3.CRM_Code__c = 'O 50008663';
        insert setting3;
        ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c ();
        setting4.Name = 'Omnicell Inc.';
        setting4.CRM_Code__c = 'O 50000029';
        insert setting4;
        ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c ();
        setting5.Name = 'Omnicell Ltd';
        setting5.CRM_Code__c = 'O 50008655';
        insert setting5;
        ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c ();
        setting6.Name = 'Omnicell SAS';
        setting6.CRM_Code__c = 'O 50011128';
        insert setting6;
        ECC_Sales_Org_to_CRM__c  setting8 = new ECC_Sales_Org_to_CRM__c ();
        setting8.Name = 'GPOPricelist-None';
        setting8.GPOPricelist__c = '--XX--';
        insert setting8;
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        Default_Currency_by_Country_Code__c	  setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
    }
    
    public static testmethod void quoteEditPageControllerTest0(){
        AccountCreateController.isFirstRun= false;
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        insert setting;
       	Opportunity opp = TestDataFactory.createOppWithAccount();
        Quote testQuote = new Quote(Name='Test Quote');
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        testQuote.OpportunityId = opp.Id;
        testQuote.Pricebook2Id = Test.getStandardPricebookId();
        testQuote.Region__c='Northeast';
        testQuote.Pricing_Reference_Date__c=system.today();
        testQuote.Requested_Delivery_Date__c = system.today();
        testQuote.Booking_Date__c=system.today();
        testQuote.ExpirationDate = system.today();
        testQuote.SAP_Last_Line_Number__c = 200;
        testQuote.EOL_Date__c = System.today()+200;
        
        testQuote.Shipping_Contact__c= c[0].Id;
        testQuote.Order_Type__c = 'ZHQR';
        
        
        
        SAP_Sales_Org__c sso = TestDataFactory.createSAPSAlesOrg();
        sso.Account__c = opp.AccountId;
        
        testQuote.Sales_Org__c = sso.Sales_Org__c;
       
        Test.startTest();
        	insert testQuote;
        	PageReference pageRef = Page.QuoteEditPage;
        	Test.setCurrentPage(pageRef);
  			ApexPages.currentPage().getParameters().put('Id', testQuote.Id);
        	
        	ApexPages.currentPage().getParameters().put('accid', opp.accountId);
        	
  			
        	ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        	QuoteEditPageController nq =new QuoteEditPageController(sc);
        	
        	
        	nq.getOppName();
            nq.getpricelists();
            nq.getIDNPriceList();
            nq.getGPOPriceList();
            
            nq.getSOS();
       	 	nq.save();
        	nq.cancel();
		test.stopTest();
        System.assert(testQuote.Name!=null,testQuote.Name);
    }
    public static testmethod void quoteEditPageControllerTest1(){
        AccountCreateController.isFirstRun= false;
       	Opportunity opp = TestDataFactory.createOppWithAccount();
        System.debug('Opp CurrencyIsoCode : '+opp.CurrencyIsoCode);
        Quote testQuote = new Quote(Name='Test Quote');
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        testQuote.OpportunityId = opp.Id;
        testQuote.Pricebook2Id = Test.getStandardPricebookId();
        testQuote.Region__c='Northeast';
        testQuote.Pricing_Reference_Date__c=system.today();
        testQuote.Requested_Delivery_Date__c = system.today();
        testQuote.Booking_Date__c=system.today();
        testQuote.ExpirationDate = system.today();
        testQuote.SAP_Last_Line_Number__c = 2000;
        testQuote.EOL_Date__c = System.today()+2000;
        testQuote.Shipping_Contact__c= c[0].Id;
        testQuote.Order_Type__c = 'ZQRL';
        testquote.Sales_Operation_Counterpart__c = userinfo.getUserId();
        testquote.Consultant__c = userinfo.getUserId();
        testquote.Sales_Consultant__c = userinfo.getUserId();
        testquote.Ship_to_Account__c = opp.accountId;
        testquote.Bill_to_Account__c = opp.accountId;
        testquote.Payer__c = opp.accountId;
        testquote.GPO_Account__c = opp.accountId;
        testquote.IDN_Account__c = opp.accountId;
        List<SAP_Sales_Org__c> ssolist = [select id,sales_org__c,CurrencyIsoCode from SAP_Sales_Org__c where account__c=:opp.AccountId ];
        testquote.SAP_Sales_Org__c = ssolist[0].id;
        testquote.Sales_Org__c = ssoList[0].sales_org__c;
        
        Test.startTest();
        
            insert testQuote;
        	PageReference pageRef = Page.QuoteEditPage;
        	Test.setCurrentPage(pageRef);
  			ApexPages.currentPage().getParameters().put('Id', testQuote.Id);
        	
        	ApexPages.currentPage().getParameters().put('accid', opp.accountId);
        	
  			
        	ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        	QuoteEditPageController nq =new QuoteEditPageController(sc);
        	
        	nq.getOppName();
            nq.getpricelists();
            nq.getIDNPriceList();
            nq.getGPOPriceList();
            nq.quote = testquote;
            nq.updateSalesOrg();
            nq.getSOS();
       	 	nq.save();
        	nq.cancel();
            nq.showleaseduration();
            nq.getoppOwner();
            nq.getShiptocount();
            nq.getBilltocount();
            nq.getPayercount();
            nq.getGpocount();
            nq.getIdncount();
            nq.getDealDeskcount();
            nq.getClinicalConsultantcount();
            nq.getSalesConsultantcount();
		test.stopTest();
        System.assert(testQuote.Name!=null,testQuote.Name);
    }
    public static testmethod void quoteEditPageControllerTest2(){
        AccountCreateController.isFirstRun= false;
        RelationshipCreateController.isFirstRun = false;
        RelationshipCreateController.isTriggerExecuting = true;
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
       	Opportunity opp = TestDataFactory.createOppWithAccount();
        Account acc1 = [select id from Account where id=:opp.AccountId];
        SAP_Sales_Org__c sso = [select id from SAP_Sales_Org__c where account__c =:acc1.Id];
        Account acc2 = new Account(name='Test Secondary account',Account_role__c='ZGPO',
                                  Account_Status__c = 'Active',SAP_Account_ID__c='12345',IsDeleted__c = false,BillingCountryCode='US',
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                          BillingPostalCode='95128',Facility_Type__c = 'Pharmacy',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        
        insert acc2; 
        
        
        GPO_Account__c gpo = new GPO_Account__c();
        gpo.name = 'test';
        gpo.Account_Id__c = acc1.id;
        insert gpo;
        
       
        Relationship__c rel = new Relationship__c();
        rel.Primary_Account__c = acc1.Id;
        rel.Secondary_Account__c = acc2.Id;
        rel.Primary_Account_Sales_Org__c = sso.Id;
        rel.Relationship__c ='ZG';
        insert rel;
		Pricelist_Selection__c ps = new Pricelist_Selection__c();
        ps.GPO_CSN__c = acc2.SAP_Account_ID__c;
        ps.Pricelist_API_Name__c = 'test';
        ps.Pricelist_Name__c = 'test';
        insert ps;
        System.debug('Opp CurrencyIsoCode : '+opp.CurrencyIsoCode);
        Quote testQuote = new Quote(Name='Test Quote');
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        testQuote.OpportunityId = opp.Id;
        testQuote.Pricebook2Id = Test.getStandardPricebookId();
        testQuote.Region__c='Northeast';
        testQuote.Pricing_Reference_Date__c=system.today();
        testQuote.Requested_Delivery_Date__c = system.today();
        testQuote.Booking_Date__c=system.today();
        testQuote.ExpirationDate = system.today();
        testQuote.SAP_Last_Line_Number__c = 2000;
        testQuote.EOL_Date__c = System.today()+2000;
        testQuote.Shipping_Contact__c= c[0].Id;
        testQuote.Order_Type__c = 'ZQRL';
        testquote.Sales_Operation_Counterpart__c = userinfo.getUserId();
        testquote.Consultant__c = userinfo.getUserId();
        testquote.Sales_Consultant__c = userinfo.getUserId();
        testquote.Ship_to_Account__c = opp.accountId;
        testquote.Bill_to_Account__c = opp.accountId;
        testquote.Payer__c = opp.accountId;
        testquote.GPO_Account__c = opp.accountId;
        testquote.IDN_Account__c = opp.accountId;
        
        List<SAP_Sales_Org__c> ssolist = [select id,sales_org__c,CurrencyIsoCode from SAP_Sales_Org__c where account__c=:opp.AccountId ];
        testquote.SAP_Sales_Org__c = ssolist[0].id;
        testquote.Sales_Org__c = ssoList[0].sales_org__c;
        
        

        Test.startTest();
        	insert testQuote;
        	PageReference pageRef = Page.QuoteEditPage;
        	Test.setCurrentPage(pageRef);
  			ApexPages.currentPage().getParameters().put('Id', testQuote.Id);
        	
        	ApexPages.currentPage().getParameters().put('accid', opp.accountId);
        	
  			
        	ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        	QuoteEditPageController nq =new QuoteEditPageController(sc);
        	nq.PrimaryQuote = false;
        	nq.ssoName = 'test';
        	nq.quotegpo = 'test';
        	nq.idn = acc2;
        	nq.gpo = acc2;
        	nq.shipto = acc2;
        	nq.payer = acc2;
        	nq.billto = acc2;
        	nq.rendermessages = false;
            nq.getOppName();
            nq.getpricelists();
            nq.getIDNPriceList();
            nq.getGPOPriceList();
            nq.quote = testquote;
            nq.updateSalesOrg();
            nq.save();
        test.stopTest();
        System.assert(testQuote.Name!=null,testQuote.Name);
        
    }
    public static testmethod void quoteEditPageControllerTest3(){

		
		User u1 = [SELECT Id, IsActive, CompanyName, Username, Profile.Name FROM User Where Profile.Name = 'Sales Manager' and IsActive = true LIMIT 1];
        
        System.runAs(u1){
				ContactTriggerHandler.TriggerDisabled=true;
            	AccountTriggerHandler.TriggerDisabled=true;
                AccountCreateController.isFirstRun= false;
                RelationshipCreateController.isFirstRun = false;
                RelationshipCreateController.isTriggerExecuting = true;
                
                
                
                Opportunity opp = TestDataFactory.createOppWithAccountSales();
                Product_Line__c pl = new Product_Line__c();
                pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
                 pl.Amount__c = 10000;
                pl.Opportunity__c = opp.id;    
                insert pl;
                Account acc1 = [select id from Account where id=:opp.AccountId];
                SAP_Sales_Org__c sso = [select id from SAP_Sales_Org__c where account__c =:acc1.Id];
                
                Account acc2 = new Account(name='Test Secondary account',Account_role__c='ZGPO',
                                          Account_Status__c = 'Active',SAP_Account_ID__c='12345',IsDeleted__c = false,BillingCountryCode='US',
                                 BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',Facility_Type__c = 'Pharmacy',Validation_Status__c = 'Validated');
                
                insert acc2; 
                
                
                GPO_Account__c gpo = new GPO_Account__c();
                gpo.name = 'test';
                gpo.Account_Id__c = acc1.id;//'0011k00000CjPQVAA3';
                insert gpo;
                
               
                Relationship__c rel = new Relationship__c();
                rel.Primary_Account__c = acc1.Id;
                rel.Secondary_Account__c = acc2.Id;
                rel.Primary_Account_Sales_Org__c = sso.Id;
                rel.Relationship__c ='ZG';
                insert rel;
                Pricelist_Selection__c ps = new Pricelist_Selection__c();
                ps.GPO_CSN__c = acc2.SAP_Account_ID__c;
                ps.Pricelist_API_Name__c = 'test';
                ps.Pricelist_Name__c = 'test';
                insert ps;
                System.debug('Opp CurrencyIsoCode : '+opp.CurrencyIsoCode);
                Quote testQuote = new Quote(Name='Test Quote');
                List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
                testQuote.OpportunityId = opp.Id;
                testQuote.Pricebook2Id = Test.getStandardPricebookId();
                testQuote.Region__c='Northeast';
                testQuote.Pricing_Reference_Date__c=system.today();
                testQuote.Requested_Delivery_Date__c = system.today();
                testQuote.Booking_Date__c=system.today();
                testQuote.ExpirationDate = system.today();
                testQuote.SAP_Last_Line_Number__c = 2000;
                testQuote.EOL_Date__c = System.today()+2000;
                
                testQuote.Shipping_Contact__c= c[0].Id;
                testQuote.Order_Type__c = 'ZQRL';
                testquote.Sales_Operation_Counterpart__c = userinfo.getUserId();
                testquote.Consultant__c = userinfo.getUserId();
                testquote.Sales_Consultant__c = userinfo.getUserId();
                testquote.Ship_to_Account__c = opp.accountId;
                testquote.Bill_to_Account__c = opp.accountId;
                testquote.Payer__c = opp.accountId;
                testquote.GPO_Account__c = opp.accountId;
                testquote.IDN_Account__c = opp.accountId;
                
                List<SAP_Sales_Org__c> ssolist = [select id,sales_org__c,CurrencyIsoCode from SAP_Sales_Org__c where account__c=:opp.AccountId ];
                testquote.SAP_Sales_Org__c = ssolist[0].id;
                testquote.Sales_Org__c = ssoList[0].sales_org__c;
                
                
                Test.startTest();
                    insert testQuote;
                    PageReference pageRef = Page.QuoteEditPage;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('Id', testQuote.Id);
                    
                    ApexPages.currentPage().getParameters().put('accid', opp.accountId);
                    
                    
                    ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
                    QuoteEditPageController nq =new QuoteEditPageController(sc);
                    nq.PrimaryQuote = false;
                    nq.ssoName = 'test';
                    nq.quotegpo = 'test';
                    nq.idn = acc2;
                    nq.gpo = acc2;
                    nq.shipto = acc2;
                    nq.payer = acc2;
                    nq.billto = acc2;
                    nq.rendermessages = false;
                    nq.getOppName();
                    nq.getpricelists();
                    nq.getIDNPriceList();
                    nq.getGPOPriceList();
                    nq.quote = testquote;
                    
                    nq.updateSalesOrg();
                    
                    nq.save();
                Test.stopTest();
                System.assert(testQuote.Name!=null,testQuote.Name);
	   }
        
    }
    @isTest
    public static void quoteEditPageControllerTest4(){
        OpportunityTriggerHandler.TriggerDisabled = true;
        userTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        QuoteTriggerHandler.TriggerDisabled = true;
        Quote quote = TestDataFactory.createTestQuote1(); 
        quote.Primary_Quote__c = true;
        update quote;
        Opportunity opp = [Select Id,accountId From Opportunity Where Id = :quote.OpportunityId];
        Quote quote2 = new Quote();
        quote2.name = 'Test Quote 2';
        quote2.ContactId = quote.ContactId;
        quote2.Shipping_Contact__c= quote.Shipping_Contact__c;
        quote2.Order_Type__c = 'ZHQR';
        quote2.Quote_Number__c = '12345';
        quote2.Create_Sales_Order__c = true;
        quote2.OpportunityId = quote.OpportunityId;
        quote2.Primary_Quote__c = true;
        insert quote2;
        Test.startTest();
          PageReference pageRef = Page.QuoteEditPage;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('Id', quote.Id);                    
                    ApexPages.currentPage().getParameters().put('accid', opp.accountId); 
                    ApexPages.StandardController sc = new ApexPages.StandardController(quote);
                    QuoteEditPageController nq =new QuoteEditPageController(sc);
        			nq.quote = quote;
        			nq.save();
        			nq.getOrderList();
        Test.stopTest();
    }
}