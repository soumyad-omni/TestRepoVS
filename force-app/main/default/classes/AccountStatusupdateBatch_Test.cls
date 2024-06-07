@isTest
private class AccountStatusupdateBatch_Test {
		
    	public testmethod static void checkboxAutomation1(){
        	Account acc = TestDataFactory.createTestAccountQuotePrint();
            acc.Account_Status__c = 'Prospect';
            acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
            AccountTriggerHandler.TriggerDisabled = true;
            update acc;
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('NAA_Opportunity').getRecordTypeId();
            opp.name = 'Test Opp';
            opp.stageName = '1 Solution Design';
            opp.CloseDate = Date.parse('7/10/2023');
            opp.ExpectedInstallDate__c = System.today()+60;
            opp.AccountId = acc.id;
            opp.OppStatus__c = 'Open';
            opp.Services_Enablement_Owner__c = 'Tara Bakker';
            insert opp;
            opp.stageName = '6 Closed Won';
            opp.OppStatus__c = Label.Fully_Booked;
            update opp;
            
            Test.startTest();
            AccountStatusupdateBatch c = new AccountStatusupdateBatch();
            Database.executeBatch(c);
            Test.stopTest();
            
            Account act=[select id,name,Account_Status__c from account where id=:acc.id];
            //System.assertEquals(act.Account_Status__c,'Prospect');
        }
        public testmethod static void checkboxAutomation2(){
           // Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
         insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
        Account acc = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                          BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acc.texcellency__DefHC_HospitalID__c = 1;
        acc.Territory_Name__c = 'TestTerr';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        //acc.PIS_HIS__c  = 'test';
        insert acc; 
        System.debug('acc : '+acc);
        SAP_Sales_Org__c ssoc = new SAP_Sales_Org__c(Account__c=acc.id,Sales_org__c = 'AU01',Sales_Office__c ='AU03',Incoterms_1__c='DAP',District__c='US0007',Distribution_Channel__c='01',Customer_Pricing_Procedure__c='1',SAP_Division__c='00',Incoterms_2__c='Test',tax_classification__c='1',Terms_of_Payment__c='MD10',Shipping_Conditions__c='01');
        insert ssoc;
        acc.Has_Historic_Bookings__c =true; 
        acc.Account_Status__c = 'Active';
        Update acc;
        acc.Account_Status__c = 'Prospect';
        List<Account> listAccUpdate = new List<Account>();
        listAccUpdate.add(acc);
        Update acc;
        update listAccUpdate;
            Test.startTest();
            AccountStatusupdateBatch c = new AccountStatusupdateBatch();
            Database.executeBatch(c);
            Test.stopTest();
            
            Account act=[select id,name,Account_Status__c from account where id=:acc.id];
            System.assertEquals(act.Account_Status__c,'Active');
        }
    	public static testMethod void testschedule() {
			Test.StartTest();
            ScheduleAccountStatusupdateBatch sh1 = new ScheduleAccountStatusupdateBatch();
			String sch = '0 5 * * * ?'; 
            system.schedule('Account Status Update Job', sch, sh1); 
            Test.stopTest(); 
        } 
}