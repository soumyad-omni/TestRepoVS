public class AccountFieldTrackTriggerHandler {
    public static void handleBeforeinsert(List<SObject> newItems){
        list<Trigger_Configuration__c> tl = [select name, IsDisabled__c from Trigger_Configuration__c where name = 'AccountFieldTrack'];
        if( !tl.isEmpty() && tl[0].IsDisabled__c == false){
        List<Account_History__c> newAccnts= newItems;     
        for (Account_History__c a : newAccnts) { 
           a.Edited_Time__c = string.valueOf(Datetime.now().format());
           a.Date__c = Datetime.now(); //Added for IBA-2996
        }
            
        }
    }

}