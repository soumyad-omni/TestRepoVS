global class ScheduledUpdateTerritoryInAccounts implements Schedulable {
    global void execute(SchedulableContext ctx) {
        getListofAccountTerritoryChange updateTerritoryInAccountsBatch = new getListofAccountTerritoryChange(0);
        Database.executeBatch(updateTerritoryInAccountsBatch); 
    }    
}