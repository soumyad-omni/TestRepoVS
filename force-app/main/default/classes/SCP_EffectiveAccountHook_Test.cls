@istest
public class SCP_EffectiveAccountHook_Test {
    @istest
    Public static void hookTestMethod(){
        SCP_TestDataFactory.createCastIron();
      
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        acc.IsDeleted__c = false;
        acc.Validation_Status__c = 'Validated';
        insert acc;
        
        ccrz.cc_bean_EffectiveAccount mockAccount = new ccrz.cc_bean_EffectiveAccount(acc);
        List<ccrz.cc_bean_EffectiveAccount> listMock = new List<ccrz.cc_bean_EffectiveAccount>();
        listMock.add(mockAccount);
         
        Map<string,Object> inputData=new Map<string,Object>(); 
        inputData.put('EffectiveAccounts',listMock);
        SCP_EffectiveAccountHook hk =  new SCP_EffectiveAccountHook();
        hk.fetchAccounts(inputData);
    }
    
     @istest
    Public static void hookTestMethod1(){
        SCP_TestDataFactory.createCastIron();
      
        Account acc = SCP_TestDataFactory.createAccounts(1)[0];
        acc.IsDeleted__c = false;
        acc.Validation_Status__c = 'Validated'; 
        insert acc;
        
        ccrz.cc_bean_EffectiveAccount mockAccount = new ccrz.cc_bean_EffectiveAccount(acc);
        List<ccrz.cc_bean_EffectiveAccount> listMock = new List<ccrz.cc_bean_EffectiveAccount>();
        listMock.add(mockAccount);
        system.debug('###listMock-- '+listMock);
        Map<string,Object> inputData=new Map<string,Object>(); 
        inputData.put('EffectiveAccounts',listMock);
        SCP_EffectiveAccountHook hk =  new SCP_EffectiveAccountHook();
        hk.fetchAccounts(inputData);
    }
   }