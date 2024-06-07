@istest
public class contactwhereusednewbatch_test {
    
    @testsetup
    static void testdatasetup(){
        // List<String> pickListValuesList = QuotePrintOutController.getPickListValuesIntoList('Quote', 'Select_Canned_Language__c');
        //List<String> selectedExhibits = QuotePrintOutController.getPickListValuesIntoList('Quote', 'Print_Exhibits__c');
        //List<String> selectedSections = QuotePrintOutController.getPickListValuesIntoList('Quote', 'Print_Sections__c');
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondev.omnicell.com';
        setting.Print_Compare_End_Point__c = 'https://printcastirondev.omnicell.com';
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
        Conga_Print_Section_Ids__c sec1 = new Conga_Print_Section_Ids__c(Name= 'Summary Product Only',Print_Section_Id__c = '0000');
        insert sec1;
        Conga_Print_Section_Ids__c sec2 = new Conga_Print_Section_Ids__c(Name= 'Summary Service Only',Print_Section_Id__c = '0000');
        insert sec2;
        Conga_Print_Section_Ids__c sec3 = new Conga_Print_Section_Ids__c(Name= 'Summary_by_Par_Location',Print_Section_Id__c = '0000');
        insert sec3;
        Conga_Print_Section_Ids__c sec4 = new Conga_Print_Section_Ids__c(Name= 'Detail by Par Location',Print_Section_Id__c = '0000');
        insert sec4;
        Conga_Print_Section_Ids__c sec5 = new Conga_Print_Section_Ids__c(Name= 'Print Config Pictures',Print_Section_Id__c = '0000');
        insert sec5;
        Conga_Print_Section_Ids__c sec6 = new Conga_Print_Section_Ids__c(Name= 'Detail by Par Location with pictures',Print_Section_Id__c = '0000');
        insert sec6;
        Conga_Print_Section_Ids__c sec7 = new Conga_Print_Section_Ids__c(Name= 'Summary by Par Location with pictures',Print_Section_Id__c = '0000');
        insert sec7;
        Conga_Print_Section_Ids__c sec8 = new Conga_Print_Section_Ids__c(Name= 'Detail by Par Location with signoff',Print_Section_Id__c = '0000');
        insert sec8;
        Conga_Exhibit_IDs__c ex1 = new Conga_Exhibit_IDs__c(Name= 'IVX',Conga_Template_Id__c='0000');
        insert ex1;
        Conga_Exhibit_IDs__c ex2 = new Conga_Exhibit_IDs__c(Name= 'CRx Upgrade',Conga_Template_Id__c='0000');
        insert ex2;
        Conga_Exhibit_IDs__c ex3 = new Conga_Exhibit_IDs__c(Name= 'Performance Center (PSOG only)',Conga_Template_Id__c='0000');
        insert ex3;
        Conga_Exhibit_IDs__c ex4 = new Conga_Exhibit_IDs__c(Name= 'Performance Center (w. EMM)',Conga_Template_Id__c='0000');
        insert ex4;
        Conga_Exhibit_IDs__c ex5 = new Conga_Exhibit_IDs__c(Name= 'ServiceNow',Conga_Template_Id__c='0000');
        insert ex5;
        Conga_Base_Template__c temp1 = new Conga_Base_Template__c(Name= 'Summary by Product',template_id__c = '0000');
        insert temp1;
        Conga_Base_Template__c temp2 = new Conga_Base_Template__c(Name= 'Pictures Only',template_id__c = '0000');
        insert temp2;
        Conga_Base_Template__c temp3 = new Conga_Base_Template__c(Name= 'Summary by Product with Zero Dollars',template_id__c = '0000');
        insert temp3;
        Conga_Base_Template__c temp4 = new Conga_Base_Template__c(Name= 'Display Usa Price List',template_id__c = '0000');
        insert temp4;
        Conga_Base_Template__c temp5 = new Conga_Base_Template__c(Name= 'Products Unbundled',template_id__c = '0000');
        insert temp5;
        Conga_Base_Template__c temp6 = new Conga_Base_Template__c(Name= 'Generic Drawers',template_id__c = '0000');
        insert temp6;
        
        List<Canned_Language__c> cList = new List<Canned_Language__c>();
        Canned_Language__c c = new Canned_Language__c();
        c.Name = 'Buyout Products';
        c.Canned_Language_Detail__c = 'test';
       	cList.add(c); 
        Canned_Language__c c1 = new Canned_Language__c();
        c1.Name = 'Classic Hardware EOL –Lease';
        c1.Canned_Language_Detail__c = 'test';
       	cList.add(c1); 
        Canned_Language__c c2 = new Canned_Language__c();
        c2.Name = 'Connect-RX Upgrade';
        c2.Canned_Language_Detail__c = 'test';
       	cList.add(c2); 
        Canned_Language__c c3 = new Canned_Language__c();
        c3.Name = 'Definitions';
        c3.Canned_Language_Detail__c = 'test';
       	cList.add(c3); 
        Canned_Language__c c4 = new Canned_Language__c();
        c4.Name = 'Development Product(Omnicell)';
        c4.Canned_Language_Detail__c = 'test';
       	cList.add(c4); 
        Canned_Language__c c5 = new Canned_Language__c();
        c5.Name = 'Development Product(Aesynt)';
        c5.Canned_Language_Detail__c = 'test';
       	cList.add(c5); 
        Canned_Language__c c6 = new Canned_Language__c();
        c6.Name = 'Extended Support Term';
        c6.Canned_Language_Detail__c = 'test';
       	cList.add(c6); 
        Canned_Language__c c7 = new Canned_Language__c();
        c7.Name = 'Fee Increase';
        c7.Canned_Language_Detail__c = 'test';
       	cList.add(c7); 
        Canned_Language__c c8 = new Canned_Language__c();
        c8.Name = 'Maintenance Extension';
        c8.Canned_Language_Detail__c = 'test';
       	cList.add(c8); 
        Canned_Language__c c9 = new Canned_Language__c();
        c9.Name = 'Omnicell Capital Program';
        c9.Canned_Language_Detail__c = 'test';
       	cList.add(c9); 
        Canned_Language__c c10 = new Canned_Language__c();
        c10.Name = 'Payment Terms 70%';
        c10.Canned_Language_Detail__c = 'test';
       	cList.add(c10); 
        Canned_Language__c c11 = new Canned_Language__c();
        c11.Name = 'Payment Terms 80%';
        c11.Canned_Language_Detail__c = 'test';
       	cList.add(c11); 
        Canned_Language__c c12 = new Canned_Language__c();
        c12.Name = 'Payment Terms – Product Fees (Connect-Rx Upgrade)';
        c12.Canned_Language_Detail__c = 'test';
       	cList.add(c12); 
        Canned_Language__c c13 = new Canned_Language__c();
        c13.Name = 'Payment Terms – Product Fees (Purchase)';
        c13.Canned_Language_Detail__c = 'test';
       	cList.add(c13); 
        Canned_Language__c c17 = new Canned_Language__c();
        c17.Name='Replacement Products(Aesynt)';
        c17.Canned_Language_Detail__c = 'test';
       	cList.add(c17); 
        Canned_Language__c c18 = new Canned_Language__c();
        c18.Name='Replacement Products(Omnicell)';
        c18.Canned_Language_Detail__c = 'test';
       	cList.add(c18); 
        Canned_Language__c c19 = new Canned_Language__c();
        c19.Name='RXI/RXP Bundle';
        c19.Canned_Language_Detail__c = 'test';
       	cList.add(c19); 
        Canned_Language__c c20 = new Canned_Language__c();
        c20.Name='Schedule D-3';
        c20.Canned_Language_Detail__c = 'test';
       	cList.add(c20); 
        Canned_Language__c c21 = new Canned_Language__c();
        c21.Name='ServiceNow';
        c21.Canned_Language_Detail__c = 'test';
       	cList.add(c21); 
        Canned_Language__c c22 = new Canned_Language__c();
        c22.Name='Virtual Server Requirement';
        c22.Canned_Language_Detail__c = 'test';
       	cList.add(c22); 
        Canned_Language__c c23 = new Canned_Language__c();
        c23.Name='Virtualization Considerations';
        c23.Canned_Language_Detail__c = 'test';
       	cList.add(c23); 
        Canned_Language__c c24 = new Canned_Language__c();
        c24.Name='Windows 7 to XP Downgrade';
        c24.Canned_Language_Detail__c = 'test';
       	cList.add(c24); 
        Canned_Language__c c25 = new Canned_Language__c();
        c25.Name='Aesynt has made no commitment';
        c25.Canned_Language_Detail__c = 'test';
       	cList.add(c25); 
        Canned_Language__c c26 = new Canned_Language__c();
        c26.Name='Omnicell has made no commitment';
        c26.Canned_Language_Detail__c = 'test';
       	cList.add(c26); 
        Canned_Language__c c27 = new Canned_Language__c();
        c27.Name='Non-GA Waiver';
        c27.Canned_Language_Detail__c = 'test';
       	cList.add(c27);
        Canned_Language__c c28 = new Canned_Language__c();
        c28.Name='SS: PO at Sign.';
        c28.Canned_Language_Detail__c = 'test';
       	cList.add(c28);
        
        insert cList;
         
        List<Exhibits__c> ex = new List<Exhibits__c>();
        Exhibits__c e1 = new Exhibits__c(Name='CRx Upgrade',Exhibit_Detail__c='Test');
        ex.add(e1);
        Exhibits__c e2 = new Exhibits__c(Name='IVX',Exhibit_Detail__c='Test');
        ex.add(e2);
        Exhibits__c e3 = new Exhibits__c(Name='Performance Center (PSOG only)',Exhibit_Detail__c='Test');
        ex.add(e3);
        Exhibits__c e4 = new Exhibits__c(Name='Performance Center (w. EMM)',Exhibit_Detail__c='Test');
        ex.add(e4);
        Exhibits__c e5 = new Exhibits__c(Name='ServiceNow',Exhibit_Detail__c='Test');
        ex.add(e5);
        Exhibits__c e6 = new Exhibits__c(Name='Simplifi 797',Exhibit_Detail__c='Test');
        ex.add(e6);
        Exhibits__c e7 = new Exhibits__c(Name='Omnicell One',Exhibit_Detail__c='Test');
        ex.add(e7);
        Exhibits__c e8 = new Exhibits__c(Name='Professional Service',Exhibit_Detail__c='Test');
        ex.add(e8);
        
        insert ex;
        
    }
    
