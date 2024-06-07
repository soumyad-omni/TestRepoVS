@isTest
public class Account_error_controllerTest {

       public static Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
       public static Id recTypeAccountItn = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'International Customer' LIMIT 1].Id;    
       
        @testsetup
        static void testdatasetup(){
            SCP_TestDataFactory.createContact_Customsetting();
            Account acct = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      BillingCountryCode = 'AZ',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015',SAP_Account_ID__c='0000013903',Validation_Status__c='Validated',Facility_Type__c = 'Correctional Facilities');
            acct.Facility_Type__c = 'Pharmacy';
            acct.BILLINGSTREET = '41 Moss';
            acct.BillingPostalCode = 'DY6 9HP';
            AccountTriggerHandler.TriggerDisabled = true;
            insert acct; 
            UserTriggerHandler.TriggerDisabled = True;
            User u = TestDataFactory.createUserBusinessAdmin(true, 'TestUser', 'BusinessAdmin');
            UserTriggerHandler.TriggerDisabled = True;
            User u1 = TestDataFactory.createSalesUser(true, 'TestSales', 'RepUser');
            SCP_TestDataFactory.createCastIron();
        
            CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.Accountendpoint__c = 'https://castirondev.omnicell.com';
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
        @isTest
        static void UpdateAccount_Test () {
            List<Account> accList = new List<Account>();
            AccountTriggerHandler.TriggerDisabled = true;
            QuoteTriggerHandler.TriggerDisabled = true;
            OpportunityTriggerHandler.TriggerDisabled = true;
            QuoteTriggerHandler.quoteUpdated = true;
             //OpportunityTriggerHandler.opportunityChanged = true;
             AccountTriggerHandler_Top200Customer.TriggerDisabled = true;
            // NOTES: test 200 records
          
            // create custom setting class to include values needed in before insert trigger
            Default_Currency_by_Country_Code__c c = new Default_Currency_by_Country_Code__c ();
            c.Name = 'AZ';
            c.Currency_Code__c = 'USD';
            Insert c; 
           
            //use to trigger feed      
            Account acct2 = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                            Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                            Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                            BillingCountryCode = 'US',RecordtypeId = recTypeAccount,
                                            Account_Status__c = 'Active',IsDeleted__c = false,  
                                            Transport_Zone__c='US00000001',Partner_Type__c= '0015'); 
               // need sap account id to satisfy sales org workflow
            acct2.SAP_Account_ID__c = '500300';
            acct2.Validation_Status__c = 'Validated';
            acct2.Facility_Type__c = 'Pharmacy';
            acct2.BILLINGSTREET = '41 Moss';
            acct2.BillingPostalCode = '77777';
            accList.add(acct2);
            //insert acct2;
            Account acct = new Account(name='My New Account',Account_role__c='ZGPO',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountryCode = 'US',RecordtypeId = recTypeAccount,
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Validation_Status__c = 'Validated',  
                                      Transport_Zone__c='US00000001',Partner_Type__c= '0015');           
             acct.Facility_Type__c = 'Pharmacy';
             acct.BILLINGSTREET = '41 Moss';
             acct.BillingPostalCode = '77777';
            // get a list of accounts to use for testing
            List<Account> accountList = createAccounts(4);
            
            // create system admin to run test
            User u1 = Testdatafactory.createUser(false,'Sam', 'Test1');
            User salesUser = Testdatafactory.createSalesUser(false,'Mary', 'Test2');
            accountList[0].Validation_Status__c = 'Awaiting Validation';
            update accountList[0];
            
            test.StartTest();
                /*Account_Field_Tracking__c  setting1 = new Account_Field_Tracking__c ();
                setting1.Name = 'ACCOUNT_ROLE__C';
                insert setting1;
                Account_Field_Tracking__c  setting2 = new Account_Field_Tracking__c ();
                setting2.Name = 'FACILITY_TYPE__C';
                insert setting2;
                Account_Field_Tracking__c  setting3 = new Account_Field_Tracking__c ();
                setting3.Name = 'BILLINGCITY';
                insert setting3;*/
               AccountCreateController.isTriggerExecuting = false;
               AccountCreateController.isFirstRun = true;    
                
               // make a change to initiate update
               //accountList[0].Applix_Account__c = 20040001;

               //System.assertEquals(20040001,accountList[0].Applix_Account__c);
               System.assertEquals('Awaiting Validation',accountList[0].Validation_Status__c);
               

               System.debug('Running test for no sales org');
               AccountCreateController.isTriggerExecuting = false;
               AccountCreateController.isFirstRun = true;
               try{  
                   accountList[1].Validation_Status__c = 'Validated';
                   update accountList[1];
                   system.debug('Sales Org Found');
               }
               catch(Exception e){
                    system.debug('Error ' + e.getMessage());
                    System.assert(e.getMessage().contains('Account Record Must Include Sales Organization Data'));
               }
               

               System.debug('Running test for no partner type');
               AccountCreateController.isTriggerExecuting = false;
               AccountCreateController.isFirstRun = true;
               try{
                   accountList[2].Validation_Status__c = 'Validated';
                   accountList[2].Partner_Type__c = '';        
                   SAP_Sales_Org__c sso2 = Testdatafactory.createSalesOrg(accountList[2].Id);    
                   update accountList[2]; 
                   system.debug('Partner Type Found');
               }
               catch(Exception e){
                    system.debug('Error ' + e.getMessage());
                   // System.assert(e.getMessage().contains('Account Record Must Include Partner Type'));
               }
                

               System.debug('Running test for no transportation zone');
               AccountCreateController.isTriggerExecuting = false;
               AccountCreateController.isFirstRun = true;
               try{
                   accountList[2].Validation_Status__c = 'Validated';
                   accountList[2].Partner_Type__c= '0015';
                   accountList[2].Transport_Zone__c = ''; 
                   update accountList[2];
               }
               catch(Exception e){
                    system.debug('Error ' + e.getMessage());
                    System.assert(e.getMessage().contains('Account Record Must Include Transportation Zone'));
               }
                

               System.debug('Running test for invalid record type');
               AccountCreateController.isTriggerExecuting = false;
               AccountCreateController.isFirstRun = true;
               try{
                   accountList[2].Validation_Status__c = 'Validated';
                   accountList[2].Partner_Type__c= '0015';
                   accountList[2].Transport_Zone__c='US00000001'; 
                   accountList[2].RecordTypeId = recTypeAccount;
                   accountList[2].Facility_Type__c='Children\'s Hospital';
                   update accountList[2];    
                   system.debug('Valid Record Type');
               }
               catch(Exception e){
                    system.debug('Error ' + e.getMessage());
                   // System.assert(e.getMessage().contains('Account Record Type Must be \'NAA Customer\' or \'International\'.'));
               }
             

               System.debug('Running test for validation');
               AccountCreateController.isTriggerExecuting = false;
               AccountCreateController.isFirstRun = true;
               accountList[3].Validation_Status__c = 'Validated';
               accountList[3].Partner_Type__c= '0015';
               accountList[3].Transport_Zone__c='US00000001'; 
               accountList[3].RecordTypeId = recTypeAccount;
               update accountList[3];
               System.assertEquals('Validated',accountList[3].Validation_Status__c);

               // test after insert
               //acct.ParentId = accountList[3].Id;
               acct.Shipping_Instructions__c = 'Test01';
               accList.add(acct);
            
               insert accList;
               //System.assertEquals(acct.ParentId,accountList[3].Id);
               //System.assertNotEquals(null,acct.Id);
                
               // test after update
               acct.Shipping_Instructions__c = 'new01';
               update acct;
               System.assertEquals('new01',acct.Shipping_Instructions__c);   
  
               SAP_Sales_Org__c sso5 = Testdatafactory.createSalesOrg(acct2.Id); 
               
               System.debug('Running test for User Not Permitted');
               AccountCreateController.isTriggerExecuting = false;
               AccountCreateController.isFirstRun = true;
               try{
                    acct2.Validation_Status__c = 'Validated';
                     acct2.Facility_Type__c='Children\'s Hospital';
                    acct2.Account_role__c='ZCSN';
                    update acct2;
               }
               catch(Exception e){
                    system.debug('Error ' + e.getMessage());
                    //System.assert(e.getMessage().contains('You do not have permission to change a validated account'));
               }
   				Account_error_controller.getError(acct2.id);
            test.StopTest();
       } 
        static List<Account> createAccounts(Integer numberOfAccounts){
            List<Account> accList=new List<Account>();   
            for(Integer i=0;i<numberOfAccounts;i++){
                Account acc = Testdatafactory.createUSTestAccount();
                accList.add(acc);
            }
            return accList;
       }
}