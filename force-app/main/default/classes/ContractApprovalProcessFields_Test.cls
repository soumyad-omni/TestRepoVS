/**********************************************************************
Name:  ContractApprovalProcessFields_Test
Copyright © 2018
======================================================
======================================================
Purpose: 
Test class for the ContractApprovalProcessFields_Class

======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                      DATE             DETAIL               Description
0.1          Haripriya Maturi          7/31/2018                            INITIAL DEVELOPMENT
***********************************************************************/
@isTest
public class ContractApprovalProcessFields_Test {
    public static testmethod void testApprovalProcessFields(){  
    
       AccountCreateController.isFirstRun= false;
       Account acc = TestDatafactory.createTestAccountQuotePrint();  
       
       Id recTypeContract = [SELECT Id FROM RecordType WHERE SObjectType = 'Contracts__c' AND Name = 'Boilerplate' LIMIT 1].Id;
       //Contracts__c con = TestDatafactory.createContract();
       
        Contracts__c contr = new Contracts__c();
        contr.Account__c = acc.Id;
        contr.Type__c = 'Boilerplate Master Agreement';
        contr.Has_all_Checklist_Document_Been_Uploaded__c = true;
        contr.RecordTypeId = recTypeContract;
        contr.Bookings_Team_Approved__c = false;
        
        insert contr;
        
        System.debug('Contract : '+contr.Type__c);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(contr.id);

        
        req1.setProcessDefinitionNameOrId('Contract_Boiler_Plate_Approval');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);

    }
}