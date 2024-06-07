/**
 * @File Name          : QuoteApprovalProgressController_Test_New.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/6/2020, 6:09:14 pm
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/6/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
public class QuoteApprovalProgressController_Test_New {
		public static Id recTypeQuoteApproval = [SELECT Id FROM RecordType WHERE SObjectType = 'Quote_Approval__c' AND Name = 'NAA Budgetary Quote' LIMIT 1].Id;
        @testSetup 
    static void setup() {
         CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
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
    	QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        contactTriggerHandler.TriggerDisabled = True;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.RecordTypeId = recTypeQuoteApproval;
        qa.Need_Manual_Approval__c = true;
        qa.Quote__c=quote.Id;
        qa.Requires_Deal_Desk_Approval__c = true;
        qa.Requires_Legal_Approval__c = true;
        qa.Requires_RX_Config_Approval__c = true;
        qa.Requires_Sales_Finance_Approval__c = true;
        qa.Requires_Tech_Svcs_Approval__c = true;
        
        insert qa;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(qa.id);
        req1.setSubmitterId(userinfo.getUserId());
        List<Id> users = new List<Id>();
        users.add(userinfo.getUserId());
        req1.setNextApproverIds(users);
        Approval.ProcessResult result = Approval.process(req1);
        
        
        QuoteApprovalProgressController.getPendingQueues(qa.Id);
        
        
        QuoteApprovalProgressController.getQueuesNotStarted(qa.Id);
        QuoteApprovalProgressController.getRejectedQueues(qa.Id);
        Test.stopTest();
        System.assert(result.isSuccess());
    }
    public static testMethod void QuoteApprovalProgressControllertest2(){
        contactTriggerHandler.TriggerDisabled = True;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId();
        qa.Quote__c= quote.Id;
        qa.Requires_Deal_Desk_Approval__c = true;
        qa.Requires_Legal_Approval__c = true;
        qa.Requires_RX_Config_Approval__c = true;
        qa.Requires_Sales_Finance_Approval__c = true;
        qa.Requires_Tech_Svcs_Approval__c = true;
        insert qa;
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
        Test.stopTest();
    }
    public static testMethod void QuoteApprovalProgressControllertest3(){
        contactTriggerHandler.TriggerDisabled = True;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        qa.Quote__c= quote.Id;
        insert qa;
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
        Test.stopTest();
    }
    public static testMethod void QuoteApprovalProgressControllertest4(){
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        contactTriggerHandler.TriggerDisabled = True;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('PES Inception Order/PA Quote').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        qa.Quote__c= quote.Id;
        qa.Need_Finance_Team_Approval__c = true;
        qa.Need_Operations_Team_Approval__c = true;
        qa.Need_Legal_Team_Approval__c = true;
        insert qa;
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
        Test.stopTest();
    }
    public static testMethod void QuoteApprovalProgressControllertest5(){
        contactTriggerHandler.TriggerDisabled = True;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.Quote__c= quote.Id;
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        insert qa;
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
        Test.stopTest();
    }	
    public static testMethod void QuoteApprovalProgressControllertest6(){
        contactTriggerHandler.TriggerDisabled = True;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.Quote__c= quote.Id;
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('PES Inception Order/PA Quote').getRecordTypeId();
        qa.Need_CSC_Approval__c = true;
        qa.Need_Finance_Team_Approval__c = true;
        qa.Need_Operations_Team_Approval__c = true;
        qa.Need_Legal_Team_Approval__c = true;
        Quote_Approval_Chevron__c qac = new Quote_Approval_Chevron__c();
        insert qa;
        qac.Quote_Approval__c = qa.Id;
        insert qac;
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
        Test.stopTest();
    }
    public static testMethod void QuoteApprovalProgressControllertest7(){
        contactTriggerHandler.TriggerDisabled = True;
        Quote quote = createQuote();
        Quote_Line__c ql = createQuoteLine();
        Product2 prod = new Product2(Name = 'TestProduct-SV',Family = 'test',External_ID__c = '1234567890123',ProductCode = 'TestProduct-SV',DW_Product_Line__c = 'testdw',SAP_Product_Type__c = 'testsap');
        insert prod;
        ql.Product__c = prod.id;
        System.debug('Prod : '+ql.product__r.productcode);
        Test.startTest();
        insert quote;
        quote.Quote_Number__c = '1234';
        quote.Create_Sales_Order__c = true;
       
        update quote;
        ql.Quote__c = quote.Id;
        insert ql;
        Quote_Approval__c qa = new Quote_Approval__c();
        qa.RecordTypeId = Schema.SObjectType.Quote_Approval__c.getRecordTypeInfosByName().get('International ADC/VBM Supplement').getRecordTypeId();
        qa.Quote__c= quote.Id;
        qa.Requires_Deal_Desk_Approval__c = true;
        qa.Requires_Legal_Approval__c = true;
        qa.Requires_RX_Config_Approval__c = true;
        qa.Requires_Sales_Finance_Approval__c = true;
        qa.Requires_Tech_Svcs_Approval__c = true;
        Quote_Approval_Chevron__c qac = new Quote_Approval_Chevron__c();
        insert qa;
        qac.Quote_Approval__c = qa.Id;
        insert qac;
        
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		req.setComments('Rejecting request');
        req.setAction('Reject');
        Id workItemId = getWorkItemId(qa.id); 

        if(workItemId == null)
        {            
        }
        else
        {
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req);
        }
        QuoteApprovalProgressController.updateQA(true, 'Test', qa);
        QuoteApprovalProgressController.updateQA(false, 'Test', qa);
        QuoteApprovalProgressController.updateQAProgress(qac, 'Rejected', new Map<String, String>());
        QuoteApprovalProgressController.getChRecordId('a2z4F000000JF5M');
        //QuoteApprovalProgressController.getRejectedQueues(qa.Id);
        //List<DateTime> dt = QuoteApprovalProgressController.getApprovedDate(qa.Id);
        Test.stopTest();
    }
    //Create Quote
    public static Quote createQuote(){
        
        Quote quote = new Quote();
        quote.name = 'Test Quote';
        List<Contact> c = [select ID, SAP_Contact_ID__c from Contact Where ID=:TestDataFactory.createContactWithAccount_Integration().Id];
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.Region__c='Northeast';
        quote.Pricing_Reference_Date__c=system.today();
        quote.Requested_Delivery_Date__c = system.today();
        quote.Booking_Date__c=system.today();
        quote.ExpirationDate = system.today();
        quote.SAP_Last_Line_Number__c = 200;
        quote.EOL_Date__c = System.today()+200;
        quote.Supplement_Version__c = 2;
        quote.Status = 'E0009';
        quote.Shipping_Contact__c= c[0].Id;
        quote.Order_Type__c = 'ZHQR';
        Opportunity opp = TestDataFactory.createOppWithAccount_Integration1();	
        quote.OpportunityId = opp.Id;
        Product_Line__c pl = new Product_Line__c();
        pl.Portfolio_Segment__c = 'Automated Dispensing Cabinets';//Performance Center';
        pl.Amount__c = 10000;
        pl.Opportunity__c = opp.id;    
        insert pl;
        return quote;
    }
    //Create Quote line
    public static Quote_Line__c createQuoteLine(){
        Quote_Line__c ql = new Quote_Line__c();
        RecordType qlNonConfigRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Quote_Line__c' AND Name = 'Non-Configurator Product'];
        ql.RecordTypeId = qlNonConfigRecordType.id;
        
        ql.Higher_Level_Item__c = 0;
        ql.Quantity__c = 1;
        ql.SAP_Line_Number__c = 0;
        ql.SAP_Line_Item_GUID__c = '400';
        ql.Sales_Text__c = 'test';
        ql.Material_Type__c = 'SERVICE';
        ql.Part_of_a_Bundle__c = true;
        ql.Customer_Price__c = 200;
        ql.Conga_Product__c = 'TestProduct-SV';
        ql.Contract_List_Price__c = 200;
        ql.Line_Status__c = 'E0006';
        return ql;
    }
    public Static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;

        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }

        return retVal;
    }
    
}