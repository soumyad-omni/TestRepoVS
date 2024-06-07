public class userDeactivateFrozen45DaysQueueable implements Queueable { 
    List<User> updateUsrList = New List<User>();
    public userDeactivateFrozen45DaysQueueable(List<User> usrList)
    {
        this.updateUsrList = usrList;
    }
    public void execute(QueueableContext context)
    {
        if(!this.updateUsrList.isEmpty())    
        {
            try
            {
                update updateUsrList;
            }
            catch(Exception ex)
            {UserUpdateFromOpticWebService.saveErrorLogException(ex.getMessage(), 'userDeactivateFrozen45DaysQueueable-->catch','Queueable',updateUsrList[0].Id); }
            //{Error__c err = ErrorLogging.RestResourceLog(ex.getMessage(), 'userDeactivateFrozen45DaysQueueable-->catch','Queueable',updateUsrList[0].Id); insert err;}
        }
    }
}