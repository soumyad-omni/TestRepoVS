/**
 *@Description		: This class is responsible for updating Segment information in Account's External Data objects
 * 
 *@File Name        : TIAccountSegmentUpdate.cls
 *@Author           : Pabitra Tripathy
**/

public class TIAccountSegmentUpdate implements Queueable{
    Id acctId;
    String targetInitiaveName;
    String propagationType;
    Set<Id> topChilds;
    Map<Id,Set<Id>> parentChildMap;
    Set<Id> oldAcctset;
    Set<Id> oldTopChilds;
    Map<Id,Set<Id>> oldParentChildMap;
    boolean isRunOldParent;
    List<TIParentSegment.AcctTi> acctTiList;
    
    public TIAccountSegmentUpdate(Set<Id> topChilds,Map<Id,Set<Id>> parentChildMap,List<TIParentSegment.AcctTi> acctTiList,
                                  Set<Id> oldAcctset,Set<Id> oldTopChilds,Map<Id,Set<Id>> oldParentChildMap,boolean isRunOldParent){
        this.topChilds = topChilds;
        this.parentChildMap = parentChildMap;
       	this.acctTiList = acctTiList;
        
        this.oldAcctset = oldAcctset;
    	this.oldTopChilds = oldTopChilds;
    	this.oldParentChildMap = oldParentChildMap;  
        this.isRunOldParent = isRunOldParent;
    }
    
    public void execute(QueueableContext context){
        for(TIParentSegment.AcctTi accTi:acctTiList){
            acctId = accTi.acctId;
        	targetInitiaveName = accTi.tiName;
        	propagationType = accTi.propagationType;
            
        	System.debug('Ti AcctSegUpdate Id '+acctId+'topclild size '+topChilds.size()+' tgIniName  '+targetInitiaveName+' proType '+propagationType);
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
            else continue;
            
        	Map<Id,External_Data__c> extDtMap = new Map<Id,External_Data__c>();
        	Set<Id> keys=new Set<Id>();
          	//get all childs of TI and create External Data object if not exist
             for(Account ac:topAccChildsExt){
              	 keys.add(ac.Id);
                if(ac.External_Data__c==null){
                  if(extDtMap.get(ac.Id)==null){
                      extDtMap.put(ac.Id, new External_Data__c(AccountID__c=ac.Id));
                  }
              	}
          	}
			
        	if(extDtMap!=null && !extDtMap.isEmpty()){
            	insert extDtMap.values();
       		}
			
        	List<External_Data__c> extDataList= [SELECT Id,AccountID__c,Account_Segment__c,Own_Segment__c,isTiSegmentChanged__c 
                                                 FROM External_Data__c WHERE AccountID__c IN :keys];          
       		System.debug('Ti extData List '+extDataList.size());
           	Map<Id,External_Data__c> extDataMap = new Map<Id,External_Data__c>();
            for (External_Data__c exDt:extDataList){
                 extDataMap.put(exDt.AccountID__c,exDt);       
            }
      
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
        
        if(isRunOldParent){
        	System.enqueueJob(new TIParentSegment(oldAcctset,oldTopChilds,oldParentChildMap,oldAcctset,oldTopChilds,oldParentChildMap,false));
        }
    }
}