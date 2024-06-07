@isTest
public class DefaultOpportunityTeamBatchClass_Test {
    @testsetup
    static void testdatasetup(){
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
        
        AccountCreateController.isFirstRun= false;
        Opportunity opp = new Opportunity();
        opp.name = 'Test Opportunity for update';
        opp.stageName = '1 Initial Sales Activity';
        opp.CloseDate = System.today()+30;
        Account acc = TestDataFactory.createTestAccountQuotePrint();
        //Account acc = new Account(name='t'+system.now().millisecond()+math.round(math.random()*10000),Account_role__c='ZCSN',Account_Territory__c='WA, BC',RecordTypeid=recTypeAccount);
        //insert acc;
        opp.AccountId = acc.id;
        opp.OppStatus__c = 'Open';
        insert opp;   
    }
    public testmethod static void childopty2(){
        User us=TestDataFactory.createUser(true,'testUser','SalesQuota');
        System.runAs(us){
            AccountCreateController.isFirstRun= false; 
            test.startTest();
            Quote qt=TestDataFactory.createTestQuote_Integration();
            qt.Primary_Quote__c=TRUE;
            update qt;
            Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE ID =: qt.OpportunityId LIMIT 1 ];
            opp.PrimaryQuote__c=qt.Id;
            Product_segment__c ps=new Product_segment__c(Quote__c = qt.Id,Opportunity__c= opp.Id, product_segment__c = 'Performance Center');
            insert ps;
            
            OpportunityTeamMember otm = new OpportunityTeamMember (OpportunityId = opp.id,UserId = us.id,TeamMemberRole = 'Sales Rep');
            insert otm;
            //opp.AccountId = TestDataFactory.createTestAccountQuotePrint().id;
            
            update opp;
            DefaultOpportunityTeamButtonController.scheduleBatch();
            //Database.executeBatch(new DefaultOpportunityTeamBatchClass());
            test.stopTest();
        }
    }
}