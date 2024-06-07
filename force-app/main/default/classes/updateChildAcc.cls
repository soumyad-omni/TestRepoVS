public class updateChildAcc implements Queueable {
   // Allows unit test (or other code) to disable this trigger for the transaction
    public static boolean UpdateChildDisabled= false;
    private list<id> accounts;
    private string top1;
    private string top2;
    
    public updateChildAcc(list<id> acc) {
        this.accounts = acc;
        //this.top1 = t1;
        //this.top2 = t2;
    }
    public void execute(QueueableContext context) {
        if(!UpdateChildDisabled){
        List<Account> accnt = [SELECT Id, Top_level_1__c, Top_level_2__c FROM Account WHERE id =: accounts];
        list<Account> updateacc=new List<Account> ();
            for(Account a : accnt){
                //a.Top_level_1__c = top1;
                //a.Top_level_2__c = top2;
                updateacc.add(a);
            }
        QuoteTriggerHandler.TriggerDisabled = true;
        AccountTriggerHandler.TriggerDisabled = true;
        OpportunityTriggerHandler.TriggerDIsabled = true;
            update updateacc;
        system.debug('***updateacc '+updateacc);
        }
    
    }
}