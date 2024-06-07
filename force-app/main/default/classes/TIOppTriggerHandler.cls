/**********************************************************************
Name:  TIOppTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Trigger on Target_Initiative_Opportunity__c Object, implemented logic for before insert and after insert events
Restricted creation of duplicate Opportunities in "Target Initiative Opportunity" to be created under "Target Initiative" in before insert event.
Implemented creation of Account(if not exisits) in "Target Initiative Account" object under same "Target Initiative" in after insert event.
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Haripriya Maturi         1/31/2019       INITIAL DEVELOPMENT
***********************************************************************/
public class TIOppTriggerHandler implements ITriggerHandler{
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public static Boolean isFirstTime = true;
    
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('TargetInitiativeOppTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems) {
        List<Target_Initiative_Opportunity__c> TIOList = newItems;     
               
        Set<Id> tiID = new Set<Id>();
        Set<Id> OppId = new Set<Id>();
        Map<id,Target_Initiative_Opportunity__c> existingOppMap = new Map<id,Target_Initiative_Opportunity__c>();
        for(Target_Initiative_Opportunity__c tio: TIOList){
            tiId.add(tio.Target_Initiative__c);
            OppId.add(tio.Opportunity__c);
            //soumyad start
            system.debug('tio...'+tio);
            string tarinit = tio.Target_Initiative__c;
            string opp= tio.Opportunity__c;
            system.debug('tiolist...'+TIOList);        
            system.debug('tarinit...'+tarinit);        
            string oppaccid = [select AccountId from opportunity where id= :opp].AccountId;
            List<Target_Initiative_Account__c> aclist = new List<Target_Initiative_Account__c>();            
            aclist = [select Account__r.NAME from Target_Initiative_Account__c where Target_Initiative__r.id= :tarinit];
            system.debug('acList ...'+aclist);
            List<Target_Initiative_Account__c> updatetiaList = new List<Target_Initiative_Account__c>();
            for(Target_Initiative_Account__c t: aclist)
              {                            
                if(oppaccid == t.Account__c)
                {
                t.Has_Opportunities__c= true;
                system.debug('acc...'+oppaccid);
                updatetiaList.add(t);
                update updatetiaList;
                system.debug('afterupdate...'+t);
                }
              }
        
            //soumyad end
        }
        List<Target_Initiative_Opportunity__c> existingOpp = [Select id, name, Opportunity__c, Opportunity__r.Id from Target_Initiative_Opportunity__c where Target_Initiative__c in:tiId and Opportunity__c in:OppId];
        
        for(Target_Initiative_Opportunity__c eo: existingOpp){
            existingOppMap.put(eo.Opportunity__c,eo);
        }
        System.debug(existingOppMap);
        for(Target_Initiative_Opportunity__c tio: TIOList){
            System.Debug('tio.Opportunity__c : '+tio.Opportunity__c);
            if(existingOppMap.containsKey(tio.Opportunity__c) ){
                tio.addError('Cannot save duplicate Opportunity');
            }
        }
        
    }
    
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
    }
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        /* IBA-1849 starts */
        List<Target_Initiative_Opportunity__c> oldTIOpp = oldItems.values();
        List<Target_Initiative_Opportunity__c> newTIOpp = newItems.values();
        Set<Id> setOldOfTargetInitiatives = new Set<Id>();
        Set<Id> setNewOfTargetInitiatives = new Set<Id>();
       	Set<Id> targetIniOppIds = new Set<Id>();
        String oldInitiativeName;
        String newInitiativeName;
        for(Target_Initiative_Opportunity__c oldto: oldTIOpp) {
            setOldOfTargetInitiatives.add(oldto.target_initiative__c);
            targetIniOppIds.add(oldto.Opportunity__c);
            //System.debug('oldTI: ' + oldto.target_initiative__c);
        }
        for(Target_Initiative_Opportunity__c newto: newTIOpp) {
            setNewOfTargetInitiatives.add(newto.target_initiative__c);
            //System.debug('newTI: ' + newto.target_initiative__c);
        }
        
        List<Target_Initiative__c> oldtiList = [Select Id, Name from Target_Initiative__c where Id in:setOldOfTargetInitiatives];
        for(Target_Initiative__c oldtI: oldtiList){
            //targetInitiativeOppSet.add(oldtI.Id);
            oldInitiativeName = oldtI.Name;
            //System.debug(' old TI Name: '+ oldInitiativeName);
        }
        List<Target_Initiative__c> newtiList = [Select Id, Name from Target_Initiative__c where Id in:setNewOfTargetInitiatives];
        for(Target_Initiative__c newtI: newtiList){
            //targetInitiativeOppSet.add(newtI.Id);
            newInitiativeName = newtI.Name;
            //System.debug(' new TI Name: '+ newInitiativeName);
        }
        Opportunity targetOpp = [SELECT Id, Name, Opportunity_Segment__c From Opportunity where Id in :targetIniOppIds];
        
        Set<String> segementSet = new Set<String>();
        if(targetOpp!=null){
           		if(targetOpp.Opportunity_Segment__c!=null) {     
             		segementSet = new Set<String>();
                    if(targetOpp.Opportunity_Segment__c.contains(';')){
                		segementSet.addAll(targetOpp.Opportunity_Segment__c.split(';'));
            		}else{
                        segementSet.add(targetOpp.Opportunity_Segment__c);
            		}
             		if(segementSet.contains(oldInitiativeName) && !segementSet.contains(newInitiativeName)){
                 		segementSet.remove(oldInitiativeName);
                        segementSet.add(newInitiativeName);
                    	if(!segementSet.isEmpty())    
                 			targetOpp.Opportunity_Segment__c = setToString(segementSet);
                 		else
                      		targetOpp.Opportunity_Segment__c=null;  
             		}
              	}
            OpportunityTriggerHandler.TriggerDisabled = true;
            Try{
            	update targetOpp;
        	}catch(Exception e){
            	system.debug('##The following exception has occurred: '+ e.getMessage());
        	}
			OpportunityTriggerHandler.TriggerDisabled = false;
        }
        //system.debug('###test_update');
        /* IBA-1849 ends */
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        /* IBA-1849 starts */
        List<Target_Initiative_Opportunity__c> TIOList = oldItems.values();
        Set<Id> setOfTargetInitiatives=new Set<Id>();
       	Set<Id> targetIniOppIds = new Set<Id>();
        String initiativeName;
        for(Target_Initiative_Opportunity__c to: TIOList) {
            setOfTargetInitiatives.add(to.target_initiative__c);
            targetIniOppIds.add(to.Opportunity__c);
            //System.debug('Opp: ' + to.Opportunity__c);
        }
        List<Target_Initiative__c> tiList = [Select Id, Name from Target_Initiative__c where Id in:setOfTargetInitiatives
                                                 /*and Use_for_segmentation__c = true*/];
        
        Set<String> targetInitiativeOppSet = new Set<String>(); 
            
        for(Target_Initiative__c tI: tiList){
            targetInitiativeOppSet.add(tI.Id);
            initiativeName = tI.Name;
            //System.debug(' TI Name: '+ initiativeName);
        }
        Opportunity targetOpp = [SELECT Id, Name, Opportunity_Segment__c From Opportunity where Id in :targetIniOppIds];
        Set<String> segementSet = new Set<String>();
        if(targetOpp!=null && targetInitiativeOppSet!=null){
           		if(targetOpp.Opportunity_Segment__c!=null) {     
             		segementSet = new Set<String>();
                    if(targetOpp.Opportunity_Segment__c.contains(';')){
                		segementSet.addAll(targetOpp.Opportunity_Segment__c.split(';'));
            		}else{
                        segementSet.add(targetOpp.Opportunity_Segment__c);
            		}
             		if(segementSet.contains(initiativeName)){
                 		segementSet.remove(initiativeName);
                    	if(!segementSet.isEmpty())    
                 		targetOpp.Opportunity_Segment__c = setToString(segementSet);
                 	else
                      targetOpp.Opportunity_Segment__c=null;  
             		}
              	}
            OpportunityTriggerHandler.TriggerDisabled = true;
            Try{
            	update targetOpp;
        	}catch(Exception e){
            	system.debug('##The following exception has occurred: '+ e.getMessage());
        	}
			OpportunityTriggerHandler.TriggerDisabled = false;
        }
        /* IBA-1849 Ends */
    }
    
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }
    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){
        List<Target_Initiative_Opportunity__c> TIOList = newItems.values();
        if(isFirstTime){
            cretaeTIAccount(TIOList);
        }
        /* IBA-1849 starts*/
        Set<Id> setOfTargetInitiatives = new Set<Id>();
       	Set<Id> targetIniOppIds = new Set<Id>();
        for(Target_Initiative_Opportunity__c tio: TIOList){
            setOfTargetInitiatives.add(tio.Target_Initiative__c);
            targetIniOppIds.add(tio.Opportunity__c);
        }
        
        List<Target_Initiative_Opportunity__c> oppTarget =[Select Id, Target_Initiative__c, Opportunity__c,Opportunity__r.Opportunity_Segment__c,Target_Initiative__r.name,Target_Initiative__r.Use_for_segmentation__c
                                                          from Target_Initiative_Opportunity__c  where Opportunity__r.id in :targetIniOppIds  and Target_Initiative__c IN :setOfTargetInitiatives] ;
        Map<id,Opportunity> mapOpp = new Map<id,Opportunity>([SELECT Id, Name, Opportunity_Segment__c From Opportunity where Id in :targetIniOppIds]);
        Map<id,Opportunity> updateOpp = new Map<id,Opportunity>();
        Set<String> segementSet = new Set<String>();
        
        if(oppTarget != null && !oppTarget.isEmpty()){
           	for(Target_Initiative_Opportunity__c tg : oppTarget){
                Opportunity oppS;
                if(mapOpp.get(tg.Opportunity__c)!= null){
                    oppS = mapOpp.get(tg.Opportunity__c);
                }
                if(oppS!=null){
                    if(oppS.Opportunity_Segment__c == null){
                		oppS.Opportunity_Segment__c = tg.Target_Initiative__r.name;
               		}
             		else{
                    	segementSet = new Set<String>();
                    	if(oppS.Opportunity_Segment__c.contains(';')){
                			segementSet.addAll(oppS.Opportunity_Segment__c.split(';'));
            			}else{
                            segementSet.add(oppS.Opportunity_Segment__c);
            			}
                    	if(!segementSet.contains(tg.Target_Initiative__r.name)){
                        	oppS.Opportunity_Segment__c +=';'+tg.Target_Initiative__r.name;
                    	}
                	}
                }
            	updateOpp.put(oppS.id,oppS);
             }
        }
        
        if(updateOpp != null && !updateOpp.isEmpty()){
            OpportunityTriggerHandler.TriggerDisabled = true;
            updateChildAcc.UpdateChildDisabled=true;
            Try{
            	update updateOpp.values();
        	}catch(Exception e){
            	system.debug('##The following exception has occurred: '+ e.getMessage());
        	}
			OpportunityTriggerHandler.TriggerDisabled = false;
            updateChildAcc.UpdateChildDisabled=false;
        }  
        /* IBA-1849 ends*/
    }
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
    }
    
    public void cretaeTIAccount(List<Target_Initiative_Opportunity__c> tioList){
        isFirstTime = false;
        Set<Id> tId = new Set<Id>();
        Set<String> acctName = new Set<String>();
        Map<String,Id> acctIDNameMap = new Map<String,Id>();
        List<Target_Initiative_Account__c> tiaList = new List<Target_Initiative_Account__c>();
        
        for(Target_Initiative_Opportunity__c tio: tioList){
            tId.add(tio.Target_Initiative__c);
            acctName.add(tio.Account_Name__c); 
        }
        System.Debug('acctIDNameMap : '+tioList);
        string opp= tioList[0].Opportunity__c;
        string oppaccid = [select AccountId from opportunity where id= :opp].AccountId;
        List<Account> act = [Select id, name from Account where id= :oppaccid];
        
        for(Account a: act){
            acctIDNameMap.put(a.Name,a.Id);
        }
        System.Debug('acctIDNameMap : '+acctIDNameMap);
        List<Target_Initiative_Account__c> existingList = [Select id, name,Account_Name__c from Target_Initiative_Account__c where Target_Initiative__c in:tId and Account__c in:acctIDNameMap.Values()];
        Map<String,Id> existingAcctMap = new Map<String,Id>();
        
        for(Target_Initiative_Account__c el: existingList){
            existingAcctMap.put(el.Account_Name__c,el.Id);
        }
        System.debug('existingAcctMap : '+existingAcctMap);
        for(Target_Initiative_Opportunity__c tio: tioList){
            Target_Initiative_Account__c tia = new Target_Initiative_Account__c();
            tia.Target_Initiative__c = tio.Target_Initiative__c;
            tia.Account__c = acctIDNameMap.get(tio.Account_Name__c);

            if(!existingAcctMap.containsKey(tio.Account_Name__c)){
                tiaList.add(tia);
            }
        }
        
        if(tiaList.size()>0){
            insert tiaList;
            System.debug('insert : '+tiaList);
        }
    }
    
    //start IBA-1849
    //Utility function to convert Set<String> to String
    public static String setToString(Set<String> setStr){
        String conStr='';
		for(String str:setStr){
    	conStr+=str+';';
		}
        if(conStr.length()>0)  {  
		conStr = conStr.substring(0, conStr.length()-1);
        }
      return conStr;
    }//END IBA-1849
}