@isTest
public class BCH_UpdateTopFlagAsFalseInAccount_Test {
    
    
    public static testmethod void UpdateParentAndChildHierarchyTest(){
        AccountTriggerHandler.TriggerDisabled=true;
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	pacc.Is_Top_200__c = true;
        pacc.RecordTypeId=recTypeAccount;
        update pacc;
        
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	    acc1.Is_Top_200__c = true;
        acc1.RecordTypeId = recTypeAccount;
        acc1.ParentId = pacc.Id;
        update acc1;
        
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	   acc2.Is_Top_200__c = true;
        acc2.RecordTypeId = recTypeAccount;
        acc2.ParentId = pacc.Id;
        update acc2; 
        
        Account acc3 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	    acc3.Is_Top_200__c = true;
        acc3.RecordTypeId = recTypeAccount;
        acc3.ParentId = pacc.Id;
        update acc3; 
        
        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        insert tarIni;
        
        //Insert Target Initiative Account
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
        
        test.StartTest();
        Map<Id,Target_Initiative_Account__c> tagMap = new  Map<Id,Target_Initiative_Account__c>([Select Id, Account__c,Target_Initiative_Name__c from Target_Initiative_Account__c LIMIT 100]);
        UpdateAccount_OnTop200.updateAccount_OnAfterUnDelete(tagMap);
        UpdateAccount_OnTop200.updateAccount_OnAfterDelete(tagMap);
        test.StopTest();
    }
    
    public static testmethod void UpdateParentAndChildHierarchyTest1(){
        AccountTriggerHandler.TriggerDisabled=true;
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	 pacc.Is_Top_200__c = true;
        pacc.RecordTypeId=recTypeAccount;
        update pacc;
        
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	 acc1.Is_Top_200__c = true;
        acc1.RecordTypeId = recTypeAccount;
        acc1.ParentId = pacc.Id;
        update acc1;
        
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	acc2.Is_Top_200__c = true;
        acc2.RecordTypeId = recTypeAccount;
        acc2.ParentId = pacc.Id;
        update acc2; 
        
        Account acc3 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	 acc3.Is_Top_200__c = true;
        acc3.RecordTypeId = recTypeAccount;
        acc3.ParentId = pacc.Id;
        update acc3; 
        
        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        insert tarIni;
        
        //Insert Target Initiative Account
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
        
        delete tarAcc;
        
        test.StartTest();
        BCH_UpdateTopFlagAsFalseInAccount obj = new BCH_UpdateTopFlagAsFalseInAccount();
        obj.tarAccId =  tarIni.Id;
        Id batchId = Database.executeBatch(obj);
        test.StopTest();
    }
    
    public static testmethod void UpdateParentAndChildHierarchyTest2(){
        AccountTriggerHandler.TriggerDisabled=true;
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	pacc.Is_Top_200__c = true;
        pacc.RecordTypeId=recTypeAccount;
        update pacc;
        
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	acc1.Is_Top_200__c = true;
        acc1.RecordTypeId = recTypeAccount;
        acc1.ParentId = pacc.Id;
        update acc1;
        
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	   acc2.Is_Top_200__c = true;
        acc2.RecordTypeId = recTypeAccount;
        acc2.ParentId = pacc.Id;
        update acc2; 
        
        Account acc3 = TestDataFactory.createTestAccountQuotePrint();
        //IBA-4149	 acc3.Is_Top_200__c = true;
        acc3.RecordTypeId = recTypeAccount;
        acc3.ParentId = pacc.Id;
        update acc3; 
        
        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        insert tarIni;
        
        //Insert Target Initiative Account
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
        
        delete tarAcc;
        
        test.StartTest();
        BCH_UpdateIsDeletedFromTopAccounts obj = new BCH_UpdateIsDeletedFromTopAccounts();
        obj.tarAccId =  tarIni.Id;
        Id batchId = Database.executeBatch(obj);
        test.StopTest();
    }
    
    public static testmethod void UpdateParentAndChildHierarchyTest3(){
        AccountTriggerHandler.TriggerDisabled=true;
        Id recTypeAccount = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'US & Canada Customer' LIMIT 1].Id;
        
        Account pacc = TestDataFactory.createTestAccountQuotePrint();
        pacc.RecordTypeId=recTypeAccount;
        update pacc;
        
        Account acc1 = TestDataFactory.createTestAccountQuotePrint();
        acc1.RecordTypeId = recTypeAccount;
        acc1.ParentId = pacc.Id;
        update acc1;
        
        Account acc2 = TestDataFactory.createTestAccountQuotePrint();
        acc2.RecordTypeId = recTypeAccount;
        acc2.ParentId = pacc.Id;
        update acc2; 
        
        Account acc3 = TestDataFactory.createTestAccountQuotePrint();
        acc3.RecordTypeId = recTypeAccount;
        acc3.ParentId = pacc.Id;
        update acc3; 
        
        //Insert Target Initiative
        Target_Initiative__c tarIni = new Target_Initiative__c ();
        tarIni.Name          = 'Top Accounts';
        tarIni.Start_Date__c = System.today();
        tarIni.End_Date__c   = System.today()+60;
        insert tarIni;
        
        //Insert Target Initiative Account
        Target_Initiative_Account__c tarAcc = new Target_Initiative_Account__c();
        tarAcc.Account__c           = pacc.Id;
        tarAcc.Target_Initiative__c = tarIni.Id;
        insert tarAcc;
        
        test.StartTest();
        Map<Id,Target_Initiative_Account__c> tagMap = new  Map<Id,Target_Initiative_Account__c>([Select Id, Account__c,Target_Initiative_Name__c from Target_Initiative_Account__c LIMIT 100]);
        UpdateAccount_OnTop200.updateAccount_OnAfterInsert(tagMap);
        test.StopTest();
    }
    
}