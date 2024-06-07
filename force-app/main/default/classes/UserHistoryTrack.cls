public class UserHistoryTrack implements Queueable{//IBA-4492
    List <User_Field_History__c> uh;
    public UserHistoryTrack(List <User_Field_History__c> uh){
        this.uh=uh;
    }
    public void execute(QueueableContext context) {
        try {
            insert uh;
        }
        catch(Exception e) {
            system.debug(e);
        }
    }
}