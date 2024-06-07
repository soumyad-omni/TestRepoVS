public class RunAccountTeamGEOComponentController {
    @AuraEnabled
    public static void runAccountTeamBatch(){
        AccountTeamPopulation_Batch b = new AccountTeamPopulation_Batch();
      	database.executebatch(b);
    }

}