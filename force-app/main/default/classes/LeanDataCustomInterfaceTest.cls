@isTest(seeAllData=false)
public class LeanDataCustomInterfaceTest{
    
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;    
    
    @testSetup
    static void setupData(){
        UserTriggerHandler.TriggerDisabled = true;
        User u = TestDataFactory.createUserBusinessAdmin(true, 'TestUser', 'BusinessAdmin');
        User u1 = TestDataFactory.createSalesUser(true, 'TestSales', 'RepUser');
        SCP_TestDataFactory.createCastIron();
        
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
    
    static testMethod void leandataTestMethods(){
        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User u1 = new User(firstname= 'Test1',
                  lastname='XXXX1',
                  Alias='Test1',
                  email = 'omctest1'+system.now().millisecond()+'@test.com',
                  username= 'omctest1'+system.now().millisecond()+'@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  isActive = true,
                  timezonesidkey='America/Los_Angeles');       
        UserTriggerHandler.TriggerDisabled = true;
        insert u1;
        system.runAs(u1){
        
        
        LeanDataCustomInterface testInterface = new LeanDataCustomInterface();
        List<SObject> matchedAccountList = new List<SObject>();
        AccountTriggerHandler.TriggerDisabled = true;
        Account matchedAccount = TestDataFactory.createUSTestAccount();
        
        matchedAccountList.add(matchedAccount);
        
        List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'test' LIMIT 1];
        List<Territory2Model> lstTerr = [SELECT Id, Name, State FROM Territory2Model where State = 'Active'];
            
        Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=lstTerr[0].Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
        insert objTerr;
        ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = matchedAccount.Id, Territory2Id =objTerr.Id, AssociationCause='Territory2Manual' );
        insert objObjectTerritory2Association;
        
        Lead primaryLead = new Lead();
        primaryLead.FirstName = 'Test';
        primaryLead.LastName = 'Lead';
        primaryLead.Company = 'Test Company';
        primaryLead.Email = 'testlead@company.com';
        primaryLead.LeanData__Reporting_Matched_Account__c = matchedAccount.Id;
        primaryLead.OwnerId = System.UserInfo.getUserId();
        insert primaryLead;
        
        Contact primarycontact = new Contact();
        primarycontact.FirstName = 'Test';
        primarycontact.LastName = 'Contact';
        primarycontact.AccountId = matchedAccount.Id;
        primarycontact.OwnerId = System.UserInfo.getUserId();
        insert primarycontact;
		
		UserTerritory2Association objUserTerritory2Association1 = new UserTerritory2Association(Territory2Id= objTerr.Id, 
                                                                                                 UserId= u1.Id,
                                                                                                 RoleInTerritory2='Test Role');
        insert objUserTerritory2Association1;
            
            
        
        Map<String, SObject> chosenSObjects = new Map<String, SObject>();
        Map<String,Object> additionalParameters = new Map<String,Object>();
        
        chosenSObjects.put('L2A', (SObject)matchedAccount);
        
        testInterface.getMapOfCustomInterfaceNodeNamesToEdges();
        
        testInterface.additionalParametersMap();
        
        additionalParameters.put('Role', 'Test Role');
        
        testInterface.customRoutingRule((SObject)primaryLead, chosenSObjects, 'Route to ETM Territory', additionalParameters);
        testInterface.customRoutingRule((SObject)primarycontact, chosenSObjects, 'Route to ETM Territory', additionalParameters);
        
        testInterface.customRoutingRule((SObject)primaryLead, chosenSObjects, 'bad param');
        testInterface.customRoutingRule((SObject)primarycontact, chosenSObjects, 'bad param');
        testInterface.customInterfaceLogMap();
            system.assertEquals('Test Role', objUserTerritory2Association1.RoleInTerritory2);
        }
    }
}