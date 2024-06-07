@isTest
Public Class SCP_CyberSourceCaptureAPI_Test{

 @TestSetup
 public static void setupTestData(){
     
     Account acnt = new Account();
     acnt.Name='Test Omnicell CyberSource';
     acnt.BillingStreet='Test building Omnicell';
     acnt.BillingCity='columbus';
     acnt.BillingStateCode='IN';
     acnt.BillingCountryCode='US';
     acnt.BillingPostalCode='47201';
     acnt.Facility_Type__c='Ambulatory Surgical Center';
     accounttriggerhandler.triggerdisabled = true;
     insert acnt;
     
     
     Contact con= new Contact();
     con.FirstName='Fname';
     con.LastName='Lname';
     con.Email='Testemailcybersource@gmail.com';
     con.AccountId=acnt.id;
     con.SAP_Contact_ID__c='54367892';
     con.Phone='123456789';
     insert con;
     
     ccrz__E_Cart__c cart= new ccrz__E_Cart__c();
     cart.ccrz__Account__c=acnt.id;
     cart.ccrz__ActiveCart__c=True;
     cart.ccrz__Contact__c=con.id;
     cart.ccrz__Name__c='123456642';
     
     insert cart;
     
     
     ccrz__E_Order__c order= new ccrz__E_Order__c();
     
     order.ccrz__Account__c = acnt.id;
     order.ccrz__Contact__c=con.id;
     order.ccrz__CurrencyISOCode__c='USD';
     order.ccrz__EffectiveAccountID__c=acnt.id;
     order.ccrz__Name__c='Name of the order';
     order.ccrz__OrderStatus__c='Order Submitted';
     order.ccrz__OriginatedCart__c=cart.id;
     order.Reference_Number__c='123232';
     
     insert order;
     
    /* ccrz__E_Invoice__c invoice= new ccrz__E_Invoice__c();
     invoice.ccrz__BillTo__c=acnt.id;
     invoice.ccrz__CCOrder__c=order.id;
     invoice.ccrz__Contact__c=con.id;
     invoice.ccrz__CurrencyCode__c='USD';
     invoice.ccrz__InvoiceId__c='13213243214';
     invoice.ccrz__OriginalAmount__c=12234;
     invoice.ccrz__RemainingAmount__c=12234;
     invoice.ccrz__Status__c='OPEN';
     
     insert invoice;*/
     
     ccrz__E_TransactionPayment__c tp= new ccrz__E_TransactionPayment__c();
     tp.ccrz__Account__c=acnt.id;
     tp.ccrz__Amount__c=12345;
     tp.ccrz__BillTo__c=acnt.id;
     tp.ccrz__CCOrder__c=order.id;
     tp.ccrz__Contact__c=con.id;
     tp.ccrz__RequestAmount__c=12345;
     insert tp;
     
     SCP_Integration_Details__c intDetails= new SCP_Integration_Details__c();
     intDetails.SCP_Application_Name__c='SCP_Cybersource_Capture';
     intDetails.NAme='SCP_Cybersource_Capture';
     intDetails.SCP_End_Point__c='123456789009876543211234567890';
     intDetails.SCP_Is_Active__c=True;
     intDetails.SCP_Key_Client_Id__c='12345678909876543211234567890';
     intDetails.SCP_Method_Type__c='POST';
     intDetails.SCP_Password_Client_Secret__c='098764431123456789';
     intDetails.SCP_Timeout__c=12000;
     insert intDetails;
       
 }
 
  Static testMethod Void test1(){
    //setupTestData();
    Account acnt=[SELECT id FROM Account WHERE Name='Test Omnicell CyberSource'];
    Contact con=[SELECT id FROM Contact WHERE Email='Testemailcybersource@gmail.com' AND Accountid=:acnt.id];
    ccrz__E_Order__c order = [SELECT id FROM ccrz__E_Order__c WHERE ccrz__Account__c=:acnt.id AND ccrz__Contact__c=:con.id and 
                              ccrz__EffectiveAccountID__c=:acnt.id];
    ccrz__E_TransactionPayment__c tp=[SELECT id FROM ccrz__E_TransactionPayment__c WHERE ccrz__Account__c=:acnt.id AND ccrz__BillTo__c=:acnt.id];
    
     ccrz__E_Invoice__c invoice= new ccrz__E_Invoice__c();
     invoice.ccrz__BillTo__c=acnt.id;
     invoice.ccrz__CCOrder__c=order.id;
     invoice.ccrz__Contact__c=con.id;
     invoice.ccrz__CurrencyCode__c='USD';
     invoice.ccrz__InvoiceId__c='13213243214';
     invoice.ccrz__OriginalAmount__c=12234;
     invoice.ccrz__RemainingAmount__c=12234;
     invoice.ccrz__Status__c='OPEN';
     
     insert invoice;
     
     Test.startTest();
         System.enqueueJob(new SCP_CyberSourceCaptureAPI(tp.id,invoice.id));
     Test.stopTest();
    
  }

    
    Static testMethod Void test2(){
    //setupTestData();
    Account acnt=[SELECT id FROM Account WHERE Name='Test Omnicell CyberSource'];
    Contact con=[SELECT id FROM Contact WHERE Email='Testemailcybersource@gmail.com' AND Accountid=:acnt.id];
    ccrz__E_Order__c order = [SELECT id FROM ccrz__E_Order__c WHERE ccrz__Account__c=:acnt.id AND ccrz__Contact__c=:con.id and ccrz__EffectiveAccountID__c=:acnt.id];
    ccrz__E_TransactionPayment__c tp=[SELECT id FROM ccrz__E_TransactionPayment__c WHERE ccrz__Account__c=:acnt.id AND ccrz__BillTo__c=:acnt.id];
    
     ccrz__E_Invoice__c invoice= new ccrz__E_Invoice__c();
     //invoice.ccrz__BillTo__c=acnt.id;
     //invoice.ccrz__CCOrder__c=order.id;
     //invoice.ccrz__Contact__c=con.id;
     invoice.ccrz__CurrencyCode__c='USD';
     invoice.ccrz__InvoiceId__c='13213243214';
     invoice.ccrz__OriginalAmount__c=12234;
     invoice.ccrz__RemainingAmount__c=12234;
     invoice.ccrz__Status__c='OPEN';
     
     insert invoice;
     
     Test.startTest();
         System.enqueueJob(new SCP_CyberSourceCaptureAPI(tp.id,invoice.id));
     Test.stopTest();
    
  }
    
  Static testMethod Void test3(){
    
     
     
     
     Test.startTest();
         System.enqueueJob(new SCP_CyberSourceCaptureAPI('123456789012345','123456789012345'));
     Test.stopTest();
    
  }  
    
    Static testMethod Void test4(){ 
    //setupTestData();
    Account acnt=[SELECT id FROM Account WHERE Name='Test Omnicell CyberSource'];
    Contact con=[SELECT id FROM Contact WHERE Email='Testemailcybersource@gmail.com' AND Accountid=:acnt.id];
    ccrz__E_Order__c order = [SELECT id FROM ccrz__E_Order__c WHERE ccrz__Account__c=:acnt.id AND ccrz__Contact__c=:con.id and 
                              ccrz__EffectiveAccountID__c=:acnt.id];
    
        ccrz__E_Cart__c cart = [select id,ccrz__Account__c from ccrz__E_Cart__c   WHERE ccrz__Account__c  =:acnt.ID  LIMIT 1]; 
        ccrz__E_Order__c order1= new ccrz__E_Order__c();
     
     order1.ccrz__Account__c = acnt.id;
     order1.ccrz__Contact__c=con.id;
     order1.ccrz__CurrencyISOCode__c='USD';
     order1.ccrz__EffectiveAccountID__c=acnt.id;
     order1.ccrz__Name__c='Name of the order1';
     order1.ccrz__OrderStatus__c='Order Submitted';
     order1.ccrz__OriginatedCart__c=cart.id;
     order1.Reference_Number__c='123232';
        order1.ccrz__Order__c = order.id; 
     
     insert order1;
        
    ccrz__E_TransactionPayment__c tp=[SELECT id FROM ccrz__E_TransactionPayment__c WHERE ccrz__Account__c=:acnt.id AND ccrz__BillTo__c=:acnt.id];
    
     ccrz__E_Invoice__c invoice= new ccrz__E_Invoice__c();
     invoice.ccrz__BillTo__c=acnt.id;
     invoice.ccrz__CCOrder__c=order1.id;
     invoice.ccrz__Contact__c=con.id;
     invoice.ccrz__CurrencyCode__c='USD';
     invoice.ccrz__InvoiceId__c='13213243214';
     invoice.ccrz__OriginalAmount__c=12234;
     invoice.ccrz__RemainingAmount__c=12234;
     invoice.ccrz__Status__c='OPEN';
     
     insert invoice;
     
     Test.startTest();
         System.enqueueJob(new SCP_CyberSourceCaptureAPI(tp.id,invoice.id));
     Test.stopTest();
    
  }

    
    
}