global class ScheduledUpdateTerritoryInAccountsRetry implements Schedulable {
    global void execute(SchedulableContext ctx) {
        getListofAccountTerritoryChange updateTerritoryInAccountsBatch = new getListofAccountTerritoryChange(1);
        Database.executeBatch(updateTerritoryInAccountsBatch); 
    }    
}