@isTest
public class BatchKlarityDataUploadTest {

    @testsetup
    static void testdatasetup(){
        
        
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c();
		obj2.Name = 'Klarity_Mulesoft_Authorization';
        obj2.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        obj2.SCP_Method_Type__c = 'POST';
        obj2.SCP_Key_Client_Id__c = '38e29b8aa70d412285406c4e7b988c79';
        obj2.SCP_Password_Client_Secret__c = 'a725edAD3A2F4503A3B3794A4e2c143E';
        obj2.SCP_Grant_Type__c = 'CLIENT_CREDENTIALS';
        obj2.SCP_Timeout__c = 12000;
        insert obj2;
        
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
    
    public testmethod static void agreementData(){
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c();
		obj.Name = 'Klarity_DataUploadEndpoint';
        obj.SCP_End_Point__c = 'http://sit-sfdc-klarity-prc-api.us-w1.cloudhub.io/api/upload';        
        obj.SCP_Method_Type__c = 'POST';
        obj.SCP_Timeout__c = 12000;
        insert obj;
        
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c();
		obj2.Name = 'Klarity_Mulesoft_Authorization';
        obj2.SCP_End_Point__c = 'https://sit-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        obj2.SCP_Method_Type__c = 'POST';
        obj2.SCP_Key_Client_Id__c = '7025062d8ac3456cb6895916d3916dc1';
        obj2.SCP_Password_Client_Secret__c = '0829e03669104163A07D20a924815567';
        obj2.SCP_Grant_Type__c = 'CLIENT_CREDENTIALS';
        obj2.SCP_Timeout__c = 12000;
        insert obj2;
        
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
        insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        insert acc; 
        System.debug('acc : '+acc);
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        
        
        
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.AccountId = acc.id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp.OppStatus__c = 'Fully Booked';
        opp.Opportunity_Segment__c = 'test1;test2'; 
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        opp.CloseDate = system.today();
        insert opp;
        TestDataFactory.createProductLine(opp.id);
        
        ContactTriggerHandler.TriggerDisabled = true;
        Contact con = TestDataFactory.createContactForAcc(acc.id);
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';  
        quote.OpportunityId = opp.Id;
        quote.ContactId= con.id;
        QuoteTriggerHandler.TriggerDisabled= false;
        quote.Bill_to_Account__c = opp.AccountId;
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.SAP_Expected_Bookings__c=0;
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= con.Id;
        quote.Order_Type__c = 'ZQR';
        quote.subscription_Months__c = 1;        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        quote.Division__c = 'Atlantic';
        QuoteTriggerHandler.TriggerDisabled = true;
        insert quote;
        
        Product2 pr = TestDataFactory.createTestProduct();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product').getRecordTypeId();
        ql.Quote__c = quote.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Product__c=pr.Id;
        ql.Contract_List_Price__c = 1000;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Insert ql;
        
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();        
        qta.Quote__c=quote.Id;
        qta.Status__c = 'Approved';
        insert qta;
        
        Quote.Supplement_Version__c = 2;        
        Quote.Master_Agreement__c = '123456';
        Quote.Service_Level__c = 'GD';
        Quote.Net_Weight__c = 20.5;
        Quote.Total_Cost__c = 100;
        Quote.Overhead_Cost__c = 50;
        Quote.Labor_Cost__c = 10;
        Quote.Net_Value__c = 100;
        Quote.Fee_Increase__c = 10;
        Quote.SAP_Expected_Bookings__c = 200;
        Quote.SAP_NPV__c = 20;            
        Quote.Supplement_Generated__c = '01';
        Quote.Status = 'E0018';
        Quote.Primary_Quote__c = true;
        Quote.ExpirationDate = Date.newInstance(2021, 2, 11);
        Quote.Has_Critical_Errors__c = true;        
        Quote.Region__c = 'Northeast';
        Quote.Description = 'Test Desc';
        Quote.Currency__c = 'AWG';           
        Quote.Tax = 30;        
        Quote.Total_Net__c = 200;        
        Quote.Incoterms_1__c = 'COL';
        Quote.Incoterms_2__c = 'test'; 
        Quote.Order_Net_Price__c = 200;
        Quote.GSA_Result1__c = 'Test GSA';        
        Quote.GSA_Net_Price__c = 20;
        Quote.GSA_Price_Difference__c = 12;
        Quote.Quote_Revision__c = '2';
        Quote.SAP_Sales_Order_Number__c = '12345';      
        Quote.Product_PO_Number__c = '12345';
        Quote.Service_PO_Number__c = '12345';  
        Quote.Exchange_Rate_Override__c = False;
        Quote.Sales_Org__c = 'OM01';       
        Quote.Free_Month_for_Lease__c = 2.5;  
        Quote.Free_Month_Service__c = 2.5;
        Quote.Service_Duration__c = 25;          
        Quote.Booking_Date__c = Date.newInstance(2019,02,14);        
        Quote.Pricing_Reference_Date__c = Date.newInstance(2019,2,15);       
        Quote.Email = 'test@test.com';
        Quote.Phone = '9999999999';        
        Quote.Status = 'E0013';
        Quote.ECC_Sales_Order_Number__c = '123456';
        QuoteTriggerHandler.TriggerDisabled = true;
        Update quote;
        
        List<echosign_dev1__SIGN_Agreement__c> Listsa = new List<echosign_dev1__SIGN_Agreement__c>();
        echosign_dev1__SIGN_Agreement__c sa = new echosign_dev1__SIGN_Agreement__c();
        sa.Quote_Approval__c = qta.Id;
        sa.echosign_dev1__Document_Key__c = 'hadfiefhbiuabhfiuehfiuaehiug';
        sa.echosign_dev1__Status__c = 'Signed';
        sa.CreatedDate = system.today();
        sa.ProcessedForKlarity__c = false;
        sa.echosign_dev1__SignedPDF__c  = 'https://secure.na1.echosign.com/document/cp/3AAABLblqZhDAeLvAhhsNOzRTAHrfruCBe-z_6g5s8nHor6C10Nae9y0fwi7tPQqSQua_6GPzooonM4ALsuaFZCQTsclAPlYnKO/document.pdf';
        Insert sa;
        
        Listsa.add(sa);
        
        Attachment a = new Attachment();
        a.Body = Blob.valueOf('jsdhfahadiuhuoafudf');
        a.Name = 'Test';
        a.ParentId = sa.Id;
        insert a;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Klarity_MuleAccessTokenMock());
        BatchKlarityDataUpload b = new BatchKlarityDataUpload();
		database.executeBatch(b,5);
        
        KlarityCalloutQueueable job = new KlarityCalloutQueueable();
        job.FinalJSON = '{"Contracts": [], "QAP": []}';
        //job.Processed_Docs = Listsa; commented as part of IBA-5772
        System.enqueueJob(job);
        
        Test.stopTest();
    }
    
