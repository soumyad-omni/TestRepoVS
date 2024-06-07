public with sharing class ccShipmentTriggerHandler {
    
    Public Static void beforeInsertEve(List<ccrz__E_OrderShipment__c> TriggerNewList){
        Id currentUserProfileId = UserInfo.getProfileId();
        String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name;
        Set<id> contid = new Set<id>();
        list<string> orderId = new list<string>();
        for(ccrz__E_OrderShipment__c shp:TriggerNewList){
            orderId.add(shp.ccrz__Order__c);
        }
        list<ccrz__E_Order__c> orderL = [select id, ccrz__OriginatedCart__c,ccrz__Contact__c from ccrz__E_Order__c where id =:orderId];
        for(ccrz__E_Order__c order:orderL){
            if(order.ccrz__OriginatedCart__c == null && profileName == 'API Only' ){
                contid.add(order.ccrz__Contact__c);
            }
            
            
        }
        map<id,contact> contactM = new map<id,contact>();
        if(contid.size()>0){
            for(contact objCS : [select id,email from contact where id =:contid]){
                contactM.put(objCS.id, objCS);
            }
            
        }
        list<ccrz__E_Order__c> ord = new list<ccrz__E_Order__c>();
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(ccrz__E_Order__c order:orderL){
            
            if(order.ccrz__OriginatedCart__c == null && profileName == 'API Only' && contactM.containskey(order.ccrz__Contact__c) ){
                ord.add(order);
            } 
        }
        if(ord.size()>0){
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 1); 
            String ss = String.valueOf(Datetime.now().second());
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            confrimationEmailECC sch = new confrimationEmailECC(ord,contactM);
            System.schedule('Ecc order Shipment email', nextFireTime ,sch);
        }
    }
    
    
}