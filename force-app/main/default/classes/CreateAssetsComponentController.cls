public class CreateAssetsComponentController {
    @AuraEnabled
    public List<fieldWrapper2> wrapperList {get;set;} 
    @AuraEnabled
    public static List<fieldWrapper2> insertData(string qlId, string jsonData) {
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(jsonData, List<fieldWrapper>.class);
        CreateAssetsComponentController obj = new CreateAssetsComponentController();
        obj.wrapperList = new List<fieldWrapper2>();
        String returnresponse ='';
        set<String> uniqueIdSet2 = new set<String>();
        Map<String,C4C_Assets__c> map1 = new Map<String,C4C_Assets__c>();
        List<Quote_Line_Assests__c> existingrecrods = new List<Quote_Line_Assests__c>();
        List<Quote_Line_Assests__c> assetstoInsert = new List<Quote_Line_Assests__c>();
        List<Quote_Line_Assests__c> assetstoInsert1 = new List<Quote_Line_Assests__c>();
        Set<Quote_Line_Assests__c> assetstoInsert2 = new Set<Quote_Line_Assests__c>();
        Quote_Line__C ql = [Select id,Quote__r.accountid from Quote_Line__C where id =: qlId];
        existingrecrods = [Select id,Quote_Line__c,Unique_ID__c,Assets__c from Quote_Line_Assests__c where Quote_Line__c =: qlId];
        String accId = ql.Quote__r.accountid;
        List<C4C_Assets__c> listAssets = new List<C4C_Assets__c>();
        Set<String> uniqId = new Set<String>();
        for(fieldWrapper wrapper: datalist) {
            uniqId.add(wrapper.uniqueId);
        }
        system.debug('rt...' +uniqId);
        listAssets = [Select id,Name,Unique_ID__c from C4C_Assets__c where Account__c =:accId AND Unique_ID__c IN:uniqId];
        System.debug('rj..' +listAssets.size());
        for(C4C_Assets__c ass: listAssets) {
            map1.put(ass.Unique_ID__c,ass);
        }
        if(existingrecrods != Null) {
            for(Quote_Line_Assests__c qla: existingrecrods) {
                uniqueIdSet2.add(qla.Unique_ID__c);
            }                
        }
        
        for(fieldWrapper wrapper: datalist) {
            fieldWrapper2 wrapper1 = new fieldWrapper2();
            if(uniqueIdSet2.contains(wrapper.uniqueId)) {
                wrapper1.uniqueValue = wrapper.uniqueId ;
                wrapper1.status = 'Relationship already Exist';
                obj.wrapperList.add(wrapper1);
            }else {
                Quote_Line_Assests__c qla = new Quote_Line_Assests__c();
                C4C_Assets__c record = map1.get(wrapper.uniqueId);
                if(record != Null) {
                    qla.Quote_Line__c = ql.id;
                    qla.Unique_ID__c = wrapper.uniqueId;
                    qla.Assets__c = record.id;
                    assetstoInsert.add(qla);
                    wrapper1.uniqueValue = wrapper.uniqueId ;
                    wrapper1.status = 'Relationship Created Successfully';
                    obj.wrapperList.add(wrapper1);
                }else {
                    wrapper1.uniqueValue = wrapper.uniqueId ;
                    wrapper1.status = 'Unique ID does not Exist';
                    obj.wrapperList.add(wrapper1);
                }
            }
        }
        
        if(assetstoInsert.size() > 0){
            assetstoInsert2.addAll(assetstoInsert);
            assetstoInsert1.addAll(assetstoInsert2);
            try {
                insert assetstoInsert1;
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                returnresponse = 'ERROR';
            }
        }
        system.debug('obj.wrapperList....' +obj.wrapperList);
        return obj.wrapperList;
    }
    
    public class fieldWrapper {
        public string uniqueId;
    }
    public class fieldWrapper2 {
        @AuraEnabled
        public string uniqueValue;
        @AuraEnabled
        public string status ;
    }
    
    public void queryRecords() {
        List<Account> acc = [Select id from Account limit 200];
        List<Opportunity> opp = [Select id from Opportunity limit 200];
        List<Quote> qq = [Select id from Quote limit 200];
        Map<id,Account> map1 = new Map<id,Account>();
        Map<id,Opportunity> map2 = new Map<id,Opportunity>();
        Map<id,Quote> map3 = new Map<id,Quote>();
        Boolean b1 = false;
        Boolean b2 = false;
        Boolean b3 = false;
        for(Account a : acc) {
            if(a != Null) {
                map1.put(a.id,a);
            } 
        }
        for(Opportunity a : opp) {
            if(a != Null) {
                map2.put(a.id,a);
            }
        }
        for(Quote a : qq) {
            if(a != Null) {
                map3.put(a.id,a);
            }
        }
        for(Account a : acc) {
            Account ac = map1.get(a.id);
            if(ac != Null) {
                b1 = true;
            }
        }
        for(Account a : acc) {
            Account ac = map1.get(a.id);
            if(ac != Null) {
                b2 = true;
            }
        }
        for(Account a : acc) {
            Account ac = map1.get(a.id);
            if(ac != Null) {
                b3 = true;
            }
        }
    }
}