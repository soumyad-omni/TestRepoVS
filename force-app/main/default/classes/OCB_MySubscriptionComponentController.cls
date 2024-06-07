global class OCB_MySubscriptionComponentController {
	
    global OCB_MySubscriptionComponentController(){
        
    }
    @RemoteAction
    global static ccrz.cc_RemoteActionResult getAllSubscriptions(ccrz.cc_RemoteActionContext ctx){
         ccrz.cc_RemoteActionResult ccRemoteActionResult = ccrz.cc_CallContext.init(ctx);
         ccRemoteActionResult.success = false;
         Map<String,object> outputMap= new Map<String,Object>();
        
         try{
            String accountId = '';
            accountId = ccrz.cc_CallContext.effAccountId;
            String topParentId = '';
            List<Account> efftiveacc = [Select Pardot_Top_Level_Parent_Id__c From Account Where id = :accountId];
            if(efftiveacc.size()>0){
                 topParentId = efftiveacc[0].Pardot_Top_Level_Parent_Id__c;
            }
            List<Account> accAll = [Select id From Account Where Pardot_Top_Level_Parent_Id__c=: topParentId];
            Set<String> primAccSet = new Set<String>();
            for(Account ac : accAll){
                 primAccSet.add(ac.id);
            }
            List<ccrz__E_Subscription__c> AllSubList = [Select Id,Name,ccrz__SubscriptionProduct__r.Name,ccrz__InstallmentNextDate__c,ccrz__RecurringPrice__c,ccrz__SubscriptionStatus__c,ccrz__CCOrder__r.ccrz__BuyerFirstName__c,ccrz__CCOrder__r.ccrz__BuyerLastName__c,ccrz__Account__r.SAP_Customer_Number__c,ccrz__Account__r.Name From ccrz__E_Subscription__c Where ccrz__EffectiveAccountID__c IN :primAccSet Order By CreatedDate DESC];
            ccRemoteActionResult.success = true; 
            outputMap.put('AllSubList',AllSubList); 
        }
        catch(Exception e) {
            ccRemoteActionResult.success = false; 
        }
        ccRemoteActionResult.data = outputMap;
        return ccRemoteActionResult ;
    }
}