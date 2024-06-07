global class upHasOppDeleteOpp {

    public static void updatefield(List<Target_Initiative_Opportunity__c> target){
        for(Target_Initiative_Opportunity__c oppid:target){
                
        string opp= oppid.Opportunity__c;
        string tarinit = oppid.Target_Initiative__c;
        List<Target_Initiative_Account__c> tiopList = new List<Target_Initiative_Account__c>();
        tiopList = [select Account__r.NAME from Target_Initiative_Account__c where Target_Initiative__r.id= :tarinit];
        
        string oppaccid = [select AccountId from opportunity where id= :opp].AccountId;
        system.debug('tiopList....'+tiopList);
        system.debug('oppaccid....'+oppaccid);
        List<Target_Initiative_Account__c> tiaList = new List<Target_Initiative_Account__c>();
        tiaList = [select id,Has_Opportunities__c,Account__c from Target_Initiative_Account__c where Account__r.Id= :oppaccid];
        set<Target_Initiative_Account__c> updatetiaList = new set<Target_Initiative_Account__c>();
        List<Target_Initiative_Account__c> updatetiaList1 = new List<Target_Initiative_Account__c>();
        
        List<Target_Initiative_Opportunity__c> opList = new List<Target_Initiative_Opportunity__c>();
        system.debug('tarinit ...'+tarinit);
        opList = [select Opportunity__r.Account.NAME from Target_Initiative_Opportunity__c where Target_Initiative__r.id= :tarinit];
        
        List<string> opList1 = new List<string>();
           
           //IBA-3005 Updated the For loop 
        List<Id> OppIds = new List<id>();
            
        for(Target_Initiative_Opportunity__c o: opList)
        {
          //  opList1.add([select AccountId from opportunity where id= :o.Opportunity__c].AccountId);
          OppIds.add(o.Opportunity__c);
        }
         List<Opportunity> Oppslist=  [select AccountId from opportunity where id= :OppIds];
          
            
            for(Opportunity o: Oppslist)
        {
          //  opList1.add([select AccountId from opportunity where id= :o.Opportunity__c].AccountId);
          opList1.add(o.AccountId);   //IBA-3005 changes End 
        }
        system.debug('opList ...'+opList);
        system.debug('opList ...'+opList1);
        integer n=0;
        
        for(String tt: opList1)
        {
            if(tt == oppaccid)
            {
                n = 1;
            }
        }
        
        if(n==0){
        for(Target_Initiative_Account__c t: tiaList)
              {
                for(Target_Initiative_Account__c a: tiopList)
                {            
                if(oppaccid == a.Account__c)
                {
                t.Has_Opportunities__c= false;
                system.debug('t.Has_Opportunities__c...'+t.Has_Opportunities__c);
                updatetiaList.add(t);
                }
                }
              }            
            updatetiaList1.addall(updatetiaList);
            update updatetiaList1;
        }
       
    }
    }
    
}