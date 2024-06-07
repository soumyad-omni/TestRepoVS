/**
 *@Description		: Test class for TIAccountSegmentUpdate
 * 
 *@File Name        : TIAccountSegmentUpdate_Test.cls
 *@Author           : Pabitra Tripathy
**/
@isTest
public class TIAccountSegmentUpdate_Test {
static testmethod void TIAccountSegmentUpdate(){
		Trigger_Configuration__c  setting111 = new Trigger_Configuration__c ();
        setting111.Name = 'AccountFieldTrack';
        setting111.IsDisabled__c = false;
        insert setting111;
    	Id recTypeAccountUS = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        test.startTest();
        Account act0 = new Account(name='My New Account100',Account_role__c='ZCSN',
                                      Transportation_Zone_Country__c = 'US',Primary_Language__c = 'EN',
                                      Country_Cluster__c = 'US&CA',Division_Account__c = 'Atlantic',Region__c = 'Central',Account_Territory__c='East OH',
                                      BillingCountrycode = 'US',RecordtypeId = recTypeAccountUS,
                                      BillingCity='Phoenix',BillingStateCode='AZ',BillingPostalCode='12345',BillingStreet='test123',
                                      Account_Status__c = 'Active',IsDeleted__c = false,
                                      Facility_Type__c='Hospice', 
                                      //ParentId = '0011N00001pYpTbQAK',
                                      Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada1',SAP_Account_ID__c='123456789009876540',
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
                                      Validation_Status__c = 'Validated',
                                      Territory_Name__c='testCanada',SAP_Account_ID__c='123456789009876543',
                                      Transport_Zone__c='US00000002',Partner_Type__c= '0015');
       
        insert act1;
	    act1.ParentId=null;
        update act1;
    
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
		   		
        Set<Id> topChilds= new Set<Id>{act0.Id,act1.Id};
    	Map<Id,Set<Id>> parentChildMap = new Map<Id,Set<Id>>();
        parentChildMap.put(act0.Id,new Set<Id>{act1.id}); 
        List<TIParentSegment.AcctTi> acctTiList = new List<TIParentSegment.AcctTi>();
        TIParentSegment.AcctTi tiacc= new TIParentSegment.AcctTi ();
        tiacc.acctId = act0.Id;
        tiacc.tiId   = ti01.Id; 
        tiacc.tiName  = ti01.Name;
        tiacc.propagationType = ti01.Type_of_account_propagation__c;	
	    acctTiList.add(tiacc);

    	
    		System.enqueueJob(new TIAccountSegmentUpdate(topChilds,parentChildMap,acctTiList,null,null,null,false));
  		test.stopTest(); 
    }

}