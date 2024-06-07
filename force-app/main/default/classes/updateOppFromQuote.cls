global class updateOppFromQuote implements database.Batchable<sobject>{
    
    public database.QueryLocator start(database.BatchableContext bc){
        return database.getQueryLocator('select id, Opportunity__c, Project_Name__c, Ship_to_Account_Name_ML__c from Update_Opportunity_From_Quote__c');
    }
    
    public void execute(database.BatchableContext bc, list<Update_Opportunity_From_Quote__c> oqList){
        
        list<id> oppid = new list<id>();
        map<id,Update_Opportunity_From_Quote__c> oqMap = new map<id,Update_Opportunity_From_Quote__c>();
        for(Update_Opportunity_From_Quote__c oq:oqList){
            oppid.add(oq.Opportunity__c);
            oqMap.put(oq.Opportunity__c,oq);
        }
        
        list<opportunity> oppList = [select id, Project_Name__c, Ship_to_Account_Name_ML__c from opportunity where id =: oppid];
        list<Update_Opportunity_From_Quote__c> oq2delete = new list<Update_Opportunity_From_Quote__c>();
        for(opportunity opp:oppList){
            Update_Opportunity_From_Quote__c oq = oqMap.get(opp.id);
            
            if(oq.Project_Name__c == 'blank'){
                opp.Project_Name__c = '';
            }
            if(oq.Ship_to_Account_Name_ML__c != null){
                opp.Ship_to_Account_Name_ML__c = oq.Ship_to_Account_Name_ML__c;
            }
            oq2delete.add(oq);
        }
        opportunitytriggerhandler.triggerdisabled = true;
        update oppList;
        delete oq2delete;
        
    }
    
    public void finish(database.BatchableContext bc){
        
    }

}