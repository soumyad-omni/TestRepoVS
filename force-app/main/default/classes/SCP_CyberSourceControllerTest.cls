/*** 
Test Class For - SCP_CyberSourceController
Developer - Subramanyam Gopinath
***/
@isTest
public class SCP_CyberSourceControllerTest{
    
    @testSetup 
    public static void dataSetup(){
        
        Account acc;
        Contact con;
        User thisUser = [select Id from User where Profile.Name =: 'System Administrator' and IsActive = True and UserRoleId != null LIMIT 1];
        
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;


        System.runAs(thisUser){
            acc = new Account(Name = 'Test Account'+math.random(), Account_Name2__c = 'Test Acc Name',Facility_Type__c= 'Hospice',Validation_Status__c = 'Validated',IsDeleted__c = false,BillingStreet='test123',Account_Role__c='ZCSN');
            insert acc;
            con = new Contact(LastName = 'Test Contact',AccountId = acc.id);
            insert con;
            
            ccrz__E_Cart__c ec = SCP_TestDataFactory.createCarts(1,acc, con, contAdd)[0];
            insert ec;
            ec.ccrz__EncryptedId__c = ec.Id;
            ec.ccrz__EffectiveAccountID__c=acc.Id;
            update ec;
            
            String ProfileName = System.Label.OCB_RegisterUserProfile;
            
            //UserRole ur = [Select id From UserRole where Name =:'Community Health Systems Customer User' limit 1];
             Profile profileId = [select Id,name from Profile where Name =:ProfileName limit 1];
                  
            
            User CommUser = new User();
            CommUser.FirstName = 'TestUserfirstName';
            CommUser.LastName = 'TestUserlastName';
            CommUser.UserName = CommUser.FirstName + '.' + CommUser.LastName + '@unitTest.com';        
            CommUser.Email = 'testusermail@omnicell.com';
            CommUser.Alias = CommUser.FirstName.substring(0, 1) + CommUser.LastName.left(7);
            CommUser.CommunityNickname = CommUser.FirstName + ' ' + CommUser.LastName;
            CommUser.TimeZoneSidKey = 'America/New_York';
            CommUser.LocaleSidKey = 'en_US';
            CommUser.EmailEncodingKey = 'UTF-8';
            CommUser.LanguageLocaleKey = 'en_US';
            CommUser.IsActive= True;
            CommUser.ContactId=con.id;
            CommUser.ProfileId = profileId.id;
            insert CommUser;
        }
        SAP_Sales_Org__c salOrg = new SAP_Sales_Org__c();
        salOrg.Account__c = acc.id;
        salOrg.CurrencyIsoCode = 'USD';
        salOrg.Sales_Office__c = 'OMDD';
        salOrg.Distribution_Channel__c = '01';
        salOrg.Incoterms_1__c = 'DDP';
        salOrg.Incoterms_2__c = 'Newyork'; 
        salOrg.Tax_Classification__c = '1';
        insert salOrg;
        System.assert(salOrg.id != null);
        Relationship__c rel = new Relationship__c();
        rel.Primary_Account__c = acc.id;
        rel.Relationship__c ='RE';
        rel.Secondary_Account__c = acc.id;
        rel.Primary_Account_Sales_Org__c = salOrg.id;
        insert rel;
        
    }
    @isTest
    public static void testBillingAddressContactList(){
    
        Account acct = [SELECT Id,Name FROM Account WHERE Name like '%Test Account%' LIMIT 1];
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName like '%Test Contact%' LIMIT 1];
        SAP_Sales_Org__c salOrg = [select id from SAP_Sales_Org__c where Account__c =: acct.id];
        Relationship__c rel= [SELECT Id,Relationship__c ,Secondary_Account__c,Primary_Account__c FROM Relationship__c LIMIT 1];
        ccrz__E_Cart__c  cartObj = [Select Id from ccrz__E_Cart__c Limit 1];
        ccrz__E_ContactAddr__c  contAdd = [Select Name from ccrz__E_ContactAddr__c Limit 1];
            Test.startTest();
            PageReference myVfPage = Page.OmniCellBillingAddress;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',cartObj.Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acct.Id);
            SCP_CyberSourceController CybSr = new SCP_CyberSourceController();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
            SCP_CyberSourceController.getBillingAddressContactList(ctx,'test');
            SCP_CyberSourceController.getBillingAddressList(ctx);
            ccrz.cc_RemoteActionResult Remt = new ccrz.cc_RemoteActionResult();
            Remt = ccrz.cc_CallContext.init(ctx);
            Test.stopTest();
    }
    
    @isTest
    public static void testBillingAddressContactList2(){
    
        Account acct = [SELECT Id,Name FROM Account WHERE Name like '%Test Account%' LIMIT 1];
        Contact cont = [SELECT Id,LastName FROM Contact WHERE LastName like '%Test Contact%' LIMIT 1];
        SAP_Sales_Org__c salOrg = [select id from SAP_Sales_Org__c where Account__c =: acct.id];
        Relationship__c rel= [SELECT Id,Relationship__c ,Secondary_Account__c,Primary_Account__c FROM Relationship__c LIMIT 1];
        ccrz__E_Cart__c  cartObj = [Select Id from ccrz__E_Cart__c Limit 1];
        ccrz__E_ContactAddr__c  contAdd = [Select Name from ccrz__E_ContactAddr__c Limit 1];
            Test.startTest();
            PageReference myVfPage = Page.OmniCellBillingAddress;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',contAdd.Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acct.Id);
            SCP_CyberSourceController CybSr = new SCP_CyberSourceController();
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();
        	ctx.currentCartId = cartObj.id;
            SCP_CyberSourceController.getBillingAddressContactList(ctx,'test');
            SCP_CyberSourceController.getBillingAddressList(ctx);
        	SCP_CyberSourceController.doUploadAttachment(ctx,'test body','name',null);
        	SCP_CyberSourceController.dAttachment(ctx);
            ccrz.cc_RemoteActionResult Remt = new ccrz.cc_RemoteActionResult();
            Remt = ccrz.cc_CallContext.init(ctx);
            Test.stopTest();
    }
}