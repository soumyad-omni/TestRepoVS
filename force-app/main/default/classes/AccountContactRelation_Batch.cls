/***********************************************************************************************************
Name:  AccountContactRelation_Batch
Copyright © 2018
============================================================================================================
============================================================================================================
Purpose: 
This Batch was scheduled at hourly basis, this Batch will retrieve all LastModifiedDate=Today records of AccountContactRelation object.
Then it will check Contact.SAP_Contact_ID__c!=null & Account.SAP_Account_ID__c!=null,then send details to castiron via REST api class

============================================================================================================
=============================================================================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Capgemin Dev Team          10/01/2018                           INITIAL DEVELOPMENT
*************************************************************************************************************/
global class AccountContactRelation_Batch implements DataBase.Batchable<sObject>,Database.AllowsCallouts{
    
    global AccountContactRelation_Batch(){        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        return Database.getQueryLocator('select Id,AccountId,Account.SAP_Account_ID__c,ContactId,Contact.SAP_Contact_ID__c,Roles FROM AccountContactRelation where LastModifiedDate=today AND HOUR_IN_DAY(LastModifiedDate) > 1'); 
    } 

    
    global void execute(DataBase.BatchableContext BC,List<AccountContactRelation> acr){
    
        Set<Id> actconrelIds = new Set<Id>();
        Set<Id> newactconIds = new Set<Id>();
        if(acr.size()>0)
        {
         system.debug('inside if...');
         for(AccountContactRelation ActConRel : acr)
         {
          system.debug('inside for...');
          actconrelIds.add(ActConRel.Id);
          system.debug('ActconrelIds...'+actconrelIds);
         }
        }
        
        List<AccountContactRelation> acList = [select id,AccountId,Account.SAP_Account_ID__c,ContactId,Contact.SAP_Contact_ID__c from AccountContactRelation where id IN:actconrelIds];
        system.debug('acList...'+acList);
         
         
         if(acList.size()>0)
         {
         for(AccountContactRelation actcon : acList)
         {
            if(actcon.Account.SAP_Account_ID__c != null && actcon.Contact.SAP_Contact_ID__c != null)
            {
              system.debug('SAP acct number...'+actcon.Account.SAP_Account_ID__c);
              system.debug('SAP contact number...'+actcon.Contact.SAP_Contact_ID__c);
              newactconIds.add(actcon.Id);
              system.debug('newactconIds..'+newactconIds);
            }
         }
         try
         {
          system.debug('in try..');
          //OmnicellAcctContRelationToCastIron_Old.callOutMethod(newactconIds);
          OmnicellAcctContRelationToCastIron_Class.callOutMethod(newactconIds);
          
         }catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'AccountContactRelation_Batch','App');
        }
         }  
    }
    global void finish(DataBase.BatchableContext BC){
     
    }
}