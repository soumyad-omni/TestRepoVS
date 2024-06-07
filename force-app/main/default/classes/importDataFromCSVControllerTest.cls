@isTest
public class importDataFromCSVControllerTest {

		   
    	@testsetup
        static void testdatasetup(){
            Account_DataLoad__c  setting11111 = new Account_DataLoad__c ();
        setting11111.name = 'Dataload';
        setting11111.isDisabled__c = false;
        insert setting11111;
            
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
		public testmethod static void test1(){
            accounttriggerhandler.TriggerDisabled = true;
            AccountCreateController.isFirstRun= false;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.Services_Enablement_Owner__c = 'Tara Bakker';
            Account acc = TestDataFactory.createTestAccountQuotePrint();
            //acc.PIS_HIS__c = 'Allscripts';
            update acc;
            opp.AccountId = acc.id;
            opp.ExpectedInstallDate__c = System.today()+60;
            opp.OppStatus__c = 'Open';
            insert opp;
            opp.Professional_Services_Notes__c = 'xyz';
            opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
            opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
            opp.Self_Install_Desired__c = 'No';
            opp.StageName = '6 Closed Won';
            update opp;
            UserTerritory2Association ut2a = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive from UserTerritory2Association 
                                                           where User.IsActive = true and RoleInTerritory2 = 'Account Owner' LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(ut2a);
            importDataFromCSVController idf = new importDataFromCSVController(sc);
            idf.documentName = 'Test';
            idf.readSuccess = true;
            idf.disabled = true;
            idf.startDate = System.today();
            idf.endDate = System.today()+60;
            String pblob= '1234\n123456\n'+acc.SAP_Account_ID__c;
            idf.csvFileBody = blob.valueOf(pblob);
            Test.startTest();
            idf.readFromFile();
            idf.readCSVFile();
            idf.saveData();
            idf.redirectToHome();
            Test.stopTest();
    	}
    	public testmethod static void test2(){
            accounttriggerhandler.TriggerDisabled = true;
            AccountCreateController.isFirstRun= false;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.Services_Enablement_Owner__c = 'Tara Bakker';
            Account acc = TestDataFactory.createTestAccountQuotePrint();
            opp.AccountId = acc.id;
            opp.ExpectedInstallDate__c = System.today()+60;
            opp.OppStatus__c = 'Open';
            insert opp;
            //opp.StageName = '6 Closed Won';
            //update opp;
            UserTerritory2Association ut2a = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive from UserTerritory2Association 
                                                           where User.IsActive = true and RoleInTerritory2 = 'Account Owner' LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(ut2a);
            importDataFromCSVController idf = new importDataFromCSVController(sc);
            idf.documentName = 'Test';
            idf.readSuccess = true;
            idf.disabled = true;
            idf.startDate = System.today();
            idf.endDate = System.today()+10;
            String pblob= '1234\n123456\n'+acc.SAP_Account_ID__c;
            idf.csvFileBody = blob.valueOf(pblob);
            Test.startTest();
            idf.readFromFile();
            idf.readCSVFile();
            idf.saveData();
            idf.redirectToHome();
            Test.stopTest();
    	}
    	public testmethod static void test3(){
            accounttriggerhandler.TriggerDisabled = true;
            UserTerritory2Association ut2a = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive from UserTerritory2Association 
                                                           where User.IsActive = true and RoleInTerritory2 = 'Account Owner' LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(ut2a);
            importDataFromCSVController idf = new importDataFromCSVController(sc);
            idf.documentName = 'Test';
            idf.readSuccess = true;
            idf.disabled = true;
            idf.csvFileBody = null;
            Test.startTest();
            idf.readFromFile();
            Test.stopTest();
    	} 
		public testmethod static void test4(){
            accounttriggerhandler.TriggerDisabled = true;
            AccountCreateController.isFirstRun= false;
            Opportunity opp = new Opportunity();
            opp.name = 'Test Opportunity for update';
            opp.stageName = '1 Initial Sales Activity';
            opp.CloseDate = System.today()+30;
            opp.Services_Enablement_Owner__c = 'Tara Bakker';
            Account acc = TestDataFactory.createTestAccountQuotePrint();
            //acc.PIS_HIS__c = 'Allscripts';
            update acc;
            opp.AccountId = acc.id;
            opp.ExpectedInstallDate__c = System.today()+60;
            opp.OppStatus__c = 'Open';
            insert opp;
            opp.Professional_Services_Notes__c = 'xyz';
            opp.Is_the_current_Omnicell_hardware_leased__c = 'No';
            opp.CAD_Drawings_Obtained_if_Carousel_XR2__c = 'No';
            opp.Self_Install_Desired__c = 'No';
            opp.StageName = '6 Closed Won';
            update opp;
            UserTerritory2Association ut2 = [Select User.Name,RoleInTerritory2,UserId,Territory2Id,IsActive from UserTerritory2Association 
                                                           where User.IsActive = true and RoleInTerritory2 = 'Account Owner' LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(ut2);
            importDataFromCSVController idf = new importDataFromCSVController(sc);
            idf.documentName = 'Test';
            idf.readSuccess = true;
            idf.disabled = true;
            idf.startDate = System.today();
            idf.endDate = System.today()+60;
            idf.csvFileBody = null;
            Test.startTest();
            idf.readFromFile();
            idf.redirectToHome();
            Test.stopTest();
    	}
}