global class ProjectProductMappingBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query='';
        //query = 'Select Id, Name, Opportunity__c, Category__c, Project_Product_Mapping__c,	Opportunity_Segment__c From Opportunity Where OppStatus__c != \'Lost\' And RecordType.Name=\'U.S & Canada Opportunity\'  ';
        query = 'Select Id, Name, Opportunity__c, Category__c, Project_Product_Mapping__c, Opportunity_Segment__c From Opportunity Where OppStatus__c != \'Lost\' And RecordType.DeveloperName IN (\'NAA_Opportunity\',\'US_Canada_Advanced_Services\',\'US_Canada_Specialty\')  '; //IBA-5992
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        List<Project_Product_Mapping__c> ppl=[Select Id, Portfolio_Segment1__c, Project_Product_Mapping__c From Project_Product_Mapping__c];
        Map<String, Project_Product_Mapping__c> ppm = new  Map<String, Project_Product_Mapping__c>();
        for(Project_Product_Mapping__c p: ppl){
            ppm.put(p.Portfolio_Segment1__c, p);
        }
        
        Set<Id> sid =new Set<Id>();
        for(Opportunity o: oppList){
            sid.add(o.Id);
        }
        List<Product_Line__c> opppl = [Select Id, Portfolio_Segment__c,Opportunity__r.Id From Product_Line__c Where Opportunity__r.Id=:sid];
        
        Map<Id, List<Product_Line__c>> spl= new Map<Id, List<Product_Line__c>>();
        for(Product_Line__c pc: opppl){
            if(spl.ContainsKey(pc.Opportunity__c)){
                List<Product_Line__c> Prol= spl.get(pc.Opportunity__c);
                prol.Add(pc);
                spl.put(pc.Opportunity__c, prol);
            }
            else{
                spl.put(pc.Opportunity__c, new List<Product_Line__c>{pc});
            }
            
        }
        
        list<opportunity> updateOpp = new list<opportunity>();
        
        for(Opportunity onew: oppList){
            string oldval = onew.Project_Product_Mapping__c;
            Set<String> sst= new Set<String>();
            if(spl.ContainsKey(onew.Id)){
                List<Product_Line__c> prol= spl.get(onew.Id);
                if(!prol.isEmpty() && prol != null){
                    
                    for(Product_Line__c pl: prol){  
                        if(ppm.ContainsKey(pl.Portfolio_Segment__c)){
                            Project_Product_Mapping__c pmc= ppm.get(pl.Portfolio_Segment__c);
                            if(pmc.Project_Product_Mapping__c != null)
                            sst.add(pmc.Project_Product_Mapping__c);
                        }
                        
                    }
                    if(sst.Size()==1){
                        
                        for(String s: sst){
                            onew.Project_Product_Mapping__c=s;
                        }            
                    }else if(sst.Size()>1){
                        onew.Project_Product_Mapping__c='Multi-Solution';
                    }
                    else{
                        onew.Project_Product_Mapping__c=null;
                    }
                    
                    if(oldval != onew.Project_Product_Mapping__c){
                        updateOpp.add(onew);
                    }
                }
            }
        }
        
        if(updateOpp.size() > 0){
            OpportunityTriggerHandler.TriggerDisabled = True;
            database.update(updateOpp,false);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}