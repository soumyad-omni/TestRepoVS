@isTest
private class upHasOppDeleteOpp_test {
    
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;

    static testMethod void upHasOppDeleteOpptestclass1() {
                test.startTest();

        Target_Initiative__c tinit = new Target_Initiative__c(name = 'tar01',End_Date__c=Date.newInstance( 2019, 5, 5 ), Start_Date__c=Date.newInstance( 2019, 10, 10));
        insert tinit;
        AccountTriggerHandler.TriggerDisabled=True;
        
        account acc = new account(
            name = 'acc0001', 
            IsDeleted__c = False, 
            Account_Role__c = 'ZCSN',
            Transport_Zone__c='US00000004',
            Primary_Language__c = 'EN',
            BillingCountryCode = 'US',
            Partner_Type__c= '0015',
            BILLINGSTREET = '21 Morris Ave',
            Facility_Type__c = 'Correctional Facilities',
            Validation_Status__c='Validated',
            Billingcity='Rockville Centre',
            BillingStatecode='NY',
            BillingPostalCode = '11570',
            Country_Cluster__c='US&CA',
            Division_Account__c='Atlantic',
            Region__c='Central',
            Account_Territory__c='East OH',
            Transportation_Zone_Country__c='US',
           RecordtypeId=recTypeAccount
        );
        insert acc;   
        
          acc.ParentId=null;
          update acc;
        
        Target_Initiative_Account__c tarAc = new Target_Initiative_Account__c(Target_Initiative__c = tinit.id, Account__c = acc.id, Has_Opportunities__c = True);
        insert tarAc;
        OpportunityTriggerHandler.triggerdisabled=True;
        opportunity op1 = new opportunity(AccountId = acc.id, name = 'opp001', 
                                          StageName='1 Initial Sales Activity',
                                          CloseDate = Date.newInstance( 2019, 12, 12),
                                          Opportunity__c='Omnicell Opportunity',
                                          OpportunityGroup__c='Purchase',
                                          Opportunity_Segment__c='Segment1',
                                          OppStatus__c='open',
                                          ExpectedInstallDate__c=Date.newInstance( 2021, 12, 12));
        op1.Services_Enablement_Owner__c = 'Tara Bakker';
        op1.Pipeline_Category__c = 'Development';
        op1.Self_Install_Desired__c = 'No';
        op1.Professional_Services_Notes__c = 'Test';
        op1.Is_the_current_Omnicell_hardware_leased__c = 'No';
        op1.Lease_Expiration_Date__c = System.Today()+1;
        op1.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        op1.ExpectedInstallDate__c = System.Today();
        op1.How_many_contract_years__c = '2';
        op1.Contract_Year__c = '2';
        op1.Specialty_Open_Date__c = System.Today();
        op1.Seismic_Restraint_Required__c = 'No';
        op1.Professional_Services_Intake_Status__c='Project Scope Identified';
        User oid = [Select Id, name from User where profile.name ='System Administrator' limit 1];
        op1.OwnerId= oid.Id;
        insert op1;
        opportunity op2 = new opportunity(AccountId = acc.id, name = 'opp002', 
                                          StageName='1 Initial Sales Activity',
                                          Opportunity__c='Omnicell Opportunity',
                                          OpportunityGroup__c='Purchase',
                                          Opportunity_Segment__c='Segment1',
                                          OppStatus__c='open',
                                          CloseDate = Date.newInstance( 2019, 12, 12),
                                          ExpectedInstallDate__c=Date.newInstance( 2021, 12, 12));
        op2.Services_Enablement_Owner__c = 'Tara Bakker';
        op2.Pipeline_Category__c = 'Development';
        op2.Self_Install_Desired__c = 'No';
        op2.Professional_Services_Notes__c = 'Test';
        op2.Is_the_current_Omnicell_hardware_leased__c = 'No';
        op2.Lease_Expiration_Date__c = System.Today()+1;
        op2.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
        op2.ExpectedInstallDate__c = System.Today();
        op2.How_many_contract_years__c = '2';
        op2.Contract_Year__c = '2';
        op2.Specialty_Open_Date__c = System.Today();
        op2.Seismic_Restraint_Required__c = 'No';
        op2.Professional_Services_Intake_Status__c='Project Scope Identified';
        op2.OwnerId= oid.Id;
        insert op2;
        Target_Initiative_Opportunity__c tarOp1 = new Target_Initiative_Opportunity__c(Opportunity__c=op1.id,Target_Initiative__c = tinit.id);
        insert tarOp1;
        Target_Initiative_Opportunity__c tarOp2 = new Target_Initiative_Opportunity__c(Opportunity__c=op2.id,Target_Initiative__c = tinit.id);
        insert tarOp2;
        
        delete tarOp1;
        
                test.stopTest();

    }
}