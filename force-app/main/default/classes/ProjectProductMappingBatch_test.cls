@isTest
public class ProjectProductMappingBatch_test {
    public static Id recTypeAccount1 = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Competitor' LIMIT 1].Id;
    
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
         /*Group grp = new Group();
        grp.Name= 'Professional Services';
        grp.Type = 'Regular';
        insert grp;*/
        Project_Product_Mapping__c pm = new Project_Product_Mapping__c();
        pm.Portfolio_Segment1__c = 'MA Consumable';
        pm.Project_Product_Mapping__c = 'Consumables';
        insert pm;
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        usertriggerhandler.triggerdisabled = true;
                        String orgId=UserInfo.getOrganizationId(); 
                        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
                        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
                        String uniqueName=orgId+dateString+RandomId; 
                        User uu=new User(firstname = 'ABC', 
                                         lastName = 'XYZ', 
                                         email = uniqueName + '@test' + orgId + '.org', 
                                         Username = uniqueName + '@test' + orgId + '.org', 
                                         EmailEncodingKey = 'ISO-8859-1', 
                                         Alias = uniqueName.substring(18, 23), 
                                         TimeZoneSidKey = 'America/Los_Angeles', 
                                         LocaleSidKey = 'en_US', 
                                         LanguageLocaleKey = 'en_US', 
                                         ProfileId = pf.Id
                                        );
        insert uu;
        GroupMember gMem = new GroupMember();
        gMem.UserOrGroupId = uu.id;
        ContactTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDisabled = true;
        QuoteTriggerHandler.TriggerDisabled = True;
        QuoteLineTriggerHandler.TriggerDisabled = True;
        AccountCreateController.isFirstRun= false;
        AccountCreateController.isTriggerExecuting=false;        
        Product_Line__c pl = TestDataFactory.createTestProdLine();
        pl.Quote__c = null;
        pl.Product_Line__c = 'MA Consumable';
        test.startTest();
        update pl;
        
        
        ProjectProductMappingBatch_Scheduler sch1 = new ProjectProductMappingBatch_Scheduler();
        
        String sch = '0 0 1 * * ?'; 
        system.schedule('Test Product Line Batch', sch, sch1);
        
        test.stopTest();
        //ProjectProductMappingBatch b = new ProjectProductMappingBatch();
        //Database.executeBatch(b,100);
    }
    
    
}