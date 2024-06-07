@isTest
public class BCH_UpdateIsDeletedFromTopAccounts_Test{
	public static testmethod void UpdateIsDeletedFromTopAccountsTest(){
		Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
		AccountCreateController.isFirstRun= false; 
        Accounttriggerhandler.TriggerDisabled = true;
		Account pacc = TestDataFactory.createTestAccountQuotePrint();
        pacc.Segment__c='Top Accounts';
		
		pacc.RecordTypeId=recTypeAccount;
		update pacc;
        if(recTypeAccount!=null){
        Account_History__c accHistory = new Account_History__c();
        accHistory.Account__c = pacc.Id;
        accHistory.Field__c = 'Segment';
        }
		/*
		Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        acc1.Is_Top_200__c = FALSE;
        acc1.RecordTypeId = recTypeAccount;
        acc1.ParentId = pacc.Id;
        update acc1;
		
		Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        acc2.Is_Top_200__c = FALSE;
        acc2.RecordTypeId = recTypeAccount;
        acc2.ParentId = pacc.Id;
        update acc2; 
		
		Account acc3 = TestDataFactory.createTestAccountQuotePrint();
        acc3.Is_Top_200__c = FALSE;
        acc3.RecordTypeId = recTypeAccount;
        acc3.ParentId = pacc.Id;
        update acc3; */
		
		//Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;        
        tarIni.Use_for_segmentation__c = true;
        insert tarIni;
		
		//Insert Target Initiative Account
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
		 List<Target_Initiative__c> targetList = [Select Id, Name,Use_for_segmentation__c from Target_Initiative__c 
                                                     where Use_for_segmentation__c = true and 
                                                     Type_of_account_propagation__c = 'Apply to account and all child accounts'];
		test.StartTest();        
		BCH_UpdateIsDeletedFromTopAccounts dfromTop= new BCH_UpdateIsDeletedFromTopAccounts();
        dfromTop.targetList = targetList;
        Database.executeBatch(dfromTop, 30);  
       // Database.executeBatch(dfromTop);
        test.StopTest();
	}
}