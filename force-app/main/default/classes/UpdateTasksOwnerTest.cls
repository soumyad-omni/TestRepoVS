@isTest
public class UpdateTasksOwnerTest {
    public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
    @isTest
    public static void test1(){
        // create custom setting class to include values needed in before insert trigger
         /*   Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
            c.Name = 'AZ';
            c.Currency_Code__c = 'USD';
            Insert c;   */
         Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        Account_DataLoad__c aDataload= New Account_DataLoad__c(Name='Dataload');
         insert aDataload;
        Account_SendEmail_Off__c accSendOff = New Account_SendEmail_Off__c(name = 'Account SendEmail Off');
        insert accSendOff; 
           
            //use to trigger feed      
            Account acct = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Prospect',IsDeleted__c = false,BillingCountryCode='US',Annual_Bill_Date__c=System.today(),
                         BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',Facility_Type__c='Critical Access',
                          BillingPostalCode='95128', SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH',Transportation_Zone_Country__c='US',Transport_Zone__c='US00000002');
        acct.texcellency__DefHC_HospitalID__c = 1;
        acct.Territory_Name__c = 'TestTerr';
        insert acct;
        
        ContactTriggerHandler.TriggerDisabled = True;
        Contact con = new Contact();
        
        con.Salesforce_Contact_ID__c ='5678';
        con.SAP_Contact_GUID__c = '3467';
        con.AccountId = acct.Id;
      //  con.MailingState = 'Alabama';
        con.LastName = 'Test Con';
        con.Score_Threshold_Met__c = true;
        con.Omnicell_Job_Code__c = 'Z7';
        con.Recent_Conversion_Campaign__c = 'test Campaign';
        insert con;
        
        TaskTriggerHandler.TriggerDisabled = True;
        Task tsk = new Task();
        tsk.Facility_Type__c = 'Short-term Acute Care Hospital';
        tsk.WhoId = con.Id;
        tsk.Activity_Type__c = 'Account';
        tsk.Activity_SubType__c = 'Follow-up on Marketing Campaign Contact/Lead';
        tsk.Status = 'In Progress';
        insert tsk;
        
        
        Job_title_Classification__c j = new Job_title_Classification__c(Classification__c = 'A-Strategic Buyer',
                                                                        name = 'A1');
        insert j;
        Lead l = new Lead(LastName = 'Test Lead',
                          Company = 'Test Company',
                          Omnicell_Job_Title__c = 'A1', 
                          Marketing_Portfolio_Segment__c = 'Omnicell 340B');
        insert l;
        
        Job_title_Classification__c j1 = new Job_title_Classification__c(Classification__c = 'A-Strategic Buyer',
                                                                        name = 'A8');
        insert j1;
        Lead l1 = new Lead(LastName = 'Test Lead 111',
                          Company = 'Test Company 11',
                          Omnicell_Job_Title__c = 'A8', 
                          Recent_Conversion_Campaign__c = 'EnlivenHealth');
        insert l1;
        
        Task tsk1 = new Task();
        tsk1.Facility_Type__c = 'Short-term Acute Care Hospital';
        tsk1.WhoId = l1.Id;
        tsk1.Activity_Type__c = 'Account';
        tsk1.Activity_SubType__c = 'Follow-up on Marketing Campaign Contact/Lead';
        tsk1.Status = 'In Progress';
        insert tsk1;
        
        UpdateTasksOwner.updateTask();
        UpdateTasksOwner.updateLeadOwner();
    }

}