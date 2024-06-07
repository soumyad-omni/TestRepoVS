global  class SCP_cc_hk_Subscriptions  extends ccrz.cc_hk_Subscriptions{

global override Map<String,Object> fetchSubscription(Map<String,Object> inputData) {
 
      Map<String,Object> ccMap;
      List<Map<String,Object>> subs4 = new List<Map<String,Object>>();
      List<String> orderIds = new List<String>();
      Map<String,Map<String,Object>> additionalData = new Map<String,Map<String,Object>>();
       
     
     if (!Test.isRunningTest()){
            ccMap = super.fetchSubscription(inputData);
      }else{
          ccMap=inputData;
      } 
      
      
     // ccMap = super.fetchSubscription(inputData);    
      Map<String,Object> subs = (Map<String,Object>)ccMap.get('subscription');
      
      if(subs.get('orderHistory')!=null){
      subs4 = (List<Map<String,Object>>)subs.get('orderHistory');
      
      for(Map<String, Object>order : subs4) {
            orderIds.add(order.get('sfid').toString());
        } 
     }
     if(!orderIds.isempty()){
      String query = 'SELECT Id,SAP_Order_Number__c FROM ccrz__E_Order__c WHERE Id IN :orderIds';
      List<ccrz__E_Order__c> OrderObjects =  Database.query(query);
      for(ccrz__E_Order__c t: OrderObjects) {
            Map<String, Object> tData = new Map<String, Object>{
                    'SAPOrderNumber' => t.SAP_Order_Number__c 
            };
            additionalData.put(t.Id, tData);
          }
        
        
          for (Integer i = 0; i < subs4.size() ; i++) {
            Map<String, Object> OrderHistory= subs4[i];
            String key = OrderHistory.get('sfid').toString();

            if(additionalData.containsKey(key)) {
                OrderHistory.putAll(additionalData.get(key));
            }
        }
        ccMap.put('subs4',subs4);
     }
     
  return ccMap;
}
}