    @istest
    private static void test1(){
        
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        List<CampaignMember> CampaignMemberList= new List<CampaignMember>(); 
        
        camp.Status='Planned';
        insert camp;
        Lead ld=TestDataFactory.createLead(1)[0];
        insert ld;
        contactTriggerHandler.triggerdisabled = true;   
        AccountTriggerHandler.triggerdisabled = true;
        AccountCreateController.isFirstRun= false;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
        List<Contact> c = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
        
        ContactWhereUsed__c cwu = new ContactWhereUsed__c(Contact_ID__c = c[0].id, Contact__c = c[0].id);
        insert cwu;
                
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        
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
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;
        
        Product_Line__c pl2 = new Product_Line__c();
        pl2.Portfolio_Segment__c = 'Carousels';
        pl2.Amount__c = 10000;
        pl2.Opportunity__c =opp.id;    
        insert pl2;
        OpportunityContactRole opr = new OpportunityContactRole(ContactId = c[0].id, OpportunityId = opp.Id);
        insert opr;
        
        CampaignMember member=new CampaignMember(leadId=ld.Id,campaignid=camp.Id,status='Sent', ContactId = c[0].id );
        
        CampaignMemberList.add(member);
        
        
        Test.StartTest();
        insert CampaignMemberList;
        insert quote;
        
        ContactReportNewBatchSchedule sh1 = new ContactReportNewBatchSchedule();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    
    @istest
    private static void test2(){
        AccountTriggerHandler.triggerdisabled = true;
        Campaign camp=TestDataFactory.createCampaign(1)[0];
        List<CampaignMember> CampaignMemberList= new List<CampaignMember>(); 
        contactTriggerHandler.triggerdisabled = true;
        camp.Status='Planned';
        insert camp;
        Lead ld=TestDataFactory.createLead(1)[0];
        insert ld;
               
                
        AccountCreateController.isFirstRun= false;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
        List<Contact> c = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
                      
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        
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
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        Product_Line__c pl2 = new Product_Line__c();
        pl2.Portfolio_Segment__c = 'Carousels';
        pl2.Amount__c = 10000;
        pl2.Opportunity__c =opp.id;    
        insert pl2;
        
        quote.OpportunityId = opp.Id;
        
        OpportunityContactRole opr = new OpportunityContactRole(ContactId = c[0].id, OpportunityId = opp.Id);
        insert opr;
        
        CampaignMember member=new CampaignMember(leadId=ld.Id,campaignid=camp.Id,status='Sent', ContactId = c[0].id );
        
        CampaignMemberList.add(member);
        
        
        Test.StartTest();
        insert CampaignMemberList;
        insert quote;
        
        ContactReportNewBatchSchedule sh1 = new ContactReportNewBatchSchedule();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }

}