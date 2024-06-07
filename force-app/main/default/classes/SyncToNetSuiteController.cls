public with sharing class SyncToNetSuiteController {

    @AuraEnabled(cacheable=true)
    public static Boolean getButtonVisibility(String quoteId){
        Set<String> oppRTforNetSuite = new Set<String>();
        List<NetSuite_Opp_RecordType__c> allnetsuiteRecType = NetSuite_Opp_RecordType__c.getall().values();
        for(NetSuite_Opp_RecordType__c rdType: allnetsuiteRecType){
            oppRTforNetSuite.add(rdType.Name);
        }
        Set<String> quoteOrderTypeforNetSuite = new Set<String>();
        List<NetSuite_Quote_Order_Type__c> allnetsuitequoteOrderTypes = NetSuite_Quote_Order_Type__c.getall().values();
        for(NetSuite_Quote_Order_Type__c qtOrdType: allnetsuitequoteOrderTypes){
            quoteOrderTypeforNetSuite.add(qtOrdType.Name);
        }
        List<Quote> quotesendToNetSuite = [Select Id From Quote Where Id =:quoteId
                                                               AND Opportunity.RecordType.Name IN :oppRTforNetSuite AND NetSuite_ID__c = '' 
                                                               AND Status = 'E0024' AND Opportunity.OpportunityGroup__c = 'Advanced Services' 
                                                               AND Order_Type__c IN :quoteOrderTypeforNetSuite AND Opportunity.StageName = '6 Closed Won' 
                                                               AND ECC_Sales_Order_Number__c != '']; 
        
        Set<String> profilesHaveAccess = new Set<String>();
        List<NetSuite_Button_Visibility__c> allprofiles = NetSuite_Button_Visibility__c.getall().values();
        for(NetSuite_Button_Visibility__c prof: allprofiles){
            profilesHaveAccess.add(prof.Profile_Name__c);
        }
        
        String currentUserProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        if(profilesHaveAccess.contains(currentUserProfileName) && quotesendToNetSuite.size()>0){
            return true;
        }
        else {
            return false;
        }        
    }

    @AuraEnabled
    public static resultWrap sendToNetSuite(String quoteId){
        resultWrap result = new resultWrap();
        try {
            Set<Id> quoteIds = new Set<Id>();
            System.debug(quoteId);
            quoteIds.add(quoteId);
            system.enqueueJob(new OrderInfoSendToNetSuiteQueueable(quoteIds));
            result.success = true;
            result.message = System.Label.NetSuite_Success_Message;
        } catch (Exception e) {
            result.success = false;
            result.message = e.getMessage();
        }
        System.debug(result);
        return result;
    }

    public class resultWrap{
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String message;
    }
}