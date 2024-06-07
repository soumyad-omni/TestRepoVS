@isTest (SeeAllData=true)
public class OmnicellCommunityLoginTest {
	@isTest
    public static void testLoginHistory () {
        OmnicellCommunityLoginHistoryBatch_Sch se = new OmnicellCommunityLoginHistoryBatch_Sch();
        se.execute(null);
    }
}