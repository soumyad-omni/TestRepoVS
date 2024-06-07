@isTest
public class UpdateContactInfoInUserTest {
    
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
        AccountCreateController.isFirstRun= false;
        AccountTriggerHandler.TriggerDisabled = true;
        Contact cont = TestDataFactory.createContactWithAccount_Integration();
    }
    
    @isTest
    public static void testmethod1(){        
        List<Contact> conList = [Select Id,Email,FirstName,MiddleName,LastName From Contact Limit 1];
        Profile pf= [Select Id from profile where Name='Omnicell B2B Storefront Profile' Limit 1]; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        Map<Id,Contact> userConMap = new Map<Id,Contact>();
        
        if(conList.size()>0){
            User uu=new User(firstname = 'ABC', 
                             lastName = 'XYZ', 
                             email = uniqueName + '@test' + orgId + '.org', 
                             Username = uniqueName + '@test' + orgId + '.org', 
                             EmailEncodingKey = 'ISO-8859-1', 
                             Alias = uniqueName.substring(18, 23), 
                             TimeZoneSidKey = 'America/Los_Angeles', 
                             LocaleSidKey = 'en_US', 
                             LanguageLocaleKey = 'en_US', 
                             ProfileId = pf.Id,
                             contactId = conList[0].Id
                            ); 
            insert uu;  
            userConMap.put(uu.Id,conList[0]);
            Test.startTest();
            	system.enqueueJob(new UpdateContactInfoInUser(userConMap));
            Test.stopTest();
        }        
    }    
}