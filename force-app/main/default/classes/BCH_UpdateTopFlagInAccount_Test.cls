@isTest
public class BCH_UpdateTopFlagInAccount_Test {
    
    
    public static testmethod void UpdateTopFlagInAccountTest(){
		Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
		AccountCreateController.isFirstRun= false; 
        Accounttriggerhandler.TriggerDisabled = true;
        
		test.StartTest();
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
		//IBA-4149  pacc.Is_Top_200__c = false;
		pacc.RecordTypeId=recTypeAccount;
        pacc.Segment__c = 'Top Accounts;AM Segment';
		update pacc;
					
		Account acc0 = TestDataFactory.createTestAccountQuotePrint();
       	acc0.RecordTypeId = recTypeAccount;
        acc0.ParentId = pacc.Id;
     //IBA-4149   acc0.Is_Top_200__c = FALSE;
        update acc0; 
		
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
       //IBA-4149  acc1.Is_Top_200__c = FALSE;
       	acc1.RecordTypeId = recTypeAccount;
        acc1.ParentId = pacc.Id;
        update acc1;
		
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
      //IBA-4149    acc2.Is_Top_200__c = FALSE;
       	acc2.RecordTypeId = recTypeAccount;
        acc2.ParentId = pacc.Id;
        //IBA-4149 acc2.Is_Top_200__c = FALSE;
        update acc2;

        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        tarIni.Use_for_segmentation__c = true;
        tarIni.Type_of_account_propagation__c = 'Apply to individual account';
        insert tarIni;
		
        Target_Initiative__c tarIni1 = new Target_Initiative__c ();
        tarIni1.Name          = 'My top report';
        tarIni1.Start_Date__c = System.today();
        tarIni1.End_Date__c   = System.today()+60;
        tarIni1.Use_for_segmentation__c = true;
        tarIni1.Type_of_account_propagation__c = 'Apply to individual account';
        insert tarIni1;

		Target_Initiative__c tarIni2 = new Target_Initiative__c ();
        tarIni2.Name          = 'AM Segment';
        tarIni2.Start_Date__c = System.today();
        tarIni2.End_Date__c   = System.today()+60;
        tarIni2.Use_for_segmentation__c = true;
        tarIni2.Type_of_account_propagation__c = 'Apply to individual account';
        insert tarIni2;
        
		//Insert Target Initiative Account
       /*
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
		*/

		 List<Target_Initiative__c> targetList = [Select Id, Name,Use_for_segmentation__c from Target_Initiative__c 
                                                     where Use_for_segmentation__c = true and 
                                                     Type_of_account_propagation__c = 'Apply to individual account'];
		
		  BCH_UpdateTopFlagInAccount obj = new BCH_UpdateTopFlagInAccount();
          obj.targetList = targetList;
          obj.targetInitiativeName	= targetList[0].Name;
		  Id batchId = Database.executeBatch(obj,30);
		test.StopTest();
	}

}