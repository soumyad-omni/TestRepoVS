@isTest
public class updateOppAccDivision_test {
    static void testdatasetup(){
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        
        
        Opportunity_Field_Tracking__c s1 = new Opportunity_Field_Tracking__c();
        s1.name ='ASSOCIATED_OPPORTUNITY__C';
        insert s1;
        
        Opportunity_Field_Tracking__c s2 = new Opportunity_Field_Tracking__c();
        s2.name ='COMPETITOR__C';
        insert s2;
        
        Opportunity_Field_Tracking__c s3 = new Opportunity_Field_Tracking__c();
        s3.name ='Contract_Year__c';
        insert s3;
        Opportunity_Field_Tracking__c s4 = new Opportunity_Field_Tracking__c();
        s4.name ='AccountId';
        insert s4;
        
        Opportunity_Field_Tracking__c s5 = new Opportunity_Field_Tracking__c();
        s5.name ='Competitor__c';
        insert s5;
        
        SCP_Integration_Details__c settingScp = new SCP_Integration_Details__c();
        settingScp.SCP_Application_Name__c ='SCP_AccountSFDCTOSAP';
        settingScp.Name = 'SCP_AccountSFDCTOSAP';
        settingScp.SCP_End_Point__c = 'ABC';
        insert  settingScp;       
        
        Opportunity_Field_Tracking__c  setting11 = new Opportunity_Field_Tracking__c ();
        setting11.Name = 'ACCOUNTID';
        insert setting11;
        Opportunity_Field_Tracking__c  setting12 = new Opportunity_Field_Tracking__c ();
        setting12.Name = 'AMOUNT';
        insert setting12;
        Opportunity_Field_Tracking__c  setting333 = new Opportunity_Field_Tracking__c ();
        setting333.Name = 'EXPECTED_BOOKINGS__C';
        insert setting333;
        Opportunity_Field_Tracking__c  setting13 = new Opportunity_Field_Tracking__c ();
        setting13.Name = 'NAME';
        insert setting13;
        Opportunity_Field_Tracking__c  setting22 = new Opportunity_Field_Tracking__c ();
        setting22.Name = 'RECORDTYPEID';
        insert setting22;
        Opportunity_Field_Tracking__c  setting33 = new Opportunity_Field_Tracking__c ();
        setting33.Name = 'CloseDate';
        insert setting33;
        Opportunity_Field_Tracking__c  setting44= new Opportunity_Field_Tracking__c ();
        setting44.Name = 'Competitor__c';
        insert setting44;
        Opportunity_Field_Tracking__c  setting211 = new Opportunity_Field_Tracking__c ();
        setting211.Name = 'RECORDTYPEID';
        insert setting211;
        
        Opportunity_Field_Tracking__c  setting212 = new Opportunity_Field_Tracking__c ();
        setting212.Name = 'STATUS_REASON__C';
        insert setting212;
        
        Opportunity_Field_Tracking__c  setting213 = new Opportunity_Field_Tracking__c ();
        setting213.Name = 'PROFESSIONAL_SERVICES_INTAKE_STATUS__C';
        insert setting213;
        
        Opportunity_Field_Tracking__c  setting214 = new Opportunity_Field_Tracking__c ();
        setting214.Name = 'EXPECTEDINSTALLDATE__C';
        insert setting214;
        
        Opportunity_Field_Tracking__c  setting215 = new Opportunity_Field_Tracking__c ();
        setting215.Name = 'OWNERID';
        insert setting215;
        
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
        
        
        AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        //acc.PIS_HIS__c  = 'test';
        acc.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc; 
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        
        Account acc1 = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                   BillingPostalCode='95128', SAP_Account_ID__c='13903',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc1.texcellency__DefHC_HospitalID__c = 1;
        acc1.Territory_Name__c = 'TestTerr';
        //acc1.PIS_HIS__c  = 'test';
        acc1.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc1; 
        
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        opportunitytriggerhandler.TriggerDisabled=true; 
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Non Comm. Book - No Service PO';
        opp.Credit_Approved_For__c = acc1.id;
        //opportunitytriggerhandler.TriggerDisabled = true;
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
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        User oid = [Select Id, name from User where profile.name ='System Administrator' limit 1];
        opp.OwnerId= oid.Id;
        insert opp;
        
        
    } 

    public testMethod static void test1(){
         Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        //acc.PIS_HIS__c  = 'test';
        acc.Division_Account__c ='Atlantic';
        AccountTriggerHandler.TriggerDisabled = true;
        insert acc; 
        
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        opportunitytriggerhandler.TriggerDisabled=true; 
        opp.AccountId = acc.id;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.OppStatus__c = 'Non Comm. Book - No Service PO';
        //opp.Credit_Approved_For__c = acc1.id;
        //opportunitytriggerhandler.TriggerDisabled = true;
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
        opp.Professional_Services_Intake_Status__c='Project Scope Identified';
        User oid = [Select Id, name from User where profile.name ='System Administrator' limit 1];
        opp.OwnerId= oid.Id;
        insert opp;
            UpdateOppDivController.updateDiv();
            
            
    }
}