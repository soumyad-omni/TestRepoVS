/**********************************************************************
Name:  TestDataFactory
=======================================================================
Purpose: This class contains verious methods to generate test data for test classes.                                  
=======================================================================
History                                                            
-------                                                            

VERSION      AUTHOR                   DATE             DETAIL               Description
0.1          Venu Kukkapalli          06/14/2018       INITIAL DEVELOPMENT
0.2          Linda Neel               10/31/2018       ADDED CODE           method to create and insert a sales org for given account
method to create and insert US account
method to create Sales User
***********************************************************************/

@isTest
Public class TestDataFactory {
    
    
    public static Id recTypeCampaignEvent = [SELECT Id FROM RecordType WHERE SObjectType = 'Campaign' AND Name = 'Campaign' LIMIT 1].Id;
    public static Id recTypeContract = [SELECT Id FROM RecordType WHERE SObjectType = 'Contracts__c' AND Name = 'Boilerplate' LIMIT 1].Id;
    public static Id recTypeQuoteApproval = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote' LIMIT 1].Id;
    
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;
    public static Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    public static Id qlNonConfigRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product' LIMIT 1].Id;
    
    public static Product2 p;
    // Campaign record creation method
    
    
    Public static List<Campaign> createCampaign(Integer numberOfCampaigns){
        List<Campaign> cmList=new List<Campaign>();
        for(integer i=0;i<numberOfCampaigns;i++){
            Campaign cm=new Campaign();
            cm.Name='Test Campaign'+i;
            cm.Campaign_Region__c = 'NA - North America';
            cm.Market_Portfolio_Segment__c = 'Automated Dispensing Cabinets';
            cm.IsActive=True;
            cmList.add(cm);
        }  
        return cmList;
    }
    
    // Lead record creation method
    Public static List<Lead> createLead(Integer numberOfLeads){
        List<Lead> leadList=new List<Lead>();
        for(integer i=0;i<numberOfLeads;i++){
            Lead ld=new Lead();
            ld.firstName='TestClass';
            ld.lastname='Lead'+i;
            ld.company='test company'+i;
            ld.email='testmail'+i+'@gmial.com';
            leadList.add(ld);
        }  
        return leadList;
    }
    // Account record creation method
    Public static List<Account> createAccounts(Integer numberOfAccounts){
        List<Account> accList=new List<Account>();
        for(Integer i=0;i<numberOfAccounts;i++){
            Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
            setting111.Name = 'AccountFieldTrack';
            setting111.IsDisabled__c = false;
            insert setting111;
            Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
            insert aDataload;
            Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
            insert accSendOff; 
            Account acc=new Account( SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
            acc.Account_Status__c='Prospect';
            acc.IsDeleted__c=false;
            acc.name='Test Account'+i;
            acc.BillingCity='Musterstadt';
            acc.BILLINGSTREET = '41 Moss';
            acc.BillingCountry = 'United States';
            acc.BillingState = 'Alabama';
            acc.BillingPostalCode = '77777';
            acc.Account_role__c='ZCSN';
            acc.Recordtypeid=recTypeAccount;
            acc.Facility_Type__c = 'Pharmacy';
            acc.texcellency__DefHC_HospitalID__c = 1;
            acc.Territory_Name__c = 'TestTerr';
            acc.Annual_Bill_Date__c=System.today();
            accList.add(acc);
        }
        return accList;
    }
    // Account record creation method
    Public static Account createTestAccount(){
        Default_Currency_by_Country_Code__c   setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
        Account acc = new Account(name='Acc0000001',Account_role__c='ZCSN',
                                  RecordtypeId = recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'AZ';
        insert acc;
        return acc;
    }    // LJN 10/31/2018 - added to create US account
    Public static Account createUSTestAccount(){
        
        // create and insert - US Customer   
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
        insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff;  
        Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                   Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                   BillingCountryCode = 'AZ',RecordtypeId = recTypeAccountUS,
                                   Account_Status__c = 'Active',IsDeleted__c = false,
                                   //Validation_Status__c = 'Awaitng Validation', // default value
                                   Transport_Zone__c='US00000001',Partner_Type__c= '0015',Facility_Type__c = 'Correctional Facilities');
        acct.Facility_Type__c = 'Pharmacy';
        acct.BILLINGSTREET = '41 Moss';
        acct.BillingPostalCode = 'DY6 9HP';
        AccountTriggerHandler.TriggerDisabled = True;
        insert acct;
        return acct;        
    }
    public static Account createTestAccountQuotePrint(){
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
        insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
        dCurrencyCCodeCSetting();//Haripriya
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        insert acc; 
        System.debug('acc : '+acc);
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        system.debug('ACC'+acc.id+ssoc.id); 
        return acc;
    }
    public static Target_Initiative__c createTestTargetInitiative(){
        Target_Initiative__c ti = new Target_Initiative__c();
        ti.Name = 'Test Target Initiative';
        ti.Start_Date__c = Date.today();
        ti.End_Date__c = Date.today().addDays(3);
        insert ti;
        return ti;
    }
    public static Target_Initiative_Account__c createTestTargetInitiativeAccount(){
        Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
        Target_Initiative__c ti = TestDataFactory.createTestTargetInitiative();
        Account a = TestDataFactory.createTestAccountQuotePrint();
        tia.Account__c = a.Id;
        tia.Target_Initiative__c = ti.Id;
        insert tia;
        return tia;
    }
    public static Target_Initiative_Opportunity__c createTestTIOpp(){
        Target_Initiative_Opportunity__c tio = new Target_Initiative_Opportunity__c();
        Target_Initiative__c ti = TestDataFactory.createTestTargetInitiative();
        Opportunity opp = TestDataFactory.createOppWithAccount();
        tio.Opportunity__c = opp.Id;
        tio.Target_Initiative__c = ti.Id;
        insert tio;
        return tio;
    }
    /*IBA-1849 Starts*/
    public static void update_delete_TestTIOpp(){
        List<Target_Initiative__c> tiList = new List<Target_Initiative__c>();
        Target_Initiative__c ti1 = new Target_Initiative__c();
        ti1.Name = 'test1';
        ti1.Start_Date__c = Date.today();
        ti1.End_Date__c = Date.today().addDays(3);
        tiList.add(ti1);
        Target_Initiative__c ti2 = new Target_Initiative__c();
        ti2.Name = 'test3';
        ti2.Start_Date__c = Date.today();
        ti2.End_Date__c = Date.today().addDays(3);
        tiList.add(ti2);
        insert tiList;
        Target_Initiative_Opportunity__c tio = new Target_Initiative_Opportunity__c();
        Opportunity opp = TestDataFactory.createOppWithAccount();
        tio.Opportunity__c = opp.Id;
        tio.Target_Initiative__c = ti1.Id;
        insert tio;
        tio.Target_Initiative__c = ti2.Id;
        update tio;
        delete tio;
    }
    /*IBA-1849 Ends*/
    public static Marketing_Product__c createTestMarketProduct(){
        Target_Initiative_Account__c tia = TestDataFactory.createTestTargetInitiativeAccount();
        Target_Initiative__c ti = TestDataFactory.createTestTargetInitiative();
        Marketing_Product__c mp = new Marketing_Product__c();
        mp.Target_Initiative_Account__c = tia.Id;
        mp.Expected_Bookings__c = 10;
        //mp.Units__c = '2';
        mp.Target_Initiative__c=ti.id;
        insert mp;
        return mp;
    }
    public static Contact createTestContact(Boolean insertRecord, Id accId, String lastName, Id OwnerId) {
        castIronCSetting();
        Contact retCon = new Contact();
        retCon.AccountId = accId;
        retCon.Salesforce_Contact_ID__c ='5678';
        retCon.SAP_Contact_GUID__c = '3467';
        retCon.LastName = lastName;
        if(insertRecord) {
            insert retCon;
        }
        return retCon;
    }
    public static Lead createTestLead(Boolean insertRecord, Id accId, String companyName, String lastName, Id OwnerId) {
        Lead retLead = new Lead();
        retLead.LastName = lastName;
        retLead.Account__c = accId;
        retLead.Company = companyName;
        if(insertRecord) {
            insert retLead;
        }
        return retLead;
    }
    public static Campaign createTestCampaignwithparent(Boolean insertRecord, String campName, Id parent) {
        Campaign retCamp = new Campaign();
        retCamp.Name = campName;
        retCamp.ParentId = parent;
        retCamp.RecordTypeId = recTypeCampaignEvent;
        if(insertRecord) {
            insert retCamp;
        }
        return retCamp;
    }
    public static Campaign createTestCampaign(Boolean insertRecord, String campName) {
        Campaign retCamp = new Campaign();
        retCamp.Name = campName;
        retCamp.RecordTypeId = recTypeCampaignEvent;
        if(insertRecord) {
            insert retCamp;
        }
        return retCamp;
    }
    public static CampaignMember createCampaignMemberFromContact(Boolean insertRecord, Id campId, Id contactId, String responseStatus) {
        CampaignMember retMember = new CampaignMember();
        retMember.CampaignId = campId;
        retMember.ContactId = contactId;
        retMember.Status = responseStatus;
        if(insertRecord) {
            insert retMember;
        }
        return retMember;
    }
    public static CampaignMember createCampaignMemberFromLead(Boolean insertRecord, Id campId, Id leadId, String responseStatus) {
        CampaignMember retMember = new CampaignMember();
        retMember.CampaignId = campId;
        retMember.LeadId = leadId;
        retMember.Status = responseStatus;
        if(insertRecord) {
            insert retMember;
        }
        return retMember;
    }
    // Create Campaign member History record - Bharath SF-BUG-1080
    Public static List<Campaign_Member_History__c> createCampaignmemberhistory(Integer numberOfCampaignhistory, List<Campaign> Campaign, Id campaignMemberId){
        List<Campaign_Member_History__c> cmhList=new List<Campaign_Member_History__c>();
        for(integer i=0;i<numberOfCampaignhistory;i++){
            Campaign_Member_History__c cmh=new Campaign_Member_History__c();
            cmh.Name='Test CampaignHistory'+i; 
            cmh.Status__c = 'Sent';
            if(Campaign[i].Id!=null)
                cmh.Campaign__c = Campaign[i].Id;
            cmh.Campaign_Member_Id__c = campaignMemberId;
            cmh.Cancel_Date__c = System.today()+5;
            cmh.Tour_Date__c =System.today()+3;
            cmh.Inquiry_Date__c = System.today()+2;
            cmh.Register_Date__c = System.today()+3;
            cmh.Description__c = 'Test Description'+ i;
            cmhList.add(cmh);
        }  
        return cmhList;
    }
    // Methods starting from here are from existing TestHelper class
    public static User getCurrentUser() {
        return [Select Id from User where Id = :UserInfo.getUserId()];
    }
    //don't use spaces in the first/last names, it will cause an issue with the email containing spaces
    public static User createUser(Boolean insertRecord, String firstName, String lastName) {
        Id sysAdminId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'].get(0).Id;
        User retUser = new User();
        retUser.FirstName = firstName;
        retUser.LastName = lastName;
        retUser.UserName = firstName + '.' + lastName + '@unitTest.com';
        System.debug('User Name : '+retUser.UserName);
        retUser.Email = + System.now().millisecond()+'.testusermail@omnicell.com';
        retUser.Alias = firstName.substring(0, 1) + lastName.left(7);
        retUser.CommunityNickname = firstName + ' ' + lastName;
        retUser.TimeZoneSidKey = 'America/New_York';
        retUser.LocaleSidKey = 'en_US';
        retUser.EmailEncodingKey = 'UTF-8';
        retUser.LanguageLocaleKey = 'en_US';
        retUser.User_Division__c = 'Inside';
        retUser.User_Territory__c = 'Inside';
        retUser.Position_Name__c = 'Bookings Team';
        retUser.Country_Cluster__c = 'US&CA';
        retUser.Region_User__c = 'Central';
        retUser.Division__c = 'Atlantic';
        retUser.Territory__c = 'East OH';
        retUser.ProfileId = sysAdminId;
        if(insertRecord) {
            insert retUser;
        }
        return retUser;
    }    
    public static User createSalesUser(Boolean insertRecord, String firstName, String lastName) {
        Id sysAdminId = [SELECT Id, Name FROM Profile WHERE Name = 'Sales Representative'].Id;
        User retUser = new User();
        retUser.FirstName = firstName;
        retUser.LastName = lastName;
        retUser.UserName = firstName + '.' + lastName + '@unitTest.com';
        retUser.Email = 'testsalesusermail@omnicell.com';
        retUser.Alias = firstName.substring(0, 1) + lastName.left(7);
        retUser.CommunityNickname = firstName + ' ' + lastName;
        retUser.TimeZoneSidKey = 'America/New_York';
        retUser.LocaleSidKey = 'en_US';
        retUser.EmailEncodingKey = 'UTF-8';
        retUser.LanguageLocaleKey = 'en_US';
        retUser.Country_Cluster__c = 'US&CA';
        retUser.Region_User__c = 'Central';
        retUser.Division__c = 'Atlantic';
        retUser.Territory__c = 'East OH';
        retUser.User_Territory__c = 'Inside';
        retUser.ProfileId = sysAdminId;
        if(insertRecord) {
            insert retUser;
        }
        return retUser;
    } 
    public static User createUserBusinessAdmin(Boolean insertRecord, String firstName, String lastName) {
        Id sysAdminId = [SELECT Id, Name FROM Profile WHERE Name = 'Business Administrator'].Id;
        User retUser = new User();
        retUser.FirstName = firstName;
        retUser.LastName = lastName;
        retUser.UserName = firstName + '.' + lastName + '@unitTest.com';
        retUser.Email = 'testsalesusermail@omnicell.com';
        retUser.Alias = firstName.substring(0, 1) + lastName.left(7);
        retUser.CommunityNickname = firstName + ' ' + lastName;
        retUser.TimeZoneSidKey = 'America/New_York';
        retUser.LocaleSidKey = 'en_US';
        retUser.EmailEncodingKey = 'UTF-8';
        retUser.LanguageLocaleKey = 'en_US';
        retUser.Country_Cluster__c = 'US&CA';
        retUser.Region_User__c = 'Central';
        retUser.Division__c = 'Atlantic';
        retUser.Territory__c = 'East OH';
        retUser.User_Territory__c = 'Inside';
        retUser.ProfileId = sysAdminId;
        if(insertRecord) {
            insert retUser;
        }
        return retUser;
    }
    // Task create method
    public static Task createTask(Id whatId, Boolean recurring) {
        Task retTask = new Task();
        //subject?
        retTask.IsRecurrence = recurring;
        if(recurring) {
            retTask.RecurrenceStartDateOnly = Date.today();
            retTask.RecurrenceType = 'RecursEveryWeekday';
            retTask.RecurrenceDayOfWeekMask = 2;
            retTask.RecurrenceEndDateOnly = retTask.RecurrenceStartDateOnly.addMonths(1);
        }
        retTask.WhatId = whatId;
        insert retTask;
        return retTask;
    }
    // create Campaign contact
    public static Contact createCampaignContact(Boolean insertRecord, Id accId, String lastName) {
        Contact retCon = new Contact();
        retCon.AccountId = accId;
        retCon.LastName = lastName;
        if(insertRecord) {
            insert retCon;
        }
        return retCon;
    }
    // create Contract record
    public static Contracts__c createContract(){
        Account acc = createTestAccountQuotePrint();
        //Account acc=new Account(name='Test account',Account_role__c='ZCSN',Account_Territory__c='AZ');
        //insert acc;
        //acct = createTestAccount();
        
        Contracts__c contr = new Contracts__c();
        contr.Account__c = acc.Id;
        contr.Type__c = 'Boilerplate Master Agreement';
        contr.Has_all_Checklist_Document_Been_Uploaded__c = true;
        contr.RecordTypeId = recTypeContract;
        contr.Bookings_Team_Approved__c = false;
        
        insert contr;
        
        return contr;
    }
    public static Opportunity createOpportunity(){
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c='Matthew Merson';
        insert opp;
        return opp;
    }
    public static Opportunity createOppWithAccount(){
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.PAW_ExternalID__c = '2344';
        opp.ExpectedInstallDate__c = System.today()+60;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.Opportunity_Segment__c = 'test1;test2'; //IBA-1849
        opp.Services_Enablement_Owner__c = 'Neal Moriconi'; 
        // opp.Is_this_an_Upgrade__c = 'No'; //IBA-3633
        AccountTriggerHandler.TriggerDisabled = True;
        insert opp;
        createProductLine(opp.id);
        return opp;
    }
    public static Quote createPrimaryTestQuote(){
        //List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:createContactWithAccount_Integration().Id];
        OpportunityTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        AccountCreateController.isFirstRun= false;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        //quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        //quote.ContactId= createTestContact(true, createUSTestAccount().id, 'Testnamett1',null).id;
        //Contact cont= createContactWithAccount_Integration();
        quote.OpportunityId = createOppWithAccount().Id;
        Opportunity opp = [select accountid from opportunity where id=:quote.opportunityId];//sravan 22feb
        createProductLine(opp.id);
        Contact cont = createContactForAcc(opp.AccountId);//sravan 22feb
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        //quote.Bill_to_Account__c = createTestAccountQuotePrint().Id;
        quote.Bill_to_Account__c = opp.AccountId;//Sravan 22feb
        quote.Pricebook2Id = Test.getStandardPricebookId();
        insert quote;
        return quote;
    }
    public static Quote createTestQuote(){
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        quote.Quote_Number__c = 'test123';
        quote.OpportunityId = createOpportunity().Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        insert quote;
        return quote;
        
        
    }
    public static Opportunity createOppWithAccount_Integration(){
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = 'Proposal';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Matthew Merson';
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated');
        //acc.BillingCountryCode = 'AZ';
        //acc.Validated__c = 'Validated';
        //acc.Account_Status__c = 'Active';
        //acc.Account_Territory__c = 'AZ';
        // acc.IsDeleted__c = false;
        
        //insert acc;
        //Account acc = createTestAccountQuotePrint();
        Account acc = createUSTestAccount();
        opp.AccountId = acc.id;
        
        insert opp;
        return opp;
    }
    public static Opportunity createOppWitOptyTypeAndAccount_Integration(){
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = 'Proposal';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Opportunity__c='MTS Opportunity';
        opp.OppStatus__c = 'PO Received - Pending Paperwork';
        Account acc = createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        //opp.Is_this_an_Upgrade__c = 'No';
        insert opp;
        return opp;
    }
    public static Contact createContactWithAccount_Integration(){
        castIronCSetting();//Haripriya
        dCurrencyCCodeCSetting();//Haripriya  
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
        insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff;  
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Transportation_Zone_Country__c='AD',Partner_Type__c='0001',Transport_Zone__c='IN00000002',Account_Territory__c='CT',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Validated__c = 'Validated',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated');
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'AZ';
        acc.Facility_Type__c = 'Pharmacy';
        acc.SAP_Account_ID__c = '0000000000';
        acc.BILLINGSTREET = '41 Moss';
        acc.BillingPostalCode = 'DY6 9HP';
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        
        SAP_Sales_Org__c sso= new SAP_Sales_Org__c(Sales_Org__c = 'OM01',CurrencyIsoCode = 'USD',Customer_Pricing_Procedure__c='1',Default_GPO_Price_List__c='A0',Default_IDN_Price_List__c='A1',Distribution_Channel__c='01',Sales_Office__c = 'OMNE',Shipping_Conditions__c = 'AW',Terms_of_Payment__c = 'NT30',Account__c = acc.Id,Incoterms_1__c = 'ALT',Service_Level__c='AN',Incoterms_2__c='San Francisco');
        insert sso;
        
        //acc.Validation_Status__c = 'Validated';
        //update acc;
        con.AccountId = acc.id;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        
        /*con.SAP_Contact_ID__c='1234';
con.Salesforce_Contact_ID__c ='5678';
con.SAP_Contact_GUID__c = '3467';
update con;*/
        return con;
    }
    public static Contact createContactForAcc(Id accId){
        castIronCSetting();//Haripriya
        dCurrencyCCodeCSetting();//Haripriya        
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
        con.AccountId = accId;
        //con.Title = 'Manager';
        insert con;
        return con;
    }
    public static Contact ContactWithoutSAPContactId_Integration(){
        castIronCSetting();//Haripriya
        dCurrencyCCodeCSetting();//Haripriya        
        Contact con = new Contact();
        con.LastName='Smith';
        con.Is_Active__c ='Y';
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Transportation_Zone_Country__c='AD',Partner_Type__c='0001',Transport_Zone__c='IN00000002',Account_Territory__c='CT',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Validated__c = 'Validated',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated');
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'AZ';
        acc.Facility_Type__c = 'Correctional Facilities';
        insert acc;
        
        acc.SAP_Account_ID__c ='1234';
        update acc;
        
        SAP_Sales_Org__c sso= new SAP_Sales_Org__c(Sales_Org__c = 'OM01',CurrencyIsoCode = 'USD',Customer_Pricing_Procedure__c='1',Default_GPO_Price_List__c='A0',Default_IDN_Price_List__c='A1',Distribution_Channel__c='01',Sales_Office__c = 'OMNE',Shipping_Conditions__c = 'AW',Terms_of_Payment__c = 'NT30',Account__c = acc.Id,Incoterms_1__c = 'ALT',Service_Level__c='AN');
        insert sso;
        //acc.Validation_Status__c = 'Validated';
        //update acc;
        con.AccountId = acc.id;
        insert con;
        //con.SAP_Contact_ID__c='1234';
        //update con;
        return con;
    }
    public static AccountContactRelation createAcctConRel_Integration(){
        AccountContactRelation actcon = new AccountContactRelation();
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Partner_Type__c='0001',Transportation_Zone_Country__c='AD',Transport_Zone__c='IN00000002',Account_Territory__c='CT',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD');
        //insert acc;
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'AZ';
        acc.Facility_Type__c='Retail Clinic';
        insert acc;
        acc.SAP_Account_ID__c = '0000001234';
        update acc;
        
        actcon.AccountId = acc.id;
        actcon.ContactId = createContactWithAccount_Integration().Id;
        insert actcon;
        
        return actcon;
    }
    public static SAP_Sales_Org__c createSAPSAlesOrg_Integration(){
        SAP_Sales_Org__c sso= new SAP_Sales_Org__c();
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='CT',RecordtypeId = recTypeAccount);
        //insert acc;
        Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',RecordtypeId = recTypeAccount,CurrencyIsoCode='USD',Account_Status__c = 'Active',IsDeleted__c = false,Validation_Status__c = 'Validated',SAP_Account_ID__c='12345');
        acc.BillingCountryCode = 'AZ';
        acc.Facility_Type__c='Retail Clinic';
        insert acc;
        
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',Distribution_Channel__c='01',Incoterms_2__c='Test',tax_classification__c='1');
        insert ssoc;
        return ssoc; 
        /*sso.Sales_Org__c = 'OM01';
sso.Account__c = acc.Id;
sso.Terms_of_Payment__c = 'NT30';
sso.Shipping_Conditions__c = 'AW';
sso.Sales_Office__c = 'U556';
sso.Distribution_Channel__c='01';
sso.Incoterms_1__c = 'ALT';
sso.Service_Level__c='AN';
sso.Default_GPO_Price_List__c='A0';
sso.Default_IDN_Price_List__c='A1';
sso.Customer_Pricing_Procedure__c='1';
return sso;*/
    }
    public static SAP_Sales_Org__c createSAPSAlesOrgForAccount(Id accId){
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=accId,Sales_org__c = 'OM01',Sales_Office__c ='U556',Incoterms_1__c='CFR',Distribution_Channel__c='02',Incoterms_2__c='Test',tax_classification__c='1');
        insert ssoc;
        return ssoc;
    }
    public static Quote createTestQuote1(){
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        Opportunity opp = TestDataFactory.createOppWithAccount();  
        quote.OpportunityId = opp.Id;
        System.debug('#### Opportunity'+ QuoteTriggerHandler.TriggerDisabled);
        Contact con = new Contact();
        con.LastName='Smith'+ system.now().millisecond();
        con.Is_Active__c ='Y';
        con.AccountId = opp.AccountId;
        con.Omnicell_Job_Code__c = 'D3';
        insert con;
        quote.ContactId= con.id;
        QuoteTriggerHandler.TriggerDisabled= false;
        System.debug('#### Contact'+ QuoteTriggerHandler.TriggerDisabled);
        quote.Bill_to_Account__c = opp.AccountId;
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.SAP_Expected_Bookings__c=0;
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= con.Id;
        quote.Order_Type__c = 'ZHQR';
        quote.subscription_Months__c = 1;
        //       Opportunity opp = TestDataFactory.createOppWithAccount();  
        System.debug('####'+ QuoteTriggerHandler.TriggerDisabled);
        //       quote.OpportunityId = opp.Id;
        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        insert quote;
        
        
        return quote;
    } 
    public static Quote createTestQuote_Integration(){
        System.debug('####'+ QuoteTriggerHandler.TriggerDisabled);
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        System.debug('####'+ QuoteTriggerHandler.TriggerDisabled);
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:createContactWithAccount_Integration().Id];
        //quote.Quote_Number__c = 'test123';
        System.debug('####'+ QuoteTriggerHandler.TriggerDisabled);
        quote.OpportunityId = createOppWithAccount_Integration().Id;
        quote.Pricebook2Id = Test.getStandardPricebookId();
        System.debug('####'+ QuoteTriggerHandler.TriggerDisabled);
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
        Opportunity opp = TestDataFactory.createOppWithAccount();  
        System.debug('####'+ QuoteTriggerHandler.TriggerDisabled);
        quote.OpportunityId = opp.Id;
        insert quote;
        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        
        
        return quote;
    }
    public static Account createTestAccountQuotePrint1(){
        dCurrencyCCodeCSetting();
        
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',/*PIS_HIS__c  = 'test',*/SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        acc.Annual_Bill_Date__c = System.today()+100;
        acc.Service_Escalator__c = 10;
        insert acc; 
        System.debug('acc : '+acc);
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        system.debug('ACC'+acc.id+ssoc.id); 
        return acc;
    }
    public static Opportunity createOppWithAccount_Integration1(){
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = 'Proposal';
        opp.CloseDate = System.today()+30;
        opp.PAW_ExternalID__c = '2344';
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Angelica Cortez';
        Account acc = createTestAccountQuotePrint1();
        opp.AccountId = acc.id;
        insert opp;
        return opp;
    }
    public static Quote createTestQuote_Integration1(){
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:createContactWithAccount_Integration().Id];
        
        quote.OpportunityId = createOppWithAccount_Integration1().Id;
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
        quote.EOL_Date__c = System.today();
        quote.Master_Agreement__c = 'test';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        
        insert quote;
        
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        
        update quote;
        
        
        return quote;
    }
    public static Quote_Line__c createTestQuoteLine_Integration(){
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        
        insert ql;
        
        ql.SAP_Line_Number__c = 200;
        update ql;
        return ql;
    }
    //creates test quote line record for a quote record
    public static Quote_Line__c createTestQuoteLineForQuote(Id quoteId){
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        Product2 prod = new Product2(Name = 'Renewal',Family = 'test',External_ID__c = '123456',ProductCode = 'Renewal-SV');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('quote.Id : '+quote.Id);
        ql.Quote__c = quoteId;
        insert ql;
        return ql;
    }
    public static Quote_Line__c deleteTestQuoteLine_Integration(){
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Contract_List_Price__c = 200;
        //Added by Sravan
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = false;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'TestProduct',Family = 'test',External_ID__c = '123456',ProductCode = 'TestProduct');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        
        insert ql;
        System.debug('Supplement : '+ql.Conga_Supplement_Version__c);
        //delete ql;
        
        return ql;
    }
    public static Quote_Line__c ServiceTestQuoteLine_Integration(){
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = createTestQuote_Integration().Id;
        ql.Higher_Level_Item__c = 200;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 201;
        ql.SAP_Line_Item_GUID__c = '400';
        //Added by Sravan
        ql.Material_Type__c = 'PRODUCT';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct';
        Product2 prod = new Product2(Name = 'TestProduct',Family = 'test',External_ID__c = '123456',ProductCode = 'TestProduct');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        //insert ql;
        
        //delete ql;
        
        return ql;
    }
    public static Quote_Line__c createTestQuoteLine_WithQuoteId(Id quoteId){
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        ql.Quote__c = quoteId;
        ql.Higher_Level_Item__c = 1;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 200;
        ql.Contract_List_Price__c = 200;
        insert ql;
        return ql;
    }
    public static Conga_Quote_Print__c createTestCongaQuotePrint(Id quoteId){
        Conga_Quote_Print__c qp = new Conga_Quote_Print__c();
        //qp.Print_Layout__c = layout;
        qp.Quote_Record_ID__c = quoteID;
        qp.Change_Order__c = '';
        qp.Name = 'test_quote_print_record';
        qp.Section_Ids__c = '0000000000';
        qp.Exhibit_Ids__c = '0000000000';
        qp.Print_Output_Format__c = 'PDF';
        insert qp;
        return qp;
    }
    public static List<Quote_Line__c> listcreateTestQuoteLine_Integration(Integer numOfQuotes){
        List<Quote_Line__c> qlList = new List<Quote_Line__c>();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        for(Integer i=0;i<numOfQuotes;i++){
            Quote_Line__c ql = new Quote_Line__c();
            ql.RecordTypeId = qlNonConfigRecordType.id;
            ql.Quote__c = createTestQuote_Integration().Id;
            ql.Higher_Level_Item__c = 1;
            ql.Quantity__c = 1;
            ql.SAP_Line_Number__c = 200;
            
        }
        insert qlList;
        return qlList;
    }
    public static Product_Line__c createTestProdLine(){
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = createOppWithAccount().Id;
        pl.Quantity__c = 3;
        pl.Quote__c = createPrimaryTestQuote().Id;
        insert pl;
        return pl;
    }
    public static Product_Segment__c createTestProdSegment(Account acc){
        Product_Segment__c ps = new Product_Segment__c();
        ps.Amount__c = 1000;
        ps.Date_Booked__c = System.today()-5;
        ps.Estimate__c = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        opp.AccountId = acc.id;
        insert opp;
        ps.Opportunity__c = opp.Id;
        ps.Quantity__c = 3;
        ps.Quote__c = createPrimaryTestQuote().Id;
        ps.Product_Segment__c='Test';
        insert ps;
        return ps;
    }  
    public static Business_Segment__c createTestBusinessSegment(){
        Business_Segment__c ps = new Business_Segment__c();
        ps.Amount__c = 1000;
        ps.Date_Booked__c = System.today()-5;
        ps.Estimate__c = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        insert opp;
        ps.Opportunity__c = opp.Id;
        ps.Quantity__c = 3;
        ps.Quote__c = createPrimaryTestQuote().Id;
        ps.Business_Segment__c='Test';
        insert ps;
        return ps;
    } 
    public static Quote_Line_Type__c createTestQuoteLineItemType(){
        Quote_Line_Type__c qlt = new Quote_Line_Type__c();
        qlt.Amount__c = 1000;
        qlt.Date_Booked__c = System.today()-5;
        qlt.Estimate__c = true;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        opp.AccountId = acc.id;
        insert opp;
        qlt.Opportunity__c = opp.Id;
        qlt.Quantity__c = 3;
        qlt.Quote__c = createPrimaryTestQuote().Id;
        insert qlt;
        return qlt;
    }
    public static void createProduct(){
        p = new product2(name='Test Product',ProductCode='W0196',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Test Product Line',DW_Product_Segment__c='Test Product Segment',DW_Business_Segment__c='Test Business Segment', External_ID__c='t'+system.now());
        p.Family = 'License';
        insert p;
    }
    public static Product2 createTestProduct(){
        Product2 p = new product2(name='Test Product',ProductCode='W0196',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Test Product Line',DW_Product_Segment__c='Test Product Segment',DW_Business_Segment__c='Test Business Segment', External_ID__c='t'+system.now());
        p.Family = 'License';
        insert p;
        return p;
    }
    public static Product2 createTest2Product(){
        Product2 p = new product2(name='Test Product2',ProductCode='W0126',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Robotic IV Insourcing Solution (RIIS)',DW_Product_Segment__c='Test Product Segment',DW_Business_Segment__c='Test Business Segment', External_ID__c='t5'+system.now());
        p.Family = 'License';
        insert p;
        return p;
    }
    public static Product2 createTest3Product(){
        Product2 p = new product2(name='Test Product',ProductCode='W0116',Business_Line__c='Medication Dispensing Cabinets',DW_Product_Line__c='Test Product Line',DW_Product_Segment__c='Test Product Segment',DW_Business_Segment__c='Test Business Segment', External_ID__c='t2'+system.now());
        p.Family = 'License';
        insert p;
        return p;
    }
    public static Product2 createTest4Product(){
        Product2 p = new product2(name='Test Product2',ProductCode='W0146',Business_Line__c='IV Product Solutions',DW_Product_Line__c='Robotic IV Insourcing Solution (RIIS)',DW_Product_Segment__c='Test Product Segment',DW_Business_Segment__c='Test Business Segment', External_ID__c='t'+system.now());
        p.Family = 'License';
        insert p;
        return p;
    }
    public static Quote_Line__c createQuoteLineItem(){
        Id pricebookId = Test.getStandardPricebookId();
        createProduct();
        PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId, product2id = p.id,unitprice=1.0,isActive=true);
        insert pbe;
        Quote_Line__c qli = new Quote_Line__c(Product__c=p.id,Quantity__c=10);
        qli.Quote_Line_Item_Type__c='New';
        qli.Customer_Price__c = 100;
        qli.Total_Cost__c = 2000;
        insert qli;
        return qli;
    }
    public static Product_Changes__c createProductChanges(){
        Product2 p = new product2(name='Test Product1 Test1',ProductCode='W0197',Business_Line__c='IV Product Solutions1',DW_Product_Line__c='Test Product Line1',DW_Product_Segment__c='Test Product Segment1',DW_Business_Segment__c='Test Business Segment1', External_ID__c='t'+system.now());
        p.Family = 'testLicense';
        insert p;
        
        Product_Changes__c pc = new Product_Changes__c();
        pc.Active__c = true;
        pc.Effective_Date__c = System.Today()-1;
        pc.Error_Message__c = 'this test product oudated from today onwards';
        pc.Old_Product_Number__c = p.id;
        return pc;
    }
    public static Product_Changes__c createProductChangesForQuoteLine(Id prodId){
        Product_Changes__c pc = new Product_Changes__c();
        pc.Active__c = true;
        pc.Effective_Date__c = System.Today()-1;
        pc.Error_Message__c = 'this test product oudated from today onwards';
        pc.Old_Product_Number__c = prodId;
        insert pc;
        return pc;
    }
    public static Quote_Approval__c createQuoteApprovalRec(){
        Quote_Approval__c qtApp = new Quote_Approval__c();
        qtApp.RecordTypeId = recTypeQuoteApproval;
        qtApp.Need_Manual_Approval__c = true;
        return qtApp;
    }
    public static Quote_Approval__c createQuoteApprovalRecForQuote(Id qId){
        Quote_Approval__c qtApp = new Quote_Approval__c();
        qtApp.RecordTypeId = recTypeQuoteApproval;
        qtApp.Quote__c = qId;
        qtApp.Need_Manual_Approval__c = true;
        return qtApp;
    }
    public static SAP_Sales_Org__c createSAPSAlesOrg(){
        SAP_Sales_Org__c sso= new SAP_Sales_Org__c();
        sso.Sales_Org__c = 'OM01';
        sso.Terms_of_Payment__c = 'NT30';
        sso.Shipping_Conditions__c = 'AW';
        sso.Sales_Office__c = 'OMC';
        sso.Distribution_Channel__c='01';
        sso.Incoterms_1__c = 'ALT';
        sso.Service_Level__c='AN';
        sso.Default_GPO_Price_List__c='A0';
        sso.Default_IDN_Price_List__c='A1';
        sso.Customer_Pricing_Procedure__c='1';
        return sso;
    }
    // LJN 10/31/2018 - added to create sales org for given account
    public static SAP_Sales_Org__c createSalesOrg(Id accountId){
        
        SAP_Sales_Org__c sso= new SAP_Sales_Org__c();
        sso.Account__c = accountId;
        sso.Sales_Org__c = 'OM01';
        sso.Terms_of_Payment__c = 'NT30';
        sso.Shipping_Conditions__c = 'AW';
        sso.Sales_Office__c = 'OMC';
        sso.Distribution_Channel__c='01';
        sso.Incoterms_1__c = 'ALT';
        sso.Incoterms_2__c='MOUNTAIN VIEW';
        sso.Service_Level__c='AN';
        sso.Default_GPO_Price_List__c='A0';
        sso.Default_IDN_Price_List__c='A1';
        sso.Customer_Pricing_Procedure__c='1';
        sso.Default_Price_Code__c = 'CVS';           
        sso.Pricing_Date__c = Date.valueOf('2018-10-31'); 
        sso.Customer_Pricing_Procedure__c = '1';
        insert sso;
        return sso;
    }
    public static Relationship__c createRelationshipForAccount(Id accid){
        Relationship__c rel = new Relationship__c();
        rel.Primary_Account__c = accid;
        Account acc = createTestAccountQuotePrint();
        List<Sap_Sales_Org__c> sso = [select id,name from SAP_Sales_Org__c where Account__c =: accid];
        rel.Secondary_Account__c = acc.id;
        rel.Primary_Account_Sales_Org__c = sso[0].Id;
        return rel;
    }
    public static AccountTeamMember createTestAccountTeamMemberWithAccId(Id accid){
        AccountTeamMember atm = new AccountTeamMember();
        User user = TestDataFactory.createUser(true,'test','user');
        atm.AccountId = accid;
        atm.AccountAccessLevel = 'Read';
        atm.OpportunityAccessLevel = 'Read';
        atm.ContactAccessLevel = 'Read';
        atm.TeamMemberRole = 'Lead Qualifier';
        atm.UserId = user.id;
        insert atm;
        return atm;
    }
    public static AccountTeamMember createTestAccountTeamMember(){
        AccountTeamMember atm = new AccountTeamMember();
        User user = TestDataFactory.createUser(true,'test','user');
        atm.AccountAccessLevel = 'Read';
        atm.OpportunityAccessLevel = 'Read';
        atm.ContactAccessLevel = 'Read';
        atm.TeamMemberRole = 'Lead Qualifier';
        atm.UserId = user.id;
        return atm;
    }
    //Haripriya - 26/11/2018
    public static void  castIronCSetting(){
        CastIronIntegration__c contact_setting = new CastIronIntegration__c();
        contact_setting.Name= 'CastIronIntegration';
        contact_setting.AccountRole_SoldTo__c = 'ZCSN';
        insert contact_setting;
    }
    //Haripriya - 27/11/2018
    public static void eccSOrgToCRMCSetting(){
        ECC_Sales_Org_to_CRM__c setting1 = new ECC_Sales_Org_to_CRM__c();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.ECC_Code__c = 'AU01';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        
        ECC_Sales_Org_to_CRM__c setting2 = new ECC_Sales_Org_to_CRM__c();
        setting2.Name = 'MACH4 - GmbH';
        setting2.ECC_Code__c = 'OM32';
        setting2.CRM_Code__c = 'O 50008654';
        insert setting2;
        
        ECC_Sales_Org_to_CRM__c setting3 = new ECC_Sales_Org_to_CRM__c();
        setting3.Name = 'Omnicell - St.Petes';
        setting3.ECC_Code__c = 'OM02';
        setting3.CRM_Code__c = 'O 50008663';
        insert setting3;
        
        ECC_Sales_Org_to_CRM__c setting4 = new ECC_Sales_Org_to_CRM__c();
        setting4.Name = 'Omnicell Inc.';
        setting4.ECC_Code__c = 'OM01';
        setting4.CRM_Code__c = 'O 50000029';
        insert setting4;
        
        ECC_Sales_Org_to_CRM__c setting5 = new ECC_Sales_Org_to_CRM__c();
        setting5.Name = 'Omnicell Ltd';
        setting5.ECC_Code__c = 'OM31';
        setting5.CRM_Code__c = 'O 50008655';
        insert setting5;
        
        ECC_Sales_Org_to_CRM__c setting6 = new ECC_Sales_Org_to_CRM__c();
        setting6.Name = 'Omnicell SAS';
        setting6.ECC_Code__c = 'OM34';
        setting6.CRM_Code__c = 'O 50011128';
        insert setting6;        
    }
    //Haripriya - 27/11/2018
    public static void dCurrencyCCodeCSetting(){
        Default_Currency_by_Country_Code__c dccc_setting1 = new Default_Currency_by_Country_Code__c();
        dccc_setting1.Name = 'AZ';
        dccc_setting1.Currency_Code__c = 'USD';
        insert dccc_setting1;
        
        Default_Currency_by_Country_Code__c dccc_setting2 = new Default_Currency_by_Country_Code__c();
        dccc_setting2.Name = 'US';
        dccc_setting2.Currency_Code__c = 'USD';
        insert dccc_setting2;
    }
    public static Account createTestAccountQuotePrintSales(){
        dCurrencyCCodeCSetting();//Haripriya
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                                  BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                                  BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated');
        insert acc; 
        System.debug('acc : '+acc);
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        system.debug('ACC'+acc.id+ssoc.id); 
        return acc;
    }
    public static Opportunity createOppWithAccountSales(){
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        Account acc = TestDataFactory.createTestAccountQuotePrintSales();
        opp.AccountId = acc.id;
        opp.Services_Enablement_Owner__c = 'Matthew Merson';
        opp.OppStatus__c = 'Open';
        insert opp;
        return opp;
    }
    public static Quote createTestQuote_IntegrationSales(){
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:createContactWithAccount_Integration().Id];
        quote.OpportunityId = createOppWithAccount_IntegrationSales().Id; /* Changed Line */
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
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccountSales();  /* Changed Line */
        quote.OpportunityId = opp.Id;
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
        update quote;
        return quote;
    }
    public static Opportunity createOppWithAccount_IntegrationSales(){
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity';
        opp.stageName = 'Proposal';
        opp.CloseDate = System.today()+30;
        opp.ExpectedInstallDate__c = System.today()+60;
        Account acc = createTestAccountQuotePrintSales();
        opp.AccountId = acc.id;
        insert opp;
        return opp;
    }
    public static void createProductLine(ID opID){
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = opID;    
        insert pl;
    }
    //IBA-2656 starts
    public static List<PAR_Location__c> createParLocation(Account a){
        List<PAR_Location__c> parloc = new List<PAR_Location__c>();
        PAR_Location__c pl = new PAR_Location__c(Name = 'Test1',Account__c = a.id);
        PAR_Location__c p2 = new PAR_Location__c(Name = 'Test2',Account__c = a.id);
        parloc.add(pl);
        parloc.add(p2);
        insert parloc;
        return parloc;
    }
    //IBA-2656 ends
    public static void createOCProd(String proCode){
        OC_Cloud_Product__c ocProd = new OC_Cloud_Product__c();
        ocProd.Name = proCode;
        ocProd.Product_Name__c = proCode;
        insert ocProd;
    }
    public static void createReplProd(String proCode){
        Replacement_Products__c replProd = new Replacement_Products__c();
        replProd.Name = proCode;
        replProd.Product_Name__c = proCode;
        insert replProd;
    }
    public static void createWinProd(String proCode){
        Win7_Support_Products__c winProd = new Win7_Support_Products__c();
        winProd.Name = proCode;
        winProd.Product_Name__c = proCode;
        insert winProd;
    }
    public static void createCannedLan(){
        List<Canned_Language__c> clList = new List<Canned_Language__c>();
        Canned_Language__c cl = new Canned_Language__c(Name='Development Product(Omnicell)',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl);
        Canned_Language__c cl1 = new Canned_Language__c(Name='ServiceNow',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl1);
        Canned_Language__c cl2 = new Canned_Language__c(Name='Connect-RX Upgrade',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
        clList.add(cl2);
        Canned_Language__c cl3 = new Canned_Language__c(Name='Classic Hardware EOL �Lease',Canned_Language_Detail__c = 'Test',Omnicell_or_Aesynt__c='Omnicell');
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
    }
    public static void createCongaBaseTemplateCS(){
        List<Conga_Base_Template__c> btList = new List<Conga_Base_Template__c>();
        
        APXTConga4__Conga_Template__c ct1 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Omnicell as Service SOW');
        insert ct1;
        Conga_Base_Template__c b1 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW', template_id__c = 'testid');
        btList.add(b1);
        
        APXTConga4__Conga_Template__c ct2 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Omnicell as Service Supplement');
        insert ct2;
        Conga_Base_Template__c b2 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement', template_id__c = ct2.Id);
        btList.add(b2);
        
        APXTConga4__Conga_Template__c ct3 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Omnicell as Service SOW Prof');
        insert ct3;
        Conga_Base_Template__c b3 = new Conga_Base_Template__c(Name = 'Omnicell as Service SOW Prof', template_id__c = ct3.Id);
        btList.add(b3);
        
        APXTConga4__Conga_Template__c ct4 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Omnicell as Service Supplement Prof');
        insert ct4;
        Conga_Base_Template__c b4 = new Conga_Base_Template__c(Name = 'Omnicell as Service Supplement Prof', template_id__c = ct4.Id);
        btList.add(b4);
        
        APXTConga4__Conga_Template__c ct5 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Summary by Product OmnicellService');
        insert ct5;
        Conga_Base_Template__c b5 = new Conga_Base_Template__c(Name = 'Summary by Product OmnicellService', template_id__c = ct5.Id);
        btList.add(b5);
        
        APXTConga4__Conga_Template__c ct6 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Pass SOW');
        insert ct6;
        Conga_Base_Template__c b6 = new Conga_Base_Template__c(Name = 'Pass SOW', template_id__c = ct6.Id);
        btList.add(b6);
        
        APXTConga4__Conga_Template__c ct7 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Summary By Omnicell IVX Workflow');
        insert ct7;
        Conga_Base_Template__c b7 = new Conga_Base_Template__c(Name = 'Summary By Omnicell IVX Workflow', template_id__c = ct7.Id);
        btList.add(b7);
        
        APXTConga4__Conga_Template__c ct8 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Summary By Omnicell IVX Products');
        insert ct8;
        Conga_Base_Template__c b8 = new Conga_Base_Template__c(Name = 'Summary By Omnicell IVX Products', template_id__c = ct8.Id);
        btList.add(b8);
        
        APXTConga4__Conga_Template__c ct9 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'IVX Workflow APSA');
        insert ct9;
        Conga_Base_Template__c b9 = new Conga_Base_Template__c(Name = 'IVX Workflow APSA', template_id__c = ct9.Id);
        btList.add(b9);
        
        APXTConga4__Conga_Template__c ct10 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Pass Budgetary');
        insert ct10;
        Conga_Base_Template__c b10 = new Conga_Base_Template__c(Name = 'Pass Budgetary', template_id__c = ct10.Id);
        btList.add(b10);
        
        APXTConga4__Conga_Template__c ct11 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'APSA - Default');
        insert ct11;
        Conga_Base_Template__c b11 = new Conga_Base_Template__c(Name = 'APSA - Default', template_id__c = ct11.Id);
        btList.add(b11);
        
        APXTConga4__Conga_Template__c ct12 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'IVX as Service SOW');
        insert ct12;
        Conga_Base_Template__c b12 = new Conga_Base_Template__c(Name = 'IVX as Service SOW', template_id__c = ct12.Id);
        btList.add(b12);
        
        APXTConga4__Conga_Template__c ct13 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'IVX as Service SOW Prof');
        insert ct13;
        Conga_Base_Template__c b13 = new Conga_Base_Template__c(Name = 'IVX as Service SOW Prof', template_id__c = ct13.Id);
        btList.add(b13);
        
        APXTConga4__Conga_Template__c ct14 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Summary by IVX Product OmnicellService');
        insert ct14;
        Conga_Base_Template__c b14 = new Conga_Base_Template__c(Name = 'Summary by IVX Product OmnicellService', template_id__c = ct14.Id);
        btList.add(b14);
        
        APXTConga4__Conga_Template__c ct15 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'POCS Supplement without Signature');
        insert ct15;
        Conga_Base_Template__c b15 = new Conga_Base_Template__c(Name = 'POCS Supplement without Signature', template_id__c = ct15.Id);
        btList.add(b15);
        
        APXTConga4__Conga_Template__c ct16 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Point of Care Service Budgetary Quote');
        insert ct16;
        Conga_Base_Template__c b16 = new Conga_Base_Template__c(Name = 'Point of Care Service Budgetary Quote', template_id__c = ct16.Id);
        btList.add(b16);
        
        APXTConga4__Conga_Template__c ct17 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Point of Care Services Supplement');
        insert ct17;
        Conga_Base_Template__c b17 = new Conga_Base_Template__c(Name = 'Point of Care Services Supplement', template_id__c = ct17.id);
        btList.add(b17);
        
        APXTConga4__Conga_Template__c ct18 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Omnicell XR2 as Service SOW Prof');
        insert ct18;
        Conga_Base_Template__c b18 = new Conga_Base_Template__c(Name = 'Omnicell XR2 as Service SOW Prof', template_id__c = ct17.id);
        btList.add(b18);
        //insert btList;
        
        APXTConga4__Conga_Template__c ct19 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'CPDS SOW for CMA no prof');
        insert ct19;
        Conga_Base_Template__c b19 = new Conga_Base_Template__c(Name = 'CPDS SOW for CMA no prof', template_id__c = ct19.id);
        btList.add(b19);
        
        APXTConga4__Conga_Template__c ct20 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'CPDS SOW Services Only for CMA no prof');
        insert ct20;
        Conga_Base_Template__c b20 = new Conga_Base_Template__c(Name = 'CPDS SOW Services Only for CMA no prof', template_id__c = ct20.id);
        btList.add(b20);
        
        APXTConga4__Conga_Template__c ct21 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'IVCS SOW for CMA no prof');
        insert ct21;
        Conga_Base_Template__c b21 = new Conga_Base_Template__c(Name = 'IVCS SOW for CMA no prof', template_id__c = ct21.id);
        btList.add(b21);
        
        APXTConga4__Conga_Template__c ct22 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'CPDS SOW for CMA prof');
        insert ct22;
        Conga_Base_Template__c b22 = new Conga_Base_Template__c(Name = 'CPDS SOW for CMA prof', template_id__c = ct22.id);
        btList.add(b22);
        
        APXTConga4__Conga_Template__c ct23 = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'IVCS SOW for CMA prof');
        insert ct23;
        Conga_Base_Template__c b23 = new Conga_Base_Template__c(Name = 'IVCS SOW for CMA prof', template_id__c = ct23.id);
        btList.add(b23);
        insert btList;
    }
    public static Quote_Line__c createQTLine(Product2 prod,Quote q, String sapGUID, String matType){
        Quote_Line__c ql1 = new Quote_Line__c();
        ql1.RecordTypeId = qlNonConfigRecordTypeId;
        ql1.Quote__c = q.Id;
        ql1.Higher_Level_Item__c = 0;
        ql1.Quantity__c = 1;
        ql1.SAP_Line_Number__c = 0;
        ql1.SAP_Line_Item_GUID__c = sapGUID;
        ql1.Sales_Text__c = 'test';
        ql1.Material_Type__c = matType;
        ql1.Part_of_a_Bundle__c = true;
        ql1.Customer_Price__c = 200;
        ql1.Conga_Product__c = prod.ProductCode;
        ql1.Contract_List_Price__c = 200;
        ql1.Line_Status__c = 'E0006';
        ql1.Product__c = prod.id;
        ql1.Quote__c = q.Id;
        return ql1;
    }
    public static void createQAP(Quote q,String recordTypeId){
        Quote_Approval__c qta = new Quote_Approval__c();
        qta.RecordTypeId = recordTypeId;
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
        qta.Quote__c = q.id;
        insert qta;
        
    }
    public static Map<String,Product2> createZQRSProd(){
        Map<String,Product2> prodMap = new Map<String,Product2>();
        Product2 cpds = new Product2(Name = 'CPDS',Family = 'test1',External_ID__c = '1234111890121',ProductCode = 'CPDS',Portfolio_Segment__c ='Central Pharmacy Dispensing Service');
        insert cpds;
        prodMap.put('CPDS',cpds);
        Product2 ivcs = new Product2(Name = 'IVCS',Family = 'test1',External_ID__c = '1234222890122',ProductCode = 'IVCS',Portfolio_Segment__c = 'IV Compounding Service');
        insert ivcs;
        prodMap.put('IVCS',ivcs);
        Product2 pass = new Product2(Name = 'PASS',Family = 'test1',External_ID__c = '1234333890123',ProductCode = 'PASS',Portfolio_Segment__c = 'IV Legacy');
        insert pass;
        prodMap.put('PASS',pass);
        Product2 ivx = new Product2(Name = 'IVX',Family = 'test1',External_ID__c = '1234564440124',ProductCode = 'IVX',Portfolio_Segment__c = 'IVX Workflow');
        insert ivx;
        prodMap.put('IVX',ivx);
        return prodMap;
    }
    public static void createOpportunityHistoryTrackingFields(){
        List<Opportunity_Field_Tracking__c> oppFieldTrackList = new List<Opportunity_Field_Tracking__c>();
        Opportunity_Field_Tracking__c s1 = new Opportunity_Field_Tracking__c(name ='ASSOCIATED_OPPORTUNITY__C');        
        Opportunity_Field_Tracking__c s2 = new Opportunity_Field_Tracking__c(name ='COMPETITOR__C');
        Opportunity_Field_Tracking__c s3 = new Opportunity_Field_Tracking__c(name ='CONTRACT_YEAR__C');
        Opportunity_Field_Tracking__c s4 = new Opportunity_Field_Tracking__c(name ='ACCOUNTID');
        Opportunity_Field_Tracking__c s5 = new Opportunity_Field_Tracking__c(name ='Walkthrough_Guide_Complete_Date__c');
        Opportunity_Field_Tracking__c s6 = new Opportunity_Field_Tracking__c(name ='PROFESSIONAL_SERVICES_INTAKE_STATUS__C');
        Opportunity_Field_Tracking__c s7= new Opportunity_Field_Tracking__c(name ='STATUS_REASON__C');
        Opportunity_Field_Tracking__c s8= new Opportunity_Field_Tracking__c(name ='PAW_PROJECT_STATUS__C');
        Opportunity_Field_Tracking__c s9= new Opportunity_Field_Tracking__c(name ='DATE_IN_PHASE__C');
        Opportunity_Field_Tracking__c s10= new Opportunity_Field_Tracking__c(name ='PAW_PHASE__C');
        Opportunity_Field_Tracking__c s11= new Opportunity_Field_Tracking__c(name ='FUNDING_APPROVED_FOR_RELEASE__C');
        Opportunity_Field_Tracking__c s12= new Opportunity_Field_Tracking__c(name ='BUDGET_APPROVED__C');
        Opportunity_Field_Tracking__c s13= new Opportunity_Field_Tracking__c(name ='WALKTHROUGH_GUIDES_COMPLETE__C');
        Opportunity_Field_Tracking__c s14= new Opportunity_Field_Tracking__c(name ='FINAL_APPROVAL_PROCESS__C');
        Opportunity_Field_Tracking__c s15= new Opportunity_Field_Tracking__c(name ='KNOWN_PROCUREMENT_PROCESS__C');
        Opportunity_Field_Tracking__c s16= new Opportunity_Field_Tracking__c(name ='KEY_STAKEHOLDER_ALIGNMENT__C');
        Opportunity_Field_Tracking__c s17= new Opportunity_Field_Tracking__c(name ='FINAL_APPROVAL_ACQUIRED__C');
        Opportunity_Field_Tracking__c s18= new Opportunity_Field_Tracking__c(name ='CONFIGURATIONS_CONFIRMED__C');
        Opportunity_Field_Tracking__c s19= new Opportunity_Field_Tracking__c(name ='RISK_TO_CURRENT_QUARTER__C');
        Opportunity_Field_Tracking__c s20= new Opportunity_Field_Tracking__c(name ='SALES_PROCESS_KICKOFF_MEETING__C');
        Opportunity_Field_Tracking__c s21= new Opportunity_Field_Tracking__c(name ='STEP_10_IT_ENGAGEMENT__C');
        Opportunity_Field_Tracking__c s22= new Opportunity_Field_Tracking__c(name ='STEP_11_IMPLEMENTATION_REVIEW__C');
        Opportunity_Field_Tracking__c s23= new Opportunity_Field_Tracking__c(name ='EBC_SITE_VISIT_AND_OR_REF_CALL__C');
        Opportunity_Field_Tracking__c s24= new Opportunity_Field_Tracking__c(name ='STEP_2_WORKFLOW_BUSINESS_ANALYSIS__C');
        Opportunity_Field_Tracking__c s25= new Opportunity_Field_Tracking__c(name ='GAP_ANALYSIS_AND_TECH_COMPARISONS__C');
        Opportunity_Field_Tracking__c s26= new Opportunity_Field_Tracking__c(name ='DATA_COLLECTION_AND_VALIDATION__C');
        Opportunity_Field_Tracking__c s27= new Opportunity_Field_Tracking__c(name ='STEP_5_FINANCE_REVIEW__C');
        Opportunity_Field_Tracking__c s28= new Opportunity_Field_Tracking__c(name ='STEP_6_ROI_OR_PROFORMA_REVIEW__C');
        Opportunity_Field_Tracking__c s29= new Opportunity_Field_Tracking__c(name ='STEP_7_VALIDATE_PROCUREMENT_PROCESS__C');
        Opportunity_Field_Tracking__c s30= new Opportunity_Field_Tracking__c(name ='BLUEPRINTING_DOCUMENTS_ON_QAP__C');
        Opportunity_Field_Tracking__c s31= new Opportunity_Field_Tracking__c(name ='STEP_9_CUSTOMER_SUCCESS_ENGAGEMENT__C');
        Opportunity_Field_Tracking__c s32 = new Opportunity_Field_Tracking__c (Name = 'AMOUNT');
        Opportunity_Field_Tracking__c s33 = new Opportunity_Field_Tracking__c (Name = 'EXPECTED_BOOKINGS__C');
        Opportunity_Field_Tracking__c s34 = new Opportunity_Field_Tracking__c (Name = 'NAME');
        Opportunity_Field_Tracking__c s35 = new Opportunity_Field_Tracking__c (Name = 'RECORDTYPEID');
        Opportunity_Field_Tracking__c s36 = new Opportunity_Field_Tracking__c (Name = 'CloseDate');
        Opportunity_Field_Tracking__c s37 = new Opportunity_Field_Tracking__c (Name = 'EXPECTEDINSTALLDATE__C');
        Opportunity_Field_Tracking__c s38 = new Opportunity_Field_Tracking__c (Name = 'OWNERID');
        Opportunity_Field_Tracking__c s39 = new Opportunity_Field_Tracking__c (Name = 'OPPORTUNITY_PUSH_REASON__C');
        Opportunity_Field_Tracking__c s40 = new Opportunity_Field_Tracking__c (Name = 'Other_Push_Reason__c');
        Opportunity_Field_Tracking__c s41 = new Opportunity_Field_Tracking__c (Name = 'OPPORTUNITY_PULL_REASON__C');
        Opportunity_Field_Tracking__c s42 = new Opportunity_Field_Tracking__c (Name = 'Other_Pull_Reason__c');
        oppFieldTrackList.add(s1);
        oppFieldTrackList.add(s2);
        oppFieldTrackList.add(s3);
        oppFieldTrackList.add(s4);
        oppFieldTrackList.add(s5);
        oppFieldTrackList.add(s6);
        oppFieldTrackList.add(s7);
        oppFieldTrackList.add(s8);
        oppFieldTrackList.add(s9);
        oppFieldTrackList.add(s10);
        oppFieldTrackList.add(s11);
        oppFieldTrackList.add(s12);
        oppFieldTrackList.add(s13);
        oppFieldTrackList.add(s14);
        oppFieldTrackList.add(s15);
        oppFieldTrackList.add(s16);
        oppFieldTrackList.add(s17);
        oppFieldTrackList.add(s18);
        oppFieldTrackList.add(s19);
        oppFieldTrackList.add(s20);
        oppFieldTrackList.add(s21);
        oppFieldTrackList.add(s22);
        oppFieldTrackList.add(s23);
        oppFieldTrackList.add(s24);
        oppFieldTrackList.add(s25);
        oppFieldTrackList.add(s26);
        oppFieldTrackList.add(s27);
        oppFieldTrackList.add(s28);
        oppFieldTrackList.add(s29);
        oppFieldTrackList.add(s30);
        oppFieldTrackList.add(s31);
        oppFieldTrackList.add(s32);
        oppFieldTrackList.add(s33);
        oppFieldTrackList.add(s34);
        oppFieldTrackList.add(s35);
        oppFieldTrackList.add(s36);
        oppFieldTrackList.add(s37);
        oppFieldTrackList.add(s38);
        oppFieldTrackList.add(s39);
        oppFieldTrackList.add(s40);
        oppFieldTrackList.add(s41);
        oppFieldTrackList.add(s42);

        insert oppFieldTrackList;
    }
    public static void createSalesOrgCRM_CS(){
        List<ECC_Sales_Org_to_CRM__c> salesOrgCRMList = new List<ECC_Sales_Org_to_CRM__c>();
        ECC_Sales_Org_to_CRM__c  setting01 = new ECC_Sales_Org_to_CRM__c (Name = 'AU SalesOrg Omnicell',CRM_Code__c = 'O 50008662');
        salesOrgCRMList.add(setting01);
        ECC_Sales_Org_to_CRM__c  setting02 = new ECC_Sales_Org_to_CRM__c (Name = 'MACH4 - GmbH',CRM_Code__c = 'O 50008654');
        salesOrgCRMList.add(setting02);
        ECC_Sales_Org_to_CRM__c  setting03 = new ECC_Sales_Org_to_CRM__c (Name = 'Omnicell - St.Petes',CRM_Code__c = 'O 50008663');
        salesOrgCRMList.add(setting03);
        ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c (Name = 'Omnicell Inc.',CRM_Code__c = 'O 50000029');
        salesOrgCRMList.add(setting4);
        ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c (Name = 'Omnicell Ltd',CRM_Code__c = 'O 50008655');
        salesOrgCRMList.add(setting5);
        ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c (Name = 'Omnicell SAS',CRM_Code__c = 'O 50011128');
        salesOrgCRMList.add(setting6);
        
        insert salesOrgCRMList;
    }
}