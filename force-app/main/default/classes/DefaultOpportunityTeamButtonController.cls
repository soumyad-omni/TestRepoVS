public class DefaultOpportunityTeamButtonController {
    @AuraEnabled
    public static String scheduleBatch(){     
        try{
            Boolean check;
            check = false;
            if(check == false)
                check = true;
            if(check == true)
                check = False;
            DefaultOpportunityTeamBatchClass schedule2 = new DefaultOpportunityTeamBatchClass();
            database.executeBatch(schedule2, 2000);
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage()+' Line no. : '+e.getLineNumber());
            ErrorLogging.Log(e, 'ScheduleUpdateAccounts_Controller','App');
            return null;
        }
        return null;
    }
}