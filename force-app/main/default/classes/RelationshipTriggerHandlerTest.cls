@isTest
public class RelationshipTriggerHandlerTest {

    public static testmethod void relationshipTestOne(){
        test.StartTest();
            AccountCreateController.isFirstRun= false;
            RelationshipCreateController.isFirstRun = true;
            RelationshipCreateController.isTriggerExecuting = false;
            AccountTriggerHandler.TriggerDisabled = true;
            Account acc1 = TestDataFactory.createTestAccountQuotePrint();
            SAP_Sales_Org__c sso = [select id from SAP_Sales_Org__c where account__c =:acc1.Id];
            
            Account acc2 = new Account(name='Test Secondary account',Account_role__c='ZGPO',Facility_Type__c='Short-term Acute Care Hospital',
                                       Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
                                       BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                       BillingPostalCode='95128',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
            
            insert acc2;
            
            GPO_Account__c gpo = new GPO_Account__c();
            gpo.name = 'test';
            gpo.Account_Id__c = '0011k00000CjPQVAA3';
            insert gpo;
            
            
            Relationship__c rel = new Relationship__c();
            rel.Primary_Account__c = acc1.Id;
            rel.Secondary_Account__c = acc2.Id;
            rel.Primary_Account_Sales_Org__c = sso.Id;
            rel.Relationship__c ='ZG';
            try{
                insert rel;
            }
            
            catch(Exception e){
                system.debug('Error ' + e.getMessage());
                System.assert(e.getMessage().contains('Primary Account has not been validated or is archived'));
                System.assert(e.getMessage().contains('Secondary Account has not been validated or is archived'));
            }
            
            acc1.GPOCheck__c = true;
            update acc1;
        
        test.StopTest();   
        
    }
    
    public static testmethod void relationshipTestTwo(){
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        accounttriggerhandler.triggerdisabled = true;
        List<Account> acclist = TestDataFactory.createAccounts(2);
        AccountTriggerHandler.TriggerDisabled = True;        
        insert acclist;
        Account acc1 = acclist[0];
        Account acc2 = acclist[1];
        System.debug('***'+acc1.Id);
        SAP_Sales_Org__c sso1 = TestDataFactory.createSAPSAlesOrgForAccount(acc1.Id);
        acclist[0].Validation_Status__c = 'Validated';
        acclist[1].Validation_Status__c = 'Validated';
        update acclist;
        GPO_Account__c gpa = new GPO_Account__c();
        gpa.Account_Id__c = acc2.Id;
        gpa.Name = 'GPO';
        insert gpa;
        
        Relationship__c rel = new Relationship__c();
        rel.Primary_Account__c = acc1.Id;
        rel.Secondary_Account__c = acc2.Id;
        rel.Relationship__c ='ZG';
        rel.Primary_Account_Sales_Org__c = sso1.Id;
        
        Test.startTest();        	
        	insert rel;
        	rel.Default_Partner_Flag__c = True;
        	update rel;
        	delete rel;
        Test.stopTest();
    }
    
    public static testmethod void relationshipTestThree(){
        AccountCreateController.isFirstRun= false;
        RelationshipCreateController.isFirstRun = false;
        RelationshipCreateController.isTriggerExecuting = true;
        AccountTriggerHandler.TriggerDisabled = true;
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        SAP_Sales_Org__c sso = [select id from SAP_Sales_Org__c where account__c =:acc1.Id];
        
        Account acc2 = new Account(name='Test Secondary2 account',Account_role__c='ZCSN',Facility_Type__c='Short-term Acute Care Hospital',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                   BillingPostalCode='95128',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        
        insert acc2; 
        String oldValues = '{"id": "'+acc2.Id+'","SAP_Account_ID__c": "3100000275"}';
        SAP_Sales_Org__c sp = new SAP_Sales_Org__c(Account__c = acc2.id);
        sp.Sales_Office__c='OMNE';
        sp.Incoterms_2__c = 'San Francisco';
        sp.Incoterms_1__c = 'CPT';
        insert sp;
        
        GPO_Account__c gpo = new GPO_Account__c();
        gpo.name = 'test';
        gpo.Account_Id__c = '0011k00000CjPQVAA3';
        insert gpo;
        
        
        Relationship__c rel = new Relationship__c();
        rel.Primary_Account__c = acc1.Id;
        rel.Secondary_Account__c = acc2.Id;
        rel.Primary_Account_Sales_Org__c = sso.Id;
        rel.Relationship__c ='RE';
        insert rel;
        
        acc1.GPOCheck__c = true;
        update acc1;
        delete rel;
        acc1.GPOCheck__c = false;
        update acc1;
        
        RelationshipTriggerHandler relhand = new RelationshipTriggerHandler();
        relhand.IsAccountValid(acc1.Id);
        relhand.ValidateRelationship(rel);
        relhand.getRecordTypes();
    } 
    
    public static testmethod void relationshipTestFour(){
        
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        RelationshipCreateController.isFirstRun = false;
        RelationshipCreateController.isTriggerExecuting = true;
        
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        SAP_Sales_Org__c sso = [select id from SAP_Sales_Org__c where account__c =:acc1.Id];
        
        Account acc2 = new Account(name='Test Secondary account',Account_role__c='ZGPO',Facility_Type__c='Short-term Acute Care Hospital',
                                   Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',
                                   BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                   BillingPostalCode='95128',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        
        insert acc2; 
        
        
        GPO_Account__c gpo = new GPO_Account__c();
        gpo.name = 'test';
        gpo.Account_Id__c = '0011k00000CjPQVAA3';
        insert gpo;
        
        
        Relationship__c rel = new Relationship__c();
        rel.Primary_Account__c = acc1.Id;
        rel.Secondary_Account__c = acc2.Id;
        rel.Primary_Account_Sales_Org__c = sso.Id;
        rel.Relationship__c ='ZG';
        insert rel;
        
        
        acc1.GPOCheck__c = true;
        update acc1;
        
        
        test.starttest();
            RelationshipCreateController.isFirstRun = true;
            RelationshipCreateController.isTriggerExecuting = false;
            
            try{
                rel.Relationship__c ='AG';
                update rel;
                
            }
            catch(Exception e){
                system.debug('Error ' + e.getMessage());
                System.assertEquals('AG',rel.Relationship__c);
                System.assert(e.getMessage().contains('Secondary Account has not been validated or is archived'));
            }
        test.stoptest();
    }    
}