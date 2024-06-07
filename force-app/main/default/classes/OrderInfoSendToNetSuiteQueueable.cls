public class OrderInfoSendToNetSuiteQueueable implements Queueable{//IBA-4831
    public Set<Id> quoteIds;
    public OrderInfoSendToNetSuiteQueueable(Set<Id> quoteIds){
        this.quoteIds=quoteIds;
    }
    public void execute(QueueableContext context) { 
        Id quoteIdtoremove;
        for(Id st :quoteIds){
            Set<Id> quoteId = new Set<Id>();
            quoteId.add(st);
            quoteIdtoremove = st;
            OrderInfoSendToNetSuite.sendToNetSuit(quoteId);
            break;
        }
        quoteIds.remove(quoteIdtoremove);
        if(quoteIds.size()>0){
            if(!Test.isRunningTest()) {
                system.enqueueJob(new OrderInfoSendToNetSuiteQueueable(quoteIds)); 
            } 
        }
    }
}