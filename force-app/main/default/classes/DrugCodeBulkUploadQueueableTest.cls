@isTest
public class DrugCodeBulkUploadQueueableTest {
    @testSetup 
    public static void dataSetup(){
        List<ccrz__E_Attribute__c> attrList = new List<ccrz__E_Attribute__c>();
        ccrz__E_Attribute__c drugparent = new ccrz__E_Attribute__c(Name = 'NDC',ccrz__AttributeID__c = 'NDC',ccrz__DisplayName__c = 'NDC',
                                                                   ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                                   ccrz__Sequence__c = 1);
        attrList.add(drugparent);
        ccrz__E_Attribute__c machineparent = new ccrz__E_Attribute__c(Name = 'MACHINE',ccrz__AttributeID__c = 'MACHINE',ccrz__DisplayName__c = 'MACHINE',
                                                                      ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                                      ccrz__Sequence__c = 2);
        attrList.add(machineparent);
        ccrz__E_Attribute__c typeparent = new ccrz__E_Attribute__c(Name = 'TYPE',ccrz__AttributeID__c = 'TYPE',ccrz__DisplayName__c = 'TYPE',
                                                                      ccrz__EffectiveStart__c = Date.today(),ccrz__EffectiveEnd__c = Date.today()+90,
                                                                      ccrz__Sequence__c = 3);
        attrList.add(typeparent);
        insert attrList;
        
        Account acc = new Account(name='AccountForPacMed2',Account_role__c='ZCSN',
                                  RecordtypeId = TestDataFactory.recTypeAccount,
                                  Account_Status__c = 'Active',IsDeleted__c = false,Facility_Type__c='Short-term Acute Care Hospital',Validation_Status__c = 'Validated');
        acc.BillingCountryCode = 'US';
        acc.ccrz__E_AccountGroup__c = SCP_TestDataFactory.createAccountGroup('IDN-BA/GPO-N0','NEW-CALIB').Id;
        AccountTriggerHandler.TriggerDisabled = True;
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact2',AccountId = acc.id);
        ContactTriggerHandler.TriggerDisabled = True;
        insert con;
        ccrz__E_ContactAddr__c contAdd = SCP_TestDataFactory.getContactAddress();
        insert contAdd;
        ccrz__E_Attribute__c Machine = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'MACHINE'];
        ccrz__E_Attribute__c Type = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'TYPE'];
        ccrz__E_Attribute__c NDC = [Select Id From ccrz__E_Attribute__c Where ccrz__AttributeID__c = 'NDC'];
        ccrz__E_Attribute__c MachineDef = SCP_TestDataFactory.childccAttribute('DEFAULT',Machine.Id,11);
        ccrz__E_Attribute__c Canister = SCP_TestDataFactory.childccAttribute('CANISTER',Type.Id,21);
        ccrz__E_Attribute__c NDCDef = SCP_TestDataFactory.childccAttribute('DEFAULT',NDC.Id,31);
        DrugCode__c drgCode = SCP_TestDataFactory.createDrugCode('0000123456788');
        Machine__c machineData = SCP_TestDataFactory.createMachine(acc,'PACMED34349','PACMED','Canister','E2 Gen 1');
        Machine__c machineData2 = SCP_TestDataFactory.createMachine(acc,'OD400','OD400','RFID','E2 Gen 2');
        Apex_Email_Data__c emaildata = new Apex_Email_Data__c();
        emaildata.Name = 'DrugCodeBulkUpload';
        emaildata.Body__c = 'body';
        emaildata.Subject__c = 'subject';
        emaildata.CC__c = 'abc@abc.com';
        insert emaildata; 
    }
    
    @isTest
    public static void testMethod1(){
        OmnicellProductDetailController controller = new OmnicellProductDetailController() ;
        Account acc = [Select Id,Name From Account Where Name = 'AccountForPacMed2' Limit 1];  
        Contact con = [Select Id From Contact Where AccountId = :acc.Id];  
        ccrz__E_ContactAddr__c contAdd = [Select Id From ccrz__E_ContactAddr__c Limit 1];
        List<ccrz__E_Cart__c> activeCart = SCP_TestDataFactory.createCarts(1,acc,con,contAdd);
        insert activeCart[0];
        activeCart[0].ccrz__EncryptedId__c = activeCart[0].Id;
        activeCart[0].ccrz__EffectiveAccountID__c=acc.Id;
        update activeCart[0];
        
        Map<String, Object> inputData = new Map<String, Object>();
        Map<String, Object> attributeList = new Map<String, Object>();
        
        
        Test.startTest();
            PageReference myVfPage = Page.OmniCellProductDetail;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('cartID',activeCart[0].Id);
            ApexPages.currentPage().getParameters().put('effectiveAccount',acc.Id);
            ApexPages.currentPage().getParameters().put('sku','NEW-CALIB');
            ccrz.cc_RemoteActionContext ctx = new ccrz.cc_RemoteActionContext();            
            List<CSVData> cartData = new List<CSVData>();
        	CSVData obj = new CSVData();
        	obj.Machine = 'PACMED34349';
        	obj.MachineType = 'Canister';
        	obj.DrugCode = '0000123456788';
        	obj.Quantity = '1';
        	cartData.add(obj);
            string jsonstringcartData = JSON.serialize(cartData);
            OmnicellProductDetailController.bulkUpload(ctx, jsonstringcartData);
        Test.stopTest();    
    }
    public class CSVData{
        String Machine;
        String MachineType;
        String DrugCode;
        String Quantity;
        public CSVData(){
            this.Machine = Machine;
            this.MachineType = MachineType;
            this.DrugCode = DrugCode;
            this.Quantity = Quantity;
        }
    }
}