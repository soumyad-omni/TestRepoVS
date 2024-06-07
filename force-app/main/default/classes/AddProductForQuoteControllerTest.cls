@isTest
public class AddProductForQuoteControllerTest 
{
    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008654';
        insert setting2;
        ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
        setting3.Name = 'Omnicell - St.Petes';
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
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
    } 
    
    @isTest()
    public static void testAddProduct(){
        
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        quotetriggerhandler.triggerdisabled =true;
        ContactTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        List<Product2> prdList = new List<Product2>();
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT',Product_Type__c='Option');
        prdList.add(prod);
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',
                                      ProductCode = 'LEASE BUYOUT MED',Product_Type__c='Std Config Omnicell Install', 
                                      DW_Product_Line__c = 'Automated Dispensing Cabinets',
                                      DW_Product_Type__c = 'Frame');
        prdList.add(prod2);

		Test.startTest();        
        insert prdList;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = TestDataFactory.createTestQuote_Integration1().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Product__c = prdList[0].Id;
        
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        ql2.Product__c = prdList[1].Id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        ql2.Add_to_cart__c = true;
        ql2.Interim_flag__c = true;
        ql2.Par_Location__c = 'par 1';
        
        
        
        
        
        quotetriggerhandler.TriggerDisabled=true;
        opportunitytriggerhandler.TriggerDisabled = true;
        accounttriggerhandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Test Quote2';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration1().Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        Opportunity opp = TestDataFactory.createOppWithAccount();	
        
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
		con.AccountId = opp.AccountId;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        
        quote.Shipping_Contact__c= [SELECT Id FROM Contact LIMIT 1][0].Id;
        quote.Order_Type__c = 'ZHQR';
        
        ProductLineTriggerHandler.TriggerDisabled = true;
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        
        quote.OpportunityId = opp.Id;
        insert quote;
        
        quote.Quote_Number__c = '12345';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql2);
        qlList.add(ql);
        insert qlList;
        Quote_Line__c newQl = new Quote_Line__c(Quote__c = quote.Id,
                                                Product__c = prdList[1].Id,
                                                Add_to_cart__c= true,
                                                SAP_Line_Number__c = 700,
                                                SAP_Line_Item_GUID__c = '702',
                                                Higher_Level_Item__c = 0,
                                                Part_of_a_Bundle__c = false,
                                                Customer_Price__c = 50
                                                
                                               );
      //  insert newQl;
        
        Catalog_GPO_Price__c cgp = new Catalog_GPO_Price__c(Distribution_Channel__c='',GPO_Price__c=100,Product__c=prdList[1].Id);
        insert cgp;
        Catalog_IDN_Price__c cip = new Catalog_IDN_Price__c(Distribution_Channel__c='',IDN_Price__c=100,Products__c=prdList[1].Id);
        insert cip;
        Catalog_USA_Price__c cup = new Catalog_USA_Price__c(Distribution_Channel__c='',USA_List_price__c=100,Product__c =prod2.Id);
        insert cup;
        
        
        
        AddProductForQuoteController.getShipToPicklist(ql2.Quote__c);
        AddProductForQuoteController.getProductInfo(ql2.Quote__c);
        AddProductForQuoteController.searchProducts(ql2.Quote__c, 'LEASE');
        AddProductForQuoteController.QuoteLineWrapperClass wrapResult = AddProductForQuoteController.getQuoteLinesCtrl(ql2.Quote__c);
        AddProductForQuoteController.getQuoteLinesCtrls(ql2.Quote__c);
        AddProductForQuoteController.getParLocationCtrl(ql2.Quote__c);
        AddProductForQuoteController.getProductPicklistCtrl(ql2.Quote__c);
        AddProductForQuoteController.getQuoteLinesCtrlPar(ql2.Quote__c, 'Par 1');
        AddProductForQuoteController.getQuoteLinesCtrlProd(ql2.Quote__c, 'Product');
        AddProductForQuoteController.getQuoteDetails(ql2.Quote__c);
        
        for(AddProductForQuoteController.QuoteLineWrapper qlWrap : wrapResult.lstQuoteLine){
            qlWrap.isSelectedQuote = true;
        }
        
        AddProductForQuoteController.updateQuoteLinesCtrl(ql2.Quote__c, JSON.serialize(wrapResult));        
        AddProductForQuoteController.copyQuoteLines(ql2.Quote__c, quote.Id);
        AddProductForQuoteController.createQuoteLinesLookup(prod2.Id, ql2.Quote__c, 'par Name');
        
        QuoteParMap__c newParMap = new QuoteParMap__c(Quote__c=ql2.Quote__c, Par__c=ql2.Par_Location__c);
        insert newParMap;
        
        AddProductForQuoteController.createQuoteLinesForAllParA(qlList, ql2.Quote__c);
        AddProductForQuoteController.createQuoteLinesA(qlList, ql2.Quote__c, 'par Name');
        AddProductForQuoteController.checkErrorMesssage(qlList,ql2.Quote__c);
        AddProductForQuoteController.pullImageDetails(qlList,ql2.Quote__c);
        AddProductForQuoteController.previewImageError(qlList,ql2.Quote__c);
        
        AddProductForQuoteController.createQuoteLineRecord(ql2.Quote__c, prod2.Id, 2, 'par Name');
        AddProductForQuoteController.createQuoteLinesA(qlList, ql2.Quote__c, 'Par 1');
        AddProductForQuoteController.createFreightLineRecord(ql2.Quote__c);
        //AddProductForQuoteController.createQuoteLine(quoteIds[0], productId, 1.0, 'Par 1');
        
        AddProductForQuoteController.getAssetsInfo(ql2.Quote__c);
        qlList[0].Id = null;
        AddProductForQuoteController.createQLineForc4c(new list<Quote_Line__c>{qlList[0]});
        AddProductForQuoteController.deleteQuoteLinesCtrl(ql2.Quote__c, JSON.serialize(wrapResult));
        //AddProductForQuoteController.validateQuoteSync(ql2.Quote__c);
        AddProductForQuoteController.createQuoteLine(ql2.Quote__c,prod2.ProductCode, '2');
        Test.stopTest();
    }    
    
    @isTest()
    public static void testAddProductTest(){
        quotetriggerhandler.TriggerDisabled=true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        List<Product2> prdList = new List<Product2>();
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT',Product_Type__c='Option');
        prdList.add(prod);
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',
                                      ProductCode = 'LEASE BUYOUT MED',Product_Type__c='Std Config Omnicell Install', 
                                      DW_Product_Line__c = 'Automated Dispensing Cabinets',
                                      DW_Product_Type__c = 'Frame');
        prdList.add(prod2);
        
        insert prdList;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = TestDataFactory.createTestQuote_Integration1().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Product__c = prdList[0].Id;
        
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        ql2.Product__c = prdList[1].Id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        ql2.Add_to_cart__c = true;
        ql2.Interim_flag__c = true;
        ql2.Par_Location__c = 'par 1';
        
        
        Test.startTest();
        
        
        
        Quote quote = new Quote();
        quote.name = 'Test Quote2';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration1().Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        Opportunity opp = TestDataFactory.createOppWithAccount();	
        
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
		con.AccountId = opp.AccountId;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        quote.Shipping_Contact__c= [SELECT Id FROM Contact LIMIT 1][0].Id;
        quote.Order_Type__c = 'ZHQR';
        	
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        
        quote.OpportunityId = opp.Id;
        insert quote;
        
        quote.Quote_Number__c = '12345';
        quote.Create_Sales_Order__c = true;        
        update quote;
        ql.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql2);
        qlList.add(ql);
        insert qlList;        
        Catalog_GPO_Price__c cgp = new Catalog_GPO_Price__c(Distribution_Channel__c='',GPO_Price__c=100,Product__c=prdList[1].Id);
        insert cgp;
        Catalog_IDN_Price__c cip = new Catalog_IDN_Price__c(Distribution_Channel__c='',IDN_Price__c=100,Products__c=prdList[1].Id);
        insert cip;
        Catalog_USA_Price__c cup = new Catalog_USA_Price__c(Distribution_Channel__c='',USA_List_price__c=100,Product__c =prod2.Id);
        insert cup;
        
        AddProductForQuoteController.QuoteLineWrapperClass wrapResult = AddProductForQuoteController.getQuoteLinesCtrl(ql2.Quote__c);
        
        for(AddProductForQuoteController.QuoteLineWrapper qlWrap : wrapResult.lstQuoteLine){
            qlWrap.isSelectedQuote = true;
        }
                
        AddProductForQuoteController.createQuoteLinesForAllParA(qlList, ql2.Quote__c);
        AddProductForQuoteController.createQuoteLinesA(qlList, ql2.Quote__c, 'par Name');
        AddProductForQuoteController.checkErrorMesssage(qlList,ql2.Quote__c);
        
        AddProductForQuoteController.createQuoteLineRecord(ql2.Quote__c, prod2.Id, 2, 'par Name');
        AddProductForQuoteController.createQuoteLinesA(qlList, ql2.Quote__c, 'Par 1');
        Test.stopTest();
    }
        
    @isTest()
    public static void testAddProductTest3(){
        
        quotetriggerhandler.TriggerDisabled=true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        
        
        List<Product2> prdList = new List<Product2>();
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT',Product_Type__c='Option');
        prdList.add(prod);
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',
                                      ProductCode = 'LEASE BUYOUT MED',Product_Type__c='Std Config Omnicell Install', 
                                      DW_Product_Line__c = 'Automated Dispensing Cabinets',
                                      DW_Product_Type__c = 'Frame');
        prdList.add(prod2);
        
        insert prdList;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = TestDataFactory.createTestQuote_Integration1().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Product__c = prdList[0].Id;
        
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        //ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        ql2.Product__c = prdList[1].Id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        ql2.Add_to_cart__c = true;
        ql2.Interim_flag__c = true;
        ql2.Par_Location__c = 'par 1';
        
        
        Test.startTest();
        
        
        
        Quote quote = new Quote();
        quote.name = 'Test Quote2';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration1().Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        Opportunity opp = TestDataFactory.createOppWithAccount();	
        
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
		con.AccountId = opp.AccountId;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        quote.Shipping_Contact__c= [SELECT Id FROM Contact LIMIT 1][0].Id;
        quote.Order_Type__c = 'ZHQR';
        	
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        
        quote.OpportunityId = opp.Id;
        insert quote;
        
        quote.Quote_Number__c = '12345';
        quote.Create_Sales_Order__c = true;        
        update quote;
              
        ql.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql2);
        qlList.add(ql);
        insert qlList;
        Catalog_GPO_Price__c cgp = new Catalog_GPO_Price__c(Distribution_Channel__c='',GPO_Price__c=100,Product__c=prdList[1].Id);
        insert cgp;
        Catalog_IDN_Price__c cip = new Catalog_IDN_Price__c(Distribution_Channel__c='',IDN_Price__c=100,Products__c=prdList[1].Id);
        insert cip;
        Catalog_USA_Price__c cup = new Catalog_USA_Price__c(Distribution_Channel__c='',USA_List_price__c=100,Product__c =prod2.Id);
        insert cup;
        
        AddProductForQuoteController.QuoteLineWrapperClass wrapResult = AddProductForQuoteController.getQuoteLinesCtrl(ql2.Quote__c);               
       // AddProductForQuoteController.createQuoteLinesForAllParA(qlList, ql2.Quote__c);
        AddProductForQuoteController.createQuoteLinesA(qlList, ql2.Quote__c, 'par Name');
        AddProductForQuoteController.checkErrorMesssage(qlList,ql2.Quote__c);
        
        AddProductForQuoteController.getAssetsInfo(ql2.Quote__c);
        qlList[0].Id = null;
        
        AddProductForQuoteController.createQLineForc4c(new list<Quote_Line__c>{qlList[0]});
        Test.stopTest();
    }    
       
    @isTest()
    public static void testAddProductTest4(){
        
        quotetriggerhandler.TriggerDisabled=true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        
        List<Product2> prdList = new List<Product2>();
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT',Product_Type__c='Option');
        prdList.add(prod);
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',
                                      ProductCode = 'LEASE BUYOUT MED',Product_Type__c='Std Config Omnicell Install', 
                                      DW_Product_Line__c = 'Automated Dispensing Cabinets',
                                      DW_Product_Type__c = 'Frame');
        prdList.add(prod2);
        
        insert prdList;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = TestDataFactory.createTestQuote_Integration1().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Product__c = prdList[0].Id;
        
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        //ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        ql2.Product__c = prdList[1].Id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        ql2.Add_to_cart__c = true;
        ql2.Interim_flag__c = true;
        ql2.Par_Location__c = 'par 1';
        
        
        Test.startTest();
        
        
        
        Quote quote = new Quote();
        quote.name = 'Test Quote2';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration1().Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        Opportunity opp = TestDataFactory.createOppWithAccount();	
        
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
		con.AccountId = opp.AccountId;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        quote.Shipping_Contact__c= [SELECT Id FROM Contact LIMIT 1][0].Id;
        quote.Order_Type__c = 'ZHQR';
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        
        quote.OpportunityId = opp.Id;
        insert quote;
        
        quote.Quote_Number__c = '12345';
        quote.Create_Sales_Order__c = true;        
        update quote;
               
        ql.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql2);
        qlList.add(ql);
        insert qlList;
        Catalog_GPO_Price__c cgp = new Catalog_GPO_Price__c(Distribution_Channel__c='',GPO_Price__c=100,Product__c=prdList[1].Id);
        insert cgp;
        Catalog_IDN_Price__c cip = new Catalog_IDN_Price__c(Distribution_Channel__c='',IDN_Price__c=100,Products__c=prdList[1].Id);
        insert cip;
        Catalog_USA_Price__c cup = new Catalog_USA_Price__c(Distribution_Channel__c='',USA_List_price__c=100,Product__c =prod2.Id);
        insert cup;
        
        AddProductForQuoteController.QuoteLineWrapperClass wrapResult = AddProductForQuoteController.getQuoteLinesCtrl(ql2.Quote__c);               
        AddProductForQuoteController.deleteQuoteLinesCtrl(ql2.Quote__c, JSON.serialize(wrapResult));
        AddProductForQuoteController.createQuoteLine(ql2.Quote__c,prod2.ProductCode, '2');
        Test.stopTest();
    }
    
       
    @isTest()
    public static void testAddProductTest5(){
        
        quotetriggerhandler.TriggerDisabled=true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        
        List<Product2> prdList = new List<Product2>();
        Product2 prod = new Product2(Name = 'FREIGHT',Family = 'test',External_ID__c = '123456',ProductCode = 'FREIGHT',Product_Type__c='Option');
        prdList.add(prod);
        
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',
                                      ProductCode = 'LEASE BUYOUT MED',Product_Type__c='Std Config Omnicell Install', 
                                      DW_Product_Line__c = 'Automated Dispensing Cabinets',
                                      DW_Product_Type__c = 'Frame');
        prdList.add(prod2);
        
        insert prdList;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = TestDataFactory.createTestQuote_Integration1().Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Product__c = prdList[0].Id;
        
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        //ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        ql2.Product__c = prdList[1].Id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        ql2.Add_to_cart__c = true;
        ql2.Interim_flag__c = true;
        ql2.Par_Location__c = 'par 1';
        
        
        Test.startTest();
        
        
        
        Quote quote = new Quote();
        quote.name = 'Test Quote2';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration1().Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        Opportunity opp = TestDataFactory.createOppWithAccount();	
        
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
		con.AccountId = opp.AccountId;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        quote.Shipping_Contact__c= [SELECT Id FROM Contact LIMIT 1][0].Id;
        quote.Order_Type__c = 'ZHQR';
       
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 3000;
        pl.Product_Line_Picklist2__c = 'AccuFlex';
        // pl.Cost__c = 100;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 3;
        insert pl;
        
        quote.OpportunityId = opp.Id;
        insert quote;
        
        quote.Quote_Number__c = '12345';
        quote.Create_Sales_Order__c = true; 
        quote.Quote_Revision__c = '1';
        update quote;
                
        ql.Quote__c = quote.id;
        ql2.Quote__c = quote.id;
        qlList.add(ql2);
        qlList.add(ql);
        insert qlList;
        AddProductForQuoteController.createFreightLineRecord(quote.Id);
        Test.stopTest();
    }
}