@isTest
public class UpdatePLBatch_test {

    public static Id recTypeQuoteApproval = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote' LIMIT 1].Id;
    @testsetup
    static void testdatasetup(){
        
        Run_Product_line_Update__c  setting1111 = new Run_Product_line_Update__c ();
        setting1111.Name = 'Run Product line Update';
        setting1111.Run_Product_line_Update__c = true;
        insert setting1111;
        
        turn_off_print_check__c  setting111 = new turn_off_print_check__c ();
        setting111.Name = 'Compare Check';
        setting111.disabled__c = FALSE;
        insert setting111;
        
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        setting.Print_Compare_End_Point__c = 'https://printcastirondev.omnicell.com';
        setting.compare_button_endpoint__c = 'https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT';
        setting.compare_button_timeout__c = '120000';
        insert setting;
        
        Win_10_Canned_Language_Product__c w = new Win_10_Canned_Language_Product__c();
        w.name = '1';
        w.Product_Name__c = 'testname';
        insert w;
        
        Small_Parts_Addl_product__c smp = new Small_Parts_Addl_product__c ();
        smp.name = '1';
        smp.DW_prod__c = 'testdw';
        smp.SAP_prod__c = 'testsap';
        insert smp;
        
        Small_Parts_Addl_product__c smp1 = new Small_Parts_Addl_product__c ();
        smp1.name = '2';
        smp1.DW_prod__c = '';
        smp1.SAP_prod__c = 'testsap';
        insert smp1;
        
        CastIronIntegration__c  compsetting = new CastIronIntegration__c ();
        compsetting.Name = 'CastIronIntegration';
        compsetting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        compsetting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert compsetting;
        
        Compare_Integration_Creds__c testsetting = new Compare_Integration_Creds__c(Name = 'Compare Creds',
                                                                                    Endpoint__c='https://castirondatadev.omnicell.com/QuotePrintOutSFDCtoSAPtoSFDCUAT',
                                                                                    Timeout__c='120000');
        insert testsetting;
        
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
        
        Default_Currency_by_Country_Code__c	  setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'US';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        Default_Currency_by_Country_Code__c	  setting8 = new Default_Currency_by_Country_Code__c();
        setting8.Name = 'AZ';
        setting8.Currency_Code__c = 'USD';
        insert setting8;
        
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
        Conga_Print_Output__c output3 = new Conga_Print_Output__c();
        output3.Name = 'Deal Desk';
        output3.Profile_Name__c = 'Deal Desk';
        insert output3;
        Conga_Print_Output__c output4 = new Conga_Print_Output__c();
        output4.Name = 'Booking Team';
        output4.Profile_Name__c = 'Booking Team';
        insert output4;
        Conga_Print_Output__c output5 = new Conga_Print_Output__c();
        output5.Name = 'International Sales Ops';
        output5.Profile_Name__c = 'International Sales Ops';
        insert output5;
        Conga_Print_Output__c output6 = new Conga_Print_Output__c();
        output6.Name = 'Consultant';
        output6.Profile_Name__c = 'Consultant';
        insert output6;
        
        Conga_Logo__c logoomnicell = new Conga_Logo__c();
        logoomnicell.Name = 'Omnicell';
        logoomnicell.Logo_Url__c = 'testomnicell.com';
        insert logoomnicell;
        Conga_Logo__c logoaesynt = new Conga_Logo__c();
        logoaesynt.Name = 'Aesynt';
        logoaesynt.Logo_Url__c = 'testaesynt.com';
        insert logoaesynt;
        
        
        List<Canned_Language__c> cList = new List<Canned_Language__c>();
        Canned_Language__c c = new Canned_Language__c();
        c.Name = 'Buyout Products';
                
        insert cList;
        
        List<Exhibits__c> ex = new List<Exhibits__c>();
        Exhibits__c e1 = new Exhibits__c(Name='CRx Upgrade',Exhibit_Detail__c='Test');
        ex.add(e1);
                
        insert ex;
        
    }
    
    public static testmethod void UpdatePLBatch_test1(){
        AccountTriggerHandler.TriggerDisabled = true;
		OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        ContactTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        /*   SCP_TestDataFactory.createContact_Customsetting();      
      	CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
		*/
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
        //List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:setting.Id];
         Contact con = TestDataFactory.createContactWithAccount_Integration();
        //quote.Quote_Number__c = 'test123';
        //quote.OpportunityId = createOppWithAccount_Integration1().Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Region__c='Northeast';
        q.Pricing_Reference_Date__c=system.today();
        q.Requested_Delivery_Date__c = system.today();
        q.Booking_Date__c=system.today();
        q.ExpirationDate = system.today();
        q.SAP_Last_Line_Number__c = 200;
        q.EOL_Date__c = System.today()+200;
        q.Supplement_Version__c = 2;
        q.Status = 'E0009';
        q.Primary_Quote__c= true;
        
        //quote.ContactId=createContactWithAccount_Integration().Id;
        
        q.Shipping_Contact__c= con.Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        q.OpportunityId = opp.Id;
        Opportunity oppu = [select id,OppStatus__c from opportunity where id =: opp.Id ];
        oppu.OppStatus__c = 'Fully Booked';
        update oppu;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        ql.Quote__c = q.Id;
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Line_Status__c = 'E0006';
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        q.Service_PO_Number__c = '1234';
        q.Product_PO_Number__c = '1234';
        q.Master_Agreement__c = '1234';
        q.Status = 'E0013';
        q.Supplement_Generated__c = '01';
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        list<product2> pd = [SELECT Id,Segment_Changed__c,DW_Product_Line__c,Portfolio_Segment__c FROM Product2 WHERE Name = 'TestProduct-SV'];
        pd[0].Segment_Changed__c = true;
        pd[0].DW_Product_Line__c = 'testdw1';
        //pd[0].Portfolio_Segment__c = 'Anesthesia Cabinets';
        update pd;
        
        UpdatePLBatchScheduler.startPLcalc(); 
        
        test.stopTest();
    }
    
}