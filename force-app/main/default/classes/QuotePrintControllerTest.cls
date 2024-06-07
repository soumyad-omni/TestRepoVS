/**
* @File Name          : QuotePrintControllerTest.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Last Modified On   : 08-11-2020
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    15/4/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class QuotePrintControllerTest {
    public static Id recTypeQuoteApproval = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Supplement Quote' LIMIT 1].Id;
    @testsetup
    static void testdatasetup(){
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
        
        SCP_Integration_Details__c  compsetting1 = new SCP_Integration_Details__c ();
        compsetting1.Name = 'SCP_ContactSFToCRM';
        compsetting1.SCP_Method_Type__c = 'POST';
        compsetting1.SCP_Timeout__c = 120000;
        compsetting1.SCP_End_Point__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        insert compsetting1;
        
        SCP_Integration_Details__c  setting11 = new SCP_Integration_Details__c ();
        setting11.Name = 'SCP_Mulesoft_Authorization';
        setting11.SCP_Method_Type__c = 'POST';
        setting11.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting11.SCP_Timeout__c = 120000;
        setting11.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting11.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting11.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting11.SCP_Is_Active__c = true;
        insert setting11;
          SCP_Integration_Details__c  setting22 = new SCP_Integration_Details__c ();
        setting22.Name = 'SCP_ContactSFToCRM_Update';
        setting22.SCP_Method_Type__c = 'POST';
        setting22.SCP_Timeout__c = 120000;
        setting22.SCP_End_Point__c = 'http://sit-aloha-sap-sfdc-integration-contacts.us-w1.cloudhub.io/api/ContactSFToCRM_Update';
        insert setting22;
        
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
        
        Default_Currency_by_Country_Code__c   setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'US';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        Default_Currency_by_Country_Code__c   setting8 = new Default_Currency_by_Country_Code__c();
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
        Conga_Print_Output__c output7 = new Conga_Print_Output__c();
        output7.Name = 'IT Administrator';
        output7.Profile_Name__c = 'IT Administrator';
        insert output7;
        
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
        Canned_Language__c c29 = new Canned_Language__c();
        c29.Name='Software Licensing OC';
        c29.Canned_Language_Detail__c = 'test';
        c29.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c29);
        Canned_Language__c c30 = new Canned_Language__c();
        c30.Name='PT: Software Subscription OC';
        c30.Canned_Language_Detail__c = 'test';
        c30.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c30);
        Canned_Language__c c31 = new Canned_Language__c();
        c31.Name='CMA Installation Plan Approval';
        c31.Canned_Language_Detail__c = 'test';
        c31.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c31);
        Canned_Language__c c32 = new Canned_Language__c();
        c32.Name='ASA Installation Plan Approval';
        c32.Canned_Language_Detail__c = 'test';
        c32.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c32);
        Canned_Language__c c33 = new Canned_Language__c();
        c33.Name='MI: 100% signed Bonding Agreement';
        c33.Canned_Language_Detail__c = 'test';
        c33.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c33);
        
        Canned_Language__c c34 = new Canned_Language__c();
        c34.Name='Non-GA product - XTE';
        c34.Canned_Language_Detail__c = 'test Saptarsha 1';
        c34.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c34);
        
        Canned_Language__c c35 = new Canned_Language__c();
        c35.Name='Formulary Tool Kit Studies IV';
        c35.Canned_Language_Detail__c = 'test Saptarsha 2';
        c35.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c35);
        
        Canned_Language__c c36 = new Canned_Language__c();
        c36.Name='De-Installation New';
        c36.Canned_Language_Detail__c = 'test Saptarsha 3';
        c36.Omnicell_or_Aesynt__c = 'Omnicell';
        cList.add(c36);
        
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
        
        OC_SKU_based_automation__c oc = new OC_SKU_based_automation__c(Name='OC1-LAB-001', Product_name__c='OC1-LAB-001');
        insert oc;
        
        CAD_Provision_SKU__c cadsku = new CAD_Provision_SKU__c(Name='PSV-SVC-001-17', Product_name__c='PSV-SVC-001-17');
        insert cadsku;
        
        List<Installation_plan_SKU__c> inssku = new List<Installation_plan_SKU__c>();
        Installation_plan_SKU__c ins1 = new Installation_plan_SKU__c(Name='XR2-KIT-201', Product_name__c='XR2-KIT-201');
        inssku.add(ins1);
        Installation_plan_SKU__c ins2 = new Installation_plan_SKU__c(Name='XR2-KIT-200', Product_name__c='XR2-KIT-200');
        inssku.add(ins2);
        Insert inssku;
        
    }
    public static testmethod void quotePrintControllerClassTest1(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        insert clList;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        //quote.Quote_Number__c = 'test123';
        //quote.OpportunityId = createOppWithAccount_Integration1().Id;
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        quote.OpportunityId = opp.Id;
        
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
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
        insert quote;
        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Summary by Product with Zero Dollars', template_id__c = 'testid');
        btList.add(b2);
        insert btList;
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = true;
        boolean unbundled = true;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(quote.Id);
        qp.Print_Layout__c = layout;
        qp.SelectedCannedLanguageNames__c = 'Buyout Products,Development Product(Omnicell),ServiceNow,Connect-RX Upgrade,Classic Hardware EOL –Lease,Definitions,Fee Increase,Omnicell Capital Program';
        update qp;
        Conga_Quote_Print__c cqp = new Conga_Quote_Print__c();
        cqp.Select_Canned_Language__c = 'Test Canned Language';
        cqp.SelectedCannedLanguageNames__c = 'Buyout Products,Development Product(Omnicell),ServiceNow,Connect-RX Upgrade,Classic Hardware EOL –Lease,Definitions';
        cqp.Quote_Record_Id__c = quote.Id;
        insert cqp;
        QuotePrintController.updateQuote(quote.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, quote.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(quote.Id, 'Omnicell', pickListValuesList,true);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest2(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Milestone_Invoice_Term__c = '24';
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Cap','Replacement','Development Product(Omnicell),ServiceNow'};
            List<String> selectedExhibits = new List<String>{'PSOG','EMM','ServiceNow'};
                List<String> selectedSections = new List<String>{'Summary by Par Location','Detail by Par Location','Print Config','Detail by Par Location with pictures'};  
                    String layout = 'Change Order Omnicell';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        //QuotePrintController.updatequotelineExtendedPrice(q.id);
        //QuotePrintController.updatequotelineExtendedService(q.id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest3(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Conga_Quote_Print__c qp = new Conga_Quote_Print__c();        
        qp.Change_Order__c = '';
        qp.Name = 'test_quote_print_record';
        qp.Section_Ids__c = '0000000000';
        qp.Exhibit_Ids__c = '0000000000';
        qp.Print_Output_Format__c = 'PDF';
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Generally','Aesynt'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Detail by Par Location with pictures and signoff','Summary Product Only'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        //Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        
        qp.Quote_Record_ID__c = q.id;
        insert qp;
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        qp.SelectedCannedLanguageNames__c = 'Generally,Aesynt,Test';
        update qp;
        Quote_Approval__c qap = TestDataFactory.createQuoteApprovalRec();
        qap.Quote__c = q.id;
        insert qap;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        //QuotePrintController.updatequotelinewithtotalvaluesupdate(q.id);
        Conga_Email_Template_Contract__c cet = new Conga_Email_Template_Contract__c(Name='Quote Email Template');
        cet.Email_Template_Id__c = '000000000000000';
        insert cet;
        
        //QuotePrintController.sendQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.updateQuoteLine(q.Id);
        //QuotePrintController.CannedLanguagesAesynt();
        
        test.stopTest();
    } 
    public static testmethod void quotePrintControllerClassTest4(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Generally'};
            List<String> selectedExhibits = new List<String>{'IVX','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only'};  
                    
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        qp.selectedExhibitNames__c = 'IVX';
        qp.Print_Output_Format__c = output;
        qp.SelectedCannedLanguageNames__c = 'Generally';
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        //QuotePrintController.updatequotelinewithtotalvaluesupdate(q.id);
        QuotePrintController.getCannedLanguage(q.Id, 'Aesynt', pickListValuesList,true);
        //QuotePrintController.selectedPrintLayout(q.Id);
        //QuotePrintController.selectedexhibits(q.Id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest5(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        QuotePrintController qpc = new QuotePrintController();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT',dw_product_line__c='Connect-Rx',portfolio_segment__c = 'IV Legacy');
        insert prod2;
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        ql1.Product__c = prod2.id;
        //ql1.Quote__c = q.Id;
        ql1.Higher_Level_Item__c = 1;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 200;
        ql1.Contract_List_Price__c = 200;
        //qlines.add(ql1);
        Product2 prod3 = new Product2(Name = 'Simplifi797',Family = 'test',External_ID__c = '123456',ProductCode = 'Simplifi797',dw_product_line__c='Simplifi 797');
        insert prod3;
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType.id;
        ql2.Product__c = prod3.id;
        //ql2.Quote__c = q.Id;
        ql2.Higher_Level_Item__c = 1;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 400;
        ql2.Contract_List_Price__c = 200;
        ql2.Material_Type__c = 'SERVICE';
        //qlines.add(ql2);
        Quote_Line__c ql3 = new Quote_Line__c();
        ql3.RecordTypeId = qlNonConfigRecordType.id;
        ql3.Product__c = prod2.id;
        //ql3.Quote__c = q.Id;
        ql3.Higher_Level_Item__c = 1;
        ql3.Quantity__c = 1;
        ql3.SAP_Line_Number__c = 600;
        ql3.Contract_List_Price__c = 200;
        
        Quote_Line__c ql4 = new Quote_Line__c();
        ql4.RecordTypeId = qlNonConfigRecordType.id;
        ql4.Product__c = prod2.id;
        //ql3.Quote__c = q.Id;
        ql4.Higher_Level_Item__c = 0;
        ql4.Quantity__c = 1;
        ql4.SAP_Line_Number__c = 600;
        ql4.Contract_List_Price__c = 200;
        ql4.discount_percent__c = -100;
        ql4.generic_drawer_product__c = NULL;
        //RJ
        Product2 prod02 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT',dw_product_line__c='Connect-Rx',portfolio_segment__c = 'Central Pharmacy Dispensing Service');
        Quote_Line__c ql30 = new Quote_Line__c();
        ql30.RecordTypeId = qlNonConfigRecordType.id;
        ql30.Product__c = prod2.id;
        //ql3.Quote__c = q.Id;
        ql30.Higher_Level_Item__c = 1;
        ql30.Quantity__c = 1;
        ql30.SAP_Line_Number__c = 600;
        ql30.Contract_List_Price__c = 200;
        ql30.Product__c = prod02.id;
        
        Product2 prod03 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT',dw_product_line__c='Professional Services',portfolio_segment__c = 'Central Pharmacy Dispensing Service');
        Quote_Line__c ql40 = new Quote_Line__c();
        ql40.RecordTypeId = qlNonConfigRecordType.id;
        ql40.Product__c = prod2.id;
        //ql3.Quote__c = q.Id;
        ql40.Higher_Level_Item__c = 1;
        ql40.Quantity__c = 1;
        ql40.SAP_Line_Number__c = 600;
        ql40.Contract_List_Price__c = 200;
        ql40.Product__c = prod03.id;
        //RJ
        //qlines.add(ql3);
        //SF-BUG-934 Start
        Product2 prodWin = new Product2(Name = 'MSA-SUB-006',Family = 'test',External_ID__c = '87654321',ProductCode = 'MSA-SUB-006',dw_product_line__c='Automated Dispensing Cabinets');
        insert prodWin;
        Quote_Line__c qlWin = new Quote_Line__c();
        qlWin.RecordTypeId = qlNonConfigRecordType.id;
        qlWin.Product__c = prodWin.id;
        //qlWin.Quote__c = q.Id;
        qlWin.Higher_Level_Item__c = 1;
        qlWin.Quantity__c = 1;
        qlWin.SAP_Line_Number__c = 800;
        qlWin.Contract_List_Price__c = 200;
        qlWin.Material_Type__c = 'SERVICE';
        //qlines.add(qlWin);
        Win_10_Canned_Language_Product__c winp = new Win_10_Canned_Language_Product__c();
        winp.Name = 'MSA-SUB-006';
        winp.Product_Name__c = 'MSA-SUB-006';
        insert winp;
        Canned_Language__c win = new Canned_Language__c();//name='Win 10 language',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        win.Name='Win 10 language';
        win.Canned_Language_Detail__c='Windows 10';
        win.Omnicell_or_Aesynt__c = 'Omnicell';
        //SF-BUG-934 End
        Canned_Language__c c1 = new Canned_Language__c(name='Simplifi 797',Canned_Language_Detail__c='Test simpnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        Canned_Language__c c2 = new Canned_Language__c(name='IV Products',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        Canned_Language__c c3 = new Canned_Language__c(name='Simplifi 797',Canned_Language_Detail__c='Test simpnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Aesynt');
        Canned_Language__c c4 = new Canned_Language__c(name='IV Products',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Aesynt');
        
        List<Canned_Language__c> clist = new List<Canned_Language__c>();
        clist.add(c1);
        clist.add(c2);
        clist.add(c3);
        clist.add(c4);
        clist.add(win);//SF-BUG-934
        insert clist;
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql1.Quote__c = q.Id;
        ql2.Quote__c = q.Id;
        ql3.Quote__c = q.Id;
        ql4.Quote__c = q.Id;
        ql30.Quote__c = q.id;
        ql40.Quote__c = q.id;
        qlWin.Quote__c = q.Id;
        qlines.add(ql1);
        qlines.add(ql2);
        qlines.add(ql3);
        qlines.add(ql4);
        qlines.add(ql30);
        qlines.add(ql40);
        qlines.add(qlWin);
        insert qlines;
        List<String> pickListValuesList = new List<String>{'Aesynt'};
            List<String> selectedExhibits = new List<String>{'PSOG','EMM'};
                List<String> selectedSections = new List<String>{'Summary Service Only'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        //QuotePrintController.updatequotelinewithtotalvaluesupdate(q.id);
        QuotePrintController.getPrintOptions();
        String[] selectedsec = new String[]{'Summary by Product'};
            //QuotePrintController.updateparlocvalues(q.id,selectedsec,'Summary by Product',false);
            QuotePrintController.initializePrint(q.id);
        //QuotePrintController.compare(q.id);
        QuotePrintController.updateparlocvalues(q.id,selectedsec,'Summary by Par Location',true,false,false);
        //QuotePrintController.updatequotelineExtendedPrice(q.id);
        //QuotePrintController.updatequotelineExtendedService(q.id);
        
        layout = 'Omnicell';//SF-BUG-934 start
        
        QuotePrintController.initializePrint(q.id);
        QuotePrintController.updateparlocvalues(q.id,selectedsec,'Summary by Par Location',true,false,false);
        //SF-BUG-934 End
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest6(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        Quote_Print_Status__c qps = new Quote_Print_Status__c();
        qps.quote__c = q.id;
        qps.Print_Status__c = 'FINISHED';
        qps.revision_number__c = '10';
        insert qps;
        
        QuotePrintController qpc = new QuotePrintController();
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Replacement'};
            List<String> selectedExhibits = new List<String>{'ServiceNow'};
                List<String> selectedSections = new List<String>{'Summary by Par Location'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = true;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        String[] selectedsec = new String[]{'Pictures only'};
            QuotePrintController.updateparlocvalues(q.id,selectedsec,'Pictures only',false,false,false);
        
        //QuotePrintController.updatequotelineExtendedPrice(q.id);
        //QuotePrintController.updatequotelineExtendedService(q.id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest7(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = opp.id;    
        insert pl;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        QuotePrintController qpc = new QuotePrintController();
        Quote_Print_Status__c qps = new Quote_Print_Status__c();
        qps.quote__c = q.id;
        qps.Print_Status__c = 'FINISHED';
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        //ql.Quote__c = q.id;
        ql.Higher_Level_Item__c = 200;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 201;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true; 
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType1.id;
        //ql1.Quote__c = ql.Quote__c;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 200;
        ql1.SAP_Line_Item_GUID__c = '401';
        ql1.Contract_List_Price__c = 200;
        ql1.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = FALSE; 
        ql1.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod1 = new Product2(Name = 'Test Prod',Family = 'test',External_ID__c = '1234567',ProductCode = 'Test Prod');
        insert prod1;
        ql1.Product__c = prod1.id;
        ql1.Sales_Text__c = 'test';
        System.debug('Prod : '+ql1.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        //ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        //Added by Sravan
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
        ql2.Product__c = prod2.id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        ql1.Quote__c = q.Id;
        ql2.Quote__c = q.Id;
        qlList.add(ql);
        qlList.add(ql1);
        qlList.add(ql2);
        insert qlList;
        insert qps;
        //QuotePrintController.updatequotelinewithtotalvaluesupdate(q.Id);
        QuotePrintController.callBatch(q.Id, false);
        QuotePrintController.checkBatch(q.Id);
        String[] selectedsec = new String[]{'Detail by Par Location'};
            QuotePrintController.updateparlocvalues(q.id,selectedsec,'Summary by Product',true,true,true);
        //QuotePrintController.updatequotelinewithtotalvaluesupdate(q.Id);
        QuotePrintController.resetQuoteLineGrouping(q.id);
        QuotePrintController.isSupplementApproval(q.id);
        QuotePrintController.isNotOmnicellServiceOrderType(q.id);
        //QuotePrintController.updatequotelineExtendedService(q.Id);
        test.stopTest();    
        
    }
    public static testmethod void quotePrintControllerClassTest8(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = opp.id;    
        insert pl;
        QuotePrintController qpc = new QuotePrintController();
        Quote_Print_Status__c qps = new Quote_Print_Status__c();
        qps.quote__c = q.id;
        qps.Print_Status__c = 'PROCESSING';
        //qps.Detail_by_par__c = true;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        //ql.Quote__c = q.id;
        ql.Higher_Level_Item__c = 200;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 201;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true; 
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct';
        ql.conga_quantity__c = 0;
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Quote_Line__c ql1 = new Quote_Line__c();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType1.id;
        //ql1.Quote__c = ql.Quote__c;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 200;
        ql1.SAP_Line_Item_GUID__c = '401';
        ql1.Contract_List_Price__c = 200;
        ql1.Conga_product__c = 'Test Prod';
        //Added by Sravan
        ql1.Material_Type__c = 'PRODUCT';
        ql1.Part_of_a_Bundle__c = FALSE; 
        ql1.Customer_Price__c = 200;
        ql1.conga_quantity__c = 0;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod1 = new Product2(Name = 'Test Prod',Family = 'test',External_ID__c = '1234567',ProductCode = 'Test Prod');
        insert prod1;
        ql1.Product__c = prod1.id;
        ql1.Sales_Text__c = 'test';
        System.debug('Prod : '+ql1.product__r.productcode);
        Quote_Line__c ql2 = new Quote_Line__c();
        ql2.RecordTypeId = qlNonConfigRecordType1.id;
        //ql2.Quote__c = ql.Quote__c;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 600;
        ql2.SAP_Line_Item_GUID__c = '402';
        ql2.Contract_List_Price__c = 200;
        ql2.conga_quantity__c = 0;
        ql2.Conga_product__c = 'LEASE BUYOUT';
        //Added by Sravan
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = FALSE; 
        ql2.Customer_Price__c = 200;
        //ql1.Conga_Product__c = 'TestProduct';
        Product2 prod2 = new Product2(Name = 'LEASE BUYOUT',Family = 'test',External_ID__c = '12345678',ProductCode = 'LEASE BUYOUT');
        insert prod2;
        ql2.Product__c = prod2.id;
        ql2.Sales_Text__c = 'test';
        System.debug('Prod : '+ql2.product__r.productcode);
        
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        ql1.Quote__c = q.Id;
        ql2.Quote__c = q.Id;
        qlList.add(ql);
        qlList.add(ql1);
        qlList.add(ql2);
        insert qlList;
        insert qps;
        Conga_Quote_Print__c cqp = new Conga_Quote_Print__c();
        cqp.Select_Canned_Language__c = 'test';
        cqp.SelectedCannedLanguageNames__c = 'test';
        cqp.Quote_Record_ID__c = q.id;
        insert cqp;
        QuotePrintController.checkPrintCurrency(q.Id);
        QuotePrintController.setPrintFlag(q.id);
        String[] selectedCannedLan = new String[]{'test'};
            QuotePrintController.chkCannedLanguage(q.Id,selectedCannedLan);
        String[] selectedsec = new String[]{'Detail by Par Location'};
            //QuotePrintController.updateparlocvalues(q.id,selectedsec,'Detail by Par Location',false,false,false);
        String[] selectedsec1 = new String[]{'summary by product'};
            //QuotePrintController.updateparlocvalues(q.id,selectedsec1,'summary by product',false,false,false);
        test.stopTest();    
        
    }
    
    public static testmethod void quotePrintControllerClassTest9(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = opp.id;    
        insert pl;
        QuotePrintController qpc = new QuotePrintController();
        Quote_Print_Status__c qps = new Quote_Print_Status__c();
        qps.quote__c = q.id;
        qps.Print_Status__c = 'FAILED';
        //qps.Detail_by_par__c = false;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        //ql.Quote__c = q.id;
        ql.Higher_Level_Item__c = 200;
        ql.conga_higher_level_item__c = '200';
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 201;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true; 
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        //qlList.add(ql);
        
        //insert qps;
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //insert qlList;
        Conga_Quote_Print__c cqp = new Conga_Quote_Print__c();
        cqp.Select_Canned_Language__c = 'test';
        cqp.SelectedCannedLanguageNames__c = 'test';
        cqp.Quote_Record_ID__c = q.id;
        insert cqp;
        String[] selectedsec = new String[]{'Detail by Par Location'};
            QuotePrintController.updateparlocvalues(q.id,selectedsec,'Detail by Par Location',false,false,true);
        String[] prev = new String[] {'test1'};
            String[] newcan = new String[] {'test2'};    
                QuotePrintController.saveCannedLan('test', q.id, prev, newcan, 'Omnicell', true);
        insert qps;
        QuotePrintController.checkBatch(q.id);
        QuotePrintController.saveCannedLan('test', q.id, prev, newcan, 'Aesynt', true);
        qps.Print_Status__c = 'FAILED';
        update qps;
        QuotePrintController.checkBatch(q.id);
        delete qps;
        QuotePrintController.checkBatch(q.id);
        test.stopTest();    
        
    }
    public static testmethod void quotePrintControllerClassTest10(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        Canned_Language__c win = new Canned_Language__c(name='Win 10 language',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        clList.add(win);//SF-BUG-934
        Canned_Language__c cl10 = new Canned_Language__c(name='MI: 100% signed Bonding Agreement',Canned_Language_Detail__c='Test',Omnicell_or_Aesynt__c = 'Omnicell');
        clList.add(cl10);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Milestone_Invoice_Term__c = '24';
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        //SF-BUG-934 start
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        Product2 prodWin = new Product2(Name = 'MSA-SUB-006',Family = 'test',External_ID__c = '87654321',ProductCode = 'MSA-SUB-006',dw_product_line__c='Automated Dispensing Cabinets');
        insert prodWin;
        Quote_Line__c qlWin = new Quote_Line__c();
        qlWin.RecordTypeId = qlNonConfigRecordType1.id;
        qlWin.Product__c = prodWin.id;
        //qlWin.Quote__c = q.Id;
        qlWin.Higher_Level_Item__c = 1;
        qlWin.Quantity__c = 1;
        qlWin.SAP_Line_Number__c = 800;
        qlWin.Contract_List_Price__c = 200;
        qlWin.Material_Type__c = 'SERVICE';
        
        Win_10_Canned_Language_Product__c winp = new Win_10_Canned_Language_Product__c();
        winp.Name = 'MSA-SUB-006';
        winp.Product_Name__c = 'MSA-SUB-006';
        //insert winp;
        //SF-BUG-934 End
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Summary by Product with Zero Dollars', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        qlWin.Quote__c = q.Id;
        qlines.add(qlWin);
        qlines.add(ql);
        insert qlines;//SF-BUG-934
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest11(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        Canned_Language__c cl10 = new Canned_Language__c(Name='MI: 40% Order 40% Delivery & 20% Acceptance',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl10);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Milestone_Invoice_Term__c = '25';
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Display Usa Price List', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest12(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        Canned_Language__c cl10 = new Canned_Language__c(Name='MI: 40% PS Signature & 60% Bonding Agreement',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl10);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Milestone_Invoice_Term__c = '23';
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Summary by Product', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = true;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest13(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Generic Drawers', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest14(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Summary Service Only', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest15(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'u+s + qserv + nongeneric', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest16(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'general + qzero + generic', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest17(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'service + qserv + generic', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = true;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,true);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest18(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'usa + qzero + nongeneric', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest19(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'usa + qlicustom + generic', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = false;
        boolean unbundled = true;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest20(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'u+s + qserv + nongeneric', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        Quote_Print_Compare__c cmp = new Quote_Print_Compare__c();
        cmp.Name = 'Do Revision Check';
        cmp.turn_off_revision_check__c = false;
        insert cmp;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        //QuotePrintController.compare(q.id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest21(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'general + qzero + generic', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = true;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest22(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'general + qzero + nongeneric', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.selectedexhibits(q.Id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest23(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'service + qserv + nongeneric', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = true;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.selectedPrintLayout(q.Id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest24(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'usa + qzero + generic', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList,false);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest25(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'u+s + qserv + nongeneric', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.getQuote(q.Id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest26(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'service + qserv + generic', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = true;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.getUser();
        QuotePrintController.CannedLanguagesOmnicell();
        QuotePrintController.getPrintOptions();
        //QuotePrintController.selectedCannedLan(q.Id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest27(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Conga_Quote_Print__c qp = new Conga_Quote_Print__c();        
        qp.Change_Order__c = '';
        qp.Name = 'test_quote_print_record';
        qp.Section_Ids__c = '0000000000';
        qp.Exhibit_Ids__c = '0000000000';
        qp.Print_Output_Format__c = 'PDF';
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Generally','Aesynt'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Detail by Par Location with pictures and signoff','Summary Product Only'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = true;
        boolean genericdrawers = true;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        
        qp.Quote_Record_ID__c = q.id;
        insert qp;
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        qp.SelectedCannedLanguageNames__c = 'Generally,Aesynt,Test';
        update qp;
        Quote_Approval__c qap = TestDataFactory.createQuoteApprovalRec();
        qap.Quote__c = q.id;
        insert qap;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        //QuotePrintController.updatequotelinewithtotalvaluesupdate(q.id);
        Conga_Email_Template_Contract__c cet = new Conga_Email_Template_Contract__c(Name='Quote Email Template');
        cet.Email_Template_Id__c = '000000000000000';
        insert cet;
        
        //QuotePrintController.quotedraftprint(qp.Name, q.Id);
        test.stopTest();
    } 
    public static testmethod void quotePrintControllerClassTest28(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'service + qserv + generic', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = true;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.selectedCannedLan(q.Id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest29(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        q.subscription_Months__c = 84;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Conga_Quote_Print__c qp = new Conga_Quote_Print__c();        
        qp.Change_Order__c = '';
        qp.Name = 'test_quote_print_record';
        qp.Section_Ids__c = '0000000000';
        qp.Exhibit_Ids__c = '0000000000';
        qp.Print_Output_Format__c = 'PDF';
        
        Quote_Approval__c qta = new Quote_Approval__c();
        qta.RecordTypeId = recTypeQuoteApproval;
        qta.Need_Manual_Approval__c = true;
        qta.Status__c = 'Approved';
        qta.Requires_Deal_Desk_Approval__c=TRUE;
        qta.Requires_Legal_Approval__c=true;
        qta.Requires_RX_Config_Approval__c=true;
        qta.Requires_Sales_Finance_Approval__c=true;
        qta.Requires_Tech_Svcs_Approval__c=true;
        qta.Need_CSC_Approval__c=true;
        qta.Need_Finance_Team_Approval__c=true;
        qta.Need_Operations_Team_Approval__c=true;
        qta.Discounting__c=true;
        
        List<String> pickListValuesList = new List<String>{'Generally','Aesynt'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Detail by Par Location with pictures and signoff','Summary Product Only'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        
        //Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        
        qp.Quote_Record_ID__c = q.id;
        insert qp;
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        qp.SelectedCannedLanguageNames__c = 'Generally,Aesynt,Test';
        
        update qp;
        
        qta.Quote__c = q.id;
        
        //insert qta;
        
        QuotePrintController.CannedLanguagesAesynt();
        QuotePrintController.isSupplementApproval(q.id);
        test.stopTest();
    } 
    public static testmethod void quotePrintControllerClassTest30(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        Canned_Language__c win = new Canned_Language__c(name='Win 10 language',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        clList.add(win);//SF-BUG-934
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        q.subscription_Months__c = 84;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        
        
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement', template_id__c = 'testid1');
        btList.add(b2);
        Conga_Base_Template__c b3 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW Prof', template_id__c = 'testid3');
        btList.add(b3);
        Conga_Base_Template__c b4 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement Prof', template_id__c = 'testid14');
        btList.add(b4);
        Conga_Base_Template__c b5 = new Conga_Base_Template__c(Name = 'Summary by Product OmnicellService', template_id__c = 'testid15');
        btList.add(b5);
        Conga_Base_Template__c b6 = new Conga_Base_Template__c(Name = 'Pass SOW', template_id__c = 'testid16');
        btList.add(b6);
        Conga_Base_Template__c b7 = new Conga_Base_Template__c(Name = 'Summary By Omnicell IVX Workflow', template_id__c = 'testid17');
        btList.add(b7);
        insert btList;
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        
        qlines.add(ql);
        insert qlines;
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest31(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Conga_Quote_Print__c qp = new Conga_Quote_Print__c();        
        qp.Change_Order__c = '';
        qp.Name = 'test_quote_print_record';
        qp.Section_Ids__c = '0000000000';
        qp.Exhibit_Ids__c = '0000000000';
        qp.Print_Output_Format__c = 'PDF';
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Generally','Aesynt'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Detail by Par Location with pictures and signoff','Summary Product Only'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        //Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        
        qp.Quote_Record_ID__c = q.id;
        insert qp;
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        qp.SelectedCannedLanguageNames__c = 'Generally,Aesynt,Test';
        update qp;
        Quote_Approval__c qap = TestDataFactory.createQuoteApprovalRec();
        qap.Quote__c = q.id;
        insert qap;
        
        //QuotePrintController.updatequotelinewithtotalvaluesupdate(q.id);
        Conga_Email_Template_Contract__c cet = new Conga_Email_Template_Contract__c(Name='Quote Email Template');
        cet.Email_Template_Id__c = '000000000000000';
        insert cet;
        
        QuotePrintController.sendQuotePrintRecord(qp.Name, q.Id);
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest32(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Conga_Quote_Print__c qp = new Conga_Quote_Print__c();        
        qp.Change_Order__c = '';
        qp.Name = 'test_quote_print_record';
        qp.Section_Ids__c = '0000000000';
        qp.Exhibit_Ids__c = '0000000000';
        qp.Print_Output_Format__c = 'PDF';
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Generally','Aesynt'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Detail by Par Location with pictures and signoff','Summary Product Only'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = true;
        boolean genericdrawers = true;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        
        qp.Quote_Record_ID__c = q.id;
        insert qp;
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        qp.SelectedCannedLanguageNames__c = 'Generally,Aesynt,Test';
        update qp;
        Quote_Approval__c qap = TestDataFactory.createQuoteApprovalRec();
        qap.Quote__c = q.id;
        insert qap;
        
        Conga_Email_Template_Contract__c cet = new Conga_Email_Template_Contract__c(Name='Quote Email Template');
        cet.Email_Template_Id__c = '000000000000000';
        insert cet;
        
        QuotePrintController.quotedraftprint(qp.Name, q.Id);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest33(){//Added by SOurav
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        insert clList;
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        //quote.Quote_Number__c = 'test123';
        //quote.OpportunityId = createOppWithAccount_Integration1().Id;
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        quote.OpportunityId = opp.Id;
        
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
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
        insert quote;
        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        QuotePrintController qpc = new QuotePrintController();
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Summary by Product with Zero Dollars', template_id__c = 'testid');
        btList.add(b2);
        insert btList;
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase'};
            //'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = true;
        boolean zerodollars = true;
        boolean unbundled = true;
        boolean genericdrawers = true;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(quote.Id);
        qp.Print_Layout__c = layout;
        qp.SelectedCannedLanguageNames__c = 'Buyout Products,Development Product(Omnicell),ServiceNow,Connect-RX Upgrade,Classic Hardware EOL –Lease,Definitions';
        
        update qp;
        Conga_Quote_Print__c cqp = new Conga_Quote_Print__c();
        //Select_Canned_Language__c,Check_Select_Canned_Language__c,SelectedCannedLanguageNames__c
        cqp.Select_Canned_Language__c = 'Test Canned Language';
        cqp.SelectedCannedLanguageNames__c = 'Buyout Products,Development Product(Omnicell),ServiceNow,Connect-RX Upgrade,Classic Hardware EOL –Lease,Definitions,Fee Increase,Omnicell Capital Program';
        cqp.Quote_Record_Id__c = quote.Id;
        insert cqp;
        
        QuotePrintController.updateQuote(quote.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, quote.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(quote.Id, 'Omnicell', pickListValuesList,true);
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest34(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Non-GA Waiver (A)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='Definitions',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='SS: PO at Sign. (A)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='SS: Cust. Delay (A)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        Canned_Language__c win = new Canned_Language__c(name='Win 10 language',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        clList.add(win);//SF-BUG-934
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        //SF-BUG-934 start
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        Product2 prodWin = new Product2(Name = 'MSA-SUB-006',Family = 'test',External_ID__c = '87654321',ProductCode = 'MSA-SUB-006',dw_product_line__c='Automated Dispensing Cabinets');
        insert prodWin;
        Quote_Line__c qlWin = new Quote_Line__c();
        qlWin.RecordTypeId = qlNonConfigRecordType1.id;
        qlWin.Product__c = prodWin.id;
        //qlWin.Quote__c = q.Id;
        qlWin.Higher_Level_Item__c = 1;
        qlWin.Quantity__c = 1;
        qlWin.SAP_Line_Number__c = 800;
        qlWin.Contract_List_Price__c = 200;
        qlWin.Material_Type__c = 'SERVICE';
        
        Win_10_Canned_Language_Product__c winp = new Win_10_Canned_Language_Product__c();
        winp.Name = 'MSA-SUB-006';
        winp.Product_Name__c = 'MSA-SUB-006';
        //insert winp;
        //SF-BUG-934 End
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'u+s + qserv + generic', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Summary by Product with Zero Dollars', template_id__c = 'testid1');
        btList.add(b2);
        insert btList;
        //1
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        qlWin.Quote__c = q.Id;
        qlines.add(qlWin);
        qlines.add(ql);
        insert qlines;//SF-BUG-934
        //Quote_Line__c ql = TestDataFactory.createTestQuoteLine_WithQuoteId(q.Id);
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','PSOG','EMM','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Aesynt';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Aesynt', pickListValuesList,true);
        
        test.stopTest();
    }
    
    static testmethod void comparetest(){
        
        AccountTriggerHandler.TriggerDisabled = true;        
        Test.setMock(HttpCalloutMock.class, new Compare_MockCallout_API_Response());
        Quote quote = new Quote();
            quote.name = 'Test Quote';
            List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
            quote.Pricebook2Id = Test.getStandardPricebookId();
            quote.Currency__c = 'USD';
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
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
            quote.OpportunityId = opp.Id;
            quote.Service_PO_Number__c = '1234';
            quote.Product_PO_Number__c = '1234';
            quote.Supplement_Generated__c = '01';
            QuoteTriggerHandler.TriggerDisabled = true;
            
            insert quote;
            quote.Status = 'E0001';
            quote.Quote_Number__c = '1234';
            quote.Create_Sales_Order__c = true;
            quote.SAP_Sales_Order_Number__c = '0010327200';
            update quote;
        
        
        Product2 pr = new Product2();
        pr.Name = 'CPA-CAR-069';
        pr.ProductCode = 'CPA-CAR-069';
        pr.CurrencyIsoCode = 'USD';
        pr.External_ID__c='CPA-CAR-069';
        insert pr;
        
        Quote_Line__c Qline= new Quote_Line__c();
        Quote_Line__c QlineList;
      //  Qline.RecordTypeId = '0124F0000004OQ9QAM';
        
        Qline.Customer_Price__c = 123;
        Qline.Product__c = pr.Id;
        Qline.Conga_Grouped_Product__c =true;
        
          
        Qline.Conga_Quantity__c= 2.000;
        Qline.Conga1_USA_List_Price__c =332150.00;
        Qline.Conga_List_Price__c= 276250.00;
        Qline.Conga_Unit_Price__c = 276250.00;
        Qline.Conga_Extended_Price_Materials__c =276250; 
        
        
        Quote_Print_Status__c qpt = new Quote_Print_Status__c();
        
        qpt.Revision_Number__c='6';
        
        Qline.Quote__c = quote.Id;
        QuoteLineTriggerHandler.TriggerDisabled = true;
        insert Qline;
        qpt.Quote__c =quote.Id;
        insert qpt;
        
        
        
        Test.startTest();
        
        QuotePrintController.compareQuoteLine(quote.id);
        Test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest40(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        q.subscription_Months__c = 84;
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
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV');
        insert prod;
        ql.Product__c = prod.id;
                Quote_Line__c ql1 = new Quote_Line__c();
//        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        ql1.Quote__c = q.Id;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 0;
       ql1.SAP_Line_Item_GUID__c = '400';
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = 'SERVICE';
        ql1.Part_of_a_Bundle__c = true;
       ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = 'TestProduct-SV';
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0006';
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        ql1.Product__c = prod1.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        Conga_Quote_Print__c qp = new Conga_Quote_Print__c();        
        qp.Change_Order__c = '';
        qp.Name = 'test_quote_print_record';
        qp.Section_Ids__c = '0000000000';
        qp.Exhibit_Ids__c = '0000000000';
        qp.Print_Output_Format__c = 'PDF';
        
        Quote_Approval__c qta = new Quote_Approval__c();
        qta.RecordTypeId = recTypeQuoteApproval;
        qta.Need_Manual_Approval__c = true;
        qta.Status__c = 'Approved';
        qta.Requires_Deal_Desk_Approval__c=TRUE;
        qta.Requires_Legal_Approval__c=true;
        qta.Requires_RX_Config_Approval__c=true;
        qta.Requires_Sales_Finance_Approval__c=true;
        qta.Requires_Tech_Svcs_Approval__c=true;
        qta.Need_CSC_Approval__c=true;
        qta.Need_Finance_Team_Approval__c=true;
        qta.Need_Operations_Team_Approval__c=true;
        qta.Discounting__c=true;
        
        List<String> pickListValuesList = new List<String>{'Generally','Aesynt'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx','ServiceNow','Simplifi 797'};
                List<String> selectedSections = new List<String>{'Detail by Par Location with pictures and signoff','Summary Product Only'};  
                    String layout = 'Change Order Aesynt';
        String language = 'English';
        String output = 'Microsoft Word';
        String template = 'Pictures Only';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = true;
        Integer noofpictures = 4;
        String editedterms = '';
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        ql1.Quote__c = q.Id;
        insert ql1;
        
        
        //Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        
        qp.Quote_Record_ID__c = q.id;
        insert qp;
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        qp.SelectedCannedLanguageNames__c = 'Generally,Aesynt,Test';
        
        update qp;
        
        qta.Quote__c = q.id;
        
        //insert qta;
        
        QuotePrintController.CannedLanguagesAesynt();
        
        test.stopTest();
    } 
     public static testmethod void quotePrintControllerClassTest41(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        Canned_Language__c win = new Canned_Language__c(name='Win 10 language',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        clList.add(win);//SF-BUG-934
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        q.subscription_Months__c = 84;
       Quote_Approval__c qta = new Quote_Approval__c();
        qta.RecordTypeId = recTypeQuoteApproval;
        qta.Need_Manual_Approval__c = true;
        qta.Status__c = 'Approved';
        qta.Requires_Deal_Desk_Approval__c=TRUE;
        qta.Requires_Legal_Approval__c=true;
        qta.Requires_RX_Config_Approval__c=true;
        qta.Requires_Sales_Finance_Approval__c=true;
        qta.Requires_Tech_Svcs_Approval__c=true;
        qta.Need_CSC_Approval__c=true;
        qta.Need_Finance_Team_Approval__c=true;
        qta.Need_Operations_Team_Approval__c=true;
        qta.Discounting__c=true;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
                     Quote_Line__c ql1 = new Quote_Line__c();
//        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        ql1.Quote__c = q.Id;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 0;
       ql1.SAP_Line_Item_GUID__c = '400';
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = 'SERVICE';
        ql1.Part_of_a_Bundle__c = true;
       ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = 'TestProduct-SV';
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0006';
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        ql1.Product__c = prod1.id;
        
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement', template_id__c = 'testid1');
        btList.add(b2);
        Conga_Base_Template__c b3 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW Prof', template_id__c = 'testid3');
        btList.add(b3);
        Conga_Base_Template__c b4 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement Prof', template_id__c = 'testid14');
        btList.add(b4);
        Conga_Base_Template__c b5 = new Conga_Base_Template__c(Name = 'Summary by Product OmnicellService', template_id__c = 'testid15');
        btList.add(b5);
        Conga_Base_Template__c b6 = new Conga_Base_Template__c(Name = 'Pass SOW', template_id__c = 'testid16');
        btList.add(b6);
        Conga_Base_Template__c b7 = new Conga_Base_Template__c(Name = 'Summary By Omnicell IVX Workflow', template_id__c = 'testid17');
        btList.add(b7);
        insert btList;
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        ql1.Quote__c = q.Id;
         
        qlines.add(ql);
         qlines.add(ql1);
        insert qlines;
          qta.Quote__c = q.id;
        
        insert qta;
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest42(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL –Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl3);
        Canned_Language__c cl4 = new Canned_Language__c(Name='Fee Increase',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl4);
        Canned_Language__c cl5 = new Canned_Language__c(Name='Omnicell Capital Program',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl5);
        Canned_Language__c cl6 = new Canned_Language__c(Name='Development Product(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl6);
        Canned_Language__c cl7 = new Canned_Language__c(Name='Replacement Products(Aesynt)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl7);
        Canned_Language__c cl8 = new Canned_Language__c(Name='Buyout Products',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl8);
        Canned_Language__c cl9 = new Canned_Language__c(Name='Maintenance Extension',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Aesynt');
        clList.add(cl9);
        Canned_Language__c win = new Canned_Language__c(name='Win 10 language',Canned_Language_Detail__c='Test IVXnum 1 DAY LESS THAN BELOW ANNUAL BILL DATE',Omnicell_or_Aesynt__c = 'Omnicell');
        clList.add(win);//SF-BUG-934
        insert clList;
        AccountCreateController.isFirstRun= false;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        q.subscription_Months__c = 84;
       Quote_Approval__c qta = new Quote_Approval__c();
        qta.RecordTypeId = recTypeQuoteApproval;
        qta.Need_Manual_Approval__c = true;
        qta.Status__c = 'Approved';
        qta.Requires_Deal_Desk_Approval__c=TRUE;
        qta.Requires_Legal_Approval__c=true;
        qta.Requires_RX_Config_Approval__c=true;
        qta.Requires_Sales_Finance_Approval__c=true;
        qta.Requires_Tech_Svcs_Approval__c=true;
        qta.Need_CSC_Approval__c=true;
        qta.Need_Finance_Team_Approval__c=true;
        qta.Need_Operations_Team_Approval__c=true;
        qta.Discounting__c=true;
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        QuotePrintController qpc = new QuotePrintController();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
                     Quote_Line__c ql1 = new Quote_Line__c();
//        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql1.RecordTypeId = qlNonConfigRecordType.id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        ql1.Quote__c = q.Id;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 0;
       ql1.SAP_Line_Item_GUID__c = '400';
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = 'SERVICE';
        ql1.Part_of_a_Bundle__c = true;
       ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = 'TestProduct-SV';
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0006';
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        ql1.Product__c = prod1.id;
        Quote_Line__c ql2 = new Quote_Line__c();
          ql2.RecordTypeId = qlNonConfigRecordType.id;
        //Quote q = TestDataFactory.createTestQuote_Integration();
        ql2.Quote__c = q.Id;
        ql2.Higher_Level_Item__c = 0;
        ql2.Quantity__c = 1;
        ql2.SAP_Line_Number__c = 0;
        ql2.SAP_Line_Item_GUID__c = '600';
        ql2.Sales_Text__c = 'test';
        ql2.Material_Type__c = 'SERVICE';
        ql2.Part_of_a_Bundle__c = true;
        ql2.Customer_Price__c = 200;
        ql2.Conga_Product__c = 'MSA-TRN-005';
        ql2.Contract_List_Price__c = 200;
        ql2.Line_Status__c = 'E0006';
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        ql2.Product__c = prod.id;
          
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW', template_id__c = 'testid');
        btList.add(b1);
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement', template_id__c = 'testid1');
        btList.add(b2);
        Conga_Base_Template__c b3 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW Prof', template_id__c = 'testid3');
        btList.add(b3);
        Conga_Base_Template__c b4 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement Prof', template_id__c = 'testid14');
        btList.add(b4);
        Conga_Base_Template__c b5 = new Conga_Base_Template__c(Name = 'Summary by Product OmnicellService', template_id__c = 'testid15');
        btList.add(b5);
        Conga_Base_Template__c b6 = new Conga_Base_Template__c(Name = 'Pass SOW', template_id__c = 'testid16');
        btList.add(b6);
        Conga_Base_Template__c b7 = new Conga_Base_Template__c(Name = 'Summary By Omnicell IVX Workflow', template_id__c = 'testid17');
        btList.add(b7);
        insert btList;
        
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        ql1.Quote__c = q.Id;
          ql2.Quote__c = q.Id;
         
        qlines.add(ql);
         qlines.add(ql1);
          qlines.add(ql2);
        insert qlines;
          qta.Quote__c = q.id;
        
        insert qta;
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
            List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
                List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
                    String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'APSA - Default';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest43(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'APSA - Default';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest43_1(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Central Pharmacy Dispensing Service');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'APSA - Default';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest44(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CPDS –Central Pharmacy Dispensing Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Advanced Service Agreement Services';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest_44_ZQR(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
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
        Product2 prod = new Product2(Name = 'OC1-LAB-001',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'OC1-LAB-001',SAP_Product_Type__c = 'testsap',portfolio_segment__c = 'Inventory Optimization Service and Platform');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Software Licensing OC','PT: Software Subscription OC'};
            List<String> selectedExhibits = new List<String>{'PSOG','EMM','ServiceNow'};
                List<String> selectedSections = new List<String>{'Summary by Par Location'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList, true);
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest_44_ZQR_4072_1(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
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
        Product2 prod = new Product2(Name = 'XR2-KIT-200',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'XR2-KIT-200',SAP_Product_Type__c = 'testsap',portfolio_segment__c = 'Central Pharmacy Dispensing Service');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Software Licensing OC','PT: Software Subscription OC'};
            List<String> selectedExhibits = new List<String>{'PSOG','EMM','ServiceNow'};
                List<String> selectedSections = new List<String>{'Summary by Par Location'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList, true);
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest_44_ZQR_4072_2(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        Quote q = new Quote();
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        //quote.ContactId=createContactWithAccount_Integration().Id;
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();  
        q.OpportunityId = opp.Id;
        
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
        Product2 prod = new Product2(Name = 'PSV-SVC-001-17',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'PSV-SVC-001-17',SAP_Product_Type__c = 'testsap',portfolio_segment__c = 'Central Pharmacy Dispensing Service');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        test.startTest();
        insert q;
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        
        update q;
        ql.Quote__c = q.Id;
        insert ql;
        
        List<String> pickListValuesList = new List<String>{'Software Licensing OC','PT: Software Subscription OC'};
            List<String> selectedExhibits = new List<String>{'PSOG','EMM','ServiceNow'};
                List<String> selectedSections = new List<String>{'Summary by Par Location'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'Summary by Product';
        Boolean usalist = false;
        boolean zerodollars = false;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        qp.Print_Output_Format__c = output;
        update qp;
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,'',false);
        QuotePrintController.deleteQuotePrintRecord(qp.Name, q.Id);
        QuotePrintController.getPrintOptions();
        QuotePrintController.getCannedLanguage(q.Id, 'Omnicell', pickListValuesList, true);
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest44_0(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'XR2 System');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CPDS –Central Pharmacy Dispensing Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Advanced Service Agreement Services';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Autonomous Pharmacy Solutions Agreement';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest44_1(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'XR2 System');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CPDS –Central Pharmacy Dispensing Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Advanced Service Agreement Services';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Autonomous Pharmacy Solutions Agreement';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work Services';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest44_2(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CPDS –Central Pharmacy Dispensing Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Advanced Service Agreement Services';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Autonomous Pharmacy Solutions Agreement';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work Services';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest44_3(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'XR2 System');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CPDS –Central Pharmacy Dispensing Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work for CMA MA';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work Services Only for CMA MA';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest44_3_2(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'XR2-KIT-200',DW_Product_Line__c = 'XR2 System');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CPDS –Central Pharmacy Dispensing Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work for CMA MA';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work Services Only for CMA MA';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest44_4(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CPDS –Central Pharmacy Dispensing Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work for CMA MA';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work Services Only for CMA MA';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work Services';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest45(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVCS-IV Compounding Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Advanced Service Agreement Services';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest45_0(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Central Pharmacy Dispensing Service');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVCS-IV Compounding Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Advanced Service Agreement Services';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Autonomous Pharmacy Solutions Agreement';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest45_1(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'IVX Station');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Region__c='Northeast';
        q.IDN_Price_List__c='A1';
        q.Pricing_Reference_Date__c=system.today();
        q.Requested_Delivery_Date__c = system.today();
        q.Booking_Date__c=system.today();
        q.ExpirationDate = system.today();
        q.SAP_Last_Line_Number__c = 200;
        q.EOL_Date__c = System.today()+200;
        q.Supplement_Version__c = 2;
        q.Status = 'E0009';
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVCS-IV Compounding Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Advanced Service Agreement Services';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Autonomous Pharmacy Solutions Agreement';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work Services';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest45_2(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Region__c='Northeast';
        q.GPO_Price_Lists__c='A0';
        q.Pricing_Reference_Date__c=system.today();
        q.Requested_Delivery_Date__c = system.today();
        q.Booking_Date__c=system.today();
        q.ExpirationDate = system.today();
        q.SAP_Last_Line_Number__c = 200;
        q.EOL_Date__c = System.today()+200;
        q.Supplement_Version__c = 2;
        q.Status = 'E0009';
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVCS-IV Compounding Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Advanced Service Agreement Services';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Autonomous Pharmacy Solutions Agreement';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work Services';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest45_3(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'IVX Station');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVCS-IV Compounding Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work for CMA MA';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work Services Only for CMA MA';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest45_4(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX',/*'CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One',*/'Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVCS-IV Compounding Services';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work for CMA MA';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        //agreementType = 'Statement of Work';
        //QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
        //                                 zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work Services Only for CMA MA';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest46(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVX Workflow';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest46_4020(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVX Workflow';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Statement of Work Services';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest46_1(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVX Workflow';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest46_2(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        //qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'IVX Workflow';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest47(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'PASS –Packaging and Service Subscription';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    
    public static testmethod void quotePrintControllerClassTest48(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        
        
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CarePlus';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
    public static testmethod void quotePrintControllerClassTest49(){
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        TestDataFactory.createCannedLan();
        AccountCreateController.isFirstRun= false;
        Account acc = new Account(
            Name = 'Test Account',
            Account_role__c = 'ZCSN',
            Account_Status__c = 'Active',
            IsDeleted__c = false,
            BillingCountryCode = 'US',
            Annual_Bill_Date__c = System.today(),
            BillingStreet = '200 South Bascom Avenue',
            BillingCountry = 'United States',
            BillingCity = 'San Jose',
            BillingState = 'California',
            Facility_Type__c = 'Critical Access',
            BillingPostalCode = '95128',
            SAP_Account_ID__c = '123456' + System.now().millisecond() + Math.round(Math.random() * 10000),
            Validation_Status__c = 'Validated'
        );
        insert acc;
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(
            Account__c = acc.Id,
            Sales_org__c = 'AU01',
            Sales_Office__c = 'AU03',
            Incoterms_1__c = 'DAP',
            District__c = 'US0007',
            Distribution_Channel__c = '01',
            Customer_Pricing_Procedure__c = '1',
            SAP_Division__c = '00',
            Incoterms_2__c = 'Test',
            tax_classification__c = '1',
            Terms_of_Payment__c = 'MD10',
            Shipping_Conditions__c = '01'
        );
        insert ssoc;
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = '1 Solution Design',
            CloseDate = System.today() + 30,
            ExpectedInstallDate__c = System.today() + 60,
            Opportunity__c = 'Omnicell Opportunity',
            Services_Enablement_Owner__c = 'Tara Bakker',
            OppStatus__c = 'Open',
            AccountId = acc.Id
        );
        insert opp;
        Product2 prod1 = new Product2(Name = 'Test1Product-SV',Family = 'test1',External_ID__c = '1234567890124',ProductCode = 'TestProduct1-SV',DW_Product_Line__c = 'Professional Services');
        insert prod1;
        TestDataFactory.createOCProd('TestProduct1-SV');
        Product2 prod = new Product2(Name = 'MSA-TRN-005',Family = 'test',External_ID__c = '1234567890193',ProductCode = 'MSA-TRN-005');
        insert prod;
        TestDataFactory.createReplProd('MSA-TRN-005');
        TestDataFactory.createWinProd('MSA-TRN-005');
        Quote q = new Quote();
        List<Quote_Line__c> qlines = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        q.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
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
        q.Shipping_Contact__c= c[0].Id;
        q.Order_Type__c = 'ZQRS';
        q.SAP_Sales_Org__c = ssoc.Id;
        q.OpportunityId = opp.Id;
        q.Supplement_or_budgetary__c = 'supplement';
        q.subscription_Months__c = 84;
        insert q;
        
        TestDataFactory.createQAP(q,recTypeQuoteApproval);        
        Map<String,Product2> zqrsProdMap = TestDataFactory.createZQRSProd();
        
        Quote_Line__c ql = new Quote_Line__c();
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        ql.Quote__c = q.Id;
        qlines.add(ql);
        
        qlines.add(TestDataFactory.createQTLine(prod1,q,'400','SERVICE'));
        qlines.add(TestDataFactory.createQTLine(prod,q,'600','SERVICE'));
        
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('CPDS'),q,'800',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVCS'),q,'1000',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('PASS'),q,'1200',''));
        qlines.add(TestDataFactory.createQTLine(zqrsProdMap.get('IVX'),q,'1400',''));
        
        
        TestDataFactory.createCongaBaseTemplateCS();
        
        test.startTest();
        Boolean isSalesOrgInt = QuotePrintController.getSAPSalesOrgAndCurrency(q.Id);
        System.assertEquals(false, isSalesOrgInt);
        Boolean isMaPass = QuotePrintController.ismaPassSupplementApproval(q.Id);
        System.assertEquals(false, isMaPass);
        Boolean result1 = QuotePrintController.isNotOmnicellServiceOrderType(q.Id);
        System.assertEquals(true, result1);
        String result2 = QuotePrintController.checkBatch(q.Id);
        System.assertEquals('batchnotstarted', result2);
        q.Quote_Number__c = '1234';
        q.Create_Sales_Order__c = true;
        update q;

        insert qlines;
        
        List<String> pickListValuesList = new List<String>{'Buyout Products','Development Product(Omnicell)','ServiceNow','Connect-RX Upgrade','Classic Hardware EOL –Lease','Definitions','Fee Increase','Omnicell Capital Program'};
        List<String> selectedExhibits = new List<String>{'IVX','CRx Upgrade','Performance Center (PSOG only)','Performance Center (w. EMM)','ServiceNow','Simplifi 797','Omnicell One','Professional Service'};
        List<String> selectedSections = new List<String>{'Summary Product Only','Summary Service Only','Summary_by_Par_Location','Detail by Par Location','Print Config','Detail by Par Location with pictures','Summary by Par Location with pictures','Detail by Par Location with pictures and signoff'};  
        String layout = 'Omnicell';
        String language = 'English';
        String output = 'PDF';
        String template = 'CarePlus';
        Boolean usalist = false;
        boolean zerodollars = true;
        boolean unbundled = false;
        boolean genericdrawers = false;
        boolean serviceonly = false;
        Integer noofpictures = 4;
        String editedterms = '';
        String agreementType = 'Autonomous Pharmacy Solutions Agreement';
        Conga_Quote_Print__c qp = TestDataFactory.createTestCongaQuotePrint(q.Id);
        qp.Print_Layout__c = layout;
        update qp;
        
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        agreementType = 'Statement of Work';
        QuotePrintController.updateQuote(q.Id, pickListValuesList, selectedExhibits, selectedSections,layout,language,template,output,usalist,
                                         zerodollars,unbundled,serviceonly,genericdrawers,noofpictures,editedterms,pickListValuesList,false,agreementType,false);
        
        
        test.stopTest();
    }
}