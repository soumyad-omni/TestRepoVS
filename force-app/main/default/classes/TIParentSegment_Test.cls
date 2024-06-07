/**
 *@Description		: Test class for TIParentSegment
 * 
 *@File Name        : TIParentSegment_Test.cls
 *@Author           : Pabitra Tripathy
**/
@isTest
public class TIParentSegment_Test {
    static testmethod void TIParentSegment(){
        Account_SendEmail_Off__c  setting1111 = new Account_SendEmail_Off__c ();
        setting1111.Name = 'Account SendEmail Off';
        setting1111.Account_SendEmail_Off__c = false;
        insert setting1111;
        
        Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
        
        Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
        ExternalDataTriggerHandler.TriggerDisabled = true;
       	Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account act0 = new Account(name='My New Account100',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                      BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Facility_Type__c='Hospice', 
                                      //ParentId = '0011N00001pYpTbQAK',
                                      //Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada1',//SAP_Account_ID__c='1234'+system.now().millisecond()+math.round(math.random()*10000),
                                      Transport_Zone__c='US00000005',Partner_Type__c= '0015');
        insert act0;
        
        Account act1 = new Account(name='My New Account101',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                      BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54321',BillingStreet='test456',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Facility_Type__c='Hospice', 
                                      ParentId=act0.Id,
                                      //Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada',//SAP_Account_ID__c='1234'+system.now().millisecond()+math.round(math.random()*10000),
                                      Transport_Zone__c='US00000002',Partner_Type__c= '0015');
       
       	insert act1;
       
        Account act2 = new Account(name='My New Account1001',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                      BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='54675',BillingStreet='test123',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Facility_Type__c='Hospice', 
                                      //ParentId = '0011N00001pYpTbQAK',
                                      //Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada1',//SAP_Account_ID__c='1234'+system.now().millisecond()+math.round(math.random()*10000),
                                      Transport_Zone__c='US00000003',Partner_Type__c= '0015');
		
        insert act2;

        //create target initiaitve
        Target_Initiative__c ti01 = new Target_Initiative__c();
        ti01.Name          = 'Top Accounts';
        ti01.Start_Date__c = System.today();
        ti01.End_Date__c   = System.today()+60;
        ti01.Use_for_segmentation__c = true;
        ti01.Type_of_account_propagation__c = 'Apply to entire hierarchy';    
        insert ti01;
                        
        // add an account to target initiative
        Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
        tia1.Target_Initiative__c = ti01.id;
        tia1.Account__c = act1.id;
        insert tia1;
		
        Target_Initiative_Account__c tia2 = new Target_Initiative_Account__c();
        tia2.Target_Initiative__c = ti01.Id;
        tia2.Account__c = act2.Id;
        insert tia2;
    	
		   		
        Set<Id> topChilds= new Set<Id>{act0.Id,act1.Id};
    	
        Map<Id,Set<Id>> parentChildMap = new Map<Id,Set<Id>>();
        parentChildMap.put(act0.Id,new Set<Id>{act1.id});
        parentChildMap.put(act2.Id,new Set<Id>{act1.id});
        Set<Id> oldTopChilds;
        Set<Id> acctSet = new Set<Id>{act1.id};
		Set<string> accountIds = new Set<string>();
        accountIds.add(act2.id);
       test.startTest();
			act1.ParentId=act2.Id;
        	update act1;
        	System.enqueueJob(new TIParentSegment(topChilds,oldTopChilds,false,true,accountIds));
  		test.stopTest(); 
    }
}