    public testmethod static void agreementData_1(){
        SCP_Integration_Details__c obj = new SCP_Integration_Details__c();
		obj.Name = 'Klarity_DataUploadEndpoint';
        obj.SCP_End_Point__c = '';        
        obj.SCP_Method_Type__c = 'POST';
        obj.SCP_Timeout__c = 12000;
        insert obj;
        
        SCP_Integration_Details__c obj2 = new SCP_Integration_Details__c();
		obj2.Name = 'Klarity_Mulesoft_Authorization';
        obj2.SCP_End_Point__c = 'https://sit-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        obj2.SCP_Method_Type__c = 'POST';
        obj2.SCP_Key_Client_Id__c = '7025062d8ac3456cb6895916d3916dc1';
        obj2.SCP_Password_Client_Secret__c = '0829e03669104163A07D20a924815567';
        obj2.SCP_Grant_Type__c = 'CLIENT_CREDENTIALS';
        obj2.SCP_Timeout__c = 12000;
        insert obj2;
        
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
        insert aDataload;
        
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        insert acc;
        
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.AccountId = acc.id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp.OppStatus__c = 'Fully Booked';
        opp.Opportunity_Segment__c = 'test1;test2'; 
        opp.Services_Enablement_Owner__c = 'Justin Wilson';
        opp.CloseDate = system.today();
        insert opp;
        TestDataFactory.createProductLine(opp.id);
        
        ContactTriggerHandler.TriggerDisabled = true;
        Contact con = TestDataFactory.createContactForAcc(acc.id);
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';  
        quote.OpportunityId = opp.Id;
        quote.ContactId= con.id;
        QuoteTriggerHandler.TriggerDisabled= false;
        quote.Bill_to_Account__c = opp.AccountId;
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.SAP_Expected_Bookings__c=0;
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= con.Id;
        quote.Order_Type__c = 'ZQR';
        quote.subscription_Months__c = 1;        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        quote.Division__c = 'Atlantic';
        QuoteTriggerHandler.TriggerDisabled = true;
        insert quote;
        
        Product2 pr = TestDataFactory.createTestProduct();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = Schema.SObjectType.Quote_Line__c.getRecordTypeInfosByName().get('Non-Configurator Product').getRecordTypeId();
        ql.Quote__c = quote.Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.Product__c=pr.Id;
        ql.Contract_List_Price__c = 1000;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        Insert ql;
        
        Quote_approval__c qta = TestDataFactory.createQuoteApprovalRec();        
        qta.Quote__c=quote.Id;
        qta.Status__c = 'Approved';
        insert qta;
        
        Quote.Supplement_Version__c = 2;        
        Quote.Master_Agreement__c = '123456';
        Quote.Service_Level__c = 'GD';
        Quote.Net_Weight__c = 20.5;
        Quote.Total_Cost__c = 100;
        Quote.Overhead_Cost__c = 50;
        Quote.Labor_Cost__c = 10;
        Quote.Net_Value__c = 100;
        Quote.Fee_Increase__c = 10;
        Quote.SAP_Expected_Bookings__c = 200;
        Quote.SAP_NPV__c = 20;            
        Quote.Supplement_Generated__c = '01';
        Quote.Status = 'E0018';
        Quote.Primary_Quote__c = true;
        Quote.ExpirationDate = Date.newInstance(2021, 2, 11);
        Quote.Has_Critical_Errors__c = true;        
        Quote.Region__c = 'Northeast';
        Quote.Description = 'Test Desc';
        Quote.Currency__c = 'AWG';           
        Quote.Tax = 30;        
        Quote.Total_Net__c = 200;        
        Quote.Incoterms_1__c = 'COL';
        Quote.Incoterms_2__c = 'test'; 
        Quote.Order_Net_Price__c = 200;
        Quote.GSA_Result1__c = 'Test GSA';        
        Quote.GSA_Net_Price__c = 20;
        Quote.GSA_Price_Difference__c = 12;
        Quote.Quote_Revision__c = '2';
        Quote.SAP_Sales_Order_Number__c = '12345';      
        Quote.Product_PO_Number__c = '12345';
        Quote.Service_PO_Number__c = '12345';  
        Quote.Exchange_Rate_Override__c = False;
        Quote.Sales_Org__c = 'OM01';       
        Quote.Free_Month_for_Lease__c = 2.5;  
        Quote.Free_Month_Service__c = 2.5;
        Quote.Service_Duration__c = 25;          
        Quote.Booking_Date__c = Date.newInstance(2019,02,14);        
        Quote.Pricing_Reference_Date__c = Date.newInstance(2019,2,15);       
        Quote.Email = 'test@test.com';
        Quote.Phone = '9999999999';        
        Quote.Status = 'E0013';
        Quote.ECC_Sales_Order_Number__c = '123456';
        QuoteTriggerHandler.TriggerDisabled = true;
        Update quote;
        
        List<echosign_dev1__SIGN_Agreement__c> Listsa = new List<echosign_dev1__SIGN_Agreement__c>();
        echosign_dev1__SIGN_Agreement__c sa = new echosign_dev1__SIGN_Agreement__c();
        sa.Quote_Approval__c = qta.Id;
        sa.echosign_dev1__Document_Key__c = 'hadfiefhbiuabhfiuehfiuaehiug';
        sa.echosign_dev1__Status__c = 'Signed';
        sa.CreatedDate = system.today();
        sa.ProcessedForKlarity__c = false;
        sa.echosign_dev1__SignedPDF__c  = 'https://secure.na1.echosign.com/document/cp/3AAABLblqZhDAeLvAhhsNOzRTAHrfruCBe-z_6g5s8nHor6C10Nae9y0fwi7tPQqSQua_6GPzooonM4ALsuaFZCQTsclAPlYnKO/document.pdf';
        Insert sa;
        
        Listsa.add(sa);
        
        Attachment a = new Attachment();
        a.Body = Blob.valueOf('jsdhfahadiuhuoafudf');
        a.Name = 'Test';
        a.ParentId = sa.Id;
        insert a;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Klarity_MuleAccessTokenMock());
        BatchKlarityDataUpload b = new BatchKlarityDataUpload();
		database.executeBatch(b,1);
        
        KlarityCalloutQueueable job = new KlarityCalloutQueueable();
        job.FinalJSON = '{"Contracts": [], "QAP": []}';
        System.enqueueJob(job);
        Test.stopTest();
        
    }
}