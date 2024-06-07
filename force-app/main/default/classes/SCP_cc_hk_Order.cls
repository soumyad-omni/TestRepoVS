global with sharing class SCP_cc_hk_Order extends ccrz.cc_hk_Order{

    global virtual override Map<String, Object> fetchOrderHistory(Map<String, Object> inputData){
        if (!Test.isRunningTest()){
          inputData = super.fetchOrderHistory(inputData);
        }
        List<ccrz.cc_bean_MockOrder> mockOrderList = (List<ccrz.cc_bean_MockOrder>)inputData.get('ORDERS');
        List<ccrz.cc_bean_MockOrder> cc_bean_MockOrderupdated = new List<ccrz.cc_bean_MockOrder> (); 
        Set<String> orderids = new Set<String>(); 
        for(ccrz.cc_bean_MockOrder beanMock : mockOrderList){
            orderIds.add(beanMock.sfid);
        }
        Set<String> canisterCassetteOrd = new set<String>();
        List<ccrz__E_OrderItem__c> orderItemList = Database.query('Select Id,ccrz__Order__c,ccrz__Product__c,ccrz__Product__r.ccrz__SKU__c From ccrz__E_OrderItem__c Where ccrz__Order__c IN:orderIds');
        for(ccrz__E_OrderItem__c ordItem :orderItemList){
            if(ordItem.ccrz__Product__r.ccrz__SKU__c == 'NEW-CALIB' || ordItem.ccrz__Product__r.ccrz__SKU__c == 'RECALIB' 
               || ordItem.ccrz__Product__r.ccrz__SKU__c == 'REPAIR'){
                canisterCassetteOrd.add(ordItem.ccrz__Order__c);
            }
        }
        Map<Id,ccrz__E_Order__c> orderMap = new Map<Id,ccrz__E_Order__c>([SELECT Id,SAP_Order_Number__c,PO_Number__c,(select Id from ccrz__E_OrderItems__r) From ccrz__E_Order__c WHERE ID IN:orderIds]);
        
        //System.debug('###'+canisterCassetteOrd.size());
        for(ccrz.cc_bean_MockOrder beanMock : mockOrderList){
            //System.debug('###'+beanMock.sfid);
            //System.debug('###'+beanMock.canReOrder);
            if(canisterCassetteOrd.contains(beanMock.sfid)){
            	beanMock.canReOrder = false;    
            }
            //beanMock.canReOrder = false;
            if(orderMap.containsKey(beanMock.sfid)){
                Map<String, String> newMap = new Map<String, String>();
                newMap.put('SAPOrderNumber',orderMap.get(beanMock.sfid).SAP_Order_Number__c);
                newMap.put('PONumber',orderMap.get(beanMock.sfid).PO_Number__c);
                beanMock.extrinsic = newMap;
            }
            cc_bean_MockOrderupdated.add(beanMock);
        }
        inputData.put(ccrz.cc_hk_Order.PARAM_ORDERS,cc_bean_MockOrderupdated);
        return inputData;        

    }
    
    global virtual override Map<String, Object> reorder(Map<String, Object> inputData){
        inputData = super.reorder(inputData);
        System.debug('***hkreorder'+inputData);
        return inputData;
    }
    public static Boolean checkCanisterCassetteItem(String orderId){
        Boolean hasCanisterCassetteItem = false;
        return hasCanisterCassetteItem;
    }




}