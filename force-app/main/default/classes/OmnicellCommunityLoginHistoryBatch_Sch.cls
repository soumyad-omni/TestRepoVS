global class OmnicellCommunityLoginHistoryBatch_Sch implements Schedulable {
	global void execute(SchedulableContext sc) {
        OmnicellCommunityLoginHistoryBatch loginBatch = new OmnicellCommunityLoginHistoryBatch(); 
        Database.executeBatch(loginBatch, 200);
    }
}