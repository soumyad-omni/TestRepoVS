global class IsNACAccountFieldUpdate_Batch implements Database.Batchable<sObject>{
    
    global String query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        String NAARecTypeId = SObjectType.Account.getRecordTypeInfosByName().get('US & Canada Customer').getRecordTypeId();
        query = 'Select Id, Name, Facility_Type__c, Territory_Assignment_Criteria__c, Segment__c from Account where Isdeleted__c = false and RecordTypeId = :NAARecTypeId and Validation_Status__c = \'Validated\' and Account_Territory__c != null';
        system.debug('query: '+ query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        Map<Id,Account> childAccounts = new Map<Id,Account>();
        try{
            for(Account a: accountList){
                   if((a.Facility_Type__c != 'Children\'s Hospital' 
                   && a.Facility_Type__c != 'Critical Access'
                   && a.Facility_Type__c != 'Department of Defense'
                   && a.Facility_Type__c != 'Health System'
                   && a.Facility_Type__c != 'VA Hospital'
                   && a.Facility_Type__c != 'Short-term Acute Care Hospital') 
                   || (a.Territory_Assignment_Criteria__c == 'NAC Health System Owned'
                   || a.Territory_Assignment_Criteria__c == 'NAC Health System'
                   || a.Territory_Assignment_Criteria__c == 'NAC CSE'))
                   {
                           system.debug('#@a.Territory_Assignment_Criteria__c :' + a.Territory_Assignment_Criteria__c );
                           system.debug('#@a.Facility_Type__c :' + a.Facility_Type__c );
                           if(a.Segment__c!=null)
                           {
                               List<String> selections = a.Segment__c.split(';');
                               if(!selections.contains('Top Accounts')){
                                    system.debug('#@Is_NAC_Account__c : yes');  
                                    a.Is_NAC_Account__c = 'Yes';
                               }else{
                                    system.debug('Top #@Is_NAC_Account__c : no');
                                    a.Is_NAC_Account__c = 'No';  
                               }
                           }else{
                               system.debug('#Segment Eq Null@Is_NAC_Account__c : Yes');
                               a.Is_NAC_Account__c = 'Yes';  
                           }
                         
                }else{
                         system.debug('#Rest@Is_NAC_Account__c : no');
                         a.Is_NAC_Account__c = 'No';   
                }
                
                childAccounts.put(a.Id,a);
            }
            
            if(!childAccounts.isEmpty()){
               system.debug('Update');
               AccountTriggerHandler.TriggerDisabled = true;
               // Database.update(childAccounts, false);
               update childAccounts.values();
            }
        }catch(Exception e){
            throw e;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}