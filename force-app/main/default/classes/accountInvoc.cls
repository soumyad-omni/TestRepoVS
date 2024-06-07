/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-17-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-17-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class accountInvoc {
	
        public static boolean fromotherupdate = false;
        @InvocableMethod(label='getAccountinfo' description='send values to apex')
        
    	public static void getAccountinfo(list<Id> accid) {
            if(fromotherupdate == false){
            Trigger_Configuration__c tc = Trigger_Configuration__c.getInstance('TopLevelParentclassDisable');
			system.debug('tc '+system.isBatch());
            if(tc.isDisabled__c == false){
                if(system.isBatch() == false){
            List<Account> accnt = [SELECT Id, Top_level_1__c, Top_level_2__c FROM Account WHERE ParentId =: accid];
            list<id> aid=new List<id> ();
            for(Account a : accnt){
                aid.add(a.id);
            }
                    if(system.isFuture() == false){
                        updateaccount(aid);
                    }       
            
            } 
            }
            }
    }
    
    
   @future
    public static void updateaccount(list<id> acc) {
        	updateChildAcc upp = new updateChildAcc(acc);
            System.enqueueJob(upp);
    }
    
}