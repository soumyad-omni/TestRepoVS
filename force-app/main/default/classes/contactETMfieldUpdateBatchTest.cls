@isTest
public class contactETMfieldUpdateBatchTest {
    
      @testsetup
      static void testdatasetup(){
            CastIronIntegration__c  setting = new CastIronIntegration__c ();
            setting.Name = 'CastIronIntegration';
            setting.ContactInsertEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRM';
            setting.ContactUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRMUpdate';
            setting.AccountRole_SoldTo__c='ZCSN';
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
        } 
    
    	static testmethod void test1()
        {
            Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                          BillingPostalCode='95128',Transport_Zone__c='IN00000001',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
            acc.texcellency__DefHC_HospitalID__c = 1;
            acc.Territory_Name__c = 'TestTerr';
            insert acc; 
            Contact con = new Contact();
            con.LastName = 'sammm';
            con.LeadSource ='Web';
            con.Phone = '9573647724';
            con.AccountId = acc.Id;
            insert con;
            User usr = [Select id from User where Id = :UserInfo.getUserId()];

            System.RunAs(usr)
            {
                 insertTestTerritory(acc.Id,'Client Success Executive','Health Systems Executive');
            }
            
            Test.startTest();
             	 contactETMfieldUpdateBatch obj = new contactETMfieldUpdateBatch();
            	 DataBase.executeBatch(obj); 
            Test.stopTest();
        } 
    
    	private static void insertTestTerritory(Id accId,String tRole1,String tRole2)
        {
            
            List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'test' LIMIT 1];
            List<Profile> adminProfile = [select id, name from Profile where  name = 'System Administrator'];
    
            Territory2Model terrModel = new Territory2Model();
            terrModel.DeveloperName='Test_Model';
            terrModel.Name = 'Test_Territory';
            insert terrModel ;
    
            Territory2 objTerr = new Territory2(DeveloperName = 'TestTerritory', Territory2ModelId=terrModel.Id, Name='TestTerritory', Territory2TypeId=terriType[0].Id);
            insert objTerr;
    
            ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = accId, Territory2Id =objTerr.Id, AssociationCause='Territory2Manual' );
            insert objObjectTerritory2Association;
    
            Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
            User u = new User(firstname= 'Test',
                      lastname='XXXX',
                      Alias='Test',
                      email = 'test1234@test.com',
                      username= 'test1234xxx@test.com', 
                      profileId= p.id, 
                      emailencodingkey='UTF-8',
                      languagelocalekey='en_US',
                      localesidkey='en_US',
                      timezonesidkey='America/Los_Angeles');
            insert u;
    
            User u2 = new User(firstname= 'Test',
                      lastname='XXXX',
                      Alias='Test',
                      email = 'test1234122@test.com',
                      username= 'test1234xxx123@test.com', 
                      profileId= p.id, 
                      emailencodingkey='UTF-8',
                      languagelocalekey='en_US',
                      localesidkey='en_US',
                      timezonesidkey='America/Los_Angeles');
            insert u2;
            
            User u3 = new User(firstname= 'Santa',
                      lastname='Claus',
                      Alias='S_claus',
                      email = 'test1234122@test.com',
                      username= 'santaclause123@test.com', 
                      profileId= p.id, 
                      emailencodingkey='UTF-8',
                      languagelocalekey='en_US',
                      localesidkey='en_US',
                      timezonesidkey='America/Los_Angeles');
            insert u3;
    
    
            UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u.Id, RoleInTerritory2=tRole1);
            insert objUserTerritory2Association;
    
            UserTerritory2Association objUserTerritory2Association2 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u2.Id, RoleInTerritory2=tRole2);
            insert objUserTerritory2Association2 ;
    
            UserTerritory2Association objUserTerritory2Association3 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u3.Id, RoleInTerritory2='Sales Associate');
            insert objUserTerritory2Association3 ;
    
        }

}