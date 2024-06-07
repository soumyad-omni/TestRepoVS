/**********************************************************************
Name:  TITriggerHandler
======================================================
======================================================                                                           
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1       Sahid Hussain            8/17/2021       INITIAL DEVELOPMENT
***********************************************************************/
public without sharing class TITriggerHandler implements ITriggerHandler {
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    
    public boolean IsDisabled(){
        
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('TITriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
		
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems) {}
    
    //=============================================================================
    // BEFORE DELETE
    //=============================================================================
    public void beforeDelete(Map<Id, SObject> oldItems){
        /* IBA-1849 starts */
        List<Target_Initiative__c> TIOld = oldItems.values();
		Set<Id> setOfTargetInitiatives = new Set<Id>();
        Set<Id> targetIniOppIds = new Set<Id>();
        String initiativeName;
        for(Target_Initiative__c to: TIOld) {
            setOfTargetInitiatives.add(to.id);
            System.debug('to.id: '+ to.id);
            initiativeName = to.Name;
        }
        System.debug('initiativeName: '+ initiativeName);
        List<Target_Initiative_Opportunity__c> tiOppList = new List<Target_Initiative_Opportunity__c>();
        Try{
            if([Select Id, Name, Opportunity__c,Opportunity__r.Name from Target_Initiative_Opportunity__c where Target_Initiative__c in :setOfTargetInitiatives].size() > 0){
                //System.debug('if not null');
                tiOppList = [Select Id, Name, Opportunity__c,Opportunity__r.Name from Target_Initiative_Opportunity__c where Target_Initiative__c in :setOfTargetInitiatives];
            }
        }catch(Exception e){
            //tiOppList = [Select Id, Name, Opportunity__c,Opportunity__r.Name from Target_Initiative_Opportunity__c where Target_Initiative__c in :setOfTargetInitiatives];
        }
        if(tiOppList!=null){
            for(Target_Initiative_Opportunity__c tIOpp: tiOppList){
            	targetIniOppIds.add(tIOpp.Opportunity__c);
            	System.debug(' Opp Name: '+ tIOpp.Opportunity__r.Name);
        	}
        Map<id,Opportunity> mapOpp = new Map<id,Opportunity>([SELECT Id, Name, Opportunity_Segment__c From Opportunity where Id in :targetIniOppIds]);
        Map<id,Opportunity> updateOpp = new Map<id,Opportunity>();
        //Opportunity targetOpp = [SELECT Id, Name, Opportunity_Segment__c From Opportunity where Id in :targetIniOppIds];
        Set<String> segementSet = new Set<String>();
        if(tiOppList!=null && !tiOppList.isEmpty()){
            for(Target_Initiative_Opportunity__c tg : tiOppList){
                Opportunity targetOpp;
                if(mapOpp.get(tg.Opportunity__c)!= null){
                    targetOpp = mapOpp.get(tg.Opportunity__c);
                }
                if(targetOpp.Opportunity_Segment__c!=null && targetOpp!=null) {     
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
                updateOpp.put(targetOpp.id,targetOpp);
            }
           		
            OpportunityTriggerHandler.TriggerDisabled = true;
            Try{
            	update updateOpp.values();
        	}catch(Exception e){
            	system.debug('##The following exception has occurred: '+ e.getMessage());
        	}
			OpportunityTriggerHandler.TriggerDisabled = false;
            for(Opportunity o: updateOpp.values()){
                system.debug('Check: '+ o.Name);
            }
        }
        }
        /* IBA-1849 ends */
    }
    
    //=============================================================================
    // BEFORE UPDATE
    //=============================================================================
    public void beforeUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
    }
    
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        
    }
    
    //=============================================================================
    // AFTER UNDELETE
    //=============================================================================
    public void afterUndelete(Map<Id, SObject> oldItems){
        
    }

    //=============================================================================
    // AFTER INSERT
    //=============================================================================
    public void afterInsert(Map<Id, SObject> newItems){}
    
    //=============================================================================
    // AFTER UPDATE
    //=============================================================================
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
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
    }
    //END IBA-1849
}