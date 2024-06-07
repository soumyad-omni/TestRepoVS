public class TiExtDataAcctSegController {
    @AuraEnabled
    public static void updateTiExtDataAcctSeg(){
        
        TiExtDataAcctSegmentUpdateBatch tiDataAcctSegBatch = new TiExtDataAcctSegmentUpdateBatch();
        Database.executeBatch(tiDataAcctSegBatch,50);
    }
}