/**
 * @Description        : Schedule Ti ExDataAccountSegment batch
 * @File Name          : ScheduleTiExtDataAcctSeg.cls
 * @Author             : Pabitra Tripathy
**/
global class ScheduleTiExtDataAcctSeg implements Schedulable{
        global void execute(SchedulableContext ctx) {
         TiExtDataAcctSegmentUpdateBatch tiDataAcctSegBatch = new TiExtDataAcctSegmentUpdateBatch();
         Database.executeBatch(tiDataAcctSegBatch,50);   
        }
}