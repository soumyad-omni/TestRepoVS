/*
Jira Ticket Number: IBA-4438
Developer: Saptarsha Panthi
Logic: To Update those quotes one by one which are fetched from QuoteStatusUpdateBatch_Depending_On_Opps Batch Class.
*/
public class QuoteStatusUpdateQueueable implements Queueable{
    public List<quote> quoteLists;
    public QuoteStatusUpdateQueueable(List<Quote> qtlist){
        quoteLists=qtlist;
    }
    public void execute(QueueableContext context) {
        Quote q = quoteLists[quoteLists.size()-1];
        q.status='E0017';
        try {
            
            update q;
            // Start of IBA-5802 changes
            Quote_Cancel_Status__c qtupd = new Quote_Cancel_Status__c();
            qtupd = [Select id, QuoteId__c, Status__c, Updated_Date__c FROM Quote_Cancel_Status__c WHERE QuoteId__c=:q.Id limit 1];
            qtupd.Status__c = 'Success';
            qtupd.Updated_Date__c = System.Today();
            qtupd.Error_Reason__c = '';
            update qtupd;
            // End of IBA-5802 changes
            
        } 
        catch(Exception e) 
        {
            // Start of IBA-5802 changes
            Quote_Cancel_Status__c qtupd = new Quote_Cancel_Status__c();
            qtupd = [Select id, QuoteId__c, Status__c, Updated_Date__c FROM Quote_Cancel_Status__c WHERE QuoteId__c=:q.Id limit 1];
            qtupd.Status__c = 'Failed';
            qtupd.Updated_Date__c = System.Today();
            qtupd.Error_Reason__c = e.getMessage();
            update qtupd;
            // End of IBA-5802 changes
            
            System.debug(e);
        }
        quoteLists.remove(quoteLists.size()-1);
        if(quoteLists.size()>0){
            if(!Test.isRunningTest()) {
                system.enqueueJob(new QuoteStatusUpdateQueueable(quoteLists));
            }
        }
    }
}