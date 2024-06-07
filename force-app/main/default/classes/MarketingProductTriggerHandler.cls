/**********************************************************************
Name:  MarketingProductTriggerHandler
Copyright © 2018
======================================================
======================================================
Purpose: Handler contains method for Marketing Product Events
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                   DATE             DETAIL               Description
0.1         Sravan Kumar                 ?          INITIAL DEVELOPMENT
***********************************************************************/
public class MarketingProductTriggerHandler implements ITriggerHandler{
    // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean TriggerDisabled= false;
    public boolean isDisabled;
    public static Boolean isFirstTime = true;
    
    // Check to see if the trigger has been disabled by either custom setting or code
    public boolean IsDisabled(){
        Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('MarketingProductTriggerDisabled');
        if(tc != null) isDisabled= tc.isDisabled__c;
        if(isDisabled == true)
            return true;
        else
            return TriggerDisabled;
    }
    //=============================================================================
    // BEFORE INSERT
    //=============================================================================
    public void beforeInsert(List<SObject> newItems){
        
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
        
    }
    //=============================================================================
    // AFTER DELETE
    //=============================================================================
    public void afterDelete(Map<Id, SObject> oldItems){
        List<Marketing_Product__c> mkp = oldItems.values();
        List<Id> tiaids = new List<Id>();
        for(Marketing_Product__c mk : mkp){
            tiaids.add(mk.Target_Initiative_Account__c);
        }
        System.debug('TIA IDs : '+tiaids);
        updateTargetInitiative(tiaids);
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
        List<Marketing_Product__c> mkp = newItems.values();
        List<Id> tiaids = new List<Id>();
        for(Marketing_Product__c mk : mkp){
            tiaids.add(mk.Target_Initiative_Account__c);
        }
        System.debug('TIA IDs : '+tiaids);
        updateTargetInitiative(tiaids);
    }
    public void afterUpdate(Map<Id, SObject> oldItems, Map<Id, SObject> newItems){
        List<Marketing_Product__c> mkp = newItems.values();
        List<Id> tiaids = new List<Id>();
        for(Marketing_Product__c mk : mkp){
            tiaids.add(mk.Target_Initiative_Account__c);
        }
        System.debug('TIA IDs : '+tiaids);
        updateTargetInitiative(tiaids);
    }
    public static void updateTargetInitiative(List<Id> tiaids){
        List<Marketing_Product__c> mp = new List<Marketing_Product__c>();
        List<Target_Initiative_Account__c> tiac = new List<Target_Initiative_Account__c>();
        //commented below lines Anil 6/24/2019 for SF-BUG-311
        //Integer units = 0 ;
        //Decimal exp = 0;
        //mp = [select Expected_Bookings__c,Units__c from Marketing_Product__c where Target_Initiative_Account__c =:tiaids];
        //done commented above lines Anil 6/24/2019 for SF-BUG-311
        mp = [select Units__c, Expected_Bookings__c, Target_Initiative_Account__c from Marketing_Product__c where Target_Initiative_Account__c =:tiaids];
        for(Target_Initiative_Account__c tia : [select Id, name from Target_Initiative_Account__c where id=:tiaids]){                   //IBA-4344
            //added below lines Anil 6/24/2019 for SF-BUG-311
            Integer units = 0 ;
            Decimal exp = 0;
            //done adding above lines Anil 6/24/2019 for SF-BUG-311
            for(Marketing_Product__c m : mp){
                //String units = m.Units__c;
                //added below lines Anil 6/24/2019 for SF-BUG-311
                if (m.Target_Initiative_Account__c == tia.id) {
                //done adding above lines Anil 6/24/2019 for SF-BUG-311
                    if(m.Units__c != null)
                        units+=Integer.valueOf(m.Units__c);
                    if(m.Expected_Bookings__c != null)
                        exp+=m.Expected_Bookings__c;
                //added below lines Anil 6/24/2019 for SF-BUG-311
                }
                //done adding above lines Anil 6/24/2019 for SF-BUG-311
            }
            //tia.Expected_Bookings__c = exp; IBA-4344
            //tia.Total_Units__c = units; IBA-4344
            tiac.add(tia);
        }
        System.debug('TIACC : '+tiac);
        update tiac;
        
    }
}