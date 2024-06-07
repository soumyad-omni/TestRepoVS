global class TiAccountSegmentUpdateBatch2 implements Database.Batchable<sObject>{
 	   	Set<Id> topChilds;
    	Set<Id> oldTopChilds;
    	boolean isRunOldParent;
    	integer step;
    	map<integer,Set<Id>> allHier = new map<integer,Set<Id>>();
    	
    public TiAccountSegmentUpdateBatch2(Set<Id> topChilds,Set<Id> oldTopChilds,boolean isRunOldParent,integer step,map<integer,Set<Id>> allHier){//IBA-3677
        this.topChilds = topChilds;
        this.oldTopChilds = oldTopChilds;
        this.isRunOldParent = isRunOldParent;
        this.step = step;
        this.allHier = allHier;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query ='Select Id, Account__c, Target_Initiative__c,Target_Initiative_Name__c '+
            'FROM Target_Initiative_Account__c  WHERE Account__c IN :topChilds' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Target_Initiative_Account__c> targetIniAccList){
        Target_Initiative_Account__c tia=targetIniAccList[0];
        Id acctId = tia.Account__c;
        Id tiId   = tia.Target_Initiative__c; 
        String targetInitiaveName = tia.Target_Initiative_Name__c;
       
        if(tiId!=null){
            Target_Initiative__c ti = new Target_Initiative__c();
            List<Target_Initiative__c> tiList = [Select Id, Name,Type_of_account_propagation__c FROM Target_Initiative__c 
                                       WHERE Id =:tiId AND Use_for_segmentation__c = true];
            if(tiList.size()>0){//IBA-3635
                ti=tiList[0];
           
            String propagationType = ti.Type_of_account_propagation__c; 	
            
            if(propagationType =='Apply to entire hierarchy' || propagationType =='Apply to Parent and immediate Children' 
               || propagationType =='Apply to individual account') {
                   List<Account> topAccChildsExt;
                   if(propagationType=='Apply to entire hierarchy') 
                       topAccChildsExt=[SELECT Id,External_Data__c From Account where Id IN :topChilds];
                   else if(propagationType=='Apply to Parent and immediate Children'){
                       Account selfAc =[SELECT Id,External_Data__c From Account where Id  = :acctId];
                       topAccChildsExt=[SELECT Id,External_Data__c From Account where ParentId =:acctId];
                       topAccChildsExt.add(selfAc);
                   }
                   else if(propagationType=='Apply to individual account'){
                       topAccChildsExt =[SELECT Id,External_Data__c From Account where Id =:acctId];
                   }
                   //System.debug('PT '+propagationType+' topAcct '+topAccChildsExt);
                   
                   Map<Id,External_Data__c> extDtMap = new Map<Id,External_Data__c>();
                   Set<Id> keys=new Set<Id>();
                   
                   Set<Id> exDataKeys = new Set<Id>();
                   //get all childs of TI and create External Data object if not exist
                   for(Account ac:topAccChildsExt){
                       keys.add(ac.Id);
                   }
                   Set<Id> acKeys = new Set<Id>(keys);

                   List<External_Data__c> extDataL= [SELECT Id,AccountID__c FROM External_Data__c WHERE AccountID__c IN :keys];          
                   for (External_Data__c exDt : extDataL){
                       exDataKeys.add(exDt.AccountID__c);
                   }
                   for (Id exKey:exDataKeys){
                       if(acKeys.contains(exKey))
                           acKeys.remove(exKey);
                   }
                   for (Id key:acKeys){    
                        extDtMap.put(key, new External_Data__c(AccountID__c=key));
                    }
                   if(extDtMap!=null && !extDtMap.isEmpty()){
                       insert extDtMap.values();
                   }
                   
                   List<External_Data__c> extDataList= [SELECT Id,AccountID__c,Account_Segment__c,Own_Segment__c,isTiSegmentChanged__c 
                                                        FROM External_Data__c WHERE AccountID__c IN :keys];          
                   //System.debug('Ti extData List '+extDataList.size());
                 
                   List<External_Data__c> extDataUpdate = new List<External_Data__c>();  
                   for (External_Data__c uExtDt:extDataList){
                       if(uExtDt.Account_Segment__c == null){
                           uExtDt.Account_Segment__c = targetInitiaveName;
                       }
                       else{
                           Set<String> segementSet = new Set<String>();
                           segementSet.addAll(uExtDt.Account_Segment__c.split(';'));
                           if(!segementSet.contains(targetInitiaveName)){
                               uExtDt.Account_Segment__c +=';'+targetInitiaveName;
                           }
                       } 
                       uExtDt.isTiSegmentChanged__c = true;
                       extDataUpdate.add(uExtDt);
                   }
                   
                   if(!extDataUpdate.isEmpty()){
                       ExternalDataTriggerHandler.TriggerDisabled= true; 
                       update extDataUpdate;
                       }        
                   }        
               }
        }
    }
    
    global void finish(Database.BatchableContext bc){
         Set<Id> oldTopChilds;
         step= step+1;
        if(allHier.containskey(step))
         System.enqueueJob(new TIParentSegment2(allHier.get(step),oldTopChilds,false,step,allHier));
    }
}