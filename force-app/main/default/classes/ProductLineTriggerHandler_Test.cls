@isTest
public class ProductLineTriggerHandler_Test {
	@testsetup
    static void testdatasetup(){
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.EndPoint__c = 'https://castirondatadev.omnicell.com/QuoteHeaderSFToCRM';
        setting.QuoteHeaderUpdateEndpoint__c = 'https://castirondatadev.omnicell.com/ QuoteHeaderSFToCRMUpdate';
        insert setting;
        
        Conga_Print_Output__c output1 = new Conga_Print_Output__c();
        output1.Name = 'System Admin';
        output1.Profile_Name__c = 'System Administrator';
        insert output1;
        Conga_Print_Output__c output2 = new Conga_Print_Output__c();
        output2.Name = 'Business Admin';
        output2.Profile_Name__c = 'Business Administrator';
        insert output2;
        
        
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
        
        Default_Currency_by_Country_Code__c    setting7 = new Default_Currency_by_Country_Code__c();
        setting7.Name = 'AZ';
        setting7.Currency_Code__c = 'USD';
        insert setting7;
    }
    
    
    public testmethod static void accountProdLineTest(){
        ContactTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        AccountCreateController.isTriggerExecuting=false;        
        Product_Line__c pl = TestDataFactory.createTestProdLine();
        pl.Quote__c = null;
        pl.Product_Line__c = 'Performance Center';
        test.startTest();
        update pl;
        //delete pl;
        test.stopTest();
        list<id> idList = new List<id>();
        ProductLineTriggerHandler pt=New productLineTriggerHandler();
        pt.setPerfOpty(idList);
        Map<Id, SObject> oldItems=new Map<Id, SObject>();
         ProductLineTriggerHandler pt1=New productLineTriggerHandler();     
        pt1.afterdelete(oldItems);
        Map<Id, SObject> oldItems1=new Map<Id, SObject>();
         ProductLineTriggerHandler pt2=New productLineTriggerHandler();     
        pt2.afterUndelete(oldItems1);
    }
    public testmethod static void accountProdLineTestOne(){
        ContactTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        AccountCreateController.isTriggerExecuting=false;        
        Product_Line__c pl = TestDataFactory.createTestProdLine();
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
       // pl.Cost__c = 100;
        pl.Product_Line__c = 'Performance Center';
        pl.Date_Booked__c = System.today()-10;
       // pl.Cost__c = 100;
        pl.Estimate__c = true;
       // pl.Opportunity__c = TestDataFactory.createOppWithAccount().Id;
        pl.Quantity__c = 3;
        Test.startTest(); 
        //pl.Quote__c = createPrimaryTestQuote().Id;
        update pl;
        
		      
        delete pl;
        //undelete pl;
        test.stopTest();
        list<id> idList = new List<id>();
        ProductLineTriggerHandler pt=New productLineTriggerHandler();
        pt.setPerfOpty(idList);
        Map<Id, SObject> oldItems=new Map<Id, SObject>();
         ProductLineTriggerHandler pt1=New productLineTriggerHandler();     
        pt1.afterdelete(oldItems);
        Map<Id, SObject> oldItems1=new Map<Id, SObject>();
         ProductLineTriggerHandler pt2=New productLineTriggerHandler();     
         pt2.afterUndelete(oldItems1);
    }
    /*public testmethod static void prsetPerfOpty(){
       /*AccountCreateController.isFirstRun= false;
        Opportunity op1=new Opportunity();
        op1.Name = 'CSM software';
        op1.Performance_Center_Product_Line__c = true;
        
        insert op1;
        Product_Line__c pl = new Product_Line__c();
        pl.Id = op1.Id;
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Cost__c = 100;
        pl.Date_Booked__c = System.today();
        pl.Product_Line__c = 'Performance center';
        pl.Estimate__c = true;
        
        update pl;
        AccountCreateController.isFirstRun= false;         
        Product_Line__c pl = TestDataFactory.createTestProdLine();
        pl.Quote__c = null;
        pl.Product_Line__c = 'Performace Center';
        test.startTest();
        update pl;
        //delete pl;
        test.stopTest();
}*/
    /*public testmethod static void plafterdelete(){
        
        AccountCreateController.isFirstRun= false; 
        Opportunity opp=new Opportunity();
        opp.Name = 'Test palce';
        opp.Performance_Center_Product_Line__c = True;
        Map<Id, SObject> oldItems = new Map<Id, SObject>();
        oldItems.put(opp.Id ,Opp);
        insert opp;
        Product_Line__c pl = new Product_Line__c();
        pl.Id = opp.Id;
        pl.Amount__c = 1000;
        pl.Product_Line_Picklist2__c = 'Anesthesia';
        pl.Cost__c = 100;
        pl.Date_Booked__c = System.today()-10;
        pl.Estimate__c = true;
        
        pl.Opportunity__c = TestDataFactory.createOppWithAccount().Id;
        update pl;
    }*/
}