global class ScheduleAccountTeamPopulation_Batch implements Schedulable
{
    public static String sched = '0 0 00 * * ?'; 

    global static String scheduleMe() {
        ScheduleAccountTeamPopulation_Batch SC = new ScheduleAccountTeamPopulation_Batch(); 
        return System.schedule('Account Team Population', sched, SC);
    }
    global void execute(SchedulableContext sc)
    {
    AccountTeamPopulation_Batch b = new AccountTeamPopulation_Batch();
     database.executebatch(b);
      //system.schedule('Account Team Population', , new ScheduleAccountTeamPopulation_Batch());
    }
}