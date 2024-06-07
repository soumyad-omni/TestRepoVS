// TargetInitiativeTriggerHandler_Test 
// -----------------------------------------------------------------------------------------------------------
//  Author              Date            Description
//  Veny K             21/06/2018       Test Class for TargetInitiativeTriggerHandler

@isTest
public class TargetInitiativeTriggerHandler_Test {
    static testMethod void testTargetInitiativeTrigger() {
        
        System.runAs( TestDataFactory.getCurrentUser() ) {
            // create account for testing
            AccountCreateController.isFirstRun= false; 
            Accounttriggerhandler.TriggerDisabled = true;
            Account acc01 = TestDataFactory.createTestAccountQuotePrint();
           // acc01.Segment__C  = 'Top Accounts';
           //IBA-4149  acc01.Is_Top_200__c  = false;
        //IBA-4149    acc01.Is_Deleted_From_Top_Accounts__c = true;
           // acc01.
            update acc01;
            
             Account acc02 = TestDataFactory.createTestAccountQuotePrint();
            
            //create target initiaitve
            Target_Initiative__c ti01 = new Target_Initiative__c();
            ti01.Name          = 'Top Accounts';
            ti01.Start_Date__c = System.today();
            ti01.End_Date__c   = System.today()+60;
            ti01.Use_for_segmentation__c = true;
            ti01.Type_of_account_propagation__c = 'Apply to entire hierarchy';    
            insert ti01;
            
            Map<Id, Target_Initiative_Account__c> map_Tag_Initiave_Account1 = new Map<Id, Target_Initiative_Account__c>();
                        
            // add an account to target initiative
            Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
            tia1.Target_Initiative__c = ti01.id;
            tia1.Account__c = acc01.id;
            insert tia1;
            map_Tag_Initiave_Account1.put(tia1.Id, tia1);
   
            // try to add same account again
            Target_Initiative_Account__c tia2 = new Target_Initiative_Account__c();
            tia2.Target_Initiative__c = ti01.Id;
            tia2.Account__c = acc01.Id;

            Target_Initiative_Account__c tia3 = new Target_Initiative_Account__c();
            tia3.Target_Initiative__c = ti01.Id;
            tia3.Account__c = acc02.Id;
         
            insert tia3;
            map_Tag_Initiave_Account1.put(tia3.Id, tia3);


            try{
                insert tia2; 
                map_Tag_Initiave_Account1.put(tia2.Id, tia2);
            } catch(Exception e){
                System.assert(e.getMessage().contains('Cannot add this account. It has already been added to the Target Initiative.'));
            }
                            System.debug(map_Tag_Initiave_Account1);
                        UpdateAccount_OnTop200.updateAccount_OnAfterInsert(map_Tag_Initiave_Account1);
        
        }
    }
    
    static testMethod void testDeleteTargetInitiativeTrigger() {
        
        System.runAs( TestDataFactory.getCurrentUser() ) {
            
            // create account for testing
            AccountCreateController.isFirstRun= false; 
			Accounttriggerhandler.TriggerDisabled = true;
            Account acc01 = TestDataFactory.createTestAccountQuotePrint();
            
            //create target initiaitve
            Target_Initiative__c ti01 = new Target_Initiative__c();
            ti01.Name = 'Target Initiative 01';   
            ti01.Start_Date__c= System.Today();
            ti01.End_Date__c= System.Today();     
            insert ti01;
                       
            // add an account to target initiative
            Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
            tia1.Target_Initiative__c = ti01.id;
            tia1.Account__c = acc01.id;
            insert tia1;

                         
            try{
                Map<Id, Target_Initiative_Account__c> map_Tag_Initiave_Account = new Map<Id, Target_Initiative_Account__c>();
                map_Tag_Initiave_Account.put(tia1.id,tia1);                
                UpdateAccount_OnTop200.updateAccount_OnAfterDelete(map_Tag_Initiave_Account);
                delete tia1;
                undelete tia1;                
            } catch(Exception e){
                System.debug ('Exception Occured');
            }
        
        }
    }
    
    static testMethod void testafterInsertTargetInitiativeTrigger() {
        
        System.runAs( TestDataFactory.getCurrentUser() ) {
            
            
            // create account for testing
            AccountCreateController.isFirstRun= false; 
			Accounttriggerhandler.TriggerDisabled = true;
            Account acc01 = TestDataFactory.createTestAccountQuotePrint();
            Account acc02 = TestDataFactory.createTestAccountQuotePrint();
            Account acc03 = TestDataFactory.createTestAccountQuotePrint();
            acc01.ParentId=acc02.id;
            acc02.Segment__c='';
            update acc02;
            //create target initiaitve
            Target_Initiative__c ti01 = new Target_Initiative__c();
            ti01.Name = 'Top Account';   
            ti01.Start_Date__c= System.Today();
            ti01.End_Date__c= System.Today();  
            ti01.Type_of_account_propagation__c='Apply to entire hierarchy';
            insert ti01;
            
            ti01.Use_for_segmentation__c=true;
            update ti01;
            // add an account to target initiative
            Target_Initiative_Account__c tia1 = new Target_Initiative_Account__c();
            tia1.Target_Initiative__c = ti01.id;
            tia1.Account__c = acc01.id;
            insert tia1;
			
            tia1.Target_Initiative_Status__c='In Progress';
            update ti01;
            
            Target_Initiative_Account__c tia2 = new Target_Initiative_Account__c();
            tia2.Target_Initiative__c = ti01.id;
            tia2.Account__c = acc03.id;
            insert tia2;
            try{
                Map<Id, Target_Initiative_Account__c> map_Tag_Initiave_Account = new Map<Id, Target_Initiative_Account__c>();
                map_Tag_Initiave_Account.put(tia1.id,tia1);  

                UpdateAccount_OnTop200.updateAccount_OnAfterDelete(map_Tag_Initiave_Account);
                delete tia1;
                delete tia2;
                undelete tia1;
                
                Set<String> segment=new Set<String> ();
                segment.add('abc');segment.add('def');
                TargetInitiativeTriggerHandler.setToString(segment);
            
            }catch(Exception e){
                System.debug ('Exception Occured');
            }
        
        }
    }
        
}