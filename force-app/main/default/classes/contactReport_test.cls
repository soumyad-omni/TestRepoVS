@istest
public class contactReport_test {
    
    @testsetup
    static void testdatasetup(){
        
        CastIronIntegration__c  setting = new CastIronIntegration__c ();
        setting.Name = 'CastIronIntegration';
        setting.Contact_Report__c = 'https://appconndatadev.omnicell.com/AccountSFtoSAPDEV';
        insert setting;
        
    }
    
    @istest
    private static void test1(){
        
        Test.setMock(HttpCalloutMock.class, new netValue_mock());
        
        AccountCreateController.isFirstRun= false;
        Contact con = TestDataFactory.createContactWithAccount_Integration();
        List<Contact> c = [select ID,LastName,AccountId, SAP_Contact_ID__c from Contact Where ID=:con.Id];
        
        ContactWhereUsed__c cwu = new ContactWhereUsed__c(Contact_ID__c = c[0].id, Contact__c = c[0].id);
        insert cwu;
        
        Test.StartTest();
        ContactReportSchedule sh1 = new ContactReportSchedule();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
        

}