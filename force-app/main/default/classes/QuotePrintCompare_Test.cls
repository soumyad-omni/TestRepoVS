@isTest(seeAllData=false)
public class QuotePrintCompare_Test {
    
    static testmethod void compareResponse1(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        setting.Print_Compare_End_Point__c = 'https://castirondatadev.omnicell.com/QuoteRevNoItemCountSFDCtoSAPtoSFDC';
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
        
        Compare_Integration_Creds__c testsetting = new Compare_Integration_Creds__c(Name = 'Compare Creds',
                                                                               Endpoint__c='https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT',
                                                                               Timeout__c='120000');
        insert testsetting;
        
        AccountTriggerHandler.TriggerDisabled = true;
        Account act = new Account();
       // act.RecordTypeId='0124F0000004NZXQA2';
        act.name='Test Account';
        act.Account_Role__c = 'ZCSN';
        act.CurrencyIsoCode= 'USD';
        act.Partner_Type__c = '0007';
        act.Country_Cluster__c='US&CA';
        act.Division_Account__c='Atlantic';
        act.Region__c='Central';
        act.Account_Territory__c='Central IN and West OH';
        act.Facility_Type__c = 'Pharmacy';
        Insert act;  
        
        Contact ct = new Contact();
        ct.LastName ='testname';
        ct.Is_Active__c='Y';
        ct.LeadSource='Attended Event';
        ct.AccountId = act.Id;
        ct.Phone = '1234567891';
        insert ct;
        
        Opportunity opt =new Opportunity();
        opt.Name = 'Test Opp';
        opt.AccountId = act.Id;
       // opt.RecordTypeId='0124F0000004NZbQAM';
        opt.CurrencyIsoCode = 'USD';
        opt.CustomerType__c = 'Existing Customer';
        opt.CloseDate = Date.newInstance(2019, 08, 03);
        opt.StageName = 'Won';
        opt.Opportunity__c = 'Omnicell Opportunity';
        opt.OpportunityGroup__c = 'Purchase';
        opt.Pipeline_Category__c='Development';
        opt.ExpectedInstallDate__c = System.today()+60;
        opt.Services_Enablement_Owner__c = 'Tara Bakker';
       // opt.AccountId ='';
        insert opt;
        
        QuoteTriggerHandler.TriggerDisabled = true;
        Quote qtTest = new Quote();
        qtTest.Name = 'testcompare5';
        qtTest.Order_Type__c = 'ZQR';
        qtTest.Shipping_Contact__c = ct.Id;
        qtTest.OpportunityId = opt.Id;
        qtTest.Quote_Revision__c='6';
        insert qtTest;
        
        Product2 pr = new Product2();
        pr.Name = 'CPA-CAR-069';
        pr.ProductCode = 'CPA-CAR-069';
        pr.CurrencyIsoCode = 'USD';
        pr.External_ID__c='CPA-CAR-069';
        insert pr;
        
        Quote_Line__c Qline= new Quote_Line__c();
        Quote_Line__c QlineList;
      //  Qline.RecordTypeId = '0124F0000004OQ9QAM';
        Qline.Quote__c = qtTest.Id;
        Qline.Customer_Price__c = 123;
        Qline.Product__c = pr.Id;
        Qline.Conga_Grouped_Product__c =true;
        
          
		Qline.Conga_Quantity__c= 2.000;
		Qline.Conga1_USA_List_Price__c =332150.00;
		Qline.Conga_List_Price__c= 276250.00;
		Qline.Conga_Unit_Price__c = 276250.00;
		Qline.Conga_Extended_Price_Materials__c =276250; 
        insert Qline;
        
        Quote_Print_Status__c qpt = new Quote_Print_Status__c();
        qpt.Quote__c =qtTest.Id;
        qpt.Revision_Number__c='6';
        insert qpt;
        
        
        Test.setMock(HttpCalloutMock.class, new Compare_MockCallout_API_Response());
        Test.startTest();
        final string comp_creds = 'CastIronIntegration';
        
        CastIronIntegration__c compCreds = CastIronIntegration__c.getInstance(comp_creds);
        System.debug('compccreds : '+compCreds.Print_Compare_End_Point__c);
        QuotePrintcompare.compareQuoteLine(qtTest.id);
        List<QuotePrintCompare.subcomparewrapper> subcompwrap = new List<QuotePrintCompare.subcomparewrapper>();
        subcompwrap.add(new QuotePrintCompare.subcomparewrapper('SFDC','sfproduct', String.valueOf(2),
                                                                             String.valueOf(1000), String.valueOf(1000), 
                                                                             String.valueOf(2000),String.valueOf(0), 
                                                                             string.valueOf(double.valueOf(0)), string.valueOf(false)));
        Test.stopTest();
    }
}