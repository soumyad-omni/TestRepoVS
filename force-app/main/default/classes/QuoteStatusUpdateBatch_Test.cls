@isTest
public class QuoteStatusUpdateBatch_Test {
    @testsetup
    static void testdatasetup(){
        SCP_TestDataFactory.createContact_Customsetting();    
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
        
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
    }
    public testmethod static void testopplost(){
        ProductLineTriggerHandler.TriggerDisabled = true;
        ContactTriggerHandler.TriggerDisabled = true;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.Account_Status__c = 'Prospect';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        AccountTriggerHandler.TriggerDisabled = true;
        update acc;
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'NAA_Opportunity' limit 1].id;//IBA-5024
        opp.name = 'Test Opp';
        opp.stageName = '1 Solution Design';
        opp.CloseDate = System.today()+20;
        opp.ExpectedInstallDate__c = System.today()+60;
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        opp.Services_Enablement_Owner__c = 'Tara Bakker';
        insert opp;
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp.Id;
        pl.Quantity__c = 1;
        insert pl;
        
        AccountTriggerHandler.TriggerDisabled = true;
        Quote quote = new Quote();
        quote.name = 'Primary Test Quote';
        quote.Quote_Number__c = 'test111';
        quote.status='E0001';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        quote.Order_Type__c = 'ZHQR';
        quote.OpportunityId = opp.Id;
        Contact cont = TestDataFactory.createContactForAcc(opp.AccountId);
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        quote.Bill_to_Account__c = opp.AccountId;
        insert quote;
        
        opp.stageName = '7 Closed Lost';
        opp.OppStatus__c = 'Lost';
        update opp;
        
        Test.startTest();
        QuoteStatusUpdateBatch_Opps batchjob1 = new QuoteStatusUpdateBatch_Opps();
        Database.executeBatch(batchjob1);
        Test.stopTest();
        
    }
    public testmethod static void testopplost1(){
        ContactTriggerHandler.TriggerDisabled = true;
        ProductLineTriggerHandler.TriggerDisabled = true;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        acc.Account_Status__c = 'Prospect';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        AccountTriggerHandler.TriggerDisabled = true;
        update acc;
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId = [select id,Name,DeveloperName from RecordType where SobjectType ='Opportunity' and DeveloperName = 'NAA_Opportunity' limit 1].id;//IBA-5024
        opp1.name = 'Test Opp 1';
        opp1.stageName = '1 Solution Design';
        opp1.CloseDate = System.today()+35;
        opp1.ExpectedInstallDate__c = System.today()+65;
        opp1.AccountId = acc.id;
        opp1.OppStatus__c = 'Non Comissionable Booking';
        opp1.Services_Enablement_Owner__c = 'Tara Bakker';
        insert opp1;
        
        Product_Line__c pl = new Product_Line__c();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        pl.Opportunity__c = opp1.Id;
        pl.Quantity__c = 1;
        insert pl;
        
        Quote quote = new Quote();
        quote.name = 'Zero Value Test Quote';
        quote.Quote_Number__c = 'test1117';
        quote.status='E0023';
        quote.Primary_Quote__c=true;
        quote.Region__c='Northeast';
        quote.Order_Type__c = 'ZHQR';
        quote.OpportunityId = opp1.Id;
        Contact cont = TestDataFactory.createContactForAcc(opp1.AccountId);
        quote.ContactId= cont.id;
        quote.Shipping_Contact__c= cont.Id;
        quote.Bill_to_Account__c = opp1.AccountId;
        insert quote;
        
        Quote quote1 = new Quote();
        quote1.name = 'Open Test Quote';
        quote1.Quote_Number__c = 'test1118';
        quote1.status='E0001';
        quote1.Primary_Quote__c=false;
        quote1.Region__c='Northeast';
        quote1.Order_Type__c = 'ZHQR';
        quote1.OpportunityId = opp1.Id;
        Contact cont1 = TestDataFactory.createContactForAcc(opp1.AccountId);
        quote1.ContactId= cont1.id;
        quote1.Shipping_Contact__c= cont1.Id;
        quote1.Bill_to_Account__c = opp1.AccountId;
        insert quote1;       
        
        Test.startTest();
        QuoteStatusUpdateBatch_Opps batchjob2 = new QuoteStatusUpdateBatch_Opps();
        Database.executeBatch(batchjob2);
        Test.stopTest();
    }
    public static testMethod void testschedule() {
        Test.StartTest();
        ScheduleQuoteStatusUpdateBatch sh1 = new ScheduleQuoteStatusUpdateBatch();
        String sch = '0 0 0 ? * SUN'; 
        system.schedule('Quote Status Update Job', sch, sh1); 
        Test.stopTest(); 
    } 
}