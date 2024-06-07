global class contactwhereusednewbatch implements Database.Batchable<sobject> {
   
   global Database.Querylocator start (Database.BatchableContext BC) {
      return Database.getQueryLocator('SELECT id FROM Contact');
   }
   
   
   global void execute (Database.BatchableContext BC, List<Contact> scope) {
       
       list<quote> qt = [select id,Shipping_Contact__c from quote where Shipping_Contact__c =: scope];
       list<OpportunityContactRole> opp = [SELECT ContactId FROM OpportunityContactRole WHERE ContactId = : scope];
       list<CampaignMember> cm = [SELECT ContactId FROM CampaignMember WHERE ContactId = : scope];
       list<ContactWhereUsed__c> cwuexist1 = [select id,Contact__c,UsedInQuote__c,UsedInOpportunity__c,UsedInCampaignMember__c,Used_in_B2B_Order__c,Used_in_B2B_User__c from ContactWhereUsed__c where Contact__c =: scope];//iba-4493
       
       //iba-4493 start
       list<ccrz__E_Order__c> ord = [select id,ccrz__Contact__c from ccrz__E_Order__c where ccrz__Contact__c =: scope];
       list<user> usr = [select id,ContactId from user where ContactId =: scope];
       
       map<string,list<ccrz__E_Order__c>> ordMap = new map<string,list<ccrz__E_Order__c>>();
       
       for(ccrz__E_Order__c o : ord){           
           ordMap.put(o.ccrz__Contact__c, new List<ccrz__E_Order__c>{o});            
       }
       
       map<string,list<user>> usrMap = new map<string,list<user>>();
       
       for(user u : usr){           
           usrMap.put(u.ContactId, new List<user>{u});            
       }
       //iba-4493 end
       
       map<string,list<ContactWhereUsed__c>> cwuexist2 = new map<string,list<ContactWhereUsed__c>>();
       
       for(ContactWhereUsed__c q : cwuexist1){
           
           cwuexist2.put(q.Contact__c, new List<ContactWhereUsed__c>{q});
            
       }
       
       map<string,list<quote>> qtmap = new map<string,list<quote>>();
       
       for(quote q : qt){
           if(qtmap.containsKey(q.Shipping_Contact__c)){
                List<Quote> proList=qtmap.get(q.Shipping_Contact__c);
                proList.add(q);
                qtmap.put(q.Shipping_Contact__c, proList);
            }
            else{
                qtmap.put(q.Shipping_Contact__c, new List<Quote>{q});
            }
       }
       
       system.debug('qt '+qt.size());
       
       map<string,list<OpportunityContactRole>> oppmap = new map<string,list<OpportunityContactRole>>();
       
       for(OpportunityContactRole q : opp){
           if(oppmap.containsKey(q.ContactId)){
                List<OpportunityContactRole> proList=oppmap.get(q.ContactId);
                proList.add(q);
                oppmap.put(q.ContactId, proList);
            }
            else{
                oppmap.put(q.ContactId, new List<OpportunityContactRole>{q});
            }
       }
       
       map<string,list<CampaignMember>> cmmap = new map<string,list<CampaignMember>>();
       
       for(CampaignMember q : cm){
           if(cmmap.containsKey(q.ContactId)){
                List<CampaignMember> proList=cmmap.get(q.ContactId);
                proList.add(q);
                cmmap.put(q.ContactId, proList);
            }
            else{
                cmmap.put(q.ContactId, new List<CampaignMember>{q});
            }
       }
       
       list<ContactWhereUsed__c> cList = new list<ContactWhereUsed__c>();
       list<ContactWhereUsed__c> cListup = new list<ContactWhereUsed__c>();
       
       for(contact c : scope){
           list<quote> qus = qtmap.get(c.id);
           list<OpportunityContactRole> ous = oppmap.get(c.id);
           list<CampaignMember> cus = cmmap.get(c.id);
           list<ContactWhereUsed__c> cwuexist = cwuexist2.get(c.id);
           
           ContactWhereUsed__c cwu = new ContactWhereUsed__c();
           if(qus != null){
               if(qus.size() > 0){
                   cwu.UsedInQuote__c =true;
               }else{
                   cwu.UsedInQuote__c =false;
               }
       		}
           
           if(ous != null){
               if(ous.size() > 0){
                   cwu.UsedInOpportunity__c =true;
               }else{
                   cwu.UsedInOpportunity__c =false;
               }
           }
           
           if(cus != null){
               if(cus.size() > 0){
                   cwu.UsedInCampaignMember__c =true;
               }else{
                   cwu.UsedInCampaignMember__c =false;
               }
           }
           
           //iba-4493 start
           list<ccrz__E_Order__c> b2bO = ordMap.get(c.id);
           list<user> usrL = usrMap.get(c.id);
           
           if(b2bO != null){
               if(b2bO.size() > 0){
                   cwu.Used_in_B2B_Order__c =true;
               }else{
                   cwu.Used_in_B2B_Order__c =false;
               }
           }
           
           if(usrL != null){
               if(usrL.size() > 0){
                   cwu.Used_in_B2B_User__c =true;
               }else{
                   cwu.Used_in_B2B_User__c =false;
               }
           }
           //iba-4493 end
           
           cwu.Contact__c = c.id;           
           
           if(cwu.UsedInQuote__c == true || cwu.UsedInOpportunity__c == true || cwu.UsedInCampaignMember__c == true || cwu.Used_in_B2B_Order__c == true || cwu.Used_in_B2B_User__c == true){ //iba-4493
               if(cwuexist != null){
                   cwu.id = cwuexist[0].id;
                   cListup.add(cwu);
               }else{
                   cList.add(cwu);
               }
               
           }
       }
       
       if(cList.size() > 0){
           insert cList;
       }
       if(cListup.size() > 0){
           update cListup;
       }
       
   }
   
   
   global void finish(Database.BatchableContext BC) {
      
   }
}