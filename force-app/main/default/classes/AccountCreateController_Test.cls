@isTest
public class AccountCreateController_Test {
    
    @testSetup
    static void dataSetup(){
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_AccountSFDCTOSAP';
        setting.SCP_Method_Type__c = 'POST';
        setting.SCP_Timeout__c = 120000;
        setting.SCP_End_Point__c = 'http://sit-aloha-accounts.us-w1.cloudhub.io/AccountSFDCToSAP';
        insert setting;
        SCP_Integration_Details__c  setting2 = new SCP_Integration_Details__c ();
        setting2.Name = 'SCP_AccountRelationshipSFDCtoSAP';
        setting2.SCP_Method_Type__c = 'POST';
        setting2.SCP_Timeout__c = 120000;
        setting2.SCP_End_Point__c = 'http://sit-aloha-accounts.us-w1.cloudhub.io/AccountRelationshipsfromSFDC';
        insert setting2;
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        
        CastIronIntegration__c  setting3 = new CastIronIntegration__c ();
        setting3.Name = 'CastIronIntegration';
        setting3.Accountendpoint__c= 'https://appconndatadev.omnicell.com/AccountSFtoSAPDEV';
        setting3.AccountRelationship__c= 'https://appconndatadev.omnicell.com/AccountRelSFDCtoSAPDEV';
        insert setting3;
        
    }
    
