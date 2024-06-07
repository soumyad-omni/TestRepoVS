@isTest
public class RequestforProposal_TriggerHandlerTest {
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
        
        List<Request_for_Proposal_fields_to_Track__c> allRFPFieldsToTrack = new List<Request_for_Proposal_fields_to_Track__c>();
        
        Request_for_Proposal_fields_to_Track__c rfphist1 = new Request_for_Proposal_fields_to_Track__c();
        rfphist1.Name = 'NAME';
        allRFPFieldsToTrack.add(rfphist1);
        
        Request_for_Proposal_fields_to_Track__c rfphist2 = new Request_for_Proposal_fields_to_Track__c();
        rfphist2.Name = 'DELIVERY_METHOD__C';
        allRFPFieldsToTrack.add(rfphist2);
        
        Request_for_Proposal_fields_to_Track__c	  rfphist4 = new Request_for_Proposal_fields_to_Track__c();
        rfphist4.Name = 'QUARTER__C';
        allRFPFieldsToTrack.add(rfphist4);
        
        Request_for_Proposal_fields_to_Track__c	  rfphist5 = new Request_for_Proposal_fields_to_Track__c();
        rfphist5.Name = 'RESPONSE_TYPE__C';
        allRFPFieldsToTrack.add(rfphist5);
        
        Request_for_Proposal_fields_to_Track__c	  rfphist6 = new Request_for_Proposal_fields_to_Track__c();
        rfphist6.Name = 'RESULT__C';
        allRFPFieldsToTrack.add(rfphist6);
        
        Request_for_Proposal_fields_to_Track__c	  rfphist7 = new Request_for_Proposal_fields_to_Track__c();
        rfphist7.Name = 'STATUS__C';
        allRFPFieldsToTrack.add(rfphist7);
        
        insert allRFPFieldsToTrack;
    }
    public testmethod static void RFP1(){
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
        
        rfp.Name = 'Test RFP 1 Update';
        rfp.Status__c = 'In Progress';
        rfp.Response_Type__c = 'RFP';
        rfp.Delivery_Method__c = 'Email';
        rfp.Quarter__c='1';
        update rfp;
        

        Opportunity opp = new Opportunity();
        opp.name = 'Us and Canada Opportunity Test 4';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('U.S & Canada CORE').getRecordTypeId();
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
        opp.Professional_Services_Intake_Status__c='Customer Project Scope Review';
        opp.Request_for_Proposal_Id__c=rfp.Id;
        insert opp;
        opp.stageName = '6 Closed Won';
        update opp;
        Test.stopTest();        
    }
}