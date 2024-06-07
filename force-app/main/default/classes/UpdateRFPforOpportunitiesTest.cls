@isTest
public class UpdateRFPforOpportunitiesTest {
    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();    
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
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
        
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
        insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff;
    }
    public testmethod static void RFPUpdate1(){
        AccountTriggerHandler.TriggerDisabled=true;
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='',Validation_Status__c = 'Awaiting Validation',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        insert acc;
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        
        acc.Validation_Status__c='Validated';
        acc.SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000);
        update acc;
        
        Request_for_Proposal__c rfp = new Request_for_Proposal__c();
        rfp.Name = 'Test RFP 1';
        rfp.Status__c = 'Complete';
        rfp.Response_Type__c = 'RFI';
        rfp.Result__c = 'Withdrawn';
        rfp.Category__c = 'Government';
        rfp.Date_Due__c = System.today()+1;
        rfp.Date_Received__c = System.today()+10;
        rfp.Delivery_Method__c = 'Online Portal';
        rfp.Notes__c = 'Test RFP 1';
        Test.startTest();
        insert rfp;
        
        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test 4';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Open';
        opp.Type_Deal__c='New Solution'; 
        opp.Credit_Approved_For__c = acc.id;
        opp.Credit_Approval_Date__c = system.today();
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.Pipeline_Category__c = 'Development';
        opp.Self_Install_Desired__c = 'No';
        opp.Professional_Services_Notes__c = 'Test';
        opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp.Lease_Expiration_Date__c = System.Today()+1;
        opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp.ExpectedInstallDate__c = System.Today();
        opp.How_many_contract_years__c = '2';
        opp.Contract_Year__c = '2';
        opp.Specialty_Open_Date__c = System.Today();
        opp.Seismic_Restraint_Required__c = 'No';
        opp.Request_for_Proposal_Id__c = rfp.Id;  
        opp.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        insert opp;
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 1;
        insert pl;
        
        opp.stageName = '6 Closed Won';
        update opp;
        Test.stopTest();
    }
    public testmethod static void RFPUpdate2(){
        AccountTriggerHandler.TriggerDisabled=true;
        Account acc1 = new Account(name='t2'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='',Validation_Status__c = 'Awaiting Validation',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc1.texcellency__DefHC_HospitalID__c = 1;
        acc1.Territory_Name__c = 'TestTerr';
        insert acc1;
        SAP_Sales_Org__c ssoc1 = new SAP_Sales_Org__c(Account__c=acc1.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc1;
        
        acc1.Validation_Status__c='Validated';
        acc1.SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000);
        update acc1;
        
        Request_for_Proposal__c rfp1 = new Request_for_Proposal__c();
        rfp1.Name = 'Test RFP 1';
        rfp1.Status__c = 'Complete';
        rfp1.Response_Type__c = 'RFI';
        rfp1.Result__c = 'Withdrawn';
        rfp1.Category__c = 'Government';
        rfp1.Date_Due__c = System.today()+1;
        rfp1.Date_Received__c = System.today()+10;
        rfp1.Delivery_Method__c = 'Online Portal';
        rfp1.Notes__c = 'Test RFP 2';
        Test.startTest();
        insert rfp1;
        
        Opportunity opp1 = new Opportunity();
        opp1.name = 'Us and Canada Opportunity Test 5';
        opp1.stageName = '6 Closed Won';
        opp1.CloseDate = System.today()+30;
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp1.AccountId = acc1.id;
        opp1.ExpectedInstallDate__c = System.today()+60;
        opp1.OppStatus__c = 'Open';
        opp1.Type_Deal__c='New Solution'; 
        opp1.Credit_Approved_For__c = acc1.id;
        opp1.Credit_Approval_Date__c = system.today();
        opp1.Services_Enablement_Owner__c = 'Tara Bakker';
        opp1.Pipeline_Category__c = 'Development';
        opp1.Self_Install_Desired__c = 'No';
        opp1.Professional_Services_Notes__c = 'Test';
        opp1.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp1.Lease_Expiration_Date__c = System.Today()+1;
        opp1.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp1.ExpectedInstallDate__c = System.Today();
        opp1.How_many_contract_years__c = '2';
        opp1.Contract_Year__c = '2';
        opp1.Specialty_Open_Date__c = System.Today();
        opp1.Seismic_Restraint_Required__c = 'No';
        opp1.Request_for_Proposal_Id__c = rfp1.Id;  
        opp1.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        insert opp1;
        
        Product_Line__c pl1 = new Product_Line__c();
        pl1.Amount__c = 10000;
        pl1.Product_Line_Picklist2__c = 'Anesthesia';
        pl1.Date_Booked__c = System.today()-10;
        pl1.Estimate__c = true;
        pl1.Opportunity__c = opp1.Id;
        pl1.Quantity__c = 1;
        insert pl1;
        
        
        Delete opp1;
        Test.stopTest();
    }
    public testmethod static void RFPUpdate3(){
        ProductLineTriggerHandler.TriggerDisabled=True;
        AccountTriggerHandler.TriggerDisabled=true;
        Account acc2 = new Account(name='t2'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='',Validation_Status__c = 'Awaiting Validation',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc2.texcellency__DefHC_HospitalID__c = 1;
        acc2.Territory_Name__c = 'TestTerr';
        insert acc2;
        SAP_Sales_Org__c ssoc2 = new SAP_Sales_Org__c(Account__c=acc2.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc2;
        
        acc2.Validation_Status__c='Validated';
        acc2.SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000);
        update acc2;
        
        Request_for_Proposal__c rfp2 = new Request_for_Proposal__c();
        rfp2.Name = 'Test RFP 3';
        rfp2.Status__c = 'Complete';
        rfp2.Response_Type__c = 'RFI';
        rfp2.Result__c = 'Withdrawn';
        rfp2.Category__c = 'Government';
        rfp2.Date_Due__c = System.today()+1;
        rfp2.Date_Received__c = System.today()+10;
        rfp2.Delivery_Method__c = 'Online Portal';
        rfp2.Notes__c = 'Test RFP 3';
        Test.startTest();
        insert rfp2;
        
        Opportunity opp2 = new Opportunity();
        opp2.name = 'Us and Canada Opportunity Test 6';
        opp2.stageName = '6 Closed Won';
        opp2.CloseDate = System.today()+30;
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp2.AccountId = acc2.id;
        opp2.ExpectedInstallDate__c = System.today()+60;
        opp2.OppStatus__c = 'Open';
        opp2.Type_Deal__c='New Solution'; 
        opp2.Credit_Approved_For__c = acc2.id;
        opp2.Credit_Approval_Date__c = system.today();
        opp2.Services_Enablement_Owner__c = 'Tara Bakker';
        opp2.Pipeline_Category__c = 'Development';
        opp2.Self_Install_Desired__c = 'No';
        opp2.Professional_Services_Notes__c = 'Test';
        opp2.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp2.Lease_Expiration_Date__c = System.Today()+1;
        opp2.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp2.ExpectedInstallDate__c = System.Today();
        opp2.How_many_contract_years__c = '2';
        opp2.Contract_Year__c = '2';
        opp2.Specialty_Open_Date__c = System.Today();
        opp2.Seismic_Restraint_Required__c = 'No';
        opp2.Request_for_Proposal_Id__c = rfp2.Id;  
        opp2.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        insert opp2;
        
        Product_Line__c pl2 = new Product_Line__c();
        pl2.Amount__c = 10000.50;
        pl2.Product_Line_Picklist2__c = 'Anesthesia';
        pl2.Date_Booked__c = System.today()+30;
        pl2.Estimate__c = true;
        pl2.Opportunity__c = opp2.Id;
        pl2.Quantity__c = 1;
        insert pl2;
        
        Opportunity opp3 = new Opportunity();
        opp3.name = 'Us and Canada Opportunity Test 7';
        opp3.stageName = '7 Closed Lost';
        opp3.CloseDate = System.today()+30;
        opp3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp3.AccountId = acc2.id;
        opp3.ExpectedInstallDate__c = System.today()+60;
        opp3.OppStatus__c = 'Open';
        opp3.Type_Deal__c='New Solution'; 
        opp3.Credit_Approved_For__c = acc2.id;
        opp3.Credit_Approval_Date__c = system.today();
        opp3.Services_Enablement_Owner__c = 'Tara Bakker';
        opp3.Pipeline_Category__c = 'Development';
        opp3.Self_Install_Desired__c = 'No';
        opp3.Professional_Services_Notes__c = 'Test';
        opp3.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp3.Lease_Expiration_Date__c = System.Today()+1;
        opp3.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp3.ExpectedInstallDate__c = System.Today();
        opp3.How_many_contract_years__c = '2';
        opp3.Contract_Year__c = '2';
        opp3.Specialty_Open_Date__c = System.Today();
        opp3.Seismic_Restraint_Required__c = 'No';
        opp3.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        insert opp3;
        
        Product_Line__c pl3 = new Product_Line__c();
        pl3.Amount__c = 10000;
        pl3.Product_Line_Picklist2__c = 'Anesthesia';
        pl3.Date_Booked__c = System.today()+10;
        pl3.Estimate__c = true;
        pl3.Opportunity__c = opp3.Id;
        pl3.Quantity__c = 1;
        insert pl3;
        
        opp3.Request_for_Proposal_Id__c = rfp2.Id;
        update opp3;
        
        opp2.Request_for_Proposal_Id__c = null; 
        update opp2;
        
        Test.stopTest();
    }
    
    public testmethod static void RFPUpdate4(){
        AccountTriggerHandler.TriggerDisabled=true;
        ProductLineTriggerHandler.TriggerDisabled=True;
        Account acc3 = new Account(name='t2'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='',Validation_Status__c = 'Awaiting Validation',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc3.texcellency__DefHC_HospitalID__c = 1;
        acc3.Territory_Name__c = 'TestTerr';
        insert acc3;
        SAP_Sales_Org__c ssoc3 = new SAP_Sales_Org__c(Account__c=acc3.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc3;
        
        acc3.Validation_Status__c='Validated';
        acc3.SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000);
        update acc3;
        
        Request_for_Proposal__c rfp5 = new Request_for_Proposal__c();
        rfp5.Name = 'Test RFP 5';
        rfp5.Status__c = 'Complete';
        rfp5.Response_Type__c = 'RFI';
        rfp5.Result__c = 'Withdrawn';
        rfp5.Category__c = 'Government';
        rfp5.Date_Due__c = System.today()+1;
        rfp5.Date_Received__c = System.today()+10;
        rfp5.Delivery_Method__c = 'Online Portal';
        rfp5.Notes__c = 'Test RFP 5';
        Test.startTest();
        insert rfp5;
        
        Request_for_Proposal__c rfp6 = new Request_for_Proposal__c();
        rfp6.Name = 'Test RFP 5';
        rfp6.Status__c = 'Complete';
        rfp6.Response_Type__c = 'RFI';
        rfp6.Result__c = 'Withdrawn';
        rfp6.Category__c = 'Government';
        rfp6.Date_Due__c = System.today()+1;
        rfp6.Date_Received__c = System.today()+10;
        rfp6.Delivery_Method__c = 'Online Portal';
        rfp6.Notes__c = 'Test RFP 5';
        insert rfp6;
        
        Opportunity opp5 = new Opportunity();
        opp5.name = 'Us and Canada Opportunity Test 8';
        opp5.stageName = '6 Closed Won';
        opp5.CloseDate = System.today()+30;
        opp5.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp5.AccountId = acc3.id;
        opp5.ExpectedInstallDate__c = System.today()+60;
        opp5.OppStatus__c = 'Open';
        opp5.Type_Deal__c='New Solution'; 
        opp5.Credit_Approved_For__c = acc3.id;
        opp5.Credit_Approval_Date__c = system.today();
        opp5.Services_Enablement_Owner__c = 'Tara Bakker';
        opp5.Pipeline_Category__c = 'Development';
        opp5.Self_Install_Desired__c = 'No';
        opp5.Professional_Services_Notes__c = 'Test';
        opp5.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp5.Lease_Expiration_Date__c = System.Today()+1;
        opp5.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp5.ExpectedInstallDate__c = System.Today();
        opp5.How_many_contract_years__c = '2';
        opp5.Contract_Year__c = '2';
        opp5.Specialty_Open_Date__c = System.Today();
        opp5.Seismic_Restraint_Required__c = 'No';
        opp5.Request_for_Proposal_Id__c = rfp5.Id;  
        opp5.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        insert opp5;
        
        Product_Line__c pl5 = new Product_Line__c();
        pl5.Amount__c = 10000.50;
        pl5.Product_Line_Picklist2__c = 'Anesthesia';
        pl5.Date_Booked__c = System.today()+30;
        pl5.Estimate__c = true;
        pl5.Opportunity__c = opp5.Id;
        pl5.Quantity__c = 1;
        insert pl5;
        
        Opportunity opp4 = new Opportunity();
        opp4.name = 'Us and Canada Opportunity Test 9';
        opp4.stageName = '7 Closed Lost';
        opp4.CloseDate = System.today()+30;
        opp4.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
        opp4.AccountId = acc3.id;
        opp4.ExpectedInstallDate__c = System.today()+60;
        opp4.OppStatus__c = 'Open';
        opp4.Type_Deal__c='New Solution'; 
        opp4.Credit_Approved_For__c = acc3.id;
        opp4.Credit_Approval_Date__c = system.today();
        opp4.Services_Enablement_Owner__c = 'Tara Bakker';
        opp4.Pipeline_Category__c = 'Development';
        opp4.Self_Install_Desired__c = 'No';
        opp4.Professional_Services_Notes__c = 'Test';
        opp4.Is_the_current_Omnicell_hardware_leased__c = 'No';
        opp4.Lease_Expiration_Date__c = System.Today()+1;
        opp4.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        opp4.ExpectedInstallDate__c = System.Today();
        opp4.How_many_contract_years__c = '2';
        opp4.Contract_Year__c = '2';
        opp4.Specialty_Open_Date__c = System.Today();
        opp4.Seismic_Restraint_Required__c = 'No';
        opp5.Request_for_Proposal_Id__c = rfp6.Id;
        opp4.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        insert opp4;
        
        Product_Line__c pl4 = new Product_Line__c();
        pl4.Amount__c = 10000;
        pl4.Product_Line_Picklist2__c = 'Anesthesia';
        pl4.Date_Booked__c = System.today()+10;
        pl4.Estimate__c = true;
        pl4.Opportunity__c = opp4.Id;
        pl4.Quantity__c = 1;
        insert pl4;
        
        opp5.Request_for_Proposal_Id__c = rfp5.Id;
        update opp5;
        
        opp4.stageName = '6 Closed Won';
        opp4.Expected_Bookings__c=20000.00;
        update opp4;
        Test.stopTest();
    }
}