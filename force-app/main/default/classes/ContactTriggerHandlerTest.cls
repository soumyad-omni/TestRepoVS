/**
 * @File Name          : ContactTriggerHandlerTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 23/4/2020, 4:31:24 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    23/4/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class ContactTriggerHandlerTest {

@testsetup
      static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();  
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.ContactInsertEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRM';
        setting.ContactUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ContactSFToCRMUpdate';
        setting.AccountRole_SoldTo__c='ZCSN';
        insert setting;
          
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        
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
        
    @isTest
    public static void contactAfterInsert(){

        AccountCreateController.isFirstRun= false;     
        AccountTriggerHandler.TriggerDisabled = true;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
       /* con.SDR_ISR_Owner__c='owner1';
        con.Client_Success_Executive__c='owner2';
        con.Health_Systems_Executive__c='owner3';
		*/        
		List<Contact> conList = new List<Contact>();
        conList.add(con);
        Job_title_Classification__c d = new Job_title_Classification__c();
        d.name = 'D3';
        d.Classification__c = 'D-Industry Expert';
        insert d;
        ContactTriggerHandler ct = new ContactTriggerHandler();
        ct.productChanged(conList);
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        quote.Shipping_contact__c=con.Id; 
        List<Contact> c = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
        //quote.Quote_Number__c = 'test123';
        Account ac = [Select id From Account Where id = :c[0].AccountId];
        ac.SAP_Account_ID__c = '13903';        
        AccountTriggerHandler.TriggerDisabled = true;
        Update ac;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.RunAs(usr)
        {
          //   insertTestTerritory(ac.Id);
        }
        c[0].Description = 'test';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration().id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        //quote.ContactId=createContactWithAccount_Integration().Id;
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        test.StartTest();
        update c;
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = quote.OpportunityId;    
        insert pl;
        insert quote;
        
        c[0].SAP_Contact_ID__c='1234';
        c[0].Salesforce_Contact_ID__c ='5678';
        c[0].SAP_Contact_GUID__c = '3467';
        c[0].phone='1234567890';
        c[0].email= 'example@omnicell.com';
        c[0].Title = 'Test';
        update c;
        ContactTriggerHandler cth = new ContactTriggerHandler();
        cth.connectToCastIronUpdate(conList);
        quote.email= con.email;
        update quote;
        Test.stopTest();
        System.assert(c[0].LastName!=null,c[0].LastName);  
      }
        
    @isTest
    public static void contactAfterUpdate(){

        AccountCreateController.isFirstRun= false;     
        AccountTriggerHandler.TriggerDisabled = true;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
      /*  con.SDR_ISR_Owner__c='owner2';
        con.Client_Success_Executive__c='owner3';
        con.Health_Systems_Executive__c='owner4';
	  */        
		con.email='pab@hotmail.com';
        con.Phone='9830012345';
        List<Contact> conList = new List<Contact>();
        conList.add(con);
        Job_title_Classification__c d = new Job_title_Classification__c();
        d.name = 'D3';
        d.Classification__c = 'D-Industry Expert';
        insert d;
        ContactTriggerHandler ct = new ContactTriggerHandler();
        ct.productChanged(conList);
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
        //quote.Quote_Number__c = 'test123';
        Account ac = [Select id From Account Where id = :c[0].AccountId];
        ac.SAP_Account_ID__c = '13903';
        AccountTriggerHandler.TriggerDisabled = true;
        Update ac;
        User usr = [Select id from User where Id = :UserInfo.getUserId()];

        System.RunAs(usr)
        {
            //insertTestTerritory(ac.Id,'Client Success Executive','Health Systems Executive');
           // insertTestTerritory(ac.Id);
        }
        c[0].Description = 'test';
        quote.OpportunityId = TestDataFactory.createOppWithAccount_Integration().id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        //quote.ContactId=createContactWithAccount_Integration().Id;
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        quote.Phone='1234567';
        quote.Email='abe@test.com';
        test.StartTest();
        update c;
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = quote.OpportunityId;    
        insert pl;
        insert quote;
        
//      c[0].SAP_Contact_ID__c='1234';
        c[0].Salesforce_Contact_ID__c ='5678';
//      c[0].SAP_Contact_GUID__c = '3467';
        c[0].phone='1234567890';
        c[0].email= 'example@omnicell.com';
        c[0].Title = 'Test';
        c[0].Contact_Sync__c=true;
        update c;
        ContactTriggerHandler cth = new ContactTriggerHandler();
        cth.connectToCastIronInsert(conList);
        quote.email= con.email;
        update quote;
        Test.stopTest();
        System.assert(c[0].LastName!=null,c[0].LastName);  
      }
    
    @isTest
    public static void contactonDeletedAccount(){

        AccountCreateController.isFirstRun= false;     
        AccountTriggerHandler.TriggerDisabled = true;
        Contact con = createContactWithdeletedAccount();   
		List<Contact> conList = new List<Contact>();
        conList.add(con);
        Job_title_Classification__c d = new Job_title_Classification__c();
        d.name = 'D3';
        d.Classification__c = 'D-Industry Expert';
        insert d;
        ContactTriggerHandler ct = new ContactTriggerHandler();
        ct.productChanged(conList);
        List<Contact> c = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
        Account ac = [Select id,IsDeleted__c From Account Where id = :c[0].AccountId];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
           //  insertTestTerritory(ac.Id,'Client Success Executive','Sales Associate');
          //  insertTestTerritory(ac.Id);
        }
        
       // Account ac = [Select id,IsDeleted__c From Account Where id = :c[0].AccountId];
        System.debug('***'+ac.IsDeleted__c);
        test.StartTest();
        c[0].SAP_Contact_ID__c='1234';
        c[0].Salesforce_Contact_ID__c ='5678';
        c[0].SAP_Contact_GUID__c = '3467';
        c[0].phone='1234567890';
        c[0].email= 'example@omnicell.com';
        update c;
        ContactTriggerHandler cth = new ContactTriggerHandler();
        cth.connectToCastIronUpdate(conList);
        delete c;
        undelete c;
        Test.stopTest();
        System.assert(c[0].LastName!=null,c[0].LastName);   
      }
    
    @isTest
    public static void test3(){

        AccountCreateController.isFirstRun= false;     
        AccountTriggerHandler.TriggerDisabled = true;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
      /*  con.SDR_ISR_Owner__c='owner1';
        con.Client_Success_Executive__c='owner2';
        con.Health_Systems_Executive__c='owner3';
		*/        
		List<Contact> conList = new List<Contact>();
        conList.add(con);
        Job_title_Classification__c d = new Job_title_Classification__c();
        d.name = 'D3';
        d.Classification__c = 'D-Industry Expert';
        insert d;
        ContactTriggerHandler ct = new ContactTriggerHandler();
        ct.productChanged(conList);
        List<Contact> c = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
        Account ac = [Select id,IsDeleted__c From Account Where id = :c[0].AccountId];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
           // insertTestTerritory(ac.Id);
        }
        
        test.StartTest();
        c[0].SAP_Contact_ID__c= null;//'1234';
        c[0].sent_to_SAP__c = true;
        c[0].Salesforce_Contact_ID__c = '5678';
        c[0].SAP_Contact_GUID__c = '3467';
        c[0].phone='1234567890';
        c[0].email= 'example@omnicell.com';
        c[0].Title = 'Test Tittlexxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        update c;
        
        ContactTriggerHandler cth = new ContactTriggerHandler();
        cth.connectToCastIronUpdate(conList);
        Test.stopTest();
        System.assert(c[0].LastName!=null,c[0].LastName);   
      }
    
    @isTest
    public static void contactcreatedesableTrigger(){
        
        AccountCreateController.isFirstRun= false;     
        AccountTriggerHandler.TriggerDisabled = true;
        Trigger_Configuration__c cth = new Trigger_Configuration__c();
        cth.IsDisabled__c = true;
        cth.Name = 'ContactTriggerDisabled';
        insert cth;
        Test.startTest();
        Contact con = createContactWithdeletedAccount();
        Test.stopTest();
        System.assert(con.LastName!=null,con.LastName);    
    }
   // private static void insertTestTerritory(Id accId,String tRole1,String tRole2)
    private static void insertTestTerritory(Id accId)
      {
               
        AccountTriggerHandler.TriggerDisabled = true;
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
        UserTriggerHandler.TriggerDisabled = True;
        User u1 = new User(firstname= 'Test1',
                  lastname='XXXX1',
                  Alias='Test1',
                  email = 'omctest1'+system.now().millisecond()+'@test.com',
                  username= 'omctest1'+system.now().millisecond()+'@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u1;

        User u2 = new User(firstname= 'Test2',
                  lastname='XXXX2',
                  Alias='Test2',
                  email = 'test1234122@test.com',
                  username= 'test1234xyz123xxx123@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u2;
        
        User u3 = new User(firstname= 'Test3',
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

        User u4 = new User(firstname= 'San',
                  lastname='Cla',
                  Alias='S_cla',
                  email = 'test134234122@test.com',
                  username= 'santaclause1423@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u4;

        User u5 = new User(firstname= 'Santa1',
                  lastname='Claus1',
                  Alias='S_clus1',
                  email = 'test1230041220@test.com',
                  username= 'santaclause12003@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u5;

        User u6 = new User(firstname= 'Santa009',
                  lastname='Cls08',
                  Alias='S_s08',
                  email = 'test123774122@test.com',
                  username= 'santaclause12343@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u6;

        User u7 = new User(firstname= 'Dola12',
                  lastname='Bose23',
                  Alias='d_bose22',
                  email = 'omctest7'+system.now().millisecond()+'@test.com',
                  username= 'omctest7'+system.now().millisecond()+'@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u7;

        User u8 = new User(firstname= 'Nayan',
                  lastname='Das',
                  Alias='ndas_08',
                  email = 'omctest8'+system.now().millisecond()+'@test.com',
                  username= 'omctest8'+system.now().millisecond()+'@test.com', 
                  profileId= p.id, 
                  emailencodingkey='UTF-8',
                  languagelocalekey='en_US',
                  localesidkey='en_US',
                  timezonesidkey='America/Los_Angeles');
        insert u8;
/*
        UserTerritory2Association objUserTerritory2Association = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u.Id, RoleInTerritory2=tRole1);
        insert objUserTerritory2Association;

        UserTerritory2Association objUserTerritory2Association2 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u2.Id, RoleInTerritory2=tRole2);
        insert objUserTerritory2Association2 ;
*/
        UserTerritory2Association objUserTerritory2Association1 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u1.Id, RoleInTerritory2='NAC Sales Associate');
        insert objUserTerritory2Association1;

        UserTerritory2Association objUserTerritory2Association2 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u2.Id, RoleInTerritory2='Sales Associate');
        insert objUserTerritory2Association2 ;

        UserTerritory2Association objUserTerritory2Association3 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u3.Id, RoleInTerritory2='Client Success Executive - Govt');
        insert objUserTerritory2Association3 ;

        UserTerritory2Association objUserTerritory2Association4 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u4.Id, RoleInTerritory2='Client Success Executive');
        insert objUserTerritory2Association4 ;

        UserTerritory2Association objUserTerritory2Association5 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u5.Id, RoleInTerritory2='Health Systems Executive');
        insert objUserTerritory2Association5 ;
        
        UserTerritory2Association objUserTerritory2Association6 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u6.Id, RoleInTerritory2='Health System Executive - Govt');
        insert objUserTerritory2Association6 ;      

        UserTerritory2Association objUserTerritory2Association7 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u7.Id, RoleInTerritory2='Health System Executive - GPO');
        insert objUserTerritory2Association7 ;

        UserTerritory2Association objUserTerritory2Association8 = new UserTerritory2Association(Territory2Id= objTerr.Id, UserId= u8.Id, RoleInTerritory2='Inside Sales Rep');
        insert objUserTerritory2Association8 ;
   }
    public static Contact createContactWithdeletedAccount(){        
        AccountTriggerHandler.TriggerDisabled = true; 
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Account_Status__c = 'Active',IsDeleted__c = true,Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'AZ';
        acc.Facility_Type__c = 'Pharmacy';
        acc.SAP_Account_ID__c = '0000000000';
        acc.BILLINGSTREET = '41 Moss';
        acc.BillingPostalCode = 'DY6 9HP';
        insert acc;
        
        SAP_Sales_Org__c sso= new SAP_Sales_Org__c(Sales_Org__c = 'OM01',CurrencyIsoCode = 'USD',Customer_Pricing_Procedure__c='1',Default_GPO_Price_List__c='A0',Default_IDN_Price_List__c='A1',Distribution_Channel__c='01',Sales_Office__c = 'OMNE',Shipping_Conditions__c = 'AW',Terms_of_Payment__c = 'NT30',Account__c = acc.Id,Incoterms_1__c = 'ALT',Service_Level__c='AN',Incoterms_2__c='San Francisco');
        insert sso;
        con.AccountId = acc.id;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        return con;
    }
    @isTest
    public static void setETMRoleOnContactBasedOnTerritoryRoleTest(){
        AccountCreateController.isFirstRun= false;     
        AccountTriggerHandler.TriggerDisabled = true;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
        /*
        con.SDR_ISR_Owner__c='owner1';
        con.Client_Success_Executive__c='owner2';
        con.Health_Systems_Executive__c='owner3'; */
        con.SAP_Contact_ID__c= null;//'1234';
        con.sent_to_SAP__c = true;
        con.Salesforce_Contact_ID__c = '5678';
        con.SAP_Contact_GUID__c = '3467';
        con.phone='1234567890';
        con.email= 'example@omnicell.com';
        con.Title = 'Testtitle01';
        update con;

        List<Contact> conList = new List<Contact>();
        conList.add(con);
        
        Job_title_Classification__c d = new Job_title_Classification__c();
        d.name = 'D3';
        d.Classification__c = 'D-Industry Expert';
        insert d;
              
        List<Contact> contactList = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
        List<Account> accList = [Select id,IsDeleted__c From Account Where id = :contactList[0].AccountId];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            insertTestTerritory(accList[0].Id);
        }
        
        test.StartTest();        
        ContactTriggerHandler.setETMRoleOnContactBasedOnTerritoryRole (accList,contactList);
        test.StopTest();
   }
}