    @isTest private static void checkAccountErrorLogTest() {
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_AccountSFDCTOSAP';
        setting.SCP_End_Point__c = 'https://castirondev.omnicell.com';
        insert setting;
        
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        AccountTriggerHandler.TriggerDisabled = True;
        Account a = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a.Annual_Bill_Date__c = System.today()+100;
        a.Service_Escalator__c = 10;
        a.PO_BOX__c = '90202';
        a.Sales_Notes__c = 'Test Sales Notes';
        a.Shipping_Notes__c = 'Test Sales Notes';
            a.Customer_AR_Notes__c= 'Test Sales Notes';
            a.Customer_SO_Notes__c= 'Test Sales Notes';
        insert a; 
        String testHTML = AccountCreateController.removeHtmTag('textToremove');
        String oldValues = '{"id": "'+a.Id+'","SAP_Account_ID__c": "3100000275"}';
        
        Test.setMock(HttpCalloutMock.class, new RestMockSuccess());
        
        SAP_Sales_Org__c sp = new SAP_Sales_Org__c(Account__c = a.id);
        sp.Sales_Office__c='OMNE';
        sp.Incoterms_2__c = 'San Francisco';
        sp.Incoterms_1__c = 'CPT';
        insert sp; 
        
        try{
            AccountCreateController.CreateAccountFromProspect(a.Id, oldValues,sp.id);
            AccountCreateController.checkAccountErrorLog(a.id);
            AccountCreateController.checkSAPNumber(a.id);
        }catch(Exception e){
            System.Debug('Account not created');
        }  
        List<Account> accList = new List<Account>();
        Account a1 = new Account(name='t2'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                 Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                 BillingStreet='200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                 BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a1.Annual_Bill_Date__c = System.today()+100;
        a1.Service_Escalator__c = 10;
        a1.PO_BOX__c = '90202';
        accList.add(a1);
        insert a1; 
        AccountError__c ae = new AccountError__c(Account_Id__c = a1.id);
        insert ae;
        AccountCreateController.checkAccountErrorLog(a1.id);
        AccountCreateController.markErrorsDisplayed(a1.id);
        AccountCreateController.validateAddress(accList); 
        
        
        List<Account> accList1 = new List<Account>();
        Account a2 = new Account(name='t3'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                 Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                 BillingStreet='@# South-Bascom-Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                 BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a2.Annual_Bill_Date__c = System.today()+100;
        a2.Service_Escalator__c = 10;
        a2.PO_BOX__c = '90202';
        accList1.add(a2);
        insert a2; 
        AccountError__c ac = new AccountError__c(Account_Id__c = a2.id);
        insert ac;        
        AccountCreateController.checkAccountErrorLog(a2.id);
        AccountCreateController.markErrorsDisplayed(a2.id);
        AccountCreateController.validateAddress(accList1);
        
        OpportunityTriggerHandler.opportunityChanged = true;
        
        List<Account> accList2 = new List<Account>();
        Account a3 = new Account(name='t4'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                 Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='DE',Facility_Type__c = 'Short-term Acute Care Hospital',
                                 BillingStreet='200 South Bascom Avenue',BillingCountry='Germany', BillingCity='Wiesbaden', BillingState='Hessen',
                                 BillingPostalCode='95128',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a3.Annual_Bill_Date__c = System.today()+100;//,SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000)
        a3.Service_Escalator__c = 10;
        a3.PO_BOX__c = '90202'; 
        accList2.add(a3);
        insert a3; 
        AccountError__c ace = new AccountError__c(Account_Id__c = a3.id);
        insert ace;  
        
        test.startTest();
        AccountCreateController.checkAccountErrorLog(a3.id);
        AccountCreateController.markErrorsDisplayed(a3.id);
        AccountCreateController.validateAddress(accList2);
        
        
        test.stopTest();
        
        
        
        List<Account> accList3 = new List<Account>();
        Account a4 = new Account(name='t4'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                 Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='DE',Facility_Type__c = 'Short-term Acute Care Hospital',
                                 BillingStreet='## test #@',BillingCountry='Germany', BillingCity='Wiesbaden', BillingState='Hessen',
                                 BillingPostalCode='95128',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a4.Annual_Bill_Date__c = System.today()+100;//,SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000)
        a4.Service_Escalator__c = 10;
        a4.PO_BOX__c = '90202';
        accList3.add(a4);
        insert a4; 
        AccountError__c ace1 = new AccountError__c(Account_Id__c = a4.id);
        insert ace1;  
        AccountCreateController.validateAddress(accList3);
        
    }
    
    
     @isTest private static void checkAccountErrorLogTestV1() {
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_AccountSFDCTOSAP';
        setting.SCP_End_Point__c = 'https://castirondev.omnicell.com';
        insert setting;
        
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        AccountTriggerHandler.TriggerDisabled = True;
        Account a = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='##@@#%& 200 South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a.Annual_Bill_Date__c = System.today()+100;
        a.Service_Escalator__c = 10;
        a.PO_BOX__c = '90202';
        insert a; 
        String oldValues = '{"id": "'+a.Id+'","SAP_Account_ID__c": "3100000275"}';
        
       Test.setMock(HttpCalloutMock.class, new RestMockSuccess());
        
        SAP_Sales_Org__c sp = new SAP_Sales_Org__c(Account__c = a.id);
        sp.Sales_Office__c='OMNE';
        sp.Incoterms_2__c = 'San Francisco';
        sp.Incoterms_1__c = 'CPT';
        insert sp; 
        
        try{
           AccountCreateController.CreateAccountFromProspect(a.Id, oldValues,sp.id);
          
        }catch(Exception e){
            System.Debug('Account not created');
        }  
        List<Account> accList = new List<Account>();
        Account a1 = new Account(name='t2'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='South Bascom',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a1.Annual_Bill_Date__c = System.today()+100;
        a1.Service_Escalator__c = 10;
        a1.PO_BOX__c = '90202';
        accList.add(a1);
        insert a1; 
        AccountError__c ae = new AccountError__c(Account_Id__c = a1.id);
        insert ae;
         
            AccountCreateController.CreateAccountFromProspect(a.Id, oldValues,sp.id);
      
        
       
        List<Account> accList3 = new List<Account>();
        Account a4 = new Account(name='t4'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='DE',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='South Bascom Avenue',BillingCountry='Germany', BillingCity='Wiesbaden', BillingState='Hessen',
                                  BillingPostalCode='95128',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a4.Annual_Bill_Date__c = System.today()+100;//,SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000)
        a4.Service_Escalator__c = 10;
        a4.PO_BOX__c = '90202';
        accList3.add(a4);
        insert a4; 
        AccountError__c ace1 = new AccountError__c(Account_Id__c = a4.id);
        insert ace1;  
          AccountCreateController.CreateAccountFromProspect(a4.Id, oldValues,sp.id);
         
       }
    
    
    
     @isTest private static void checkAccountErrorLogTestV2() {
        SCP_Integration_Details__c  setting = new SCP_Integration_Details__c ();
        setting.Name = 'SCP_AccountSFDCTOSAP';
        setting.SCP_End_Point__c = 'https://castirondev.omnicell.com';
        insert setting;
        
        SCP_Integration_Details__c  setting1 = new SCP_Integration_Details__c ();
        setting1.Name = 'SCP_Mulesoft_Authorization';
        setting1.SCP_Method_Type__c = 'POST';
        setting1.SCP_Grant_Type__c='CLIENT_CREDENTIALS';
        setting1.SCP_Timeout__c = 120000;
        setting1.SCP_End_Point__c = 'https://uat-omnicell-oauth2-provider.us-w1.cloudhub.io/token';
        setting1.SCP_Key_Client_Id__c = '4682BEDF71DCD9F78329E612E42F0D2D9CA9338D2E8656F75B99BBFCA9DB8BB1sit';
        setting1.SCP_Password_Client_Secret__c = '3MVG9QBLg8QGkFeopcRhWO6XqjUDWB6W_u3esouZF6.Mmx1ak38MZs9mz3RW1PZVTsit';
        setting1.SCP_Is_Active__c = true;
        insert setting1;
        AccountTriggerHandler.TriggerDisabled = True;
        Account a = new Account(name='t1'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='US',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='South Bascom Avenue',BillingCountry='united states', BillingCity='San Jose', BillingState='California',
                                  BillingPostalCode='95128',SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000),Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a.Annual_Bill_Date__c = System.today()+100;
        a.Service_Escalator__c = 10;
        a.PO_BOX__c = '90202';
        insert a; 
         
         system.debug('isalpha ' + a.billingStreet.split(' ')[0].isalpha());
        String oldValues = '{"id": "'+a.Id+'","SAP_Account_ID__c": "3100000275"}';
        
      Test.setMock(HttpCalloutMock.class, new RestMockSuccess());
        
        SAP_Sales_Org__c sp = new SAP_Sales_Org__c(Account__c = a.id);
        sp.Sales_Office__c='OMNE';
        sp.Incoterms_2__c = 'San Francisco';
        sp.Incoterms_1__c = 'CPT';
        insert sp; 
        
        try{
           AccountCreateController.CreateAccountFromProspect(a.Id, oldValues,sp.id);
          
        }catch(Exception e){
            System.Debug('Account not created');
        }  
       
       }
    
    
    

 private class RestMockSuccess implements HttpCalloutMock { 

        public HTTPResponse respond(HTTPRequest req) {
            
            
        
        Account a4 = new Account(name='t4'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',
                                  Account_Status__c = 'Active',IsDeleted__c = false,BillingCountryCode='DE',Facility_Type__c = 'Short-term Acute Care Hospital',
                                  BillingStreet='Avenues @##',BillingCountry='Germany', BillingCity='Wiesbaden', BillingState='Hessen',
                                  BillingPostalCode='95128',Validation_Status__c = 'Validated',Country_Cluster__c='US&CA',Division_Account__c ='Atlantic',Region__c='Central',Account_Territory__c='East OH');
        a4.Annual_Bill_Date__c = System.today()+100;//,SAP_Account_ID__c='123456'+system.now().millisecond()+math.round(math.random()*10000)
        a4.Service_Escalator__c = 10;
        a4.PO_BOX__c = '90202';
        insert a4;
            
            String oldValues = '{ "E_KUNNR" : "' + a4.Id + '"}';
           
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(oldValues);
            res.setStatusCode(200);
            return res;
        }
    
    
    
    }

	
    
}