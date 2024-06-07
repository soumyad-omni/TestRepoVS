@isTest
public class UserTriggerHandlerTest {
    public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @testsetup
    static void testdatasetup(){
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        
        List<User_Field_Tracking__c> allUserFieldsToTrack = new List<User_Field_Tracking__c>();
        User_Field_Tracking__c	  usrhst1 = new User_Field_Tracking__c();
        usrhst1.Name = 'FIRSTNAME';
        allUserFieldsToTrack.add(usrhst1);
        
        User_Field_Tracking__c	  usrhst2 = new User_Field_Tracking__c();
        usrhst2.Name = 'LASTNAME';
        allUserFieldsToTrack.add(usrhst2);
        
        User_Field_Tracking__c	  usrhst3 = new User_Field_Tracking__c();
        usrhst3.Name = 'MIDDLENAME';
        allUserFieldsToTrack.add(usrhst3);
        
        User_Field_Tracking__c	  usrhst4 = new User_Field_Tracking__c();
        usrhst4.Name = 'USERNAME';
        allUserFieldsToTrack.add(usrhst4);
        
        User_Field_Tracking__c	  usrhst5 = new User_Field_Tracking__c();
        usrhst5.Name = 'PROFILEID';
        allUserFieldsToTrack.add(usrhst5);
        
        User_Field_Tracking__c	  usrhst6 = new User_Field_Tracking__c();
        usrhst6.Name = 'TIMEZONESIDKEY';
        allUserFieldsToTrack.add(usrhst6);
        
        User_Field_Tracking__c	  usrhst7 = new User_Field_Tracking__c();
        usrhst7.Name = 'COUNTRY_CLUSTER__C';
        allUserFieldsToTrack.add(usrhst7);
        
        User_Field_Tracking__c	  usrhst8 = new User_Field_Tracking__c();
        usrhst8.Name = 'LOCALESIDKEY';
        allUserFieldsToTrack.add(usrhst8);
        
        User_Field_Tracking__c	  usrhst9 = new User_Field_Tracking__c();
        usrhst9.Name = 'ISACTIVE';
        allUserFieldsToTrack.add(usrhst9);
        
        User_Field_Tracking__c	  usrhst10 = new User_Field_Tracking__c();
        usrhst10.Name = 'USERROLEID';
        allUserFieldsToTrack.add(usrhst10);
        
        User_Field_Tracking__c	  usrhst11 = new User_Field_Tracking__c();
        usrhst11.Name = 'USERPERMISSIONSINTERACTIONUSER';
        allUserFieldsToTrack.add(usrhst11);
        
        User_Field_Tracking__c	  usrhst12 = new User_Field_Tracking__c();
        usrhst12.Name = 'USERPERMISSIONSMARKETINGUSER';
        allUserFieldsToTrack.add(usrhst12);
        
        User_Field_Tracking__c	  usrhst14 = new User_Field_Tracking__c();
        usrhst14.Name = 'TITLE';
        allUserFieldsToTrack.add(usrhst14);
        
        User_Field_Tracking__c	  usrhst15 = new User_Field_Tracking__c();
        usrhst15.Name = 'DIVISION__C';
        allUserFieldsToTrack.add(usrhst15);  
        
        User_Field_Tracking__c	  usrhst16 = new User_Field_Tracking__c();
        usrhst16.Name = 'REPORTING_DIVISION_MANAGER__C';
        allUserFieldsToTrack.add(usrhst16);
        
        User_Field_Tracking__c	  usrhst17 = new User_Field_Tracking__c();
        usrhst17.Name = 'REPORTING_REGION_MANAGER__C';
        allUserFieldsToTrack.add(usrhst17);
        
        User_Field_Tracking__c	  usrhst18 = new User_Field_Tracking__c();
        usrhst18.Name = 'REPORTNG_MANAGER__C';
        allUserFieldsToTrack.add(usrhst18);
        
        User_Field_Tracking__c	  usrhst19 = new User_Field_Tracking__c();
        usrhst19.Name = 'REPORT_BUSINESS_UNIT_MANAGER__C';
        allUserFieldsToTrack.add(usrhst19);
        
        User_Field_Tracking__c	  usrhst20 = new User_Field_Tracking__c();
        usrhst20.Name = 'INTERNATIONAL_USER_REGION__C';
        allUserFieldsToTrack.add(usrhst20);
        
        User_Field_Tracking__c	  usrhst21 = new User_Field_Tracking__c();
        usrhst21.Name = '	REGION_USER__C';
        allUserFieldsToTrack.add(usrhst21);
        
        User_Field_Tracking__c	  usrhst22 = new User_Field_Tracking__c();
        usrhst22.Name = 'MANAGERID';
        allUserFieldsToTrack.add(usrhst22);
        
        User_Field_Tracking__c	  usrhst23 = new User_Field_Tracking__c();
        usrhst23.Name = 'TERRITORY__C';
        allUserFieldsToTrack.add(usrhst23);
        
        insert allUserFieldsToTrack;

        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = 'DY6 9HP';
        insert acct; 

		Profile pf= [Select Id from profile where Name='System Administrator']; 
        UserRole ur = [Select Id from UserRole where Name='US & CA'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'Manager', 
                         lastName = 'XYZ', 
                         IsActive = False,
                         UserPermissionsInteractionUser =true,
                         UserPermissionsMarketingUser = true,
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23),
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         ProfileId = pf.Id); 
        insert uu;
    }
    public static testmethod void test1(){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        UserRole ur = [Select Id from UserRole where Name='Covered'];
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         IsActive = False,
                         UserPermissionsInteractionUser =true,
                         UserPermissionsMarketingUser = true,
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23),
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         ProfileId = pf.Id,
                         UserRoleId=ur.Id); 
        
        Test.startTest();
        insert uu;
        uu.isActive = True;
        uu.UserPermissionsSupportUser = True;
        uu.Country_Cluster__c = 'US&CA';
        uu.Division__c = 'Atlantic';
        uu.Region_User__c='Central';
        uu.International_User_Region__c='ANZ-Retail';
        uu.FirstName = 'ABCDE';
        uu.MiddleName='IJK';
        uu.LastName='VWXYZ';
        uu.Report_Business_Unit_Manager__c='Joseph Manni';
        uu.Reportng_Manager__c='Daniel Filardi';
        uu.Reporting_Division_Manager__c='Michael Long';
        uu.Reporting_Region_Manager__c='Donna Sexton';
        uu.Title='AB';
        uu.LocaleSidKey='en_GB';
        uu.TimeZoneSidKey='Europe/Guernsey';
        uu.UserPermissionsMarketingUser = false;
        Profile pf1= [Select Id from profile where Name='Business Administrator']; 
        UserRole ur1 = [Select Id from UserRole where Name='Covered'];
        User man1=[Select Id from User where FirstName='Manager' Limit 1];
        uu.ProfileId=pf.Id;
        uu.UserRoleId=ur1.Id;
        uu.ManagerId=man1.Id;
        update uu;
        Test.stopTest();
    }
    
    public static testmethod void test2(){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        Profile pf2= [Select Id from profile where Name='Sales Manager'];
        /*
        Trigger_Configuration__c tc = new Trigger_Configuration__c();
        tc.Name = 'UserTriggerDisabled';
        tc.IsDisabled__c = True;
        insert tc;*/
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu1=new User(firstname = 'ABC', 
                          lastName = 'XYZ',
                          IsActive=true,
                          email = uniqueName + '@test' + orgId + '.org', 
                          UserPermissionsInteractionUser =true,
                          UserPermissionsMarketingUser = true,
                          Username = uniqueName + '@test' + orgId + '.org', 
                          EmailEncodingKey = 'ISO-8859-1', 
                          Alias = uniqueName.substring(18, 23), 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          LocaleSidKey = 'en_US', 
                          LanguageLocaleKey = 'en_US', 
                          ProfileId = pf2.Id,
                          ManagerId = userinfo.getUserId()); 
        
        Test.startTest();
        insert uu1;
        User man1=[Select Id from User where FirstName='Manager' Limit 1];
         
        uu1.ManagerId = man1.Id;
        uu1.ProfileId = pf.id;
        uu1.IsActive=False;
        update uu1;
        Test.stopTest();
    }
}