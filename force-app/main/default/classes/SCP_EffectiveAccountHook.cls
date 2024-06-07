global without sharing class SCP_EffectiveAccountHook extends ccrz.cc_hk_EffectiveAccount {
    global override Map<String,Object> fetchAccounts(Map<String,Object> inputData) {
        
        for(String inp : inputData.keySet()){
            ccrz.ccLog.log('inp key---- : ' + inp+ '  inp val ----: '+String.valueOf(inputData.get(inp)));
        }   
       
       Map<String,Object> inputDataUpdate;
       if(!Test.isRunningTest())
           inputDataUpdate = super.fetchAccounts(inputData);
       else
           inputDataUpdate = inputData;
       List<ccrz.cc_bean_EffectiveAccount> beanAccList = (List<ccrz.cc_bean_EffectiveAccount>)inputDataUpdate.get('EffectiveAccounts');
       Set<Id> deletedAccs = new Set<Id>();
       for(Account acc : [Select id from Account where IsDeleted__c = true OR Validation_Status__c = 'Invalid']){
           deletedAccs.add(acc.id);
       }
       for(Integer i= beanAccList.size()-1 ; i>=0 ;--i){
           if(deletedAccs.contains(beanAccList[i].sfid))
               beanAccList.remove(i);
       }
       Set<Id> accsIds = new Set<Id>();
       for(Integer i= beanAccList.size()-1 ; i>=0 ;--i){
           accsIds.add(beanAccList[i].sfid);
       }
       Map<Id,Account> mapAccObject = new Map<ID, Account>([SELECT Id,PO_BOX__c,SAP_Customer_Number__c FROM Account where Id in:accsIds]);
       for(Integer i= beanAccList.size()-1 ; i>=0 ;--i){
           Account accObj = mapAccObject.get(Id.valueOf(beanAccList[i].sfid));
           Map<String, Object> tempMap = new Map<String, Object>();
           tempMap.put('poBox',accObj.PO_BOX__c != null ? accObj.PO_BOX__c : '');
		   tempMap.put('csnNumber',accObj.SAP_Customer_Number__c != null ? accObj.SAP_Customer_Number__c : '');
           beanAccList[i].extrinsic = tempMap;
       }
       ccrz.ccLog.log('beanAccList---- : ' + beanAccList[0]);
       inputDataUpdate.put('EffectiveAccounts',beanAccList);
       inputDataUpdate.put('AddressSource','Account');
       return inputDataUpdate;
   }
   
}