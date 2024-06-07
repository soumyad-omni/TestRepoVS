@isTest
public class QuoteApprovalProgressController_Test {

    @testSetup 
    static void setup() {
         CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        ECC_Sales_Org_to_CRM__c  setting1 = new ECC_Sales_Org_to_CRM__c ();
        setting1.Name = 'AU SalesOrg Omnicell';
        setting1.CRM_Code__c = 'O 50008662';
        insert setting1;
        ECC_Sales_Org_to_CRM__c  setting2 = new ECC_Sales_Org_to_CRM__c ();
        setting2.Name = 'MACH4 - GmbH';
        setting2.CRM_Code__c = 'O 50008654';
        insert setting2;
        ECC_Sales_Org_to_CRM__c  setting3 = new ECC_Sales_Org_to_CRM__c ();
        setting3.Name = 'Omnicell - St.Petes';
        setting3.CRM_Code__c = 'O 50008663';
        insert setting3;
        ECC_Sales_Org_to_CRM__c  setting4 = new ECC_Sales_Org_to_CRM__c ();
        setting4.Name = 'Omnicell Inc.';
        setting4.CRM_Code__c = 'O 50000029';
        insert setting4;
        ECC_Sales_Org_to_CRM__c  setting5 = new ECC_Sales_Org_to_CRM__c ();
        setting5.Name = 'Omnicell Ltd';
        setting5.CRM_Code__c = 'O 50008655';
        insert setting5;
        ECC_Sales_Org_to_CRM__c  setting6 = new ECC_Sales_Org_to_CRM__c ();
        setting6.Name = 'Omnicell SAS';
        setting6.CRM_Code__c = 'O 50011128';
        insert setting6;
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c   ();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
        
    }
    
    public static testMethod void QuoteApprovalProgressControllertest1(){
        AccountCreateController.isFirstRun= false;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.Quote__c=qt.Id;
        qa.Requires_Deal_Desk_Approval__c = true;
        qa.Requires_Legal_Approval__c = true;
        qa.Requires_RX_Config_Approval__c = true;
        qa.Requires_Sales_Finance_Approval__c = true;
        qa.Requires_Tech_Svcs_Approval__c = true;
        Test.startTest();
        insert qa;
        Test.stopTest();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(qa.id);
        req1.setSubmitterId(userinfo.getUserId());
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        req1.setNextApproverIds(users);
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());
        
        QuoteApprovalProgressController.getPendingQueues(qa.Id);
        
        
        QuoteApprovalProgressController.getQueuesNotStarted(qa.Id);
        QuoteApprovalProgressController.getRejectedQueues(qa.Id);
        
    }  
    public static testMethod void QuoteApprovalProgressControllertest2(){
        AccountCreateController.isFirstRun= false;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId();
        qa.Quote__c=qt.Id;
        qa.Requires_Deal_Desk_Approval__c = true;
        qa.Requires_Legal_Approval__c = true;
        qa.Requires_RX_Config_Approval__c = true;
        qa.Requires_Sales_Finance_Approval__c = true;
        qa.Requires_Tech_Svcs_Approval__c = true;
        Test.startTest();
        insert qa;
        Test.stopTest();
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request');
        req.setAction('Approve');
        req.setNextApproverIds(users);
        Id workItemId;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: qa.Id])
        {
            workItemId =  workItem.Id;
        }

        if(workItemId == null)
        {
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result1 =  Approval.process(req);
        }
        QuoteApprovalProgressController.getApprovedQueues(qa.Id);
        List<DateTime> dt = QuoteApprovalProgressController.getApprovedDate(qa.Id);
    }
    
    
    public static testMethod void QuoteApprovalProgressControllertest3(){
        AccountCreateController.isFirstRun= false;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.Quote__c=qt.Id;
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        Test.startTest();
        insert qa;
        Test.stopTest();
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request');
        req.setAction('Approve');
        req.setNextApproverIds(users);
        Id workItemId;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: qa.Id])
        {
            workItemId =  workItem.Id;
        }

        if(workItemId == null)
        {
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result1 =  Approval.process(req);
        }
        ProcessInstanceStep pi = new ProcessInstanceStep();
        pi.StepStatus = 'Approved';
        QuoteApprovalProgressController.getQueuesNotStarted(qa.Id);
        
    }
    public static testMethod void QuoteApprovalProgressControllertest4(){
        AccountCreateController.isFirstRun= false;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.Quote__c=qt.Id;
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('PES Inception Order/PA Quote').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        qa.Need_Finance_Team_Approval__c = true;
        qa.Need_Operations_Team_Approval__c = true;
        qa.Need_Legal_Team_Approval__c = true;
        //Quote_Approval_Chevron__c qac = new Quote_Approval_Chevron__c();
        Test.startTest();
        insert qa;
        //qac.Quote_Approval__c = qa.Id;
        //insert qac;
        Test.stopTest();
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request');
        req.setAction('Approve');
        req.setNextApproverIds(users);
        Id workItemId;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: qa.Id])
        {
            workItemId =  workItem.Id;
        }

        if(workItemId == null)
        {
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result1 =  Approval.process(req);
        }
        QuoteApprovalProgressController.getQueuesNotStarted(qa.Id);
        QuoteApprovalProgressController.getChRecordId(qa.Id);
        //QuoteApprovalProgressController.getChRecordId('a2z4F000000JF5M');
    }
    
    public static testMethod void QuoteApprovalProgressControllertest6(){
        AccountCreateController.isFirstRun= false;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.Quote__c=qt.Id;
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('PES Inception Order/PA Quote').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        qa.Need_Finance_Team_Approval__c = true;
        qa.Need_Operations_Team_Approval__c = true;
        qa.Need_Legal_Team_Approval__c = true;
        Quote_Approval_Chevron__c qac = new Quote_Approval_Chevron__c();
        Test.startTest();
        insert qa;
        qac.Quote_Approval__c = qa.Id;
        insert qac;
        Test.stopTest();
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request');
        req.setAction('Approve');
        req.setNextApproverIds(users);
        Id workItemId;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: qa.Id])
        {
            workItemId =  workItem.Id;
        }

        if(workItemId == null)
        {
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result1 =  Approval.process(req);
        }
        QuoteApprovalProgressController.updateQA(true, 'Test', qa);
        QuoteApprovalProgressController.updateQA(false, 'Test', qa);
        QuoteApprovalProgressController.updateQAProgress(qac, 'Approved', new Map<String, String>());
        QuoteApprovalProgressController.getChRecordId('a2z4F000000JF5M');
    }
    
    public static testMethod void QuoteApprovalProgressControllertest5(){
        AccountCreateController.isFirstRun= false;
        Quote qt = TestDataFactory.createTestQuote_Integration();
        Quote_approval__c qa = TestDataFactory.createQuoteApprovalRec();
        qa.Quote__c=qt.Id;
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        Test.startTest();
        insert qa;
        Test.stopTest();
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request');
        req.setAction('Approve');
        req.setNextApproverIds(users);
        Id workItemId;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: qa.Id])
        {
            workItemId =  workItem.Id;
        }

        if(workItemId == null)
        {
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result1 =  Approval.process(req);
        }
        QuoteApprovalProgressController.updateAssignedto(qa.Id);
    }  
    
}